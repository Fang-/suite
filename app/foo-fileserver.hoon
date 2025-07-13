::  foo-fileserver: generic from-clay file-serving agent
::
::    for copying into desks as a standalone %deskname-fileserver agent.
::
::  v edit this for configuration changes v
::
|%
::  +file-root: path on this desk under which files live
::  +web-root:  url under which those files must be served
::
++  file-root  ^-  path       /web
++  web-root   ^-  (list @t)  /your-root-path/static
--
::
::  ^ edit that for configuration changes ^
::  ----- do not edit below this line -----
::
::TODO  mb refactor as library that you just call with config args?
::TODO  load config from separate file? (for easier agent updating)
::TODO  auth optionality
::TODO  set tombstoning policy on file-root
::TODO  populate cache eagerly?
::
|%
+$  state-0
  $:  %0
      foot=path
      woot=path
      cash=(set @t)
  ==
::
+$  card  card:agent:gall
::
++  store  ::  set cache entry
  |=  [url=@t entry=(unit cache-entry:eyre)]
  ^-  card
  [%pass /eyre/cache %arvo %e %set-response url entry]
::
++  read-next
  |=  [[our=@p =desk now=@da] foot=path]
  ^-  card
  =;  =task:clay
    [%pass [%clay %next foot] %arvo %c task]
  [%warp our desk ~ %next %z da+now foot]
--
::
=|  state-0
=*  state  -
::
^-  agent:gall
|_  =bowl:gall
+*  this  .
::
++  on-init
  ^-  (quip card _this)
  =.  foot  file-root
  =.  woot  web-root
  :_  this
  ::  set up the binding,
  ::  and await next file change
  ::
  :~  [%pass /eyre/connect %arvo %e %connect [~ woot] dap.bowl]
      (read-next [our q.byk now]:bowl foot)
  ==
::
++  on-save
  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old  !<(state-0 ole)
  :_  this(foot file-root, woot web-root, cash ~)
  ::  await next change on our file root
  ::  (don't care if we double-request (though clay probably dedupes?), since
  ::  all we do on-notify rn is wipe the cache)
  ::
  :-  (read-next [our q.byk now]:bowl file-root)
  ::  always clear old cache entries, in case we changed something about
  ::  the way we serve
  ::
  %+  weld
    (turn ~(tap in cash.old) (curr store ~))
  ::  if the web root changed, we must re-set our binding
  ::
  ^-  (list card)
  ?:  =(woot.old web-root)  ~
  ::NOTE  re-bind first to avoid duct shenanigans.
  ::      remove this when eyre stops restricting %disconnect to the og duct.
  :~  [%pass /eyre/connect %arvo %e %connect [~ woot.old] dap.bowl]
      [%pass /eyre/connect %arvo %e %disconnect [~ woot.old]]
      [%pass /eyre/connect %arvo %e %connect [~ web-root] dap.bowl]
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ~|  mark=mark
  ?>  ?=(%handle-http-request mark)
  =+  !<([rid=@ta inbound-request:eyre] vase)
  =;  [sav=? pay=simple-payload:http]
    =/  serve=(list card)
      =/  =path  /http-response/[rid]
      :~  [%give %fact ~[path] [%http-response-header !>(response-header.pay)]]
          [%give %fact ~[path] [%http-response-data !>(data.pay)]]
          [%give %kick ~[path] ~]
      ==
    ?.  sav  [serve this]
    :_  this(cash (~(put in cash) url.request))
    %+  snoc  serve
    (store url.request ~ auth=| %payload pay)
  ::TODO  configurable auth requirement
  :: ?.  authenticated
  ::   [[403 ~] `(as-octs:mimes:html 'unauthenticated')]
  ?.  ?=(%'GET' method.request)
    [| [405 ~] `(as-octs:mimes:html 'read-only resource')]
  =+  ^-  [[ext=(unit @ta) site=(list @t)] args=(list [key=@t value=@t])]
    =-  (fall - [[~ ~] ~])
    (rush url.request ;~(plug apat:de-purl:html yque:de-purl:html))
  ?.  =(woot (scag (lent woot) site))
    [| [500 ~] `(as-octs:mimes:html 'bad route')]
  ::  all of the below responses get put into cache on first-request,
  ::  even if we can't serve real content. we'll clear cache and retry
  ::  whenever file-root contents change.
  ::
  :-  &
  ?~  ext
    ~&  [dap.bowl %not-found-extless]
    [[404 ~] `(as-octs:mimes:html 'not found')]
  =/  =path
    :*  (scot %p our.bowl)
        q.byk.bowl
        (scot %da now.bowl)
        (weld foot (snoc (slag (lent woot) site) u.ext))
    ==
  ?.  .^(? %cu path)
    ~&  [dap.bowl %not-found path=path]
    [[404 ~] `(as-octs:mimes:html 'not found')]
  =+  .^(file=^vase %cr path)
  ::TODO  this sucks. can we really not do better than crash during request handling?
  ::      we could hard-code conversions for different file types here, but that sucks too...
  =+  ~|  [%no-mime-conversion from=u.ext]
      .^(=tube:clay %cc (scot %p our.bowl) q.byk.bowl (scot %da now.bowl) /[u.ext]/mime)
  =+  !<(=mime (tube file))
  :_  `q.mime
  ::TODO  cache headers?
  [200 ['content-type' (rsh 3^1 (spat p.mime))]~]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  ?=([%http-response @ ~] path)
  [~ this]
::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ~|  wire=wire
  ?+  wire  !!
      [%eyre %connect ~]
    ~|  sign=+<.sign
    ?>  ?=(%bound +<.sign)
    ~?  !accepted.sign  [dap.bowl %binding-rejected binding.sign]
    [~ this]
  ::
      [%eyre %cache ~]
    ~|  sign=+<.sign
    ~|  %did-not-expect-gift
    !!
  ::
      [%clay %next *]
    ::  ignore if it's for a previous file-root
    ::
    ?.  =(t.t.wire foot)  [~ this]
    ~|  sign=+<.sign
    ?>  ?=(%writ +<.sign)
    ::  request the next change, and clear the cache.
    ::  it will get refilled on first request for each file.
    ::
    :_  this(cash ~)
    :-  (read-next [our q.byk now]:bowl foot)
    (turn ~(tap in cash) (curr store ~))
  ==
::
++  on-leave  |=(* [~ this])
++  on-agent  |=(* [~ this])
++  on-peek   |=(* ~)
::
++  on-fail
  |=  [=term =tang]
  ^-  (quip card _this)
  %-  (slog (rap 3 dap.bowl ' +on-fail: ' term ~) tang)
  [~ this]
--
