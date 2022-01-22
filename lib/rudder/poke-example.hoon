::  rudder: example +on-poke implementations
::
::    written for rudder v0.1.x
::
::    this example contains two simple +on-poke implementations
::    for a "names of my enemies" webui app.
::    please also see /lib/rudder.hoon,
::    and the page side of this example in /lib/rudder/page-example.hoon.
::
/+  rudder
::
::  this file obviously is not a full gall agent. we simply mimick some
::  of the conventions to create the illusion of an agent context.
::  the +on-poke examples should transfer relatively directly into
::  a real agent though.
::
::  we start by defining some types that the app uses. normally, you
::  would just import these instead.
::
=>  |%
    ::  our enemies, as stored in app state
    ::
    +$  enemies  (list @t)
    ::  a user action made to modify the $enemies
    ::
    +$  action
      $%  [%add enemy=@t]
          [%del index=@ud]
      ==
    --
::  /~ is the most ergonomic way to import pages defined in files separate
::  from the agent implementation. /~ face type path compiles all hoon files
::  directly under the path into the given type, and places them into a
::  (map @ta type) with the given face.
::
::  (in real usage /~, like the other ford runes, must precede any hoon
::   in the file. because of this, and because we supply a fake path here,
::   this file will not compile, but just imagine this actually imports
::   /lib/rudder/page-example.hoon.)
::
/~  pages  (page:rudder enemies action)  /app/enemies
::  this state exists somewhere in the context.
::
=|  =enemies
::
|_  =bowl:gall
++  this  .
::  this first example handles http requests using default implementations
::  provided by rudder. this will show the basics of rudder configuration
::  and request handling.
::
++  on-poke-simple
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  ::  we do not deal with anything other than http requests in this example
  ::
  ?>  =(%handle-http-request mark)
  ::  the code further down is going to produce effects and
  ::  a possibly-updated list of enemies. here we simply integrate the
  ::  new enemies into our context and produce the desired output.
  ::
  =;  out=(quip card:agent:gall _enemies)
    [-.out this(enemies +.out)]
  ::  what follows is a chain of function calls, the inner ones using
  ::  passed-in configuration parameters, resulting in an outer function
  ::  that handles individual http requests. for a quick overview, the
  ::  below code will do the following:
  ::
  ::    %-  %-  (steer:rudder _enemies action)
  ::        [pages route adlib solve]
  ::    [bowl [eyre-id inbound-request] enemies]
  ::
  ::  in practice, as below, this is often structured with a %. for the
  ::  outer call instead, because the inner arguments (which we will
  ::  elaborate on soon) may be comparatively large.
  ::
  ::  to handle this http request, we provide rudder with a few things:
  ::
  %.  ::  the bowl, for general context information.
      ::
      :+  bowl
        ::  the http request itself, for obvious reasons.
        ::  remember that an $order is simply a [id=@ta inbound-request:eyre],
        ::  mapping directly onto the data eyre gives us here.
        ::
        !<(order:rudder vase)
      ::  the part of app state that's relevant to processing http requests.
      ::
      enemies
  ::  now the meat of the example: setting rudder up to handle requests
  ::  using provided implementations.
  ::
  ::  we start by calling +steer with the data and action types we will be
  ::  using. this produces a second gate, whose in- and outputs are tailored
  ::  to the data we're dealing with. note that the action is assumed to be
  ::  a cell type.
  ::  the resulting gate is then called, and given four arguments.
  ::
  %:  (steer:rudder _enemies action)
    ::  the first argument is a map of pages. usually, this is just the
    ::  map that was imported at the top of this file, though one could
    ::  imagine joining multiple maps from separate imports.
    ::
    pages
  ::
    ::  secondly, a routing function, called "+route" by rudder internally.
    ::  rudder uses this to map request urls to the pages (or redirects)
    ::  that should be served in response.
    ::  calling +point provides a default routing implementation.
    ::  it routes only for urls up to one level under the base path. any
    ::  requests with trailing slashes get redirected. file extensions are
    ::  ignored.
    ::  for example: /base/hello routes to a page named %hello,
    ::  /base/hello/ redirects to the previous url, and /base/hey/yo fails
    ::  to route at all. additionally, /base resolves to a page named %index.
    ::  +point takes three arguments for configuration.
    ::
    %:  point:rudder
      ::  the base path we're serving from.
      ::  this is the same path that the agent issued an %e %connect for.
      ::
      /enemies
      ::  a flag indicating whether the pages served here require
      ::  authentication (using +code) to view.
      ::
      &
      ::  the pages that are available. if a url would resolve to a page
      ::  that does not exist, then routing will fail.
      ::
      ~(key by pages)
    ==
  ::
    ::  thirdly, a fallback function, called "+adlib" by rudder internally.
    ::  if routing fails (that is, if the routing function does not produce
    ::  a route), then this function is called upon to handle the request
    ::  instead.
    ::  the fallback function produced by +fours simple serves a 404
    ::  'no route found' page. we are required to pass in our app's data,
    ::  so that the resulting fallback function may re-emit it, unchanged,
    ::  to abide by the interface rudder expects.
    ::
    (fours:rudder enemies)
  ::
    ::  lastly, we must provide a user action handler, called "+solve"
    ::  by rudder internally. if a user sends a POST request, and the page
    ::  can parse it into an action successfully, this handler gets called.
    ::  since this deals with app-specific data, rudder does not provide
    ::  a default implementation. below we write a minimal example.
    ::
    |=  act=action
    ::  using the given action (of the type we have specified), it must
    ::  either produce a failure message, or produce the triple of
    ::  a success message, effects, and updated data. note that
    ::  $brief is simply a ?(~ @t), containing an optional message.
    ::
    ^-  $@  brief:rudder
        [brief:rudder (list card:agent:gall) _enemies]
    ?-  -.act
      %add  ``(snoc enemies enemy.act)
      %del  ``(oust [index.act 1] enemies)
    ==
  ==
::  this second example handles http requests using a fully custom rudder
::  setup. this should give a more thorough understanding of the functions
::  and flow that rudder uses.
::
++  on-poke-custom
  ::  note that we do not include commentary that would be identical to
  ::  that in +on-poke-simple. please also see above if you missed it,
  ::  the following assumes some familiarity with the overall flow.
  ::
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  ?>  =(%handle-http-request mark)
  =;  out=(quip card:agent:gall _enemies)
    [-.out this(enemies +.out)]
  %.  [bowl !<(order:rudder vase) enemies]
  ::  now the meat of the example: setting rudder up to handle requests
  ::  using custom callbacks.
  ::
  %:  (steer:rudder _enemies action)
    pages
  ::
    ::  the routing function takes a $trail as its only argument. this is
    ::  a destructured url, containing a :site path and optional file :ext.
    ::
    |=  =trail:rudder
    ::  a $place must be deduced from the :trail. this may fail, in which
    ::  case the fallback function gets called instead.
    ::  a $place is either a %page, with an authentication requirement flag
    ::  and a page name, or an %away, redirecting to a different path.
    ::
    ^-  (unit place:rudder)
    ::  because we are bound to /enemies, all requests coming into this app
    ::  are going to have that prefix in the :trail. we use the +decap helper
    ::  to get rid of that. if it fails, something's wrong, and we give up.
    ::
    ?~  site=(decap:rudder /enemies site.trail)  ~
    ::  we provide routes for a few pages:
    ::  /enemies          ->  the example page, requires login
    ::  /enemies/index    ->  redirects to /enemies
    ::  /enemies/hitlist  ->  some imaginary bounty listing, publicly viewable
    ::
    ?+  u.site  ~
      ~             `[%page & %page-example]
      [%index ~]    `[%away (snip site.trail)]
      [%hitlist ~]  `[%page | %hitlist]
    ==
  ::
    ::  the fallback function takes an $order as its only argument. this is
    ::  the full http request, as we extracted from the poke at the start of
    ::  this arm.
    ::
    |=  =order:rudder
    ::  it must produce effects and possibly-updated data. for convenience,
    ::  the effects here include an optional $reply, for which rudder will
    ::  handle the sending if it's included.
    ::
    ^-  [[(unit reply:rudder) (list card:agent:gall)] _enemies]
    ::  because we have access to the full request, and can produce any
    ::  effects we desire, all bets are off here. this might come in handy
    ::  when wanting to do such things as delayed responses, for example.
    ::  we could store the request id in the data and set a timer, or run
    ::  some asynchronous request, so that the app can formulate and send
    ::  a response later on.
    ::  for our example, we simply issue a custom 404 message.
    ::
    =;  msg=@t  [[`[%code 404 msg] ~] enemies]
    %+  rap  3
    :~  'as of '
        (scot %da (div now.bowl ~d1))
        ', '
        url.request.order
        ' is still mia...'
    ==
  ::
    |=  act=action
    ^-  $@(@t [brief:rudder (list card:agent:gall) _enemies])
    ?-  -.act
      %add  ``(snoc enemies enemy.act)
      %del  ``(oust [index.act 1] enemies)
    ==
  ==
--
::
::  following seas to ye!
