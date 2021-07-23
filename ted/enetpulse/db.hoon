::  enetpulse/update: (partially) rebuild local database
::
::TODO  app should run this fully once a day, always uni old with new events
::      set timer for very next event, post about all recent events when fires
::
::TODO  should collapse events with identical names/descriptions into one,
::      if they're very close to each other in time?
::
::TODO  get end times from events, then check results for result_typeFK="501"
::      where value contains medal
::
::TODO  just use (om so):dejs for parsing? it's all strings, so...
::
/-  *enetpulse
/+  strandio
::
=/  testing=(unit @da)  ~  ::`~2016.7.4
=/  start-date=@da  ~2021.7.20
::
|=  args=vase
=+  !<([~ db=full-db] args)
=/  m  (strand:strandio ,vase)  ::  full-db
|^
  ;<  templates=templates-db  bind:m
    =/  m  (strand:strandio templates-db)
    ?^  templates.db  (pure:m templates.db)
    ~&  [%fetching-templates sports=~(wyt by sports)]
    (fetch-all-templates ~(tap in ~(key by sports)))
  =.  templates.db  templates
  ::
  ;<  tourneys=tourneys-db  bind:m
    =/  m  (strand:strandio tourneys-db)
    ?^  tourneys.db  (pure:m tourneys.db)
    ~&  [%fetching-tourneys templates=~(wyt by templates)]
    (fetch-all-tourneys ~(tap by templates))
  =.  tourneys.db  tourneys
  ::
  ;<  stages=stages-db  bind:m
    =/  m  (strand:strandio stages-db)
    ?^  stages.db  (pure:m stages.db)
    ~&  [%fetching-stages tourneys=~(wyt by tourneys)]
    (fetch-all-stages ~(tap by tourneys))
  =.  stages.db  stages
  ::
  ;<  events=events-db  bind:m
    =/  m  (strand:strandio events-db)
    ?^  events.db  (pure:m events.db)
    ~&  [%fetching-events stages=~(wyt by stages)]
    ::TODO  cut off everything before ~2021.7.20
    (fetch-all-events ~(tap by stages))
  =.  events.db  events
  ::
  (pure:m !>(`full-db`[templates tourneys stages events]))
::
::
++  fetch-all-events
  |=  sas=(list [stid=@t name=@t gene=gender toid=@t])
  =|  res=events-db
  =/  m  (strand:strandio events-db)
  |-  ^-  form:m
  ?~  sas  (pure:m res)
  =*  next  $(sas t.sas)
  =,  i.sas
  ;<  ves=(list [evid=@t when=@da name=@t round=@t])  bind:m
    (fetch-events stid)
  ?:  =(~ ves)
    :: ~&  [%no-events-for stid name (~(got by sports) spid:(~(got by templates.db) teid:(~(got by tourneys.db) toid)))]
    next
  =.  res
    |-
    ?~  ves  res
    =,  i.ves
    =.  res  (~(put by res) evid name round when stid)
    $(ves t.ves)
  ;<  ~  bind:m
    (sleep:strandio ~s0..5000)
  next
::
++  fetch-events
  |=  stid=@t
  =*  x  %fetch-stages
  =/  m  (strand:strandio ,(list [evid=@t wen=@da name=@t round=@t]))
  ;<  now=@da   bind:m  get-time:strandio
  ;<  jon=json  bind:m
    %-  fetch  ^~
    %-  zing
    :~  "/event/list/"
        "?includeEventProperties=yes"
        "&tf=U"
        "&tournament_stageFK={(trip stid)}"
    ==
  ?.  ?=([%o *] jon)
    ~&  [%res-not-obj x stid jon]
    (pure:m ~)
  ?.  (~(has by p.jon) 'events')
    ~&  [%res-weird-keys x stid ~(key by p.jon)]
    (pure:m ~)
  =+  jon=(~(got by p.jon) 'events')
  ?.  ?=([%o *] jon)
    :: ~&  [%res-res-not-obj x stid jon]
    (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap by p.jon)
  |=  [key=@t jon=json]
  ^-  (unit [@t @da @t @t])
  ?.  ?=([%o *] jon)
    ~&  [%res-res-res-not-obj x stid key]
    ~
  ~|  [%fev key jon]
  =;  [evid=@t when=@da nom=@t]
    ?:  &(?=(^ testing) (lth when u.testing))
      ~
    ?:  &(?=(~ testing) (lth when start-date))
      ~
    =-  `[evid when nom -]
    ?~  prop=(~(got by p.jon) 'property')  ''
    ?.  ?=([%o *] prop)  ''
    %+  roll  ~(tap by p.prop)
    |=  [[@t jon=json] out=@t]
    ?.  =('' out)  out
    =/  [name=@t value=@t]
      =,  dejs:format
      %.  jon
      (ot 'name'^so 'value'^so ~)
    ?:(=('Round' name) value '')
  :+  key
    %.  (~(got by p.jon) 'startdate')
    %+  cu:dejs:format  ::TMP  for live testing on old data
      ?~  testing
        same
      |=  when=@da
      ?:  (lth when u.testing)  when
      %+  add  now
      %+  add  ~m5
      %+  mul  ~s5
      (div (sub when u.testing) ~h1)
    %-  su:dejs:format
    (cook from-unix:chrono:userlib dum:ag)
  (so:dejs:format (~(got by p.jon) 'name'))
::
++  fetch-all-stages
  |=  tos=(list [toid=@t name=@t teid=@t])
  =|  res=stages-db
  =/  m  (strand:strandio stages-db)
  |-  ^-  form:m
  ?~  tos  (pure:m res)
  =*  next  $(tos t.tos)
  =,  i.tos
  ;<  sas=(list [stid=@t gender=@t name=@t])  bind:m
    (fetch-stages toid)
  ?:  =(~ sas)
    :: ~&  [%no-stages-for toid name]
    next
  =.  res
    |-
    ?~  sas  res
    =.  res
      %+  ~(put by res)  stid.i.sas
      [name.i.sas (parse-gender gender.i.sas) toid]
    $(sas t.sas)
  ;<  ~  bind:m
    (sleep:strandio ~s0..5000)
  next
::
++  fetch-stages
  |=  otid=@t
  =*  x  %fetch-stages
  =/  m  (strand:strandio ,(list [stid=@t gender=@t name=@t]))
  ;<  jon=json  bind:m
    (fetch "/tournament_stage/list/?tournamentFK={(trip otid)}")
  ?.  ?=([%o *] jon)
    ~&  [%res-not-obj x otid jon]
    (pure:m ~)
  ?.  (~(has by p.jon) 'tournament_stages')
    ~&  [%res-weird-keys x otid ~(key by p.jon)]
    (pure:m ~)
  =+  jon=(~(got by p.jon) 'tournament_stages')
  ?.  ?=([%o *] jon)
    :: ~&  [%res-res-not-obj x otid jon]
    (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap by p.jon)
  |=  [key=@t jon=json]
  ^-  (unit [@t @t @t])
  ?.  ?=([%o *] jon)
    ~&  [%res-res-res-not-obj x otid key]
    ~
  ~|  [%fso key jon]
  =/  res=[@t @t name=@t]
    :+  key
      (so:dejs:format (~(got by p.jon) 'gender'))
    (so:dejs:format (~(got by p.jon) 'name'))
  :: ?:  ?|  ?=(^ (find "Qualification" (trip name.res)))
  ::         ?=(^ (find "Placement" (trip name.res)))
  ::     ==
  ::   ~
  (some res)
::
++  fetch-all-tourneys
  |=  tes=(list [teid=@t name=@t gene=gender spid=@t])
  =|  res=tourneys-db
  =/  m  (strand:strandio tourneys-db)
  |-  ^-  form:m
  ?~  tes  (pure:m res)
  =*  next  $(tes t.tes)
  =,  i.tes
  ;<  tos=(list @t)  bind:m
    (fetch-tourneys teid)
  ?:  =(~ tos)
    ~&  [%no-tourneys-for teid name]
    next
  ~?  !=(1 (lent tos))
    [%unusual-amount-of-tourneys teid (lent tos)]
  =.  res
    |-
    ?~  tos  res
    =.  res  (~(put by res) i.tos name teid)
    $(tos t.tos)
  ;<  ~  bind:m
    (sleep:strandio ~s0..5000)
  next
::
++  fetch-tourneys
  |=  tempid=@t
  =*  x  %fetch-tourney
  =/  m  (strand:strandio ,(list @t))
  ;<  jon=json  bind:m
    (fetch "/tournament/list/?tournament_templateFK={(trip tempid)}")
  ?.  ?=([%o *] jon)
    ~&  [%res-not-obj x tempid jon]
    (pure:m ~)
  ?.  (~(has by p.jon) 'tournaments')
    ~&  [%res-weird-keys x tempid ~(key by p.jon)]
    (pure:m ~)
  =+  jon=(~(got by p.jon) 'tournaments')
  ?.  ?=([%o *] jon)
    :: ~&  [%res-res-not-obj x tempid jon]
    (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap by p.jon)
  |=  [key=@t jon=json]
  ^-  (unit @t)
  ?.  ?=([%o *] jon)
    ~&  [%res-res-res-not-obj x tempid key]
    ~
  ?.  (~(has by p.jon) 'name')
    ~&  [%res-no-name x tempid key]
    ~
  =+  nom=(so:dejs:format (~(got by p.jon) 'name'))
  ?:(|(=('2020' nom) =('2021' nom)) `key ~)  ::TODO  config
::
++  fetch-all-templates
  |=  spo=(list @t)
  =|  res=templates-db
  =/  m  (strand:strandio templates-db)
  |-  ^-  form:m
  ?~  spo  (pure:m res)
  =*  next  $(spo t.spo)
  ;<  tur=(list [teid=@t name=@t gender=@t])  bind:m
    (fetch-tourney-templates i.spo)
  =.  res
    |-
    ?~  tur  res
    =,  i.tur
    =.  res  (~(put by res) teid name (parse-gender gender) i.spo)
    $(tur t.tur)
  ;<  ~  bind:m
    (sleep:strandio ~s0..5000)
  next
::
++  parse-gender
  |=  gene=@t
  ^-  gender
  ?+  gene   %mixed
    %male    %male
    %female  %female
  ==
::
++  prefix-gender
  |=  [name=@t gender=@t]
  %^  cat  3
    ?+  gender  ''
      %male    'Men\'s '
      %female  'Women\'s '
    ==
  name
::
++  fetch-tourney-templates
  |=  sport=@t
  =*  x  %fetch-tourntemp
  =/  m  (strand:strandio ,(list [id=@t name=@t gender=@t]))
  ;<  jon=json  bind:m
    (fetch "/tournament_template/list/?sportFK={(trip sport)}")
  ?.  ?=([%o *] jon)
    ~&  [%res-not-obj x sport jon]
    (pure:m ~)
  ?.  (~(has by p.jon) 'tournament_templates')
    ~&  [%res-weird-keys x sport ~(key by p.jon)]
    (pure:m ~)
  =+  jon=(~(got by p.jon) 'tournament_templates')
  ?.  ?=([%o *] jon)
    :: ~?  !=([%a ~] jon)
      :: [%res-res-not-obj x sport jon]
    (pure:m ~)
  %-  pure:m
  %+  murn  ~(tap by p.jon)
  |=  [key=@t jon=json]
  ^-  (unit [_key @t @t])
  ?.  ?=([%o *] jon)
    ~&  [%res-res-res-not-obj x sport key]
    ~
  ?.  (~(has by p.jon) 'name')
    ~&  [%res-no-name x sport key]
    ~
  =+  nom=(so:dejs:format (~(got by p.jon) 'name'))
  ?~  (find "summer olympic" (cass (trip nom)))
    ~
  `[key nom (so:dejs:format (~(got by p.jon) 'gender'))]
::
++  fetch
  |=  target=tape
  ::TODO  if %o and has 'error_message'...
  (fetch-json:strandio (make-url target))
::
++  make-url
  |=  target=tape
  ;:  weld
    "http://eapi.enetpulse.com"
    target
    "&username=xx&token=xx"
  ==
::
++  sports  ^~
  %-  ~(gas by *(map @t @t))
  :~
    ['1' 'Soccer']
    ['2' 'Tennis']
    ['3' 'Golf']
    ['4' 'Athletics']
    ['5' 'Ice Hockey']
    ['6' 'Alpine']
    ['7' 'Biathlon']
    ['8' 'Bobsleigh']
    ['9' 'Cross Country Skiing']
    ['10' 'Curling']
    ['11' 'Figure Skating']
    ['12' 'Freestyle Skiing']
    ['13' 'Luge']
    ['14' 'Nordic Combined']
    ['15' 'Short Track Speed Skating']
    ['16' 'Skeleton']
    ['17' 'Ski Jumping']
    ['18' 'Snowboarding']
    ['19' 'Speed Skating']
    ['20' 'Handball']
    ['21' 'Test sport']
    ['22' 'Motorsports']
    ['23' 'Basketball']
    ['24' 'Am. Football']
    ['25' 'Bandy']
    ['26' 'Baseball']
    ['27' 'Beach volley']
    ['28' 'Floorball']
    ['29' 'Rugby Union']
    ['30' 'Cycling']
    ['31' 'Horse Racing']
    ['32' 'Archery']
    ['33' 'Badminton']
    ['34' 'Boxing']
    ['35' 'Canoeing']
    ['36' 'Diving']
    ['37' 'Equestrian']
    ['38' 'Fencing']
    ['39' 'Hockey']
    ['40' 'Gymnastics']
    ['41' 'Judo']
    ['42' 'Modern Pentathlon']
    ['43' 'Rowing']
    ['44' 'Sailing']
    ['45' 'Shooting']
    ['46' 'Swimming']
    ['47' 'Synchronised Swimming']
    ['48' 'Table Tennis']
    ['49' 'Taekwondo']
    ['50' 'Triathlon']
    ['51' 'Volleyball']
    ['52' 'Water Polo']
    ['53' 'Weight Lifting']
    ['54' 'Wrestling']
    ['55' 'Track Cycling']
    ['56' 'Mountain Bike']
    ['57' 'Softball']
    ['58' 'BMX']
    ['70' 'Reference Sport']
    ['72' 'Snooker']
    ['73' 'Cricket']
    ['74' 'Australian Football']
    ['75' 'Mixed Martial arts']
    ['76' 'Speedway']
    ['77' 'Darts']
    ['78' 'Futsal']
    ['79' 'E-sports']
    ['80' 'Rugby League']
    ['81' 'Bowls']
    ['82' 'Squash']
    ['83' 'Netball']
    ['84' 'Counter-Strike']
    ['85' 'Dota 2']
    ['86' 'Overwatch']
    ['87' 'Surfing']
    ['88' 'Skateboarding']
    ['89' 'Karate']
    ['90' 'Sport Climbing']
    ['91' 'FIFA']
    ['92' 'League of Legends']
    ['93' 'StarCraft 2']
    ['94' 'E-Motorsports']
    ['95' 'Virtual Basketball']
  ==
--
