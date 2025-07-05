::  spots: tests
::
/-  *spots
/+  *test-agent, *pal
::
/=  agent  /app/spots
::
|%
++  dap   %spots
+$  card  card:agent:gall
::
++  rid   ~.some.http.request
++  did   'some device'
++  pwd   'some secret'
::
+$  state-2
  $:  %2
      ::  mine: personal devices  ::TODO  support guest devices?
      ::  ways: personal trigger zones
      ::  news: unsent updates for devices
      ::
      mine=(map @t device)  ::TODO  card override
      ways=(map @da zone)
      news=(jug @t news-key)
      cars=(map @p [name=@t face=[url=@t dat=(unit octs)]])
      ::  auth: http basic auth password
      ::  open: clearweb location sharing keys
      ::
      auth=@t
      open=(map @ta [did=@t fro=@da til=(unit @da)])
      ::  pets: guest location groups
      ::
      pets=(map @ta bevy)
      ::  hunt: foreign devices
      ::        ::TODO  card override
      ::        ::TODO  live flag instead of unitized, for displaying "stale" locs
      ::                or timestamped, config arm for stale time
      ::  bait: per-peer device visibility set, reverse of line
      ::  line: per-device peer visibility set, reverse of bait
      ::  dogs: peers known to be tracking us
      ::
      hunt=(mip @p @t [now=(unit node) bat=(unit batt)])
      bait=(jug @p @t)
      line=(jug @t @p)
      dogs=(set @p)
  ==
::
+$  news-key
  $%  [%hunt-spot who=@p did=@t]
      [%hunt-card who=@p did=@t]
      [%ways waz=(set @da)]  ::TODO  this isn't gonna dedupe nicely...
    ::
      [%send-ways ~]  ::  'waypoints' cmd to triger publish
  ==
::
::  test helpers
::
++  branch
  =/  m  (mare ,~)
  |=  l=(list [t=@t f=form:m])  ::NOTE  can't seem to use $^ here
  ^-  form:m
  =/  e=tang  ~
  |=  s=state
  |-  ^-  output:m
  ?~  l
    ?.  =(~ e)  [%| e]
    [%& ~ s]
  =/  o  (f.i.l s)
  =?  e  ?=(%| -.o)
    =-  (weld e `tang`-)
    [(rap 3 'failed in branch \'' t.i.l '\':' ~) p.o]
  $(l t.l)
::
++  merge  ::  branch with shared, cached continuation
  |*  a=mold  ::  arg for constructing continuation, comes out of branches
  =/  w  (mare a)
  =/  m  (mare ,~)
  |=  [l=(list [t=@t f=form:w]) n=$-(a form:m)]
  ^-  form:m
  =|  err=tang
  =|  per=(map tang @t)
  =|  cac=(map @ output:m)
  |=  sat=state
  |-  ^-  output:m
  ?~  l
    ?.  =(~ err)  [%| err]
    [%& ~ sat]
  =^  res=output:m  cac
    ::  the below is essentially (((bind:m a) f.i.l n) sat)
    ::  but with the n invocation cached
    ::
    =/  wes=output:w  (f.i.l sat)
    ?:  ?=(%| -.wes)  [wes cac]
    ?^  hit=(~(get by cac) (mug p.wes))
      [u.hit cac]
    =/  res=output:m  ((n out.p.wes) state.p.wes)
    [res (~(put by cac) (mug p.wes) res)]
  ::  when printing fail traces, if a previous branch had an identical failure,
  ::  just print a reference to that for brevity
  ::
  =?  err  ?=(%| -.res)
    =-  (weld err `tang`-)
    :-  (rap 3 'failed in merge branch \'' t.i.l '\':' ~)
    ?~  pev=(~(get by per) p.res)  p.res
    [(rap 3 '[same as in merge branch \'' u.pev '\']' ~)]~
  =?  per  &(?=(%| -.res) !(~(has by per) p.res))
    (~(put by per) p.res t.i.l)
  $(l t.l)
::
++  ex-live-update
  |=  [subs=(set ship) upd=live-update]
  =;  paz=(list path)
    (ex-fact paz %spots-live-update !>(upd))
  :-  /live
  (turn ~(tap in subs) |=(=@p /live/(scot %p p)))
::
++  ex-http-response-full
  |=  simple-payload:http
  ^-  (list $-(card tang))
  =/  =path  /http-response/[rid]
  :~  (ex-fact ~[path] %http-response-header !>(response-header))
      (ex-fact ~[path] %http-response-data !>(data))
      (ex-card %give %kick ~[path] ~)
  ==
::
++  ex-json-response
  |=  [cod=@ud jon=@t]
  %+  ex-http-response-full
    [cod ['content-type' 'application/json']~]
  `(as-octs:mimes:html jon)
::
::  usage helpers
::
++  do-app-request
  |=  [user=@t device=@t pass=(unit @t)]
  |=  payload=@t
  %+  do-poke  %handle-http-request
  !>  ^-  [@ta inbound-request:eyre]
  :-  rid
  :*  authenticated=|
      secure=&
      address=[%ipv4 .127.0.0.1]
      ^=  request
      method=%'POST'
      url='/spots/post'
    ::
      ^=  header-list
      :*  ['user-agent' 'Owntrack-Android/gms/420503000']
          ['x-limit-u' user]
          ['x-limit-d' device]
        ::
          ?~  pass  ~
          =,  mimes:html
          ['authorization' (cat 3 'Basic ' (en:base64 (as-octs (rap 3 user ':' u.pass ~))))]~
      ==
    ::
      body=(some (as-octs:mimes:html payload))
  ==
::
++  easy-app-request
  (do-app-request '~zod' did `pwd)
::
++  do-setup
  =/  m  (mare ,~)
  ;<  *  bind:m  (do-init dap agent)
  ;<  *  bind:m  (do-poke %noun !>([%set-auth pwd]))
  (pure:m ~)
::
::  forceful helpers
::
++  set-state
  |=  new=state-2
  (do-load agent `!>(new))
::
++  jab-state
  |=  f=$-(state-2 state-2)
  =/  m  (mare ,~)
  ;<  =vase  bind:m  get-save
  ;<  *  bind:m  (do-load agent `!>((f !<(state-2 vase))))
  (pure:m ~)
::
::  read helpers
::
++  get-state
  =/  m  (mare state-2)
  ;<  =vase  bind:m  get-save
  (pure:m !<(state-2 vase))
::
++  get-device
  |=  did=@t
  =/  m  (mare (unit device))
  ;<  state=state-2  bind:m  get-state
  (pure:m (~(get by mine.state) did))
::
::  test-helpers
::
++  ex-response
  !!
::
::  tests
::
++  test-implicit-device-creation
  ::  device gets added into state when it submits a location
  ::
  %-  eval-mare
  =/  m  (mare ,~)
  ;<  ~  bind:m  do-setup
  ;<  ~  bind:m
    ;<  dev=(unit device)  bind:m
      (get-device did)
    (ex-equal !>(dev) !>(~))
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","_id":"03f72725","acc":13,"alt":52,"cog":0,"created_at":1746299720,"inregions":["aavvcc"],"lat":12.345678,"lon":1.2345678,"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","tst":1746299719,"vac":0,"vel":0}'
  ;<  dev=(unit device)  bind:m
    (get-device did)
  (ex-equal !>(?=(^ dev)) !>(&))
::
++  test-bad-auth
  ::  message submission/processing fails if no valid auth provided
  ::
  %-  eval-mare
  =/  m  (mare ,~)
  ;<  ~  bind:m  do-setup
  ;<  ~  bind:m
    ;<  dev=(unit device)  bind:m
      (get-device did)
    (ex-equal !>(dev) !>(~))
  %+  (merge (list card))
    =+  jon='{"_type":"location","_id":"03f72725","acc":13,"alt":52,"cog":0,"created_at":1746299720,"inregions":["aavvcc"],"lat":12.345678,"lon":1.2345678,"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","tst":1746299719,"vac":0,"vel":0}'
    :~  :-  'no auth'             ((do-app-request '~zod' did ~) jon)
        :-  'incorrect password'  ((do-app-request '~zod' did `'wrong pwd') jon)
        :-  'foreign username'    ((do-app-request '~nec' did `pwd) jon)
    ==
  |=  caz=(list card)
  ;<  ~  bind:m
    ;<  dev=(unit device)  bind:m
      (get-device did)
    (ex-equal !>(dev) !>(~))
  %+  ex-cards  caz
  (ex-http-response-full [403 ~] `(as-octs:mimes:html 'unauthorized'))
::
++  test-location-fact
  ::  location update from known device should give local subscription update
  ::
  %-  eval-mare
  =/  m  (mare ,~)
  ;<  ~  bind:m  do-setup
  ;<  ~  bind:m  (jab-state |=(s=state-2 s(mine (~(put by mine.s) did *device))))
  ;<  caz=(list card)  bind:m
    %-  easy-app-request
    '{"_type":"location","_id":"03f72725","acc":13,"alt":52,"batt":48,"bs":1,"cog":0,"created_at":1746299720,"inregions":["aavvcc"],"lat":12.345678,"lon":1.2345678,"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","tst":1746299719,"vac":0,"vel":0}'
  %+  ex-cards  caz
  %+  snoc
    (ex-json-response 200 '[]')
  %+  ex-live-update  ~
  :+  did
    %-  some
    :*  [lat=.~12.345678 lon=.~1.2345678 acc=[~ 13] alt=[~ --52] vac=[~ 0]]
        wen=[gps=~2025.5.3..19.15.19 msg=~2025.5.3..19.15.20]
        vel=[~ 0]
    ==
  `[48 %run]
::
++  test-location-history
  ::  successive location updates should be stored in the device's log,
  ::  and updates with the same location should get collapsed down into
  ::  "start" and "end" nodes for that location
  ::
  %-  eval-mare
  =/  m  (mare ,~)
  ;<  ~  bind:m  do-setup
  ;<  ~  bind:m  (jab-state |=(s=state-2 s(mine (~(put by mine.s) did *device))))
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","tst":1746299719,"created_at":1746299720,"lat":12.345678,"lon":1.2345678,"_id":"03f72725","acc":13,"alt":52,"cog":0,"inregions":["aavvcc"],"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","vac":0,"vel":0}'
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","tst":1746299720,"created_at":1746299721,"lat":23.456789,"lon":2.3456789,"_id":"03f72725","acc":13,"alt":52,"cog":0,"inregions":["aavvcc"],"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","vac":0,"vel":0}'
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","tst":1746299721,"created_at":1746299722,"lat":23.456789,"lon":2.3456789,"_id":"03f72725","acc":13,"alt":52,"cog":0,"inregions":["aavvcc"],"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","vac":0,"vel":0}'
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","tst":1746299722,"created_at":1746299723,"lat":23.456789,"lon":2.3456789,"_id":"03f72725","acc":13,"alt":52,"cog":0,"inregions":["aavvcc"],"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","vac":0,"vel":0}'
  ;<  *  bind:m
    %-  easy-app-request
    '{"_type":"location","tst":1746299723,"created_at":1746299724,"lat":34.567890,"lon":3.4567890,"_id":"03f72725","acc":13,"alt":52,"cog":0,"inregions":["aavvcc"],"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","vac":0,"vel":0}'
  ;<  dev=(unit device)  bind:m
    (get-device did)
  =/  dev  (fall dev *device)
  %+  ex-equal
    !>(log.dev)
  !>  ^+  log.dev
  :~  :*  [lat=.~34.567890 lon=.~3.4567890 acc=[~ 13] alt=[~ --52] vac=[~ 0]]
          wen=[gps=~2025.5.3..19.15.23 msg=~2025.5.3..19.15.24]
          vel=[~ 0]
      ==
      :*  [lat=.~23.456789 lon=.~2.3456789 acc=[~ 13] alt=[~ --52] vac=[~ 0]]
          wen=[gps=~2025.5.3..19.15.22 msg=~2025.5.3..19.15.23]
          vel=[~ 0]
      ==
      :*  [lat=.~23.456789 lon=.~2.3456789 acc=[~ 13] alt=[~ --52] vac=[~ 0]]
          wen=[gps=~2025.5.3..19.15.20 msg=~2025.5.3..19.15.21]
          vel=[~ 0]
      ==
      :*  [lat=.~12.345678 lon=.~1.2345678 acc=[~ 13] alt=[~ --52] vac=[~ 0]]
          wen=[gps=~2025.5.3..19.15.19 msg=~2025.5.3..19.15.20]
          vel=[~ 0]
      ==
  ==
::
++  test-new-device-news
  ::  new device should hear about locations, contact cards,
  ::  and get asked for waypoints
  ::
  %-  eval-mare
  =/  m  (mare ,~)
  ;<  ~  bind:m  do-setup
  ;<  ~  bind:m
    %-  jab-state
    |=  s=state-2
    %_  s
      cars  (~(put by cars.s) ~palfun-foslup ['nicnom' ['url' `2^0x1337]])
      hunt  (~(put bi hunt.s) ~palfun-foslup 'devais' `[[.~1.1 .~2.2 `3 ~ ~] [. .]:~2025.1.1 ~] `[77 %cha])
    ==
  ;<  caz=(list card)  bind:m
    %-  easy-app-request
    '{"_type":"location","_id":"03f72725","acc":13,"alt":52,"cog":0,"created_at":1746299720,"inregions":["aavvcc"],"lat":12.345678,"lon":1.2345678,"t":"u","tid":"zo","topic":"owntracks/~zod/phoneee","tst":1746299719,"vac":0,"vel":0}'
  %+  ex-cards  caz
  %+  snoc
    %+  ex-json-response  200
    '[{"action":"waypoints","_type":"cmd"},\
    /{"acc":3,"lon":2.2,"tst":1735689600,\
    /"topic":"pf~palfun-foslup---devais","tid":"pf~palfun-foslup---devais",\
    /"batt":77,"lat":1.1,"bs":2,"_type":"location"},\
    /{"name":"nicnom","tid":"pf~palfun-foslup---devais","face":"NxM","_type":"card"}]'
  |=(* ~)
--
