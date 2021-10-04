::  want: dependency awaiting with native web frontend
::
::    crashes on nearly all incoming events until the underlying app's
::    dependencies have been satisfied.
::    the only events not crashed on are incoming http requests, to which
::    this wrapper responds with a page showing the missing dependencies
::    and where to install them.
::    once the requirements have been met, this wrapper will no-op forever.
::    in other words, it does not account for dependencies becoming
::    unavailable, through uninstall or otherwise.*
::
::    this might not be a good idea. think long and hard about whether this
::    is right for your use case before you use it!
::
::    (* we don't do that right now, because it seems like a harder problem.
::    we would need to answer questions like "what do we do with +on-agent
::    and +on-arvo calls?", and "aren't the nacks too aggressive from the
::    perspective of other apps?". we might end up re-implementing gall's
::    blocked.state, without all the advantages/power of being gall.)
::
::TODO  allow for more-arbitrary requirements, like a timed unlock, so you
::      can do fun "install now, app goes live tomorrow" things.
::
/+  server
::
|%
+$  desire
  $%  [%app app=dude:gall from=[=ship =desk]]
      ::TODO  [%etc what=@t check=$-(bowl:gall ?)] or similar
  ==
::
++  helper
  |_  [=bowl:gall wants=(list desire)]
  ++  any-missing
    ^-  ?
    !(levy wants check)
  ::
  ++  missing
    ^-  (list desire)
    (skip wants check)
  ::
  ++  check
    |=  =desire
    ^-  ?
    ?-  -.desire
      %app  .^(? %gu /(scot %p our.bowl)/[app.desire]/(scot %da now.bowl))
    ==
  ::
  ++  webview
    |=  mis=(list desire)
    ^-  manx
    |^  page
    ::
    ++  style
      '''
      * { margin: 0.2em; padding: 0.2em; font-family: monospace; }
      p { max-width: 50em; }
      '''
    ::
    ++  page
      ^-  manx
      !!
      :: ;html
      ::   ;head
      ::     ;title:"%pals"
      ::     ;meta(charset "utf-8");
      ::     ;style:"{(trip style)}"
      ::   ==
      ::   ;body
      ::     ;h2:"%{(trip dap.bowl)} is missing some dependencies..."

      ::     The following dependencies need to be installed for this app to work
      ::   ==
      :: ==
    --
  --
::
++  agent
  |=  wants=(list desire)
  ^-  $-(agent:gall agent:gall)
  |^  agent
  ::
  +$  state-0
    $:  %0
        prev=_wants
        hold=(list card)
        held=(list [wire sign-arvo])
        live=_|
    ==
  ::
  +$  card  card:agent:gall
  ::
  ++  agent
    |=  inner=agent:gall
    =|  state-0
    =*  state  -
    ^-  agent:gall
    |_  =bowl:gall
    +*  this  .
        og  ~(. inner bowl)
        up  ~(. helper bowl wants)
    ::
    ++  on-init
      ^-  (quip card _this)
      =.  prev  wants
      ::  we call the inner on-init, but only emit cards that set up
      ::  eyre bindings. we do this so that we may serve a dependency
      ::  notification page if the app provides a frontend.
      ::  in +on-arvo, we similarly hold on to the matching %bound response.
      ::
      =^  cards  inner
        on-init:og
      =^  send  hold
        %+  skid  cards
        |=  =card
        ?=([%pass * %arvo %e %connect *] card)
      =.  send
        %+  turn  `(list card)`send
        |=  =card
        ?>  ?=([%pass * *] card)
        ~!  card
        card(p (weld /~/want p.card))
      [send this]
    ::
    ++  on-save  !>([[%want state] on-save:og])
    ++  on-load
      |=  ole=vase
      ^-  (quip card _this)
      ::NOTE  the "upgrade from lib-less app" case
      ::      is intentionally unsupported.
      =+  !<([[%want old=state-0] ile=vase] ole)
      =.  state  old
      ::
      ~?  &(live !=(prev.old wants))
        %dependencies-changed-but-already-live
      =.  prev  wants
      ::
      =^  cards  inner  (on-load:og ile)
      [cards this]
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?:  live
        =^  cards  inner  (on-poke:og mark vase)
        [cards this]
      =/  mis  missing:up
      ?~  mis
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ?.  =(%handle-http-request mark)
        ~|([dap.bowl %awaiting-dependencies] !!)
      :_  this
      =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
      %+  give-simple-payload:app:server
        eyre-id
      %+  require-authorization-simple:app:server
        inbound-request
      ^-  simple-payload:http
      :-  [503 ~]
      `(as-octt:mimes:html (en-xml:html (webview:up mis)))
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      ?:  live
        =^  cards  inner  (on-watch:og path)
        [cards this]
      ?.  any-missing:up
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ?:  ?=([%http-response *] path)
        [~ this]  ::  we will display an awaiting-dependencies page
      ~|([dap.bowl %awaiting-dependencies] !!)
    ::
    ++  on-leave
      |=  =path
      ^-  (quip card _this)
      ?:  live
        =^  cards  inner  (on-leave:og path)
        [cards this]
      ?:  ?=([%http-response *] path)
        [~ this]  ::  we handled this
      ?.  any-missing:up
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ~|([dap.bowl %awaiting-dependencies] !!)
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?:  live
        =^  cards  inner  (on-agent:og wire sign)
        [cards this]
      ?.  any-missing:up
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ~|([dap.bowl %awaiting-dependencies] !!)
    ::
    ++  on-peek
      |=  =path
      ^-  (unit (unit cage))
      ?:  =(/x/dbug/state path)
        ``noun+on-save:og
      ?:(live (on-peek:og path) ~)
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=([%~.~ %want *] wire)
        ?:  live  $(wire t.t.wire)
        [~ this(held (snoc held t.t.wire sign-arvo))]
      ?:  live
        =^  cards  inner  (on-arvo:og wire sign-arvo)
        [cards this]
      ?.  any-missing:up
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ~|([dap.bowl %awaiting-dependencies] !!)
    ::
    ++  on-fail
      |=  [=term =tang]
      ^-  (quip card _this)
      ?:  live
        =^  cards  inner  (on-fail:og term tang)
        [cards this]
      ?.  any-missing:up
        ::TODO  figure out how to deduplicate this logic cleanly
        =|  cards=(list card)
        =.  live  &
        |-  ^-  (quip card _this)
        ?.  =(~ held)  ::NOTE  some nasty tmi here
          =^  caz  this  (on-arvo (snag 0 held))
          $(held (slag 1 held), cards (weld cards caz))
        =^  caz  this  ^$
        [:(weld hold cards caz) this(hold ~)]
      ~|([dap.bowl %awaiting-dependencies] !!)
    --
  --
--
