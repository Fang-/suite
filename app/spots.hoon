::  spots: location tracking & sharing
::
::    because location is sensitive, most foreign-access subscription paths
::    contain the subscriber's @p, letting us scope updates to specific
::    listeners.
::
::    /live/[~sampel] gives live location updates for all devices _that ~sampel
::    has been given access to_. gives %spots-live-update facts.
::    removing access to a device will send a [did ~ ~] $live-update.
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
::  - support one-click setup? https://owntracks.org/booklet/guide/quicksetup/#initial-testing
::
::TODO  guest locations???
::  - let non-urbit-users co-locate on an urbit user's owntracksserver
::  - urbit user gets control over who can see who, that's just how it is
::  - only latest location/$node & battery status, no history tracking
::  - respect username field for the card, as long as it's not a valid @p
::
/-  *spots
/+  ot=owntracks, *pal, rudder,
    co=contacts,
    dbug, verb, default-agent
::
:: /~  pages  (page:rudder (map @t device) [%nop ~])  /app/spots
/=  home   /app/spots/home
/=  share  /app/spots/share
::
|%
+$  state-1
  $:  %1
      ::  mine: personal devices  ::TODO  support guest devices?
      ::  ways: personal trigger zones
      ::  news: unsent updates for devices
      ::
      mine=(map @t device)  ::TODO  card override
      ways=(map @da region)
      news=(jug @t news-key)
      cars=(map @p [name=@t face=[url=@t dat=(unit octs)]])
      ::TODO  support payload encryption
      ::  auth: http basic auth password
      ::  open: clearweb location sharing keys
      ::
      auth=@t
      open=(map @ta [did=@t fro=@da til=(unit @da)])
      ::  hunt: foreign devices
      ::        ::TODO  card override
      ::        ::TODO  live flag instead of unitized, for displaying "stale" locs
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
  ==
::
+$  card  $+(card card:agent:gall)
::
::
++  send-live
  |=  [doz=(set @p) upd=live-update]
  :+  %give  %fact
  :_  [%spots-live-update !>(upd)]
  :-  /live
  (turn ~(tap in doz) |=(=@p /live/(scot %p p)))
::
++  put-news
  |=  $:  news=(jug @t news-key)
          mine=(set @t)
      $=  what
      $%  [%hunt-spot who=@p did=@t]
          [%hunt-card who=@p dis=(set @t)]
      ==  ==
  ^+  news
  =/  nuz=(list news-key)
    ?:  ?=(%hunt-spot -.what)  [what]~
    %+  turn  ~(tap in dis.what)
    |=  h=@t
    [%hunt-card who.what h]
  %-  ~(gas ju news)
  %-  zing
  ^-  (list (list [@t news-key]))
  %+  turn  ~(tap in mine)
  |=  m=@t
  ^-  (list [@t news-key])
  (turn nuz (lead m))
::
++  make-ot-location
  ::TODO  conversions of this kind should probably go into a lib
  |=  [[who=@p did=@t] node bat=(unit batt)]
  ^-  location:ot
  %*  .  *location:ot
    tid         (make-tid:ot who did)
    topic       (make-tid:ot who did)  ::TODO  prepend 'owntracks/http/'?  ::NOTE  not respected (yet?)
    lat         lat
    lon         lon
    acc         acc
    alt         alt
    vac         vac
    vel         vel
    tst         gps.wen
    created-at  `msg.wen
    batt        ?~(bat ~ `cen.u.bat)
    bs          ?~(bat %unknown ?-(sat.u.bat %idk %unknown, %run %unplugged, %cha %charging, %ful %full))
  ==
::
++  contact-to-card
  |=  [who=@p con=contact:co]
  ^-  [nom=@t img=@t]
  ::  we fetch the avatar not directly but through a pal.dev service,
  ::  which will downscale and compress the image for us,
  ::  so that we have a smaller memory footprint.
  ::
  :-  =+  def=(scot %p who)
      =+  nom=(fall (~(get cy:co con) %nickname %text) def)
      ?:(=('' nom) def nom)
  ?^  img=(~(get cy:co con) %avatar %look)
    ::TODO  really should make these requests through paldev as a
    ::      service provider, to prevent clearweb abuse...
    %^  cat  3
      'https://pal.dev/aides/owntracks/avatar?url='
    =,  mimes:html
    (en:base64 (as-octs u.img))
  %+  rap  3
  :+  'https://pal.dev/aides/owntracks/sigil?ship='
    (rsh 3 (scot %p who))
  ?~  col=(~(get cy:co con) %color %tint)
    ~
  =+  r=(cut 3 2^1 u.col)
  =+  g=(cut 3 1^1 u.col)
  =+  b=(cut 3 0^1 u.col)
  =+  x=(div :(add (mul 299 r) (mul 587 g) (mul 114 b)) 1.000)
  :~  '&bg=rgb('  (scot %ud r)  ','  (scot %ud g)  ','  (scot %ud b)  ')'
      '&fg='  ?:((lth (sub 255 x) 70) 'black' 'white')
  ==
--
::
%-  agent:dbug
%+  verb  |
::
=|  state-1
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
  ::  set up an eyre binding,
  ::  and the contacts subscription
  ::
  :~  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
      [%pass /contacts/news %agent [our.bowl %contacts] %watch /v1/news]
  ==
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
      =+  old=!<(state-any ole)
      =?  old  ?=(%0 -.old)  (state-0-to-1 old)
      ?>  ?=(%1 -.old)
      [~ this(state old)]
  ::
  +$  state-any  $%(state-0 state-1)
  ::
  +$  state-0   $_  %*  .  *state-1  -  %0
                  mine  *(map @t device-0)
                  hunt  *(mip @p @t [now=(unit node-0) bat=(unit batt)])
                ==
  +$  device-0  _%*(. *device bac *(list node-0))
  +$  node-0    _%*(. *node alt *(unit @ud))
  ::
  ++  state-0-to-1
    |=  s=state-0
    ^-  state-1
    %=  s  -  %1
      mine  (~(run by mine.s) |=(d=device-0 d(bac (turn bac.d node-0-to-1))))
      hunt  (~(run bi hunt.s) |=([n=(unit node-0) b=(unit batt)] [(bind n node-0-to-1) b]))
    ==
  ++  node-0-to-1
    |=(n=node-0 `node`n(alt (bind alt.n sun:si)))
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::  %noun: misc utilities
    ::
      %noun
    ?+  q.vase  !!
        [%marked mark=@tas data=*]
      (on-poke mark.q.vase (slot 7 vase))
    ::
        [%kill did=@t]
      [~ this(mine (~(del by mine) did.q.vase))]
    ::
        [%set-auth @t]
      [~ this(auth +.q.vase)]
    ::
        [%share did=@t for=(unit @dr)]
      ::TODO  support revocation
      =/  key=@ta
        |-
        =+  k=(crip ((v-co:^co 12) (end 0^60 eny.bowl)))
        ?.  (~(has by open) k)  k
        $(eny.bowl (shas %next eny.bowl))
      =.  open
        %+  ~(put by open)  key
        :+  did.q.vase  now.bowl
        ?~  for.q.vase  ~
        `(add now.bowl u.for.q.vase)
      ::TODO  set timer for cleanup?
      [~ this]
    ::
        [%hunt who=@p]
      =.  hunt
        %+  ~(put by hunt)  who.q.vase
        (~(gut by hunt) who.q.vase ~)
      ::  make sure we have latest profile card details. this is potentially
      ::  redundant, but simplifies the logic. we don't want to add muddy
      ::  existence check semantics onto .cars entries.
      ::
      ::TODO  =*  who
      =/  [nom=@t img=@t]
        %+  contact-to-card  who.q.vase
        %-  contact-uni:co
        .^  =page:co  %gx
          (scot %p our.bowl)  %contacts  (scot %da now.bowl)
          /v1/book/(scot %p who.q.vase)/contact-page-0
        ==
      =/  had=[name=@t face=[url=@t (unit octs)]]
        (~(gut by cars) who.q.vase (scot %p who.q.vase) ['' ~])
      =.  cars
        ::TODO  dedupe with %contact-response-0 fact handling?
        %+  ~(put by cars)  who.q.vase
        :-  nom
        ?:  =(url.face.had img)
          face.had
        [img ~]
      ::  it's a new addition, always put it into news,
      ::  and always re-fetch the avatar
      ::  (see also comment about redundancy & simplicity above)
      ::
      =.  news
        ::TODO  dedupe with %contact-response-0 fact handling?
        %^  put-news  news
          ~(key by mine)
        [%hunt-card who.q.vase ~(key by (~(gut by hunt) who.q.vase ~))]
      :_  this
      :~  [%pass /hunt %agent [who.q.vase dap.bowl] %watch /live/(scot %p our.bowl)]
        ::
          =-  [%pass /card/(scot %p who.q.vase)/face/(scot %t img) %arvo %i -]
          [%request [%'GET' img ~ ~] *outbound-config:iris]
      ==
    ::
        [%bait who=@p did=@t show=?]
      ?.  show.q.vase
        :_  %_  this
              bait  (~(del ju bait) [who did]:q.vase)
              line  (~(del ju line) [did who]:q.vase)
            ==
        =/  upd=live-update  [did.q.vase ~ ~]
        [%give %fact [/live/(scot %p who.q.vase)]~ %spots-live-update !>(upd)]~
      :_  %_  this
            bait  (~(put ju bait) [who did]:q.vase)
            line  (~(put ju line) [did who]:q.vase)
          ==
      ?~  dev=(~(get by mine) did.q.vase)  ~
      =/  upd=live-update  [did.q.vase ?~(bac.u.dev ~ `i.bac.u.dev) bat.u.dev]
      [%give %fact [/live/(scot %p who.q.vase)]~ %spots-live-update !>(upd)]~
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
      ?+  site.query  (issue:rudder 404 ~)
          [%spots ~]
        (paint:rudder (home bowl mine auth open hunt line dogs))
      ::
          [%spots %share @ ~]
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
      ==
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
    =/  did=(unit @t)
      ::TODO  failing this, should get it from topic? or should we just assert
      ::      that it's here?
      ::      %location logic gets from the topic...
      (get-header:http 'x-limit-d' header-list.request)
    ::  if this device is new, everything is news to it
    ::
    =?  news  &(?=(^ did) !(~(has by mine) u.did))
      ::  everything is news to it, generate a set of news-keys for this
      ::  device based on everything we have in state
      ::
      %+  ~(put by news)  u.did
      ::TODO  also enqueue %send-ways command
      %+  roll  ~(tap by hunt)
      |=  [[who=@p des=(map @t [now=(unit) *])] nes=(set news-key)]
      %+  roll  ~(tap by des)
      |=  [[did=@t now=(unit) *] =_nes]
      =?  nes  (~(has by cars) who)
        (~(put in nes) [%hunt-card who did])
      =?  nes  ?=(^ now)
        (~(put in nes) [%hunt-spot who did])
      nes
    ::  send (and then forget) updates if we have them for this device
    ::
    =/  caz
      %+  spout:rudder  id
      :-  [200 ['content-type' 'application/json']~]
      ?~  did  ~
      %-  some
      %-  as-octs:mimes:html
      %-  en:json:html
      %-  responses:enjs:ot
      %+  murn  ~(tap in (~(get ju news) u.did))
      |=  k=news-key
      ^-  (unit response:ot)
      ?-  -.k
          %hunt-spot
        ?~  hun=(~(get bi hunt) +.k)  ~
        ?~  now.u.hun  ~  ::TODO  disappear the node instead? or live flag?
        (some %location (make-ot-location +.k [u.now bat]:u.hun))
      ::
          %hunt-card
        ?~  car=(~(get by cars) who.k)  ~
        %-  some
        :^  %card
            %-  some
            %^  rap  3
              name.u.car
            ?:  ?=([* ~ ~] (~(gut by hunt) who.k ~))
              ~  ::  only one device, no need to specify
            [' (' did.k ')' ~]
          dat.face.u.car
        (make-tid:ot +.k)
      ==
    =?  news  ?=(^ did)
      (~(del by news) u.did)
    ~?  &(?=([%o *] u.jon) (~(has by p.u.jon) 'topic'))
      [%with-topic (~(got by p.u.jon) 'topic')]
    |-
    ?+  -.u.mes  [caz this]
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
      =/  dev
        (~(gut by mine) did *device)
      =/  had=[(unit node) (unit batt)]
        [?~(bac.dev ~ `i.bac.dev) bat.dev]
      ::TODO  if it changes, send fact to all device baits
      ::TODO  add it as news to all our other devices
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
      :-  %+  weld  caz
          ^-  (list card)
          =/  new  [`(snag 0 bac.dev) bat.dev]
          ?:  =(had new)  ~
          [(send-live (~(get ju line) did) did new)]~
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
      :-  caz
      ::TODO  update waypoint state
      ?.  &(?=(^ lat.u.mes) ?=(^ lon.u.mes) ?=(^ rad.u.mes))
        ~&  [%unsupported-waypoint u.mes]
        this
      ::TODO  should maybe use tst.u.mes instead? transition also has wtst.
      this(ways (~(put by ways) tst.u.mes [desc [u.lat u.lon u.rad] ~]:u.mes))
    ::
      ::   %waypoints
      :: |-
      :: ?~  +.u.mes  this
      :: =^  this  ^$(u.mes [%waypoint i.u.mes])
      :: $(+.u.mes t.u.mes)
    ::
        %transition
      :-  caz  ::TODO  emit transition notification fact?
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
  ::
      [%live ?(~ [@ ~])]
    =/  for=@p
      ?^  t.path  (slav %p i.t.path)
      ?>(=(src our):bowl src.bowl)
    ?>  =(for src.bowl)
    =.  dogs  (~(put in dogs) src.bowl)
    :_  this
    %+  murn  ~(tap in (~(get ju bait) src.bowl))
    |=  did=@t
    ^-  (unit card)
    ?~  dev=(~(get by mine) did)  ~
    =/  upd=live-update
      :+  did
        ?~(bac.u.dev ~ `i.bac.u.dev)
      bat.u.dev
    `[%give %fact ~ %spots-live-update !>(upd)]
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~|  wire=wire
  ?+  wire  ~|(%strange-wire !!)
      [%hunt ~]
    ?-  -.sign
      %poke-ack  !!
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      ::  other legitimate instances of this agent shouldn't nack watches,
      ::  simply let them sit  silently until we get permission on something.
      ::  a bit radical, but in light of that we remove user intent on-nack.
      ::
      [~ this(hunt (~(del by hunt) src.bowl))]
    ::
        %kick
      :_  this
      [%pass wire %agent [src dap]:bowl %watch /live/(scot %p our.bowl)]~
    ::
        %fact
      ?.  =(%spots-live-update p.cage.sign)
        ~|  [%strange-fact mark=p.cage.sign]
        !!  ::TODO  or nop?
      =+  !<(live-update q.cage.sign)
      =.  hunt  (~(put bi hunt) src.bowl did now bat)
      ::  the data changed, which means there's news for each of our devices
      ::
      =?  news  ?=(^ now)  ::TODO  what if deletion?
        (put-news news ~(key by mine) %hunt-spot src.bowl did)
      ::TODO  give subscription updates for clients?
      [~ this]
    ==
  ::
      [%contacts %news ~]
    ::TODO  carefully re-sub on kick
    ?.  ?=(%fact -.sign)  [~ this]
    ?.  ?=(%contact-response-0 p.cage.sign)
      ~&  [dap.bowl %contacts-strange-mark mark=p.cage.sign]
      [~ this]
    =+  !<(res=response:co q.cage.sign)
    =/  pro=(unit [who=@p con=contact:co])
      ?-  -.res
        %self  ~  ::TODO  update our own card too
        %page  ?^  kip.res  ~
               `[kip.res (contact-uni:co [con mod]:res)]
        %wipe  ?^  kip.res  ~
               `[kip.res ~]
        %peer  `+.res  ::TODO  does this account for the overlay?
      ==
    ?~  pro  [~ this]
    =/  [nom=@t img=@t]
      (contact-to-card u.pro)
    =/  had=[name=@t face=[url=@t (unit octs)]]
      (~(gut by cars) who.u.pro (scot %p who.u.pro) ['' ~])
    ::  always update the entry in .cars
    ::
    =.  cars
      %+  ~(put by cars)  who.u.pro
      :-  nom
      ::  only update the url & image data part if it changed
      ::
      ?:  =(url.face.had img)
        face.had
      [img ~]
    ::  if anything changed, generate the relevant news and queue it up
    ::  for all our devices
    ::
    =?  news  !&(=(name.had nom) =(url.face.had img))
      %^  put-news  news
        ~(key by mine)
      [%hunt-card who.u.pro ~(key by (~(gut by hunt) who.u.pro ~))]
    :_  this
    ::  if the image url changed, we must request the matching octs
    ::
    ?:  =(url.face.had img)
      ~
    =-  [%pass /card/(scot %p who.u.pro)/face/(scot %t img) %arvo %i -]~
    [%request [%'GET' img ~ ~] *outbound-config:iris]
  ==
::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ~|  [wire=wire sign=[- +<]:sign]
  ?+  wire  (on-arvo:def wire sign)
      [%eyre %connect ~]
    ?>  ?=([%eyre %bound *] sign)
    ~?  !accepted.sign
      [dap.bowl 'eyre bind rejected!' binding.sign]
    [~ this]
  ::
      [%card @ %face @ ~]
    ?>  ?=([%iris %http-response *] sign)
    =*  res     client-response.sign
    =/  who=@p  (slav %p i.t.wire)
    =/  url=@t  (slav %t i.t.t.t.wire)
    ::  if we don't care about this particular url anymore, just drop it
    ::
    ?.  =(url url.face:(~(gut by cars) who ['' face=[url='' ~]]))
      ~&  %face-dont-care
      [~ this]
    ::  %progress responses are unexpected, the runtime doesn't support them
    ::  right now. if they occur, just treat them as cancels and retry.
    ::
    =?  res  ?=(%progress -.res)
      ~&  [dap.bowl %strange-iris-progress-response]  ::TODO  log properly
      [%cancel ~]
    ::  we might get a %cancel if the runtime was restarted during our
    ::  request. try to pick up where we left off.
    ::
    ?:  ?=(%cancel -.res)
      :_  this
      ::TODO  de-dupe with +on-agent?
      =-  [%pass /card/(scot %p who)/face/(scot %t url) %arvo %i -]~
      [%request [%'GET' url ~ ~] *outbound-config:iris]
    ::
    ?>  ?=(%finished -.res)
    ?:  !=(200 status-code.response-header.res)
      ~&  [dap.bowl %failed-to-load-image status-code.response-header.res url]
      [~ this]
    ?~  full-file.res
      ::TODO  will hit this for imgur links...
      ~&  [dap.bowl %strange-no-image-body url]
      [~ this]
    ::  put the image into state, update the news
    ::
    =.  cars
      %+  ~(jab by cars)  who
      |=  [name=@t [url=@t dat=(unit octs)]]
      ~?  !=(url ^url)  %face-shouldnt-care
      [name [url `data.u.full-file.res]]
    ::TODO  de-dupe with +on-agent
    =.  news
      =/  nuz=(list news-key)
        %+  turn  ~(tap in ~(key by (~(gut by hunt) who ~)))
        |=  h=@t
        [%hunt-card who h]
      %-  ~(gas ju news)
      %-  zing
      ^-  (list (list [@t news-key]))
      %+  turn  ~(tap in ~(key by mine))
      |=  m=@t
      ^-  (list [@t news-key])
      (turn nuz (lead m))
    ::TODO  subscription update?
    [~ this]
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(/x/whey path)  [~ ~]
  :^  ~  ~  %mass
  !>  ^-  (list mass)
  :~  'mine'^&+mine
      'cars'^&+cars
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
