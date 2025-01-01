::  untrack? loci? locus?: location tracking & sharing
::
::TODO  scope:
::  - per device, store time-ordered list of location reports (_type=location)
::  - store user-defined waypoints (_type=waypoint/s)
::  - devices' presence at waypoints (_type=transition)
::  - user-defined device-timeranges that describe stored routes/tracks
::  - http Basic authentication
::
::TODO  later:
::  - send other device locations in POST response bodies
::  - serve http pages with map view so you can share your own device's location
::    for the next n minutes, entropy secret in url
::  - subscribe to friends' locations over ames (also look into tours?)
::  - include friends in responses as well
::  - expose trigger zone status w/o location deets
::
::TODO  guest locations???
::  - let non-urbit-users co-locate on an urbit user's owntracksserver
::  - urbit user gets control over who can see who, that's just how it is
::  - only latest location/$node & battery status, no history tracking
::  - respect username field for the card, as long as it's not a valid @p
::
/-  *loci
/+  ot=owntracks, rudder,
    dbug, verb, default-agent
::
:: /~  pages  (page:rudder (map @t device) [%nop ~])  /app/loci
/=  share  /app/loci/share
::
|%
+$  state-0
  $:  %0
      mine=(map @t device)
      ::TODO  support current location for guests?
      ways=(map @da region)
      :: hunt=(mip @p @t [node bat=(unit batt)])
      news=(list response:ot)  ::TODO  per client device, encode as $%([%hunt @p @t] etc)
      auth=@t
      open=(map @ta [did=@t fro=@da til=(unit @da)])
  ==
::
+$  card  $+(card card:agent:gall)
--
::
%-  agent:dbug
%+  verb  |
::
=|  state-0
=*  state  -
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ::  start out with a random password
  ::
  :_  this(auth (rsh 3^2 (scot %q (end 3^4 eny.bowl))))
  ::  and set up an eyre binding
  ::
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old  !<(state-0 ole)
  =.  state  old
  [~ this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::  %noun: misc utilities
    ::
      %noun
    ?+  q.vase  !!
        [%queue-response *]
      =+  !<([%queue-response r=response:ot] vase)
      [~ this(news (snoc news r))]
    ::
        [%set-auth @t]
      [~ this(auth +.q.vase)]
    ::
        [%share did=@t for=(unit @dr)]
      =/  key=@ta
        |-
        =+  k=(crip ((v-co:co 12) (end 0^60 eny.bowl)))
        ?.  (~(has by open) k)  k
        $(eny.bowl (shas %next eny.bowl))
      =.  open
        %+  ~(put by open)  key
        :+  did.q.vase  now.bowl
        ?~  for.q.vase  ~
        `(add now.bowl u.for.q.vase)
      ::TODO  set timer for cleanup?
      [~ this]
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =+  !<(order:rudder vase)
    ~&  [dap.bowl %request url.request]
    ?.  =(url.request (rap 3 '/' dap.bowl '/post' ~))
      =/  =query:rudder  (purse:rudder url.request)
      :_  this
      %+  spout:rudder  id
      ?.  ?=([%owntracks %share @ ~] site.query)
        (issue:rudder 404 ~)
      ~&  key=i.t.t.site.query
      ?~  ved=(~(get by open) i.t.t.site.query)
        (issue:rudder 403 'expired')
      ?:  &(?=(^ til.u.ved) (gth now.bowl u.til.u.ved))
        (issue:rudder 403 'expired')
      ?~  dev=(~(get by mine) did.u.ved)
        (issue:rudder 404 'gone')
      ?+  ext.query  (issue:rudder 404 ~)
          ~
        (paint:rudder (share did.u.ved til.u.ved u.dev))
      ::
          [~ %json]
        ^-  simple-payload:http
        :-  [200 ['content-type' 'application/json']~]
        %-  :(cork en:json:html as-octs:mimes:html some)
        ?~  bac.u.dev  ~
        =+  i.bac.u.dev
        ::TMP
        :: =.  lat  (add:rd lat (div:rd .~1 (sun:rd (~(rad og +(eny.bowl)) 100))))
        :: =.  lon  (add:rd lon (div:rd .~1 (sun:rd (~(rad og eny.bowl) 100))))
        =,  enjs:format
        %-  pairs
        :~  'lat'^n+(rsh 3^2 (scot %rd lat))
            'lon'^n+(rsh 3^2 (scot %rd lon))
            'acc'^?~(acc ~ (numb u.acc))
            'bat'^?~(bat.u.dev ~ (numb cen.u.bat.u.dev))
            'wen'^s+(scot %da msg.wen)
        ==
      ==
      :: :: =/  page=$%([%])
      :: =;  out=(quip card *)
      ::   ::TODO  support editing state
      ::   [-.out this]
      :: %.  [bowl !<(order:rudder vase) mine.state]
      :: %-  (steer:rudder _mine.state ,[%nop ~])
      :: :^    pages
      ::     (point:rudder /[dap.bowl] & ~(key by pages))
      ::   (fours:rudder mine.state)
      :: |=  [%nop ~]
      :: ^-  $@(brief:rudder [brief:rudder (list card) _mine.state])
      :: 'unimplemented'
    =/  auth-head=@t
      %^  cat  3
        'Basic '
      =,  mimes:html
      (en:base64 (as-octs (rap 3 (scot %p our.bowl) ':' auth ~)))
    =/  have-head=(unit @t)
      (get-header:http 'authorization' header-list.request)
    ?.  =(have-head `auth-head)
      :_  this
      ~&  [dap.bowl %unauthorized-request]  ::TODO  removeme
      (spout:rudder id [403 ~] `(as-octs:mimes:html 'unauthorized'))
    ::TODO  check method?
    ::  try to parse & add into state as necessary
    ::
    ?~  body.request
      :_  this
      (spout:rudder id [200 ['content-type' 'application/json']~] `(as-octs:mimes:html '[]'))
    ?~  jon=(de:json:html q.u.body.request)
      ~&  [%body-not-json bod=`@t`q.u.body.request]
      :_  this
      (spout:rudder id [400 ['content-type' 'application/json']~] ~)
    ?~  mes=(message:dejs:ot u.jon)
      ~&  [%failed-to-parse u.jon]
      :_  this
      (spout:rudder id [400 ['content-type' 'application/json']~] ~)
    ~&  [%got -.u.mes]
    ::  for now, always ack, send no updates
    ::
    :-  %+  spout:rudder  id
        :-  [200 ['content-type' 'application/json']~]
        `(as-octs:mimes:html (en:json:html (responses:enjs:ot news)))
    =.  news  ~
    ~?  &(?=([%o *] u.jon) (~(has by p.u.jon) 'topic'))
      [%with-topic (~(got by p.u.jon) 'topic')]
    =/  did=(unit @t)
      (get-header:http 'x-limit-d' header-list.request)
    |-
    ?+  -.u.mes  this
        %location
      =/  did=@t
        ::REVIEW
        ::  get the device id from the request header if we can,
        ::  otherwise try to get it from the topic.
        ::  as a last resort, just use the tracker id.
        ::
        ?^  did  u.did
        =;  p  (fall (rush topic.u.mes p) tid.u.mes)
        ;~(pfix (jest 'owntracks') fas (star ;~(less fas next)) fas (cook crip (star next)))
      ~&  [%location tid=tid.u.mes topic=topic.u.mes did=did tst=tst.u.mes ca=created-at.u.mes]
      =/  dev  (~(gut by mine) did *device)
      =.  bac.dev
        =/  new=node
          =,  u.mes
          :-  [lat lon acc [alt vac]]
          [[tst (fall created-at tst)] vel]
        |-  ^+  bac.dev
        ?~  bac.dev  [new]~
        ::  once we've moved to the right place in history, store the node
        ::
        ?:  (gte msg.wen.new msg.wen.i.bac.dev)
          ::  if the new node is identical, skip it entirely
          ::
          ?:  =(new i.bac.dev)  bac.dev  ::NOTE  odd case, but happens in practice
          ::  if the gps data is different, store as-is
          ::
          ?.  =(-.new -.i.bac.dev)  [new bac.dev]
          ::  if the gps data is the same, only keep oldest & newest
          ::
          ?~  t.bac.dev  [new bac.dev]
          ?.  =(-.new -.i.t.bac.dev)  [new bac.dev]
          ::  so, here, replace latest with this new one
          ::NOTE  assumes most-recently-processed is newer
          ::TODO  should we set velocity in latest to zero? looks like vel
          ::      might be sticky in stale/reused gps fixes
          ::
          [new t.bac.dev]
        [i.bac.dev $(bac.dev t.bac.dev)]
      =.  bat.dev
        ?~  batt.u.mes  ~
        %-  some
        :-  u.batt.u.mes
        ?-  bs.u.mes
          %unknown    %idk
          %unplugged  %run
          %charging   %cha
          %full       %ful
        ==
      ::TODO  if we still want this update _here_, should correlate rids with wtst?
      :: =.  now.dev
      ::   ::TODO  emit transitions?
      ::   (sy inrids.u.mes)
      ::TODO  update ways
      ::TODO  what if we... updated ways based on received locations?
      ::      this way devices can be in regions they didn't create themselves.
      ::      would need to do coordinate overlap calcs, but probably not that hard.
      this(mine (~(put by mine) did dev))
    ::
        %waypoint
      ::TODO  update waypoint state
      ?.  &(?=(^ lat.u.mes) ?=(^ lon.u.mes) ?=(^ rad.u.mes))
        ~&  [%unsupported-waypoint u.mes]
        this
      ::TODO  should maybe use tst.u.mes instead? transition also has wtst.
      this(ways (~(put by ways) tst.u.mes [desc [u.lat u.lon u.rad] ~]:u.mes))
    ::
        %waypoints
      |-
      ?~  +.u.mes  this
      =.  this  ^$(u.mes [%waypoint i.u.mes])
      $(+.u.mes t.u.mes)
    ::
        %transition
      ::TODO  emit transition notification fact?
      =/  did=@t
        ::REVIEW
        ::  get the device id from the request header if we can,
        :: ::  otherwise try to get it from the topic.
        ::  as a last resort, just use the tracker id.
        ::
        ?^  did  u.did
        tid.u.mes
        :: =;  p  (fall (rush topic.u.mes p) tid.u.mes)  ::TODO  do receive topic, right?
        :: ;~(pfix (jest 'owntracks') fas (star ;~(less fas next)) fas (cook crip (star next)))
      ~&  [%transition did=did]
      =/  dev  (~(gut by mine) did *device)
      =.  now.dev
        ?-  event.u.mes
          %enter  (~(put in now.dev) wtst.u.mes)
          %leave  (~(del in now.dev) wtst.u.mes)
        ==
      =.  mine  (~(put by mine) did dev)
      ?~  way=(~(get by ways) wtst.u.mes)
        ~&  [%transition-for-unknown-region [tid=tid desc=desc]:u.mes]
        this
      =.  now.u.way
        ?-  event.u.mes
          %enter  (~(put in now.u.way) did)
          %leave  (~(del in now.u.way) did)
        ==
      this(ways (~(put by ways) wtst.u.mes u.way))
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  sign-arvo  (on-arvo:def wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--
