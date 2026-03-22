::  foo-fileserver: generic from-clay file-serving agent
::
::    for copying into desks as a standalone %deskname-fileserver agent.
::
::    ** in general, you should not need to modify this file directly. **
::    instead this agent will read configuration parameters from an
::    /app/fileserver/config.hoon. that file must produce a core with
::    at least a +web-root arm. all other overrides for the defaults
::    are optional.
::    see the example /app/fileserver/config.hoon for further documentation.
::
/=  config  /app/fileserver/config
::
|%
++  web-root     ^-  (list @t)                  web-root:config
::
++  defaults
  |%
  ++  file-root  ^-  path                       /web
  ++  tombstone  ^-  ?                          |
  ++  index      ^-  $@(~ [~ path])             `/index/html
  ++  extension  ^-  ?(%need %path %fall)       %need
  ++  auth       ^-  $@(? [? (list [path ?])])  &
  --
::
++  file-root  ^-  path
  !@(file-root:config file-root:defaults file-root:config)
::
++  tombstone  ^-  ?
  !@(tombstone:config tombstone:defaults tombstone:config)
::
++  index  ^-  $@(?(~ %apache) [~ u=path])
  !@(index:config index:defaults index:config)
::
++  extension  ^-  ?(%need %path %fall)
  !@(extension:config extension:defaults extension:config)
::
++  auth  ^~  ^-  (map path ?)
  =/  val=$@(? [? (list [path ?])])
    !@(auth:config auth:defaults auth:config)
  ?@  val  (~(put by *(map path ?)) / val)
  (~(gas by *(map path ?)) [/ -.val] +.val)
::
::TODO  make runtime caching disable-able
::TODO  configurable (cache) headers in the response?
::
::TODO  feels like there's a way (mb switching up the config paths back and forth?)
::      that gets this into a state where the cache entries no longer update...
::TODO  restructure so config can take a byk.bowl argument?
::TODO  populate cache eagerly? and/or be smart about busting, check %cz hashes?
--
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
+$  cart  $@(~ $^((lest card) $%([~ card] card)))
++  zang
  |=  a=(list cart)
  ^-  (list card)
  %-  zing
  %+  turn  a
  |=  b=cart
  ^-  (list card)
  ?~  b  ~
  ?^  -.b  b
  ?~  -.b  [+.b]~
  [b]~
::
++  store  ::  set cache entry
  |=  [url=@t entry=(unit cache-entry:eyre)]
  ^-  card
  [%pass /eyre/cache %arvo %e %set-response url entry]
::
++  read-next
  |=  [[our=@p =desk now=@da] =path]
  ^-  card
  =;  =task:clay
    [%pass [%clay %next path] %arvo %c task]
  [%warp our desk ~ %next %z da+now path]
::
++  set-norm
  |=  [[our=@p =desk] =path keep=?]
  ^-  card
  =;  =task:clay
    [%pass [%clay %norm path] %arvo %c task]
  [%tomb %norm our desk (~(put of *norm:clay) path keep)]
::
++  run-tombstone
  ^-  card
  [%pass /clay/tomb %arvo %c %tomb %pick ~]
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
  ::  and await next file change.
  ::  if we're tombstoning, set the policy and trigger clean-up
  ::
  :+  [%pass /eyre/connect %arvo %e %connect [~ web-root] dap.bowl]
    (read-next [our q.byk now]:bowl file-root)
  ?.  tombstone  ~
  :~  (set-norm [our q.byk]:bowl file-root |)
      run-tombstone
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
  %-  zang
  :~  ::  if the file root changed,
      ::  await the next file change on the new root
      ::
      ?:  =(foot.old file-root)  ~
      (read-next [our q.byk now]:bowl file-root)
    ::
      ::  if tombstoning is disabled,
      ::  remove it from the old root (in case we had turned it on)
      ::
      ?.  tombstone
        (set-norm [our q.byk]:bowl foot.old &)
      ::  if tombstoning is enabled,
      ::  (re-)configure tombstoning for the file root (disables it for old),
      ::  and trigger clean-up right away
      ::
      :~  (set-norm [our q.byk]:bowl file-root |)
          run-tombstone
      ==
    ::
      ::  always clear old cache entries, in case we changed something about
      ::  the way we serve
      ::
      (turn ~(tap in cash.old) (curr store ~))
    ::
      ::  if the web root changed, we must re-set our binding
      ::
      ?:  =(woot.old web-root)  ~
      ::NOTE  re-bind first to avoid duct shenanigans.
      ::      remove this when eyre stops restricting %disconnect to the og duct.
      :~  [%pass /eyre/connect %arvo %e %connect [~ woot.old] dap.bowl]
          [%pass /eyre/connect %arvo %e %disconnect [~ woot.old]]
          [%pass /eyre/connect %arvo %e %connect [~ web-root] dap.bowl]
      ==
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ::  dbug without /lib/dbug dependency
  ::
  ?:  ?=(%dbug mark)
    ~&  state=state
    %-  %-  slog
      :-  '  config:'
      %+  turn  (sloe -:!>(config))
      |=  arm=term
      :+  %rose
        ["" (trip (rap 3 '++  ' arm '  ' ~)) ""]
      [(sell (slap !>(config) %wing arm ~))]~
    %-  %-  slog
      :-  '  effective:'
      %+  murn  (sloe -:!>(..web-root))
      |=  arm=term
      ?:  =(%defaults arm)  ~
      %-  some
      :+  %rose
        ["" (trip (rap 3 '++  ' arm '  ' ~)) ""]
      [(sell (slap !>(..web-root) %wing arm ~))]~
    [~ this]
  ::  our purpose is to serve
  ::
  ~|  mark=mark
  ?>  ?=(%handle-http-request mark)
  =+  !<([rid=@ta inbound-request:eyre] vase)
  ::
  =;  [sav=$@(%| [%& auth=?]) pay=simple-payload:http]
    =/  serve=(list card)
      ::  if auth is required but requester doesn't have it,
      ::  make sure to _serve_ 403, but keep original .pay for the cache
      ::
      =?  pay  &(?=([%& %&] sav) !authenticated)
        [[403 ~] `(as-octs:mimes:html 'unauthorized')]
      =?  data.pay  ?=(%'HEAD' method.request)
        ::NOTE  runtime cache doesn't respond to HEAD requests yet, so
        ::      we may hit this even after putting the full payload in cache.
        ::      wasteful, but we'll wait on runtime improvement rather than
        ::      contorting ourselves for edge-case performance gains.
        ~
      =/  =path  /http-response/[rid]
      :~  [%give %fact ~[path] [%http-response-header !>(response-header.pay)]]
          [%give %fact ~[path] [%http-response-data !>(data.pay)]]
          [%give %kick ~[path] ~]
      ==
    ?:  ?=(%| sav)  [serve this]
    ::  if we put the response in cache, track that we did so,
    ::  we will clear the entry on desk change
    ::
    :_  this(cash (~(put in cash) url.request))
    %+  snoc  serve
    (store url.request ~ auth=auth.sav %payload pay)
  ::  don't handle illegible requests (non-read method, unknown site path)
  ::
  ?.  ?=(?(%'GET' %'HEAD') method.request)
    [%| [405 ~] `(as-octs:mimes:html 'read-only resource')]
  =+  ^-  [[ext=(unit @ta) site=(list @t)] args=(list [key=@t value=@t])]
    =-  (fall - [[~ ~] ~])
    (rush url.request ;~(plug apat:de-purl:html yque:de-purl:html))
  ?.  =(web-root (scag (lent web-root) site))
    [%| [500 ~] `(as-octs:mimes:html 'bad route')]
  =.  site  (slag (lent web-root) site)
  ::  all of the below responses get put into cache on first-request,
  ::  even if we can't serve real content. we'll clear cache and retry
  ::  whenever file-root contents change.
  ::
  :-  :-  %&
      ::  get auth flag from longest prefix
      ::
      ::NOTE  since this goes into cache after computing once,
      ::      we don't care about this search being sub-optimal
      |-
      ?:  =(/ site)  (~(got by auth) /)
      %-  (bond |.(^$(site (snip site))))
      (~(get by auth) site)
  ::  construct the relative target path,
  ::  falling back to the index file or page where applicable
  ::
  =/  target=$@(?(~ %apache) [pax=path ext=@ta])
    ::  if trailing /, resolve according to +index
    ::  if extension, resolve normally
    ::  if no extension, resolve according to +extension
    ::
    |-
    ?:  &(?=(~ ext) ?=([%$ *] (flop site)))
      =+  index=index
      ?@  index  index
      [(weld (snip site) u.index) (rear u.index)]
    ?^  ext  [(snoc site u.ext) u.ext]
    ?-  =<(. extension)
      %need  ~
      %path  [site (rear site)]
      %fall  $(site (snoc site %$))
    ==
  ::  bad targets get treated as not-founds
  ::
  ?~  target
    [[404 ~] `(as-octs:mimes:html 'not found')]
  ::  if we can resolve to a specific file, try to serve from it
  ::
  =/  bas=path
    /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl)
  ?^  target
    =/  =path
      :(weld bas file-root pax.target)
    ?.  .^(? %cu path)
      ~&  [dap.bowl %not-found path=path]
      [[404 ~] `(as-octs:mimes:html 'not found')]
    =+  .^(file=^vase %cr path)
    ::NOTE  this sucks. we really cannot do better than potentially crash here...
    ::      clay should have mark fallback behavior to/from mime always...
    =+  ~|  [%no-mime-conversion from=ext.target]
        .^(=tube:clay %cc (weld bas /[ext.target]/mime))
    =+  !<(=mime (tube file))
    :_  `q.mime
    ::TODO  cache headers?
    ::TODO  content-length? or does runtime add that even for cached responses?
    [200 ['content-type' (rsh 3^1 (spat p.mime))]~]
  ::  construct an index page
  ::
  ?>  ?=(%apache target)
  :-  [200 ['content-type' 'text/html;charset=UTF-8']~]
  =/  =spur  (weld file-root (snip site))  ::TODO  awkward, want to get from .target
  =/  l=@ud  (lent spur)
  =+  %+  roll
        =,  bowl
        .^((list path) %ct (scot %p our) q.byk (scot %da now) spur)
      |=  [pax=path fiz=(list [nom=@t ext=@t]) diz=(list @ta)]
      =.  pax  (slag l pax)
      ?+  pax  [fiz diz]
        [@ @ ~]  [[[i i.t]:pax fiz] diz]
        [@ @ ^]  [fiz ?~(diz [i.pax]~ ?:(=(i.pax i.diz) diz [i.pax diz]))]
      ==
  =.  site  (snip site)  ::  remove trailing %$
  =/  spit  (weld web-root site)
  %-  some
  %-  as-octt:mimes:html
  %-  en-xml:html
  |^  ^-  manx
      page
  ++  page
    ;html
      ;head
        ;title:"Index of {(spud spit)}"
      ==
      ;body
        ;h1:"Index of {(spud spit)}"
        ;table  ;tbody
          ;tr  ;th:""
               ;th:"Name"
               ;th:"Last modified"
               ;th:"Description"
          ==
        ::
          ;tr  ;th(colspan "4")  ;hr;  ==  ==
        ::
          ;*  ?:  =(~ site)  ~  :_  ~
          ;tr  ;td:"↖️"  ;td
            ;a/"{(spud (snip spit))}/":"Parent Directory"
          ==  ;td
            ; ~
          ==  ==
        ::
          ::  directories
          ::
          ;*  %+  turn  (flop diz)
          |=  dir=@ta
          =/  las=@da  (path-date /[dir])
          ;tr  ;td:"📁"  ;td
            ;a/"{(trip dir)}/":"{(trip dir)}/"
          ==  ;td
            ;+  :/"{(rend-date las)}"
          ==  ;*  ?:(=(dir 0v6urr6) [;td:"fileserver!"]~ ~)  ==
        ::
          ::  files
          ::
          ;*  %+  turn  (flop fiz)
          |=  [nom=@t ext=@t]
          =/  fil=@t  (rap 3 nom '.' ext ~)
          =/  las=@da  (path-date (welp site nom ext ~))
          =/  moj=tape
            ?+  ext  "📄"
              ?(%png %jpg %jpeg %gif %tiff %bmp %svg)  "🖼️"
              %hoon  "📜"
              %js  "📃"
              ?(%jam %zip %tar %gz %rar)  "📦"
            ==
          ;tr  ;td:"{moj}"  ;td
            ;a/"{(trip fil)}":"{(trip fil)}"
          ==  ;td
            ;+  :/"{(rend-date las)}"
          ==  ==
        ::
          ;tr  ;th(colspan "4")  ;hr;  ==  ==
        ==  ==
        ;address:"Apache Server at Port {(a-co:co our.bowl)}"
      ==
    ==
  ::
  ++  path-date
    ::NOTE  can get slow due to scry overhead
    |=  pax=path
    =+  bax=:(weld bas spur pax)
    =+  .^(cas=cass:clay %cw bax)
    =+  .^(haz=@uv %cz bax)
    |-  ^-  @da
    ?:  (lte ud.cas 1)  da.cas
    =.  bax  bax(&3 (scot %ud (dec ud.cas)))
    =/  had  .^(had=@uv %cz bax)
    ?.  =(haz had)  da.cas
    $(cas =>([bax=(scag 3 bax) cass=cass:clay] ~+(.^(cass %cw bax))))
  ::
  ++  rend-date  ::  2013-12-16 09:41
    |=  =@da  =,  co
    =+  (yore da)
    "{(a-co y)}-{(y-co m)}-{(y-co d.t)} {(y-co h.t)}:{(y-co m.t)}"
  --
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
    ?.  =(t.t.wire file-root)  [~ this]
    ~|  sign=+<.sign
    ?>  ?=(%writ +<.sign)
    ::  if we're tombstoning, trigger clay-side clean-up.
    ::  always request the next change, and clear the cache,
    ::  it will get refilled on first request for each file.
    ::
    :_  this(cash ~)
    %-  zang
    :+  ?:(tombstone ~ run-tombstone)
      (read-next [our q.byk now]:bowl file-root)
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
