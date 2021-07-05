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
=/  testing=(unit @da)  ~ ::`~2016.7.4
::
|=  args=vase
=+  !<([~ db=full-db] args)
=/  m  (strand:strandio ,vase)  ::  full-db
|^
  ;<  templates=templates-db  bind:m
    =/  m  (strand:strandio templates-db)
    ?^  templates.db  (pure:m templates.db)
    ~&  [%fetching-templates sports=~(wyt by sports)]
    ::TODO  needs to build names from sports (this always "Summer Olympics")
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
  :: ~&  :-  %event-names
  ::   ^-  (list [@da @t])
  ::   =-  (sort - |=([[a=@da *] [b=@da *]] (lth a b)))
  ::   %+  turn  ~(tap by events)
  ::   |=  [evid=@t name=@t when=@da stid=@t]
  ::   :-  when
  ::   ^-  @t
  ::   =/  stage=[name=@t gene=gender toid=@t]
  ::     (~(got by stages) stid)
  ::   =/  sport=@t
  ::     %-  ~(got by sports)     =<  spid
  ::     %-  ~(got by templates)  =<  teid
  ::     %-  ~(got by tourneys)       toid.stage
  ::   =?  sport  ?=(~ (find "Olympic" (trip name.stage)))
  ::     name.stage  ::TODO  mistake? sucks for boxing, sailing etc
  ::   (rap 3 sport ': ' name ~)
  ::   ::TODO  if name contains men's or women's, leave as is
  ::   ::      if name contains male or female, replace with men's or women's
  ::   ::      if name contains neither, finds gender, prepend if necessary
  ::   ::TODO  maybe include stage name?
  :: ::
  :: (pure:m !>(`full-db`[templates tourneys stages events]))
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
    ~&  [%no-events-for stid name (~(got by sports) spid:(~(got by templates.db) teid:(~(got by tourneys.db) toid)))]
    next
  =.  res
    |-
    ?~  ves  res
    =,  i.ves
    =.  res  (~(put by res) evid name round when stid)
    $(ves t.ves)
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)
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
    ~&  [%res-res-not-obj x stid jon]
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
        ::TODO  drop events prior to ~2021.7.20
        same
      |=  when=@da
      ?:  (lth when u.testing)  when
      %+  add  now
      %+  add  ~m5
      %+  mul  ~m1
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
    ~&  [%no-stages-for toid name]
    next
  =.  res
    |-
    ?~  sas  res
    =.  res
      %+  ~(put by res)  stid.i.sas
      [name.i.sas (parse-gender gender.i.sas) toid]
    $(sas t.sas)
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)
  next
::
++  old-fetch-all-stages
  =/  otids=(list [tid=@t otid=@t sid=@t temp=@t])  ~(tap by tourney-codes)
  =|  res=(map @t [temp=@t (list [@t @t @t])])
  |-  ^-  form:m
  ?~  otids  (pure:m !>(res))
  =*  next  $(otids t.otids)
  =,  i.otids
  ;<  sas=(list [stid=@t gender=@t name=@t])  bind:m
    (fetch-stages otid)
  =.  res  (~(put by res) otid [temp sas])
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)
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
    ~&  [%res-res-not-obj x otid jon]
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
    (sleep:strandio ~s0..4000)
  next
::
++  old-fetch-all-tourneys
  =/  tes=(list [ted=@t sid=@t temp=@t])  ~(tap by tourney-templates)
  =|  res=(map @t [otid=@t sid=@t temp=@t])
  |-  ^-  form:m
  ?~  tes  (pure:m !>(res))
  =*  next  $(tes t.tes)
  =,  i.tes
  ;<  tos=(list @t)  bind:m
    (fetch-tourneys ted)
  ?:  =(~ tos)
    ~&  [%no-tourneys-for ted]
    next
  =.  res  (~(put by res) ted (snag 0 tos) sid temp)
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)
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
    ~&  [%res-res-not-obj x tempid jon]
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
    (sleep:strandio ~s0..4000)
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
++  old-fetch-all-tourney-templates
  =/  spo=(list [id=@t name=@t])  ~(tap by sports)
  =|  res=(map @t [sport=@t (list [tempid=@t name=@t gender=@t])])
  |-  ^-  form:m
  ?~  spo  (pure:m !>(res))
  =*  next  $(spo t.spo)
  ;<  tur=(list [@t @t @t])  bind:m
    (fetch-tourney-templates id.i.spo)
  =?  res  !=(~ tur)
    (~(put by res) id.i.spo [name.i.spo tur])
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)
  next
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
    ~&  [%res-res-not-obj x sport jon]
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
++  stages  ^~
  %-  ~(gas by *(map @t @t))  ::  stage-id to custom name
  :~
    :-  '864990'  'Women\'s Triathlon'
    :-  '864989'  'Men\'s Triathlon'
    :-  '864991'  'Triathlon'
    :-  '867080'  'Women\'s Surfing'
    :-  '867078'  'Men\'s Surfing'
    :-  '866808'  'Men\'s Volleyball (Final Stage)'
    :-  '866675'  'Men\'s Volleyball (Grp. B)'
    :-  '866674'  'Men\'s Volleyball (Grp. A)'
    :-  '865490'  'Men\'s Boxing (-81 kg)'
    :-  '865487'  'Men\'s Boxing (-69 kg)'
    :-  '865489'  'Men\'s Boxing (-75 kg)'
    :-  '865478'  'Men\'s Boxing (-52 kg)'
    :-  '865475'  'Women\'s Boxing (-69 kg)'
    :-  '865491'  'Men\'s Boxing (-91 kg)'
    :-  '865467'  'Women\'s Boxing (-60 kg)'
    :-  '865485'  'Men\'s Boxing (-63 kg)'
    :-  '865468'  'Women\'s Boxing (-75 kg)'
    :-  '865471'  'Women\'s Boxing (-57 kg)'
    :-  '865464'  'Women\'s Boxing (-51 kg)'
    :-  '865482'  'Men\'s Boxing (-57 kg)'
    :-  '865492'  'Men\'s Boxing (91+ kg)'
    :-  '865556'  'Women\'s Synchronised Swimming'
    :-  '872813'  'Men\'s Karate (Kumite -67 kg)'
    :-  '872814'  'Women\'s Karate (Kumite -55 kg)'
    :-  '872816'  'Men\'s Karate (Kumite -75 kg)'
    :-  '872818'  'Men\'s Karate (Kumite +75 kg)'
    :-  '872812'  'Women\'s Karate (Kata)'
    :-  '872815'  'Women\'s Karate (Kumite -61 kg)'
    :-  '872809'  'Men\'s Karate (Kata)'
    :-  '872817'  'Women\'s Karate (Kumite +61 kg)'
    :-  '865303'  'Equestrian'
    :-  '866633'  'Women\'s Soccer (Qualifiers Grp. B)'
    :-  '872063'  'Women\'s Soccer (Final Stage)'
    :-  '872061'  'Women\'s Soccer (Grp. E)'
    :-  '866632'  'Women\'s Soccer (Qualifiers Grp. A)'
    :-  '866637'  'Women\'s Soccer (Qualifiers Final Stage)'
    :-  '872059'  'Women\'s Soccer (Grp. F)'
    :-  '872060'  'Women\'s Soccer (Grp. G)'
    :-  '872066'  'Women\'s Handball (Final Stage)'
    :-  '872065'  'Women\'s Handball (Grp. B)'
    :-  '872064'  'Women\'s Handball (Grp. A)'
    :-  '864431'  'Women\'s Badminton (Final Stage, Female Single)'
    :-  '864432'  'Men\'s Badminton (Final Stage, Male Double)'
    :-  '864434'  'Badminton (Final Stage, Mixed Double)'
    :-  '864433'  'Men\'s Badminton (Final Stage, Male Single)'
    :-  '864430'  'Women\'s Badminton (Final Stage, Female Double)'
    :-  '865530'  'Women\'s Judo (57 kg)'
    :-  '865535'  'Women\'s Judo (+78 kg)'
    :-  '865523'  'Men\'s Judo (73 kg)'
    :-  '865526'  'Men\'s Judo (100 kg)'
    :-  '865527'  'Men\'s Judo (+100 kg)'
    :-  '865534'  'Women\'s Judo (78 kg)'
    :-  '865525'  'Men\'s Judo (90 kg)'
    :-  '865536'  'Judo (+78 kg Mixed Team)'
    :-  '865522'  'Men\'s Judo (66 kg)'
    :-  '865529'  'Women\'s Judo (52 kg)'
    :-  '865528'  'Women\'s Judo (48 kg)'
    :-  '865521'  'Men\'s Judo (60 kg)'
    :-  '865531'  'Women\'s Judo (63 kg)'
    :-  '865532'  'Women\'s Judo (70 kg)'
    :-  '865524'  'Men\'s Judo (81 kg)'
    :-  '865533'  'Women\'s Judo (70 kg)'
    :-  '865402'  'Table Tennis (Final Stage, Mixed Doubles)'
    :-  '865399'  'Women\'s Table Tennis (Final Stage, Female Single)'
    :-  '865398'  'Men\'s Table Tennis (Final Stage, Male Single)'
    :-  '865401'  'Women\'s Table Tennis (Final Stage, Female Team)'
    :-  '865397'  'Women\'s Table Tennis (Preliminary Stage, Female Single)'
    :-  '865396'  'Men\'s Table Tennis (Preliminary Stage, Male Single)'
    :-  '865400'  'Men\'s Table Tennis (Final Stage, Male Team)'
    :-  '865496'  'Men\'s Cycling (Mens Time Trial)'
    :-  '865494'  'Men\'s Cycling (Mens Road Race)'
    :-  '865507'  'Men\'s Hockey (Final Stage)'
    :-  '865504'  'Men\'s Hockey (Grp. A)'
    :-  '865505'  'Men\'s Hockey (Grp. B)'
    :-  '865463'  'Women\'s Fencing (Team Sabre)'
    :-  '865458'  'Women\'s Fencing (Epee)'
    :-  '865453'  'Men\'s Fencing (Epee)'
    :-  '865461'  'Women\'s Fencing (Team Epee)'
    :-  '865459'  'Women\'s Fencing (Foil)'
    :-  '865462'  'Women\'s Fencing (Team Foil)'
    :-  '865457'  'Men\'s Fencing (Team Sabre)'
    :-  '865454'  'Men\'s Fencing (Foil)'
    :-  '865455'  'Men\'s Fencing (Team Epee)'
    :-  '865452'  'Men\'s Fencing (Sabre)'
    :-  '865460'  'Women\'s Fencing (Sabre)'
    :-  '865456'  'Men\'s Fencing (Team Foil)'
    :-  '865503'  'Archery (Final Stage)'
    :-  '865508'  'Men\'s Archery (Final Stage)'
    :-  '865502'  'Men\'s Archery (Ranking Round)'
    :-  '865501'  'Women\'s Archery (Ranking Round)'
    :-  '865506'  'Women\'s Archery (Final Stage)'
    :-  '864440'  'Swimming'
    :-  '864451'  'Women\'s Swimming'
    :-  '864462'  'Men\'s Swimming'
    :-  '872030'  'Men\'s Rugby Union (7\'s Pool A)'
    :-  '872033'  'Men\'s Rugby Union (7\'s Pool C)'
    :-  '872036'  'Men\'s Rugby Union (7\'s Placement Matches)'
    :-  '872032'  'Men\'s Rugby Union (7\'s Pool B)'
    :-  '872039'  'Men\'s Rugby Union (7\'s Final Stage)'
    :-  '863922'  'Women\'s Golf'
    :-  '865540'  'Women\'s Taekwondo (-57 kg)'
    :-  '865543'  'Men\'s Taekwondo (+80 kg)'
    :-  '865541'  'Men\'s Taekwondo (-80 kg)'
    :-  '865544'  'Women\'s Taekwondo (+67 kg)'
    :-  '865538'  'Men\'s Taekwondo (-58 kg)'
    :-  '865539'  'Men\'s Taekwondo (-68 kg)'
    :-  '865542'  'Women\'s Taekwondo (-67 kg)'
    :-  '865537'  'Women\'s Taekwondo (-49 kg)'
    :-  '865555'  'Women\'s Weight Lifting'
    :-  '865554'  'Men\'s Weight Lifting'
    :-  '865509'  'Women\'s Hockey (Grp. A)'
    :-  '865510'  'Women\'s Hockey (Grp. B)'
    :-  '865511'  'Women\'s Hockey (Final Stage)'
    :-  '872073'  'Men\'s 3x3 Basketball'
    :-  '872074'  'Men\'s 3x3 Basketball (Final Stage)'
    :-  '865552'  'Men\'s Diving'
    :-  '865551'  'Women\'s Diving'
    :-  '865382'  'Women\'s Track Cycling'
    :-  '872058'  'Men\'s Soccer (Final Stage)'
    :-  '872050'  'Men\'s Soccer (Grp. B)'
    :-  '872411'  'Men\'s Soccer (Qualifiers Grp. A)'
    :-  '872412'  'Men\'s Soccer (Qualifiers Grp. B)'
    :-  '872040'  'Men\'s Soccer (Grp. A)'
    :-  '872052'  'Men\'s Soccer (Grp. C)'
    :-  '872413'  'Men\'s Soccer (Qualifiers Final Stage)'
    :-  '872053'  'Men\'s Soccer (Grp. D)'
    :-  '865486'  'Women\'s Wrestling (Freestyle 50 kg)'
    :-  '865499'  'Women\'s Wrestling (Freestyle 76 kg)'
    :-  '865477'  'Men\'s Wrestling (Freestyle 57 kg)'
    :-  '865472'  'Men\'s Wrestling (Greco-Roman 77 kg)'
    :-  '865495'  'Women\'s Wrestling (Freestyle 62 kg)'
    :-  '865483'  'Men\'s Wrestling (Freestyle 97 kg)'
    :-  '865469'  'Men\'s Wrestling (Greco-Roman 60 kg)'
    :-  '865497'  'Women\'s Wrestling (Freestyle 68 kg)'
    :-  '865484'  'Men\'s Wrestling (Freestyle 125 kg)'
    :-  '865479'  'Men\'s Wrestling (Freestyle 65 kg)'
    :-  '865480'  'Men\'s Wrestling (Freestyle 74 kg)'
    :-  '865474'  'Men\'s Wrestling (Greco-Roman 97 kg)'
    :-  '865473'  'Men\'s Wrestling (Greco-Roman 87 kg)'
    :-  '865476'  'Men\'s Wrestling (Greco-Roman 130 kg)'
    :-  '865488'  'Women\'s Wrestling (Freestyle 53 kg)'
    :-  '865481'  'Men\'s Wrestling (Freestyle 86 kg)'
    :-  '865470'  'Men\'s Wrestling (Greco-Roman 67 kg)'
    :-  '865493'  'Women\'s Wrestling (Freestyle 57 kg)'
    :-  '867077'  'Men\'s Skateboarding'
    :-  '867079'  'Women\'s Skateboarding'
    :-  '872062'  'Men\'s Basketball (Final Stage)'
    :-  '872041'  'Men\'s Basketball (Grp. B)'
    :-  '865752'  'Men\'s Basketball (Qualification - Croatia)'
    :-  '872031'  'Men\'s Basketball (Grp. A)'
    :-  '865751'  'Men\'s Basketball (Qualification - Lithuania)'
    :-  '872072'  'Men\'s Basketball (Qualification Final Stage)'
    :-  '872047'  'Men\'s Basketball (Grp. C)'
    :-  '865757'  'Men\'s Basketball (Qualification - Canada)'
    :-  '865750'  'Men\'s Basketball (Qualification - Serbia)'
    :-  '865498'  'Women\'s Cycling (Womens Road Race)'
    :-  '865500'  'Women\'s Cycling (Womens Time Trial)'
    :-  '865517'  'Women\'s Water Polo (Final Stage)'
    :-  '865513'  'Men\'s Water Polo (Grp. B)'
    :-  '865515'  'Women\'s Water Polo (Grp. A)'
    :-  '865516'  'Women\'s Water Polo (Grp. B)'
    :-  '865514'  'Men\'s Water Polo (Final Stage)'
    :-  '865512'  'Men\'s Water Polo (Grp. A)'
    :-  '865383'  'Men\'s Track Cycling'
    :-  '872811'  'Women\'s Sport Climbing'
    :-  '872810'  'Men\'s Sport Climbing'
    :-  '865573'  'Men\'s Beach volley (Grp. F)'
    :-  '865571'  'Men\'s Beach volley (Grp. D)'
    :-  '865568'  'Men\'s Beach volley (Grp. A)'
    :-  '865572'  'Men\'s Beach volley (Grp. E)'
    :-  '865570'  'Men\'s Beach volley (Grp. C)'
    :-  '865574'  'Men\'s Beach volley (Final Stage)'
    :-  '865569'  'Men\'s Beach volley (Grp. B)'
    :-  '865563'  'Women\'s Beach volley (Grp. C)'
    :-  '865567'  'Women\'s Beach volley (Final Stage)'
    :-  '865564'  'Women\'s Beach volley (Grp. D)'
    :-  '865561'  'Women\'s Beach volley (Grp. A)'
    :-  '865566'  'Women\'s Beach volley (Grp. F)'
    :-  '865565'  'Women\'s Beach volley (Grp. E)'
    :-  '865562'  'Women\'s Beach volley (Grp. B)'
    :-  '865378'  'Women\'s Mountain Bike'
    :-  '865377'  'Men\'s Mountain Bike'
    :-  '865077'  'Women\'s Trampoline Gymnastics'
    :-  '865076'  'Men\'s Trampoline Gymnastics'
    :-  '865075'  'Women\'s Artistic Gymnastics'
    :-  '865078'  'Women\'s Rhythmic Gymnastics'
    :-  '865074'  'Men\'s Artistic Gymnastics'
    :-  '863546'  'Women\'s Tennis (WTA)'
    :-  '863545'  'Men\'s Tennis (ATP)'
    :-  '863547'  'Tennis (Mixed Doubles)'
    :-  '865073'  'Athletics'
    :-  '865071'  'Women\'s Athletics'
    :-  '865070'  'Men\'s Athletics'
    :-  '865576'  'Men\'s Canoeing'
    :-  '865575'  'Women\'s Canoeing'
    :-  '865518'  'Women\'s Shooting'
    :-  '865519'  'Men\'s Shooting'
    :-  '865520'  'Shooting'
    :-  '872042'  'Men\'s Baseball (Grp. A)'
    :-  '872051'  'Men\'s Baseball (Final Stage)'
    :-  '872048'  'Men\'s Baseball (Grp. B)'
    :-  '872068'  'Women\'s Basketball (Grp. B)'
    :-  '872071'  'Women\'s Basketball (Final Stage)'
    :-  '872067'  'Women\'s Basketball (Grp. A)'
    :-  '872070'  'Women\'s Basketball (Grp. C)'
    :-  '865381'  'Men\'s Sailing'
    :-  '865379'  'Sailing'
    :-  '865380'  'Women\'s Sailing'
    :-  '872046'  'Women\'s Rugby Union (7\'s Placement Matches)'
    :-  '872049'  'Women\'s Rugby Union (7\'s Final Stage)'
    :-  '872043'  'Women\'s Rugby Union (7\'s Pool A)'
    :-  '872044'  'Women\'s Rugby Union (7\'s Pool B)'
    :-  '872045'  'Women\'s Rugby Union (7\'s Pool C)'
    :-  '863921'  'Men\'s Golf'
    :-  '866678'  'Women\'s Volleyball (Grp. A)'
    :-  '866812'  'Women\'s Volleyball (Final Stage)'
    :-  '866680'  'Women\'s Volleyball (Grp. B)'
    :-  '872054'  'Men\'s Handball (Grp. A)'
    :-  '872038'  'Men\'s Handball (Grp. B)'
    :-  '872069'  'Men\'s Handball (Final Stage)'
    :-  '865404'  'Men\'s Rowing'
    :-  '865403'  'Women\'s Rowing'
    :-  '865601'  'Men\'s BMX'
    :-  '865602'  'Women\'s BMX'
  ==
::
++  tourney-codes  ^~
  ::  keyed by tournament-template-id,
  ::  values as olympics 2020 tournament id, sport id, and template name
  ::TODO  softball missing!
  %-  ~(gas by *(map @t [otid=@t sid=@t temp=@t]))
  :~  :-  '8916'   ['14755' '53' 'Weight Lifting']
      :-  '8855'   ['14712' '37' 'Equestrian']
      :-  '380'    ['16090' '20' 'Women\'s Handball']
      :-  '8912'   ['14751' '49' 'Taekwondo']
      :-  '8857'   ['14718' '44' 'Sailing']
      :-  '8867'   ['14660' '50' 'Triathlon']
      :-  '8868'   ['14717' '56' 'Mountain Bike']
      :-  '8863'   ['14583' '46' 'Swimming']
      :-  '8915'   ['14734' '34' 'Boxing']
      :-  '8875'   ['14733' '38' 'Fencing']
      :-  '8893'   ['14974' '51' 'Women\'s Volleyball']
      :-  '9698'   ['14747' '39' 'Women\'s Hockey']
      :-  '8919'   ['14720' '55' 'Men\'s Track Cycling']
      :-  '8854'   ['14753' '36' 'Diving']
      :-  '8914'   ['14750' '41' 'Judo']
      :-  '485'    ['14736' '30' 'Men\'s Cycling']
      :-  '10086'  ['15038' '88' 'Skateboarding']
      :-  '9601'   ['14475' '3' 'Women\'s Golf']
      :-  '66'     ['16084' '1' 'Men\'s Soccer']
      :-  '8913'   ['14735' '54' 'Wrestling']
      :-  '427'    ['16087' '26' 'Baseball']
      :-  '8874'   ['14738' '32' 'Archery']
      :-  '486'    ['14737' '30' 'Women\'s Cycling']
      :-  '9699'   ['14739' '39' 'Men\'s Hockey']
      :-  '454'    ['14761' '27' 'Men\'s Beach volley']
      :-  '381'    ['16083' '20' 'Men\'s Handball']
      :-  '8852'   ['14762' '35' 'Canoeing']
      :-  '8910'   ['14721' '48' 'Table Tennis']
      :-  '8923'   ['14677' '4' 'Athletics']
      :-  '158'    ['14429' '2' 'Tennis']
      :-  '8918'   ['14678' '40' 'Gymnastics']
      :-  '8901'   ['14582' '33' 'Badminton']
      :-  '9588'   ['16088' '29' 'Women\'s Rugby Union']
      :-  '9600'   ['14474' '3' 'Men\'s Golf']
      :-  '10202'  ['16237' '89' 'Karate']
      :-  '10087'  ['15039' '87' 'Surfing']
      :-  '9578'   ['16082' '29' 'Men\'s Rugby Union']
      :-  '8866'   ['14756' '47' 'Synchronised Swimming']
      :-  '65'     ['14959' '1' 'Women\'s Soccer']
      :-  '406'    ['14791' '23' 'Men\'s Basketball']
      :-  '9602'   ['14719' '55' 'Women\'s Track Cycling']
      :-  '10203'  ['16238' '90' 'Sport Climbing']
      :-  '10071'  ['16093' '23' 'Men\'s 3x3 Basketball']
      :-  '8850'   ['14722' '43' 'Rowing']
      :-  '453'    ['14760' '27' 'Women\'s Beach volley']
      :-  '8894'   ['14972' '51' 'Men\'s Volleyball']
      :-  '8917'   ['14766' '58' 'BMX']
      :-  '407'    ['16091' '23' 'Women\'s Basketball']
      :-  '8881'   ['14748' '52' 'Water Polo']
      :-  '8858'   ['14749' '45' 'Shooting']
  ==
::
++  tourney-templates  ^~
  %-  ~(gas by *(map @t [sid=@t temp=@t]))
  :~  :-  '65'     ['1' 'Women\'s Soccer']
      :-  '66'     ['1' 'Men\'s Soccer']
      :-  '158'    ['2' 'Tennis']
      :-  '380'    ['20' 'Women\'s Handball']
      :-  '381'    ['20' 'Men\'s Handball']
      :-  '10071'  ['23' 'Men\'s 3x3 Basketball']
      :-  '406'    ['23' 'Men\'s Basketball']
      :-  '407'    ['23' 'Women\'s Basketball']
      :-  '427'    ['26' 'Baseball']
      :-  '453'    ['27' 'Women\'s Beach volley']
      :-  '454'    ['27' 'Men\'s Beach volley']
      :-  '9578'   ['29' 'Men\'s Rugby Union']
      :-  '9588'   ['29' 'Women\'s Rugby Union']
      :-  '9600'   ['3' 'Men\'s Golf']
      :-  '9601'   ['3' 'Women\'s Golf']
      :-  '485'    ['30' 'Men\'s Cycling']
      :-  '486'    ['30' 'Women\'s Cycling']
      :-  '8874'   ['32' 'Archery']
      :-  '8901'   ['33' 'Badminton']
      :-  '8915'   ['34' 'Boxing']
      :-  '8852'   ['35' 'Canoeing']
      :-  '8854'   ['36' 'Diving']
      :-  '8855'   ['37' 'Equestrian']
      :-  '8875'   ['38' 'Fencing']
      :-  '9698'   ['39' 'Women\'s Hockey']
      :-  '9699'   ['39' 'Men\'s Hockey']
      :-  '8923'   ['4' 'Athletics']
      :-  '8918'   ['40' 'Gymnastics']
      :-  '8914'   ['41' 'Judo']
      :-  '8850'   ['43' 'Rowing']
      :-  '8857'   ['44' 'Sailing']
      :-  '8858'   ['45' 'Shooting']
      :-  '8863'   ['46' 'Swimming']
      :-  '8866'   ['47' 'Synchronised Swimming']
      :-  '8910'   ['48' 'Table Tennis']
      :-  '8912'   ['49' 'Taekwondo']
      :-  '8867'   ['50' 'Triathlon']
      :-  '8893'   ['51' 'Women\'s Volleyball']
      :-  '8894'   ['51' 'Men\'s Volleyball']
      :-  '8881'   ['52' 'Water Polo']
      :-  '8916'   ['53' 'Weight Lifting']
      :-  '8913'   ['54' 'Wrestling']
      :-  '8919'   ['55' 'Men\'s Track Cycling']
      :-  '9602'   ['55' 'Women\'s Track Cycling']
      :-  '8868'   ['56' 'Mountain Bike']
      :-  '8880'   ['57' 'Softball']
      :-  '8917'   ['58' 'BMX']
      :-  '9308'   ['70' 'Reference Sport']
      :-  '10087'  ['87' 'Surfing']
      :-  '10086'  ['88' 'Skateboarding']
      :-  '10202'  ['89' 'Karate']
      :-  '10203'  ['90' 'Sport Climbing']
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
