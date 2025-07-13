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
::  - devices' presence at waypoints (_type=transition)
::    - transition notifications (even w/o receiving transition event)
::    - set own location based on waypoint notif, if location is stale
::  - user-defined device-timeranges that describe stored routes/tracks
::    - should be a separate app/agent?
::
::TODO  later:
::  - share/expose trigger zone status w/o location deets
::
::TODO  guest locations???
::  - let non-urbit-users co-locate on an urbit user's owntracksserver
::  - urbit user gets control over who can see who, that's just how it is
::  - only latest location/$node & battery status, no history tracking
::  - respect username field for the card, as long as it's not a valid @p
::    - username must start with cohort name/prefix
::      - X-Limit-U header? or is that same as auth creds?
::    - first password used by "[cohort]/[username]" is respected forever
::    - single device id per guest?
::    - certainly just set tid to first 2 chars of username
::
/-  *spots
/+  spots, ot=owntracks, *pal, rudder, math, header-auth,
    co=contacts,
    dbug, verb, default-agent
::
:: /~  pages  (page:rudder (map @t device) [%nop ~])  /app/spots
/=  home   /app/spots/home
/=  share  /app/spots/share
/=  club   /app/spots/club
/=  club-setup  /app/spots/club-setup
::
|%
++  config
  |%
  ++  stale  ~m5
  --
::
+$  state-3
  $:  %3
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
      [%send-ways ~]  ::  'waypoints' cmd to trigger publish
  ==
::
+$  action
  $%  [%auth new=@t]
      [%kill did=@t]
      [%open key=(unit @ta) did=@t for=(unit @dr)]
    ::
      [%hunt who=@p]
      [%bait who=@p did=@t show=?]
    ::
      [%pets id=@ta desc=@t]
  ==
::
+$  card  $+(card card:agent:gall)
::
::
++  send-live
  |=  [doz=(set @p) upd=live-update]
  ^-  card
  :+  %give  %fact
  :_  [%spots-live-update !>(upd)]
  :-  /live
  (turn ~(tap in doz) |=(=@p /live/(scot %p p)))
::
++  send-zone  ::REVIEW  what about /zone? but then, what about zone ids in fact?
  |=  [wid=@da upd=zone-update]
  ^-  card
  :+  %give  %fact
  :_  [%spots-zone-update !>(upd)]
  :~  ::TODO  /zone ? but then, need zone ids in the facts
      /zone/(scot %da wid)
      ::TODO  /zone/(scot %t nom) ?
      ::      wouldn't that suggest we should just @ta-key zones in the first place?
  ==
::
++  put-news
  |=  $:  news=(jug @t news-key)
          mine=(set @t)
      $=  what
      $%  $<(%hunt-card news-key)
          [%hunt-card who=@p dis=(set @t)]  ::  same card for all devices
      ==  ==
  ^+  news
  =/  nuz=(list news-key)
    ?.  ?=(%hunt-card -.what)  [what]~
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
++  make-fake-zone-location
  |=  [lat=@rd lon=@rd acc=@ud tst=@da bat=(unit batt)]
  ^-  location:ot
  %*  .  *location:ot
    acc         `acc
    batt        ?~(bat ~ `cen.u.bat)
    bs          ?~(bat %unknown ?-(sat.u.bat %idk %unknown, %run %unplugged, %cha %charging, %ful %full))
    lat         lat
    lon         lon
    t           `%c
    tid         'should-be-ignored'
    tst         tst
    topic       '/should/be/ignored'
    created-at  `tst
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
  =+  img=(fall (~(get cy:co con) %avatar %look) '')
  ?.  =('' img)
    ::TODO  really should make these requests through paldev as a
    ::      service provider, to prevent clearweb abuse...
    %^  cat  3
      'https://pal.dev/aides/owntracks/avatar?url='
    =,  mimes:html
    (~(en base64 pad=| url=&) (as-octs img))
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
::
++  put-contact-card
  |=  $:  cars=(map @p [name=@t face=[url=@t dat=(unit octs)]])
          [who=@p nom=@t img=@t]
      ==
  ^-  [[new=? req=?] _cars]
  =/  had=[name=@t face=[url=@t dat=(unit octs)]]
    (~(gut by cars) who '' ['' ~])
  ::  the change is only news if the name changed, which we can share right
  ::  away. if the img changed, it must be requested before we can send it
  ::  out. receiving the matching response will mark it as news.
  ::
  :-  :-  new=!=(name.had nom)
      req=!=(url.face.had img)
  %+  ~(put by cars)  who
  :-  nom
  ::  if the url changed, we will change the url in state, (and caller must
  ::  make a request,) but keep the old octs for now. this means that the octs
  ::  in state could be stale/mismatching the url.
  ::  we do this so that clients connecting while a request is outstanding
  ::  will still get a display image if we had one previously.
  ::
  ?:  =(url.face.had img)
    face.had
  [img dat.face.had]
::
++  request-face
  |=  [who=@p img=@t]
  ^-  card
  =-  [%pass /card/(scot %p who)/face/(scot %t img) %arvo %i -]
  [%request [%'GET' img ~ ~] *outbound-config:iris]
::
++  find-zones
  |=  $:  zones=(map @da zone)
          [lat=@rd lon=@rd]
      ==
  ^-  (set @da)
  %-  sy
  %+  murn  ~(tap by zones)
  =/  distance
    (cury distance:spots [lat lon])
  |=  [wid=@da zon=zone]
  ^-  (unit _wid)
  =;  in=?  ?:(in `wid ~)
  =,  rd:math
  %+  lte
    %+  mul  .~1000  ::  km ->  m
    (distance [lat lon]:zon)  ::  km
  (sun rad.zon)  ::  m
::
++  extract-request
  |=  [=header-list:http body=(unit octs)]
  ^-  %+  each
        ::  valid, containing any of:
        ::
        $:  auth=[user=@t pass=@t]
            did=@t
            mes=(unit message:ot)
        ==
      ::  invalid, due to:
      ::
      ?(%no-auth %no-device-id %bad-body)
  =/  auth
    %+  biff
      (get-header:http 'authorization' header-list)
    extract-basic:header-auth
  ?~  auth  |+%no-auth
  ?~  did=(get-header:http 'x-limit-d' header-list)
    |+%no-device-id
  =/  mes=(unit (unit message:ot))
    ?~  body  `~
    ?~  jon=(de:json:html q.u.body)  ~
    ?~  mes=(message:dejs:ot u.jon)  ~
    `mes
  ?~  mes  |+%bad-body
  &+[u.auth u.did u.mes]
::
::TODO  systematize
++  store  ::  set cache entry
  |=  [url=@t entry=(unit cache-entry:eyre)]
  ^-  card:agent:gall
  [%pass /eyre/cache %arvo %e %set-response url entry]
--
::
%-  agent:dbug
%+  verb  |
::
=|  state-3
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
      =?  old  ?=(%1 -.old)  (state-1-to-2 old)
      =?  old  ?=(%2 -.old)  (state-2-to-3 old)
      ?>  ?=(%3 -.old)
      [~ this(state old)]
  ::
  +$  state-any  $%(state-0 state-1 state-2 state-3)
  ::
  +$  state-2
    $:  %2
        mine=(map @t device)  ::TODO  card override
        ways=(map @da zone)
        news=(jug @t news-key)
        cars=(map @p [name=@t face=[url=@t dat=(unit octs)]])
        auth=@t
        open=(map @ta [did=@t fro=@da til=(unit @da)])
        hunt=(mip @p @t [now=(unit node) bat=(unit batt)])
        bait=(jug @p @t)
        line=(jug @t @p)
        dogs=(set @p)
    ==
  ::
  ++  state-2-to-3
    |=  state-2
    ^-  state-3
    [%3 mine ways news cars auth open pets=~ hunt bait line dogs]
  ::
  +$  state-1  _%*(. *state-2 - %1)
  ::
  ++  state-1-to-2
    |=  s=state-1
    ^-  state-2
    ::  clean up erroneously acquired cards
    ::
    %=  s  -  %2
      cars  (my (skim ~(tap by cars.s) |=([who=@p *] (~(has by hunt.s) who))))
    ==
  ::
  +$  state-0   $_  %*  .  *state-1  -  %0
                  mine  *(map @t device-0)
                  hunt  *(mip @p @t [now=(unit node-0) bat=(unit batt)])
                ==
  +$  device-0  _%*(. *device log *(list node-0))
  +$  node-0    _%*(. *node alt *(unit @ud))
  ::
  ++  state-0-to-1
    |=  s=state-0
    ^-  state-1
    %=  s  -  %1
      mine  (~(run by mine.s) |=(d=device-0 d(log (turn log.d node-0-to-1))))
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
    ::TODO  tmp backcompat, removeme
    ::
      [%kill did=@t]  (on-poke %spots-action !>(`action`q.vase))
      [%set-auth @t]  (on-poke %spots-action !>(`action`q.vase(- %auth)))
      [%hunt who=@p]  (on-poke %spots-action !>(`action`q.vase))
    ::
        [%share key=(unit @ta) did=@t for=(unit @dr)]
      (on-poke %spots-action !>(`action`q.vase(- %open)))
    ::
        [%bait who=@p did=@t show=?]
      (on-poke %spots-action !>(`action`q.vase))
    ==
  ::
    ::  %spots-action: user actions
    ::
      %spots-action
    =+  !<(act=action vase)
    ?-  -.act
      %auth  [~ this(auth new.act)]
      %kill  [~ this(mine (~(del by mine) did.act))]
    ::
        %open
      =/  key=@ta
        ?^  key.act  u.key.act
        |-
        =+  k=(crip ((v-co:^co 12) (end 0^60 eny.bowl)))
        ?.  (~(has by open) k)  k
        $(eny.bowl (shas %next eny.bowl))
      ?:  =(for.act `~s0)
        ::NOTE  could un-set the potential timer, but doesn't really matter...
        [~ this(open (~(del by open) key))]
      =.  open
        %+  ~(put by open)  key
        :+  did.act  now.bowl
        ?~  for.act  ~
        `(add now.bowl u.for.act)
      :_  this
      ?~  for.act  ~
      ::NOTE  generic expiry wire, +on-arvo just checks all of .open
      [%pass /open/expire %arvo %b %wait (add now.bowl u.for.act)]~
    ::
        %hunt
      =*  who  who.act
      =.  hunt
        %+  ~(put by hunt)  who
        (~(gut by hunt) who ~)
      ::  make sure we have latest profile card details. this is potentially
      ::  redundant, but simplifies the logic. we don't want to add muddy
      ::  existence check semantics onto .cars entries.
      ::
      =/  [nom=@t img=@t]
        %+  contact-to-card  who
        ?.  .^  ?  %gu
              (scot %p our.bowl)  %contacts  (scot %da now.bowl)
              /v1/contact/(scot %p who)
            ==
          *contact:co
        .^  contact:co  %gx
          (scot %p our.bowl)  %contacts  (scot %da now.bowl)
          /v1/contact/(scot %p who)/contact-1
        ==
      =^  [new=? req=?]  cars
        (put-contact-card cars who nom img)
      ::  it's a new addition, always put it into news,
      ::  and always re-fetch the avatar, even if nothing changed.
      ::  this lets the hunt command be used as a "force re-card" tool.
      ::  (see also comment about redundancy & simplicity above.)
      ::
      =.  news
        ::TODO  dedupe with %contact-response-0 fact handling?
        %^  put-news  news
          ~(key by mine)
        [%hunt-card who ~(key by (~(gut by hunt) who ~))]
      :_  this
      :~  [%pass /hunt %agent [who dap.bowl] %watch /live/(scot %p our.bowl)]
          (request-face who img)
      ==
    ::
        %bait
      ?.  show.act
        :_  %_  this
              bait  (~(del ju bait) [who did]:act)
              line  (~(del ju line) [did who]:act)
            ==
        =/  upd=live-update  [did.act ~ ~]
        [%give %fact [/live/(scot %p who.act)]~ %spots-live-update !>(upd)]~
      :_  %_  this
            bait  (~(put ju bait) [who did]:act)
            line  (~(put ju line) [did who]:act)
          ==
      ?~  dev=(~(get by mine) did.act)  ~
      =/  upd=live-update  [did.act ?~(log.u.dev ~ `i.log.u.dev) bat.u.dev]
      [%give %fact [/live/(scot %p who.act)]~ %spots-live-update !>(upd)]~
    ::
        %pets
      =-  [~ this(pets -)]
      ?.  (~(has by pets) id.act)
        (~(put by pets) id.act %*(. *bevy desc desc.act))
      (~(jab by pets) id.act |=(b=bevy b(desc desc.act)))
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =+  !<(order:rudder vase)
    ~&  [dap.bowl %request url.request]
    ?.  =(url.request (rap 3 '/' dap.bowl '/post' ~))
      =/  =query:rudder  (purse:rudder url.request)
      ::TODO  integrate club requests properly. probably want to refactor
      ::      request handling in general.
      ?:  ?=([%spots %club @ *] site.query)
        =*  bid  i.t.t.site.query
        =*  fof
          :_  this
          (spout:rudder id (issue:rudder 404 ~))
        ?.  (~(has by pets) bid)  fof
        =/  =bevy  (~(got by pets) bid)
        ::
        ?+  t.t.t.site.query  fof
            [%post ~]
          =/  req
            (extract-request [header-list body]:request)
          ?:  ?=(%| -.req)
            :_  this
            %+  spout:rudder  id
            %-  issue:rudder
            ?-  p.req
              %no-auth       [403 'unauthorized']
              %no-device-id  [400 'no device id']
              %bad-body      [400 'bunk payload']
            ==
          =,  p.req
          ::  check provided auth.
          ::  first usage of a username gets to set the password.
          ::
          =*  fot  [(spout:rudder id (issue:rudder 403 'unauthorized')) this]
          ?~  auth  fot
          =?  bums.bevy  !(~(has by bums.bevy) user.auth)
            ::NOTE  ok to bunt node, this request _should_ set it
            (~(put by bums.bevy) user.auth ['' pass.auth *node ~])
          =/  bum  (~(got by bums.bevy) user.auth)
          ?.  =(pass.auth pas.bum)  fot
          ::  we will always produce at least a 200 response
          ::
          =/  caz=(list card)
            %^  spout:rudder  id
              [200 ['content-type' 'application/json']~]
            ::TODO  send news
            `(as-octs:mimes:html '[]')
          ::  at the end, we must always put the bum/bevy back into state.
          ::  any code below calling "this" instead of "done" is erroneous!
          ::
          =*  done
            =.  bums.bevy  (~(put by bums.bevy) user.auth bum)
            =.  pets       (~(put by pets) bid bevy)
            [caz this]
          ::  set display name from device id
          ::
          =.  nom.bum
            ::TODO  news if it changes?
            %+  fall
              (get-header:http 'x-limit-d' header-list.request)
            user.auth
          ::
          ?~  mes.p.req  done
          ?.  ?=(%location -.u.mes.p.req)  done
          =.  now.bum
            ^-  node
            ~!  u.mes
            =,  u.mes
            :-  [lat lon acc [alt vac]]
            [[tst (fall created-at tst)] vel]
          =.  bat.bum
            (make-batt:spots [batt bs]:u.mes)
          ::TODO  put news if it changes
          ::  put the new view.json into cache,
          ::  since clients will be polling for that
          ::
          =.  caz
            %+  snoc  caz
            %+  store  (rap 3 '/spots/club/' bid '/view.json' ~)
            %+  some  |
            :-  %payload
            :-  [200 ['content-type' 'application/json']~]
            %.  (~(put by bums.bevy) user.auth bum)
            :(cork bums:enjs:spots en:json:html as-octs:mimes:html some)
          done
        ::
            [%view ~]
          :_  this
          ?:  ?=([~ %json] ext.query)
            %+  spout:rudder  id
            :-  [200 ['content-type' 'application/json']~]
            %.  bums.bevy
            :(cork bums:enjs:spots en:json:html as-octs:mimes:html some)
          (spout:rudder id (paint:rudder (club bid bevy)))
        ::
            [%setup ~]
          :_  this
          %+  spout:rudder  id
          %-  paint:rudder
          %+  club-setup
            [src.bowl secure (need (get-header:http 'host' header-list.request)) eny.bowl]
          [bid bevy]
        ::
            [%nuke ~]
          =+  uid=(scot %p src.bowl)
          ?.  (~(has by bums.bevy) uid)
            :_  this
            (spout:rudder id [200 ~] `(as-octs:mimes:html 'non-existent'))
          =.  bums.bevy  (~(del by bums.bevy) uid)
          =.  pets  (~(put by pets) bid bevy)
          :_  this
          (spout:rudder id [200 ~] `(as-octs:mimes:html 'removed!'))
        ==
      ::
      :_  this
      %+  spout:rudder  id
      ?.  |(=(src our):bowl ?=([%spots %share *] site.query))
        (paint:rudder %auth url.request)
      ?+  site.query  (issue:rudder 404 ~)
          [%spots ~]
        =;  setup=@t
          (paint:rudder (home bowl mine auth open hunt line dogs setup))
        %-  config-url:ot
        =/  name=@t
          ?.  (~(has by mine) 'phone')  'phone'
          =/  n=@ud  2
          |-
          =/  t=@t  (cat 3 'phone ' (crip (a-co:^co n)))
          ?.  (~(has by mine) t)  t
          $(n +(n))
        =/  url=@t
          %+  rap  3
          :~  ?:(secure 'https://' 'http://')
              (fall (get-header:http 'host' header-list.request) '')
              '/spots/post'
          ==
        %-  ~(gas by *(map @t json))
        :~  :-  '_type'         s+'configuration'
            :-  'auth'          b+&
            :-  'cmd'           b+&
            :-  'deviceId'      s+name
            :-  'extendedData'  b+&
            :-  'mode'          n+'3'  ::  http mode
            :-  'password'      s+auth
            :-  'tid'           :-  %s  ::NOTE  somewhat unnecessary
                                =+  wot=(scot %p our.bowl)
                                ?:  (lte (met 3 wot) 4)
                                  (cut 3 1^2 wot)
                                (cat 3 (cut 3 1^1 wot) (cut 3 4^1 wot))
            :-  'url'           s+url
            :-  'username'      s+(scot %p our.bowl)
            ::TODO  include waypoints?
        ==
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
          ?~  log.u.dev  ~
          =+  i.log.u.dev
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
    =/  req
      (extract-request [header-list body]:request)
    ::  check auth validity
    ::
    =?  req  &(?=(%& -.req) !=(auth.p.req [(scot %p our.bowl) auth]))
      [%| %no-auth]
    ?:  ?=(%| -.req)
      :_  this
      %+  spout:rudder  id
      ?-  p.req
        %no-auth       [[403 ~] `(as-octs:mimes:html 'unauthorized')]
        %no-device-id  [[400 ~] `(as-octs:mimes:html 'no device id')]
        %bad-body      [[400 ~] `(as-octs:mimes:html 'bunk payload')]
      ==
    =+  mes=mes.p.req
    =+  did=did.p.req
    ::  if this device is new, everything is news to it
    ::
    =?  news  !(~(has by mine) did)
      ::  everything is news to it, generate a set of news-keys for this
      ::  device based on everything we have in state, and request that they
      ::  send us waypoints/zones if they have any
      ::
      %+  ~(put by news)  did
      =;  nes
        %-  ~(gas in nes)
        :~  [%send-ways ~]
            [%ways ~(key by ways)]
        ==
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
      %-  some
      %-  as-octs:mimes:html
      %-  en:json:html
      %-  responses:enjs:ot
      %+  murn  ~(tap in (~(get ju news) did))
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
      ::
          %ways
        ?:  =(~ waz.k)  ~
        %-  some
        :+  %cmd
          %set-waypoints
        %+  murn  ~(tap in waz.k)
        |=  wid=@da
        ^-  (unit waypoint:ot)
        ?~  way=(~(get by ways) wid)  ~
        %-  some
        :*  desc=nom.u.way
            `lat.u.way
            `lon.u.way
            `rad.u.way
            tst=wid
            uuid=~
            major=~
            minor=~
            rid=~
        ==
      ::
          %send-ways
        `[%cmd %waypoints ~]
      ==
    =.  news
      (~(del by news) did)
    ?~  mes  [caz this]
    ::NOTE  take care to include .caz in every product!
    |-  ^+  [caz this]
    ?+  -.u.mes  [caz this]
        %location
      ~&  [%location tid=tid.u.mes topic=topic.u.mes did=did tst=tst.u.mes ca=created-at.u.mes]
      =/  dev
        (~(gut by mine) did *device)
      =/  had=[(unit node) (unit batt)]
        [?~(log.dev ~ `i.log.dev) bat.dev]
      ::TODO  add it as news to all our other devices
      =.  log.dev
        =/  new=node
          =,  u.mes
          :-  [lat lon acc [alt vac]]
          [[tst (fall created-at tst)] vel]
        |-  ^+  log.dev
        ?~  log.dev  [new]~
        ::  once we've moved to the right place in history, store the node
        ::
        ?:  (gte msg.wen.new msg.wen.i.log.dev)
          ::  if the new node is identical, skip it entirely
          ::
          ?:  =(new i.log.dev)  log.dev  ::NOTE  odd case, but happens in practice
          ::  if the gps data is different, store as-is
          ::
          ?.  =(-.new -.i.log.dev)  [new log.dev]
          ::  if the gps data is the same, only keep oldest & newest
          ::
          ?~  t.log.dev  [new log.dev]
          ?.  =(-.new -.i.t.log.dev)  [new log.dev]
          ::  so, here, replace latest with this new one
          ::NOTE  assumes most-recently-processed is newer
          ::TODO  should we set velocity in latest to zero? looks like vel
          ::      might be sticky in stale/reused gps fixes
          ::
          [new t.log.dev]
        [i.log.dev $(log.dev t.log.dev)]
      =.  bat.dev
        (make-batt:spots [batt bs]:u.mes)
      ::TODO  want to factor out zone status logic once they support foreign devices too
      ::  trigger zone diffs
      ::
      =/  now-zones
        (find-zones ways [lat lon]:(snag 0 log.dev))
      =/  new-zones=(set @da)
        (~(dif in now-zones) now.dev)
      =/  gone-zones=(set @da)
        (~(dif in now.dev) now-zones)
      ::  update zone state to reflect device change
      ::
      =.  now.dev  now-zones
      =?  ways  |(!=(~ new-zones) !=(~ gone-zones))
        %-  ~(urn by ways)
        |=  [wid=@da =zone]
        ?:  (~(has in new-zones) wid)
          zone(now (~(put in now.zone) did))
        ?:  (~(has in gone-zones) wid)
          zone(now (~(del in now.zone) did))
        zone
      ::
      :-  ;:  weld
            caz
            ::  zone leave notifications
            ::
            %+  turn  ~(tap in gone-zones)
            (curr send-zone [[our.bowl did] %leave])
          ::
            ::  zone enter notifications
            ::
            %+  turn  ~(tap in new-zones)
            (curr send-zone [[our.bowl did] %enter])
          ::
            ::  location update, if location changed
            ::
            ^-  (list card)
            =/  new  [`(snag 0 log.dev) bat.dev]
            ?:  =(had new)  ~
            [(send-live (~(get ju line) did) did new)]~
          ==
      ::  finalize
      ::
      this(mine (~(put by mine) did dev))
    ::
        %waypoint
      ::TODO  if we already have a waypoint with this id, check for changes.
      ::      if it truly changed, re-run zone-presence checks for devices.
      =.  news
        ::TODO  doesn't dedupe cleanly, ideally want them all in a single %ways,
        ::      but these commands are additive, so nbd
        (put-news news ~(key by mine) [%ways tst.u.mes ~ ~])
      ::TODO  do we need to clearWaypoints to propagate deletions?
      ::      if we don't do that, waypoints might be annoying to delete in
      ::      multi-device setups...
      :-  caz
      ?.  &(?=(^ lat.u.mes) ?=(^ lon.u.mes) ?=(^ rad.u.mes))
        ~&  [%unsupported-waypoint u.mes]
        this
      ::NOTE  we ignore rid.u.mes. it's not consistently set, and we don't
      ::      care about its presence in inrids (or inregions) in %location
      ::      messages, since we calculate region/zone presence by hand
      this(ways (~(put by ways) tst.u.mes [desc [u.lat u.lon u.rad] ~]:u.mes))
    ::
        %waypoints
      |-  ^+  [caz this]
      ?~  +.u.mes  [caz this]
      =^  cas  this  ^$(u.mes [%waypoint i.u.mes])
      =.  caz  (weld caz cas)
      $(+.u.mes t.u.mes)
    ::
        %transition
      ::NOTE  we intentionally don't update zone presence state in response
      ::      to these, instead relying on locally-calculated zone presence.
      ::      this is more reliable and flexible.
      ~&  [%transition did=did]
      =/  dev
        (~(gut by mine) did *device)
      =/  stale=?
        ?|  ?=(~ log.dev)
            (gth (sub tst.u.mes msg.wen.i.log.dev) stale:config)
        ==
      ?-  event.u.mes
          %enter
        ::  if the device location is stale, and we know the zone that it
        ::  entered, treat this as a normal location update (with a potentially
        ::  large accuracy radius)
        ::
        ?.  ?&(stale (~(has by ways) wtst.u.mes))
          [caz this]
        =/  =zone  (~(got by ways) wtst.u.mes)
        =;  loc=location:ot
          ~&  %pretending-transition-is-location
          $(u.mes [%location loc])
        =,  u.mes
        %:  make-fake-zone-location
          (fall lat lat.zone)   ::NOTE  this behaves Very Bad if client misbehaves
          (fall lon lon.zone)   ::NOTE  "
          ?~(lat rad.zone acc)  ::NOTE  "
          tst
          bat.dev
        ==
      ::
          %leave
        ::  if the device location is stale, treat this as a location update
        ::  if the message has coordinates, or simply clear outward-presenting
        ::  location status if it doesn't
        ::
        ?.  stale  [caz this]
        ?.  &(?=(^ lat.u.mes) ?=(^ lon.u.mes))
          ::TODO  update zone presence state even though location didn't change?
          [[(send-live (~(get ju line) did) did ~ bat.dev) caz] this]
        =;  loc=location:ot
          ~&  %pretending-transition-is-location
          $(u.mes [%location loc])
        =,  u.mes
        (make-fake-zone-location u.lat u.lon acc tst bat.dev)
      ==
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
        ?~(log.u.dev ~ `i.log.u.dev)
      bat.u.dev
    `[%give %fact ~ %spots-live-update !>(upd)]
  ::
      [%zone @ ~]
    ?>  =(our src):bowl
    =/  wid=@da  (slav %da i.t.path)
    =/  =zone  (~(gut by ways) wid *zone)
    :_  this
    %+  turn  ~(tap in now.zone)
    |=  did=@t
    =/  upd=zone-update  [[our.bowl did] %enter]
    [%give %fact ~ %spots-zone-update !>(upd)]
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
      ::  simply let them sit silently until we get permission on something.
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
        !!  ::TODO  nop, it's safer (prevents resubscribe situations) right?
      =+  !<(live-update q.cage.sign)
      =.  hunt  (~(put bi hunt) src.bowl did now bat)
      ::  the data changed, which means there's news for each of our devices
      ::
      =?  news  ?=(^ now)  ::TODO  should push device deletion?
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
    =*  who  who.u.pro
    ::  if we aren't tracking this peer, we don't need to generate a card
    ::
    ?.  (~(has by hunt) who)
      [~ this]
    =/  [nom=@t img=@t]
      (contact-to-card u.pro)
    ::  always update the entry in .cars
    ::
    =^  [new=? req=?]  cars
      (put-contact-card cars who nom img)
    ::  if anything changed, generate the relevant news and queue it up
    ::  for all our devices
    ::
    =?  news  new
      %^  put-news  news
        ~(key by mine)
      [%hunt-card who ~(key by (~(gut by hunt) who ~))]
    :_  this
    ::  if we must request a new image, do so
    ::
    ?.  req
      ~
    [(request-face who img)]~
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
      [%open %expire ~]
    ::  presumably, some .open entry just expired,
    ::  clean up _all_ .open entries that are past their expiry date.
    ::
    ?>  ?=([%behn %wake *] sign)
    ?^  error.sign
      ::  we're fine to just defer to the next activation,
      ::  stale entries aren't the end of the world
      ::
      %-  (slog 'spots: failed to expire .open' u.error.sign)
      [~ this]
    =-  [~ this(open -)]
    %-  my
    %+  skip  ~(tap by open)
    |=  [* @t @da til=(unit @da)]
    ?~(til | (gth now.bowl u.til))
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
      [[(request-face who url)]~ this]
    ::
    ?>  ?=(%finished -.res)
    ?:  !=(200 status-code.response-header.res)
      ~&  [dap.bowl %failed-to-load-image status-code.response-header.res url]
      [~ this]
    ?~  full-file.res
      ~&  [dap.bowl %strange-no-image-body url]
      [~ this]
    ::  put the image into state, update the news
    ::REVIEW  what if octs are the same? still news?
    ::
    =.  cars
      %+  ~(jab by cars)  who
      |=  [name=@t [url=@t dat=(unit octs)]]
      ~?  !=(url ^url)  %face-shouldnt-care
      [name [url `data.u.full-file.res]]
    =.  news
      %^  put-news  news
        ~(key by mine)
      [%hunt-card who ~(key by (~(gut by hunt) who ~))]
    ::TODO  subscription update?
    [~ this]
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
      [%x %dbug %state ~]
    :^  ~  ~  %noun  !>
    =-  state(cars (~(run by cars) -))
    |=  [name=@t face=[url=@t dat=(unit octs)]]
    :-  name
    ?~  dat.face  face
    face(q.u.dat 1.337)
  ::
      [%x %whey ~]
    :^  ~  ~  %mass
    !>  ^-  (list mass)
    :~  'mine'^&+mine
        'cars'^&+cars
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
