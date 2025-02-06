::  owntracks: thin types & logic for json de/serialization
::
::    very thin layer on top of owntracks' api as documented on
::    https://owntracks.org/booklet/tech/json/
::
::    names/faces are copied directly from the json objects, with the exception
::    of underscores being replaced by hyphens.
::
::    for enums: if the api represents them as numbers we provide a $? union
::    of constant string representations. if the api represents them as single-
::    character strings, we provide a $? union of those strings.
::
::    tuple order respects the order in which elements and described in the
::    docs, which is mostly but not fully in alphabetical order.
::
!:
::TODO  look into using +mu, +re
=,  dejs-soft:format
|%
+$  message  ::TODO  fully support all message types
  $%  [%beacon json]
      [%card card]
      [%cmd json]
      [%configuration json]
      [%encrypted json]
      [%location location]
      ::  [%lwt json]  ::NOTE  mqtt only
      [%request json]
      [%status json]
      [%steps json]
      [%transition transition]
      [%waypoint waypoint]
      [%waypoints (list waypoint)]
  ==
::
+$  response  $+  owntracks-response
  $%  $>(?(%location %card %transition) message)
      [%cmd $>(?(%dump %report-location %report-steps %set-waypoints) cmd)]
  ==
::
+$  card
  $:  name=(unit @t)         ::  display name
      face=(unit octs)       ::  image data
      tid=@t                 ::  tracker id
  ==
::
+$  cmd
  $%  [%report-location ~]                  ::  trigger %location message
      [%report-steps from=(unit @da) to=(unit @da)]  ::  trigger %steps message
      [%dump ~]                             ::  trigger %configuration message
      [%status ~]                           ::  trigger %status message
      [%waypoints ~]                        ::  trigger %waypoints message
      [%clear-waypoints ~]                  ::  delete all waypoints
      [%set-configuration json]  ::TODO     ::  import configuration
      [%set-waypoints (list waypoint)]      ::  import waypoints
  ==
::
+$  location                                ::  _type=location
  $:  acc=(unit @ud)                        ::  accuracy (m) (if >0)
      alt=(unit @sd)                        ::  altitude (m)
      batt=(unit @ud)                       ::  battery %
      bs=?(%unknown %unplugged %charging %full)  :: battery status
      cog=(unit @ud)                        ::  course over ground (deg) (if >0)
      lat=@rd                               ::  latitude (deg)
      lon=@rd                               ::  longitude (deg)
      rad=(unit @ud)                        ::  radius around trigger region (m)
      t=(unit ?(%p %c %'C' %b %r %u %t %v)) ::  trigger/cause
      tid=@t                                ::  tracker id (optional in MQTT)
      tst=@da                               ::  gps fix timestamp
      vac=(unit @ud)                        ::  vertical accuracy (m) (if >0)
      vel=(unit @ud)                        ::  velocity (km/h) (if >0)
      p=(unit @rd)                          ::  barometric pressure (kpa)
      poi=(unit @t)                         ::  point of interest
      conn=(unit ?(%w %o %m))               ::  internet connectivity
      tag=(unit @t)                         ::  name of the tag
      topic=@t                              ::  publish topic (not in MQTT)
      inregions=(list @t)                   ::  list of regions device is in
      inrids=(list @t)                      ::  list of region ids device is in
      ssid=(unit @t)                        ::  wlan name
      bssid=(unit @t)                       ::  wlan mac
      created-at=(unit @da)                 ::  message creation timestamp
      m=(unit ?(%significant %move))        ::  monitoring mode
      id=(unit @t)                          ::  message identifier
  ==
::
+$  waypoint                                ::  _type=waypoint
  $:  desc=@t                               ::  region name
      lat=(unit @rd)                        ::  latitude (deg)
      lon=(unit @rd)                        ::  longitude (deg)
      rad=(unit @ud)                        ::  radius (m)
      tst=@da                               ::  creation timestamp
      uuid=(unit @t)                        ::  ble beacon uuid
      major=(unit @ud)                      ::  ble beacon major nr
      minor=(unit @ud)                      ::  ble beacon minor nr
      rid=(unit @t)                         ::  region id
  ==
::
+$  transition                              ::  _type=transition
  $:  wtst=@da                              ::  waypoint creation timestamp
      lat=(unit @rd)                        ::  latitude of transition (deg)
      lon=(unit @rd)                        ::  longitude of transition (deg)
      tst=@da                               ::  event timestamp
      acc=@ud                               ::  coordinate accuracy (m)
      tid=@t                                ::  tracker id (optional in MQTT)
      event=?(%enter %leave)                ::  transition event
      desc=(unit @t)                        ::  waypoint name
      t=(unit ?(%c %b %l))                  ::  event trigger
      rid=(unit @t)                         ::  region id
  ==
::
++  make-tid
  |=  [who=@p did=@t]
  ^-  @t
  ::TODO  prefix with a and d from ~adcdef-ghijkl
  ::TODO  '/' infix might give trouble. review once owntracks/android#1966 fixed
  (rap 3 (scot %p who) '---' did ~)
::
++  dejs
  |%
  ++  message
    |=  =json
    ^-  (unit ^message)
    %+  biff  ((ot '_type'^so ~) json)
    |=  typ=@t
    ^-  (unit ^message)
    ?+  typ  ~
      %beacon         `[%beacon json]
      %card           (bind (card json) (lead %card))
      %cmd            `[%cmd json]
      %configuration  `[%configuration json]
      %encrypted      `[%encrypted json]
      %location       (bind (location json) (lead %location))
      %request        `[%request json]
      %status         `[%status json]
      %steps          `[%steps json]
      %transition     (bind (transition json) (lead %transition))
      %waypoint       (bind (waypoint json) (lead %waypoint))
      %waypoints      (bind (waypoints json) (lead %waypoints))
    ==
  ::
  ++  card
    ^-  $-(json (unit ^card))
    %-  ut
    :~  :+  %|  'name'  so
        :+  %|  'face'  (ci ~(de base64:mimes:html | |) so)
        :+  %&  'tid'   so
        ::TODO  topic?
    ==
  ::
  ++  location
    ^-  $-(json (unit ^location))
    %-  ut
    :~  :+  %|  'acc'         ni
        :+  %|  'alt'         ns
        :+  %|  'batt'        ni
        :+  %&  'bs'          ::(cu |=(* %unknown) some) ::TODO  from int, ?(%unknown %unplugged %charging %full
                              =-  (ci - ni)
                              ~(get by (my 0^%unknown 1^%unplugged 2^%charging 3^%full ~))
        :+  %|  'cog'         ni
        :+  %&  'lat'         ne
        :+  %&  'lon'         ne
        :+  %|  'rad'         ni
        :+  %|  't'           (ci (soft ?(%p %c %'C' %b %r %u %t %v)) so)
        :+  %&  'tid'         so
        :+  %&  'tst'         du
        :+  %|  'vac'         ni
        :+  %|  'vel'         ni
        :+  %|  'p'           ne
        :+  %|  'poi'         so
        :+  %|  'conn'        (ci (soft ?(%w %o %m)) so)
        :+  %|  'tag'         so
        :+  %&  'topic'       so
        :+  %r  'inregions'   |=(j=(unit ^json) ?~(j `~ ((ar so) u.j)))
        :+  %r  'inrids'      |=(j=(unit ^json) ?~(j `~ ((ar so) u.j)))
        :+  %|  'ssid'        so
        :+  %|  'bssid'       so
        :+  %|  'created_at'  du
        :+  %r  'm'           =-  (curr biff (cu - ni))
                              ~(get by (my 1^%significant 2^%move ~))
        :+  %|  'id'          so
    ==
  ::
  ++  waypoints
    ^-  $-(json (unit (list ^waypoint)))
    (ot 'waypoints'^(ar waypoint) ~)
  ::
  ++  waypoint
    ^-  $-(json (unit ^waypoint))
    %-  ut
    :~  :+  %&  'desc'   so
        :+  %|  'lat'    ne
        :+  %|  'lon'    ne
        :+  %|  'rad'    ni
        :+  %&  'tst'    du
        :+  %|  'uuid'   so
        :+  %|  'major'  ni
        :+  %|  'minor'  ni
        :+  %|  'rid'    so
    ==
  ::
  ++  transition
    ^-  $-(json (unit ^transition))
    %-  ut
    :~  :+  %&  'wtst'   du
        :+  %|  'lat'    ne
        :+  %|  'lon'    ne
        :+  %&  'tst'    du
        :+  %&  'acc'    ni
        :+  %&  'tid'    so
        :+  %&  'event'  (ci (soft ?(%enter %leave)) so)
        :+  %|  'desc'   so
        :+  %|  't'      (ci (soft ?(%c %b %l)) so)
        :+  %|  'rid'    so
    ==
  --
::
++  enjs
  |%
  ++  responses
    |=  rez=(list ^response)
    a+(turn rez response)
  ::
  ++  response
    |=  res=^response
    ^-  json
    =,  enjs:format
    ?+  -.res  ~&([%todo-encode -.res] ~)
        %card
      %+  pairs  '_type'^s+'card'
      %-  opts
      :~  'name'^(bind name.res (lead %s))
          'face'^(bind face.res (cork ~(en base64:mimes:html | |) (lead %s)))
          'tid'^`s+tid.res
          ::TODO  topic?
      ==
    ::
        %location
      %+  pairs  '_type'^s+'location'
      %-  opts
      ^-  (list (pair @t (unit json)))
      ::NOTE  just what we get from $device
      ::TODO  everything else
      :~  'lat'^`(real lat.res)
          'lon'^`(real lon.res)
          'acc'^`(unit json)`(bind acc.res numb)
          'alt'^`(unit json)`(bind alt.res nimb)
          'vac'^`(unit json)`(bind vac.res numb)
          'tst'^`(sect tst.res)
          :: 'created_at'^(bind created-at.res sect)  ::TODO
          'vel'^(bind vel.res numb)
          'batt'^(bind batt.res numb)
          'bs'^`n+?-(bs.res %unknown ~.0, %unplugged ~.1, %charging ~.2, %full ~.3)
        ::
          'tid'^`s+tid.res
          'topic'^`s+topic.res
      ==
    ==
  ::
  ++  opts
    %+  curr  murn
    |=  (pair @t (unit json))
    ?~  q  ~
    (some p u.q)
  ::
  ++  real
    :(cork rlyd r-co:co crip (lead %n))
  --
::
::  new json helpers
::
::NOTE
++  ut  ::  object as partially unitizable tuple
  |*  wer=(pole [req=?(%& %| %r) cord fist])  ::NOTE  fake fist (;
  |=  jon=json
  ?.  ?=([%o *] jon)  ~
  =+  raw=((ut-raw wer) p.jon)
  ?.((za raw) ~ (some (zp raw)))
::
++  ut-raw  ::  object as partially unitizable tuple
  |*  wer=(pole [req=?(%& %| %r) cord fist])  ::NOTE  fake fist (;
  |=  jom=(map @t json)
  ?~  wer  ~
  :_  ((ut-raw +.wer) jom)
  =-  ~?  =(~ -)  ~[%ut-fail +<.-.wer]
      -
  %.  (~(get by jom) +<.-.wer)
  (?-(-.-.wer %& nd, %| mb, %r same) +>.-.wer)
::
++  mb  ::  +ut optional
  |*  f=fist
  |=  jun=(unit json)
  ?~  jun  [~ ~]
  =+  r=(f u.jun)
  ?~(r ~ [~ r])  ::  fail still means fail, not miss
::
++  nd  ::  +ut required
  |*  f=fist
  |=  jun=(unit json)
  ?~(jun ~ (f u.jun))
::
++  du  ::  second date  ::TODO  into dejs-soft
  (cu from-unix:chrono:userlib ni)
::
++  ns  ::  number as signed  ::TODO  into dejs-soft
  |=  jon=json
  ^-  (unit @s)
  ?.  ?=([%n *] jon)  ~
  %+  rush  p.jon
  %+  cook  new:si
  ;~(plug ;~(pose (cold %| (jest '-')) (easy %&)) dem)
::
++  nimb  ::  number from signed  ::TODO  into enjs
  |=  n=@sd
  ^-  json
  :-  %n
  %^  cat  3
    ?:((syn:si n) '' '-')
  (crip (a-co:co (abs:si n)))
--
