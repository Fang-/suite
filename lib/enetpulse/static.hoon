::TODO  for every sport, see if there's an event with "Summer Olympics" in the name, and store that
::  http://eapi.enetpulse.com/tournament_template/list/?sportFK=SPORT_ID
::  then query here to find the tournament id where name is "2020":
::  http://eapi.enetpulse.com/tournament/list/?tournament_templateFK=FROM_ABOVE
::  then query here to find the various stages of the tournament:
::  http://eapi.enetpulse.com/tournament_stage/list/?tournamentFK=TOURNAMENT_ID
::  and from there, list individual events and get their starting times:
::  http://eapi.enetpulse.com/event/list/?includeEventProperties=no&tournament_stageFK=STAGE_ID
::
::TODO  test run event timestamp gathering with 2016, everything should be there?
::
/-  *enetpulse
::
|%
++  event-name
  |=  [db=full-db evid=@t]
  ^-  @t
  =/  event=[name=@t round=@t when=@da stid=@t]
    (~(got by events.db) evid)
  =/  stage=[name=@t gene=gender toid=@t]
    (~(got by stages.db) stid.event)
  =/  discipline=@t
    (event-discipline evid db)
  =/  dis-icon=?(@t [m=@t w=@t])
    icon:(~(got by disciplines) discipline)
  %+  rap  3
  ^-  (list @t)
  :*  ?@  dis-icon  dis-icon
      ?:(?=(%female gene.stage) w.dis-icon m.dis-icon)
    ::
      ' '
      discipline
      ': '
    ::
      ::NOTE  doesn't jive well with duel events
      :: ?:  ?|  =('Men\'s' (end 3^5 name.event))
      ::         =('Women\'s' (end 3^7 name.event))
      ::         =('Men\'s' (end 3^5 name.stage))
      ::         =('Women\'s' (end 3^7 name.stage))
      ::     ==
      ::   ''
      :: ?-  gene.stage
      ::   %mixed   ''
      ::   %male    'Men\'s '
      ::   %female  'Women\'s '
      :: ==
    ::
      ?:  =('Artistic Gymnastics' name.stage)  ''
      =/  nom=tape  (trip name.stage)
      ?:  ?=(^ (find "lympics" nom))  ''
      =?  nom  =(`0 (find "Greco-Roman " nom))
        (slag 12 nom)
      (cat 3 (crip nom) ': ')
    ::
      name.event
    ::
      ?:  =('' round.event)  ~
      =?  round.event  ?=(^ (rush round.event dum:ag))
        (cat 3 'Round ' round.event)
      :~(' (' round.event ')')
  ==
::
++  disciplines  ^~
  %-  ~(gas by *(map @t [medals=@ud icon=?(@t [m=@t w=@t])]))
  discipline-list
::
++  discipline-list  ^~
  ^-  (list [@t medals=@ud icon=?(@t [m=@t w=@t])])
  :~    ['Artistic swimming' 2 '🏊' '🏊‍♀️']
        ['Diving' 8 '🏊' '🏊‍♀️']
        ['Swimming' 37 '🏊' '🏊‍♀️']
        ['Water polo' 2 '🤽‍♂️' '🤽‍♀️']
      ['Archery' 5 '🏹']
      ['Athletics' 48 '🏃' '🏃‍♀️']
      ['Badminton' 5 '🏸']
        ['Baseball' 1 '⚾️']
        ['Softball' 1 '⚾️']
        ['Basketball' 2 '⛹' '⛹️‍♀️']
        ['3x3 basketball' 2 '⛹' '⛹️‍♀️']
      ['Boxing' 13 '🥊']
        ['Canoe slalom' 4 '🛶']
        ['Canoe sprint' 12 '🛶']
        ['BMX freestyle' 2 '🚲']
        ['BMX racing' 2 '🚲']
        ['Mountain biking' 2 '🚵' '🚵‍♀️']
        ['Road cycling' 4 '🚴' '🚴‍♀️']
        ['Track cycling' 12 '🚴' '🚴‍♀️']
        ['Equestrian dressage' 2 '🐎']
        ['Equestrian eventing' 2 '🐎']
        ['Equestrian jumping' 2 '🐎']
      ['Fencing' 12 '🤺']
      ['Field hockey' 2 '🏑']
      ['Soccer' 2 '⚽️']  ::NOTE  officially "football"
      ['Golf' 2 '🏌️' '🏌️‍♀️']
        ['Artistic gymnastics' 14 '🤸‍♂️' '🤸‍♀️']
        ['Rhythmic gymnastics' 2 '🤸‍♂️' '🤸‍♀️']
        ['Trampoline gymnastics' 2 '🤸‍♂️' '🤸‍♀️']
      ['Handball' 2 '🤾‍♂️' '🤾‍♀️']
      ['Judo' 15 '🥋']
        ['Karate kata' 2 '🥋']
        ['Karate kumite' 6 '🥋']
      ['Modern pentathlon' 2 '5️⃣']
      ['Rowing' 14 '🚣' '🚣‍♀️']
      ['Rugby sevens' 2 '🏉']
      ['Sailing' 10 '⛵️']
      ['Shooting' 15 '🔫']
      ['Skateboarding' 4 '🛹']
      ['Sport climbing' 2 '🧗‍♂️' '🧗‍♀️']
      ['Surfing' 2 '🏄' '🏄‍♀️']
      ['Table tennis' 5 '🏓']
      ['Taekwondo' 8 '🥋']
      ['Tennis' 5 '🎾']
      ['Triathlon' 3 '3️⃣']
        ['Volleyball' 2 '🏐']
        ['Beach volleyball' 2 '🏐']
      ['Weightlifting' 14 '🏋' '🏋️‍♀️']
        ['Freestyle wrestling' 12 '🤼‍♂️' '🤼‍♀️']
        ['Greco-Roman wrestling' 6 '🤼‍♂️' '🤼‍♀️']
  ==
::
++  sport-to-discipline
  |=  spid=@t
  ^-  (unit @t)
  =-  ?:(?=(~ -) ~ `-)
  ?+  spid  ~
    %'1'   'Soccer'
    %'2'   'Tennis'
    %'3'   'Golf'
    %'4'   'Athletics'
    %'20'  'Handball'
    %'26'  'Baseball'
    %'27'  'Beach volleyball'
    %'29'  'Rugby sevens'  ::NOTE  we might want to manually parse this out to be sure
    %'30'  'Road cycling'
    %'32'  'Archery'
    %'33'  'Badminton'
    %'34'  'Boxing'
    %'36'  'Diving'
    %'38'  'Fencing'
    %'39'  'Field hockey'
    %'41'  'Judo'
    %'42'  'Modern pentathlon'
    %'43'  'Rowing'
    %'44'  'Sailing'
    %'45'  'Shooting'
    %'46'  'Swimming'
    %'47'  'Artistic swimming'
    %'48'  'Table tennis'
    %'49'  'Taekwondo'
    %'50'  'Triathlon'
    %'51'  'Volleyball'
    %'52'  'Water polo'
    %'53'  'Weightlifting'
    %'55'  'Track cycling'
    %'56'  'Mountain biking'
    %'57'  'Softball'
    %'87'  'Surfing'
    %'88'  'Skateboarding'
    %'90'  'Sport climbing'
  ==
::
++  event-discipline  ::TODO  switch arg order
  |=  [evid=@t db=full-db]
  ^-  @t
  =/  event     ~|  [%evid evid]
                (~(got by events.db) evid)
  =/  stage     ~|  [%stid stid.event]
                (~(got by stages.db) stid.event)
  =/  tourney   ~|  [%toid toid.stage]
                (~(got by tourneys.db) toid.stage)
  =/  template  ~|  [%teid teid.tourney]
                (~(got by templates.db) teid.tourney)
  ?^  dis=(sport-to-discipline spid.template)
    u.dis
  =*  fail
    %+  rap  3
    ~['?? ' (~(got by sports) spid.template) ': ' name.stage '; ' name.event]
  ?+  spid.template  fail
      %'23'  ::  'Basketball'  ::  ambiguous! 3x3 or no?
    ?:  ?=(^ (find "3x3" (trip name.stage)))
      '3x3 basketball'
    'Basketball'
  ::
      %'29'
    ?:  ?=(^ (find "7's" (trip name.stage)))
      'Rugby sevens'
    :: ~&  [%weird-rugby evid name.stage]
    :: 'Rugby'
    fail
  ::
      %'35'  ::  'Canoeing'  ::  ambiguous! slalom or sprint?
    ?:  ?=(^ (find "Slalom" (trip name.event)))
      'Canoe slalom'
    'Canoe sprint'
  ::
      %'37'  ::  'Equestrian'  ::  ambiguous! dressage, eventing, jumping?
      ?:  ?=(^ (find "Event" (trip name.event)))
      'Equestrian eventing'
    ?:  ?=(^ (find "Dressage" (trip name.event)))
      'Equestrian dressage'
    ?:  ?=(^ (find "Jump" (trip name.event)))
      'Equestrian jumping'
    :: ~&  [%weird-equestrian evid name.event]
    :: 'Equestrian'
    fail
  ::
      %'40'  ::  'Gymnastics'  ::  ambiguous! artistic, rhythmic, trampoline?
    ?:  =('Artistic Gymnastics' name.stage)
      'Artistic gymnastics'
    ?:  =('Trampoline Gymnastics' name.stage)
      'Trampoline gymnastics'
    ?:  =('Rhythmic Gymnastics' name.stage)
      'Rhythmic gymnastics'
    ?:  =('Artistic' (end 3^8 name.stage))  ::  2016
      'Artistic gymnastics'
    ?:  =('Rhythmic' (end 3^8 name.stage))  ::  2016
      'Rhythmic gymnastics'
    ?:  =('Trampoline' (end 3^10 name.stage))  ::  2016
      'Trampoline gymnastics'
    :: ~&  [%weird-gymnastics evid name.stage]
    :: 'Gymnastics'
    fail
  ::
      %'54'  ::  'Wrestling'  ::  ambiguous! freestyle or greco-roman
    ?:  =('Greco-Roman' (end 3^11 name.stage))
      'Greco-Roman wrestling'
    ?:  =('Freestyle' (end 3^9 name.stage))
      'Freestyle wrestling'
    :: ~&  [%weird-wrestling evid name.stage]
    :: 'Wrestling'
    fail
  ::
      %'58'  ::  'BMX'  ::  ambiguous! freestyle or racing?
    ?:  ?=(^ (find "Freestyle" (trip name.event)))
      'BMX freestyle'
    ?:  ?=(^ (find "Racing" (trip name.event)))
      'BMX racing'
    'BMX freestyle'  ::  2016
    :: ~&  [%weird-bmx evid name.event]
    :: 'BMX'
    :: fail
  ::
      %'89'  ::  'Karate'  ::  ambiguous! kata or kumite
    fail
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
::
++  result-types  ^~
  %-  ~(gas by *(map @t [code=@t name=@t]))
  :~  :+  '1'  'ordinarytime'  'Ordinary time'
      :+  '2'  'extratime'  'Extra time'
      :+  '3'  'penaltyshootout'  'Penalty Shootout'
      :+  '4'  'finalresult'  'Final Result'
      :+  '5'  'halftime'  'Halftime'
      :+  '6'  'runningscore'  'Running score'
      :+  '31'  'strokes_r1'  'Strokes 1st round'
      :+  '32'  'strokes_r2'  'Strokes 2nd round'
      :+  '33'  'strokes_r3'  'Strokes 3rd round'
      :+  '34'  'strokes_r4'  'Strokes 4th round'
      :+  '35'  'strokes_r5'  'Strokes 5th round'
      :+  '36'  'par'  'Par'
      :+  '37'  'position'  'Position'
      :+  '38'  'made_cut'  'Made cut'
      :+  '39'  'mpscore'  'Match Play Score'
      :+  '40'  'weight'  'Weight'
      :+  '51'  'period1'  'Period 1'
      :+  '52'  'period2'  'Period 2'
      :+  '53'  'period3'  'Period 3'
      :+  '54'  'penaltyshootout'  'Penalty Shootout (Deprecated)'
      :+  '60'  'quarter1'  'Quarter 1'
      :+  '61'  'quarter2'  'Quarter 2'
      :+  '62'  'quarter3'  'Quarter 3'
      :+  '63'  'quarter4'  'Quarter 4'
      :+  '80'  'set1'  'Set 1'
      :+  '81'  'set2'  'Set 2'
      :+  '82'  'set3'  'Set 3'
      :+  '83'  'set4'  'Set 4'
      :+  '84'  'set5'  'Set 5'
      :+  '85'  'setswon'  'Won sets'
      :+  '86'  'tiebreak1'  'Tiebreak 1'
      :+  '87'  'tiebreak2'  'Tiebreak 2'
      :+  '88'  'tiebreak3'  'Tiebreak 3'
      :+  '89'  'tiebreak4'  'Tiebreak 4'
      :+  '90'  'tiebreak5'  'Tiebreak 5'
      :+  '91'  'gamescore'  'Game score'
      :+  '92'  'set6'  'Set 6'
      :+  '93'  'set7'  'Set 7'
      :+  '100'  'rank'  'Rank'
      :+  '101'  'duration'  'Duration'
      :+  '102'  'points'  'Points'
      :+  '103'  'distance'  'Distance'
      :+  '104'  'comment'  'Comment'
      :+  '221'  'laps'  'Laps'
      :+  '222'  'laps_behind'  'Laps behind'
      :+  '223'  'pitstops'  'Pitstops'
      :+  '301'  'inning1'  'Inning 1'
      :+  '302'  'inning2'  'Inning 2'
      :+  '303'  'inning3'  'Inning 3'
      :+  '304'  'inning4'  'Inning 4'
      :+  '305'  'inning5'  'Inning 5'
      :+  '306'  'inning6'  'Inning 6'
      :+  '307'  'inning7'  'Inning 7'
      :+  '308'  'inning8'  'Inning 8'
      :+  '309'  'inning9'  'Inning 9'
      :+  '310'  'extra_inning'  'Extra inning'
      :+  '311'  'hits'  'Hits'
      :+  '312'  'errors'  'Errors'
      :+  '313'  'misses'  'Misses'
      :+  '401'  'horseracingodds'  'Horse Racing Odds'
      :+  '408'  'startnumber'  'Startnumber'
      :+  '501'  'medal'  'Medal'
      :+  '502'  'missed_shots'  'Missed shots'
      :+  '503'  'additional_shots'  'Additional shots'
      :+  '504'  'tries'  'Tries'
      :+  '505'  '4s'  '4s points'
      :+  '506'  '6s'  '6s points'
      :+  '507'  'overs'  'Overs'
      :+  '508'  'extra'  'Extras'
      :+  '509'  'wickets'  'Wickets'
      :+  '510'  'secondpoints'  'Second points'
      :+  '511'  'secondovers'  'Second overs'
      :+  '512'  'secondextra'  'Second extra'
      :+  '513'  'secondwickets'  'Second wickets'
      :+  '514'  'speed'  'Speed'
      :+  '515'  'jump_off_penalties'  'Jump Off Penalties'
      :+  '516'  'jump_off_time'  'Jump Off Time'
      :+  '517'  'netpoints'  'Net points'
      :+  '518'  'drawnumber'  'Draw number'
      :+  '519'  'official_rating'  'Official Rating'
      :+  '520'  'form'  'Form'
      :+  '521'  'age'  'Age'
      :+  '522'  'fastest_lap_point'  'Fastest lap point'
      :+  '523'  'handicap'  'Handicap'
      :+  '524'  'place_win'  'Place win'
      :+  '525'  'allowance'  'Allowance'
      :+  '526'  'strokes_points_r1'  'Strokes points 1st round'
      :+  '527'  'strokes_points_r2'  'Strokes points 2nd round'
      :+  '528'  'strokes_points_r3'  'Strokes points 3rd round'
      :+  '529'  'strokes_points_r4'  'Strokes points 4th round'
      :+  '530'  'strokes_points_r5'  'Strokes points 5th round'
      :+  '531'  'wins'  'Wins'
      :+  '532'  'rides'  'Rides'
      :+  '533'  'best_time'  'Best time'
      :+  '534'  'classificationpoints'  'Classification Points'
      :+  '535'  'tops'  'Tops'
      :+  '536'  'zones'  'Zones'
      :+  '537'  'top_attempts'  'Top attempts'
      :+  '538'  'zone_attempts'  'Zone attempts'
      :+  '539'  'interval'  'Interval'
      :+  '540'  'prize_money'  'Prize Money'
  ==
::
++  countries  ^~
  %-  ~(gas by *(map @t @t))
  :~  :-  '1'  'Denmark'
      :-  '2'  'England'
      :-  '3'  'Germany'
      :-  '4'  'Italy'
      :-  '5'  'France'
      :-  '6'  'Sweden'
      :-  '7'  'Norway'
      :-  '8'  'Spain'
      :-  '9'  'Netherlands'
      :-  '11'  'International'
      :-  '12'  'Portugal'
      :-  '13'  'Turkey'
      :-  '14'  'Belgium'
      :-  '15'  'Scotland'
      :-  '16'  'USA'
      :-  '17'  'Slovenia'
      :-  '19'  'Czech Republic'
      :-  '20'  'Serbia'
      :-  '21'  'Romania'
      :-  '22'  'Russia'
      :-  '23'  'Canada'
      :-  '24'  'Finland'
      :-  '25'  'Japan'
      :-  '26'  'Hungary'
      :-  '28'  'South Africa'
      :-  '29'  'Tunisia'
      :-  '30'  'Nigeria'
      :-  '31'  'Egypt'
      :-  '32'  'Cameroon'
      :-  '33'  'Greece'
      :-  '34'  'Austria'
      :-  '35'  'UAE'
      :-  '37'  'Switzerland'
      :-  '38'  'Israel'
      :-  '39'  'Australia'
      :-  '41'  'Luxembourg'
      :-  '42'  'Northern Ireland'
      :-  '44'  'Croatia'
      :-  '45'  'Ireland'
      :-  '47'  'Poland'
      :-  '48'  'Argentina'
      :-  '50'  'Thailand'
      :-  '51'  'Brazil'
      :-  '52'  'Morocco'
      :-  '53'  'Ukraine'
      :-  '54'  'Malta'
      :-  '55'  'Georgia'
      :-  '56'  'Bulgaria'
      :-  '57'  'Belarus'
      :-  '58'  'Wales'
      :-  '59'  'Cyprus'
      :-  '60'  'Estonia'
      :-  '61'  'Latvia'
      :-  '62'  'Slovakia'
      :-  '63'  'Saudi Arabia'
      :-  '64'  'Azerbaijan'
      :-  '65'  'Moldova'
      :-  '66'  'Lithuania'
      :-  '67'  'Faroe Islands'
      :-  '68'  'North Macedonia'
      :-  '69'  'Iceland'
      :-  '70'  'Bosnia and Herzegovina'
      :-  '71'  'Albania'
      :-  '72'  'Armenia'
      :-  '73'  'San Marino'
      :-  '74'  'Liechtenstein'
      :-  '76'  'Andorra'
      :-  '77'  'Chile'
      :-  '78'  'Colombia'
      :-  '79'  'Uruguay'
      :-  '80'  'Ecuador'
      :-  '81'  'Bolivia'
      :-  '82'  'Paraguay'
      :-  '83'  'Peru'
      :-  '84'  'Venezuela'
      :-  '85'  'Algeria'
      :-  '86'  'Greenland'
      :-  '87'  'Kuwait'
      :-  '88'  'South Korea'
      :-  '89'  'Malaysia'
      :-  '90'  'Singapore'
      :-  '91'  'Qatar'
      :-  '92'  'Zimbabwe'
      :-  '93'  'New Zealand'
      :-  '94'  'Fiji'
      :-  '95'  'Taiwan'
      :-  '96'  'Myanmar'
      :-  '98'  'Libya'
      :-  '99'  'Togo'
      :-  '100'  'Zambia'
      :-  '101'  'Sudan'
      :-  '102'  'Ghana'
      :-  '103'  'Liberia'
      :-  '104'  'Sierra Leone'
      :-  '105'  'Namibia'
      :-  '106'  'Senegal'
      :-  '107'  'Congo'
      :-  '108'  'DR Congo'
      :-  '109'  'Malawi'
      :-  '110'  'Burkina Faso'
      :-  '111'  'Ivory Coast'
      :-  '112'  'Jamaica'
      :-  '113'  'Trinidad and Tobago'
      :-  '114'  'Mexico'
      :-  '115'  'Nicaragua'
      :-  '116'  'El Salvador'
      :-  '117'  'Costa Rica'
      :-  '118'  'Honduras'
      :-  '119'  'Angola'
      :-  '120'  'Madagascar'
      :-  '121'  'North Korea'
      :-  '122'  'Iran'
      :-  '123'  'Iraq'
      :-  '125'  'China'
      :-  '126'  'Mali'
      :-  '127'  'Jordan'
      :-  '128'  'Hong Kong'
      :-  '129'  'Kazakhstan'
      :-  '130'  'Uzbekistan'
      :-  '131'  'Benin'
      :-  '133'  'India'
      :-  '134'  'Oman'
      :-  '135'  'Laos'
      :-  '136'  'Guatemala'
      :-  '137'  'Cuba'
      :-  '138'  'Martinique'
      :-  '139'  'Haiti'
      :-  '140'  'Bahamas'
      :-  '141'  'Indonesia'
      :-  '142'  'Puerto Rico'
      :-  '143'  'Panama'
      :-  '144'  'Bahrain'
      :-  '145'  'Rwanda'
      :-  '146'  'Guinea'
      :-  '147'  'Kenya'
      :-  '148'  'Yemen'
      :-  '149'  'Barbados'
      :-  '150'  'Kyrgyzstan'
      :-  '151'  'Botswana'
      :-  '152'  'Gabon'
      :-  '153'  'Cape Verde'
      :-  '154'  'Uganda'
      :-  '155'  'Vietnam'
      :-  '156'  'Sri Lanka'
      :-  '157'  'Palestine'
      :-  '158'  'Syria'
      :-  '159'  'Tajikistan'
      :-  '160'  'Lebanon'
      :-  '161'  'Maldives'
      :-  '162'  'Turkmenistan'
      :-  '163'  'Pakistan'
      :-  '164'  'Dominican Republic'
      :-  '165'  'St. Kitts and Nevis'
      :-  '166'  'Saint Vincent and The Grenadines'
      :-  '167'  'Vanuatu'
      :-  '168'  'French Polynesia'
      :-  '169'  'Solomon Islands'
      :-  '170'  'Great Britain'
      :-  '171'  'Tonga'
      :-  '172'  'Philippines'
      :-  '173'  'Mongolia'
      :-  '174'  'Afghanistan'
      :-  '175'  'Lesotho'
      :-  '176'  'Nepal'
      :-  '177'  'Ethiopia'
      :-  '178'  'Mauritius'
      :-  '179'  'Seychelles'
      :-  '180'  'Brunei'
      :-  '181'  'U.S. Virgin Islands'
      :-  '182'  'Micronesia'
      :-  '183'  'Bermuda'
      :-  '184'  'Nauru'
      :-  '185'  'Central African Rep.'
      :-  '186'  'Guam'
      :-  '187'  'Netherlands Antilles'
      :-  '188'  'Bangladesh'
      :-  '189'  'Bhutan'
      :-  '190'  'Monaco'
      :-  '192'  'Antigua and Barbuda'
      :-  '193'  'American Samoa'
      :-  '194'  'Belize'
      :-  '195'  'Aruba'
      :-  '196'  'Burundi'
      :-  '197'  'Cayman Islands'
      :-  '198'  'Djibouti'
      :-  '199'  'Dominica'
      :-  '200'  'Equatorial Guinea'
      :-  '201'  'Eritrea'
      :-  '202'  'Cook Islands'
      :-  '203'  'Cambodia'
      :-  '204'  'French Guiana'
      :-  '205'  'Gambia'
      :-  '206'  'Saint Lucia'
      :-  '207'  'Niger'
      :-  '208'  'Papua New Guinea'
      :-  '209'  'Chad'
      :-  '210'  'Eswatini'
      :-  '211'  'Comoros'
      :-  '212'  'Kiribati'
      :-  '213'  'Grenada'
      :-  '214'  'British Virgin Islands'
      :-  '215'  'Mozambique'
      :-  '216'  'Guyana'
      :-  '217'  'Mauritania'
      :-  '218'  'Tanzania'
      :-  '219'  'Somalia'
      :-  '220'  'Suriname'
      :-  '221'  'Sao Tome and Principe'
      :-  '222'  'Former East Timor'
      :-  '223'  'Palau'
      :-  '224'  'Samoa'
      :-  '225'  'Europe'
      :-  '226'  'GB/Ireland'
      :-  '227'  'Asia'
      :-  '228'  'Macao'
      :-  '229'  'Guadeloupe'
      :-  '230'  'Montenegro'
      :-  '465'  'Unknown'
      :-  '652'  'Undefined'
      :-  '653'  'East Timor'
      :-  '654'  'New Caledonia'
      :-  '655'  'Gibraltar'
      :-  '656'  'Guinea-Bissau'
      :-  '657'  'Marshall Islands'
      :-  '658'  'Tuvalu'
      :-  '659'  'Jersey'
      :-  '660'  'Christmas Island'
      :-  '661'  'Anguilla'
      :-  '662'  'Montserrat'
      :-  '663'  'Turks and Caicos Islands'
      :-  '664'  'Curacao'
      :-  '665'  'Zanzibar'
      :-  '666'  'South Sudan'
      :-  '667'  'Northern Mariana Islands'
      :-  '668'  'Kosovo'
      :-  '669'  'Yugoslavia'
      :-  '670'  'West Germany'
      :-  '671'  'East Germany'
      :-  '672'  'Soviet Union'
      :-  '673'  'Czechoslovakia'
      :-  '674'  'Dutch East Indies'
      :-  '675'  'Zaire'
      :-  '676'  'Crimea'
      :-  '677'  'Niue'
      :-  '678'  'Sint Maarten'
      :-  '679'  'Isle of Man'
      :-  '680'  'Guernsey'
      :-  '681'  'Bonaire'
      :-  '682'  'Saint Martin'
      :-  '684'  'Reunion'
  ==
::
++  members  ^~
  %-  ~(gas by *(map @t [name=@t athletes=@ud]))
  :~  :+  'JPN'  'Japan'  499
      :+  'AUS'  'Australia'  472
      :+  'USA'  'United States'  462
      :+  'GER'  'Germany'  406
      :+  'FRA'  'France'  396
      :+  'CHN'  'China'  392
      :+  'ITA'  'Italy'  384
      :+  'GBR'  'Great Britain'  372
      :+  'CAN'  'Canada'  371
      :+  'ROC'  'ROC'  342
      :+  'ESP'  'Spain'  331
      :+  'BRA'  'Brazil'  311
      :+  'NED'  'Netherlands'  258
      :+  'NZL'  'New Zealand'  225
      :+  'KOR'  'South Korea'  204
      :+  'POL'  'Poland'  184
      :+  'ARG'  'Argentina'  172
      :+  'MEX'  'Mexico'  160
      :+  'RSA'  'South Africa'  157
      :+  'HUN'  'Hungary'  145
      :+  'UKR'  'Ukraine'  138
      :+  'EGY'  'Egypt'  127
      :+  'BEL'  'Belgium'  125
      :+  'SWE'  'Sweden'  125
      :+  'IND'  'India'  115
      :+  'TUR'  'Turkey'  108
      :+  'ROU'  'Romania'  104
      :+  'SUI'  'Switzerland'  104
      :+  'IRL'  'Ireland'  102
      :+  'BLR'  'Belarus'  99
      :+  'POR'  'Portugal'  92
      :+  'DEN'  'Denmark'  90
      :+  'ISR'  'Israel'  88
      :+  'KAZ'  'Kazakhstan'  86
      :+  'KEN'  'Kenya'  86
      :+  'SRB'  'Serbia'  85
      :+  'GRE'  'Greece'  81
      :+  'NOR'  'Norway'  75
      :+  'CZE'  'Czech Republic'  69
      :+  'CUB'  'Cuba'  68
      :+  'IRI'  'Iran'  67
      :+  'COL'  'Colombia'  66
      :+  'UZB'  'Uzbekistan'  63
      :+  'AUT'  'Austria'  60
      :+  'DOM'  'Dominican Republic'  59
      :+  'TUN'  'Tunisia'  59
      :+  'CRO'  'Croatia'  58
      :+  'TPE'  'Chinese Taipei'  58
      :+  'CHI'  'Chile'  56
      :+  'NGR'  'Nigeria'  52
      :+  'MAR'  'Morocco'  50
      :+  'JAM'  'Jamaica'  49
      :+  'VEN'  'Venezuela'  44
      :+  'ALG'  'Algeria'  42
      :+  'HKG'  'Hong Kong'  42
      :+  'MGL'  'Mongolia'  42
      :+  'BUL'  'Bulgaria'  41
      :+  'ECU'  'Ecuador'  41
      :+  'SVK'  'Slovakia'  41
      :+  'AZE'  'Azerbaijan'  40
      :+  'THA'  'Thailand'  39
      :+  'ETH'  'Ethiopia'  36
      :+  'LTU'  'Lithuania'  36
      :+  'SLO'  'Slovenia'  35
      :+  'PER'  'Peru'  34
      :+  'PUR'  'Puerto Rico'  34
      :+  'LAT'  'Latvia'  33
      :+  'EST'  'Estonia'  32
      :+  'FIN'  'Finland'  31
      :+  'BRN'  'Bahrain'  30
      :+  'MAS'  'Malaysia'  30
      :+  'GEO'  'Georgia'  30
      :+  'FIJ'  'Fiji'  29
      :+  'MNE'  'Montenegro'  29
      :+  'EOR'  'Refugee Olympic Team'  29
      :+  'INA'  'Indonesia'  28
      :+  'CIV'  'Ivory Coast'  28
      :+  'KSA'  'Saudi Arabia'  26
      :+  'ZAM'  'Zambia'  24
      :+  'GUA'  'Guatemala'  23
      :+  'SGP'  'Singapore'  22
      :+  'TTO'  'Trinidad and Tobago'  22
      :+  'HON'  'Honduras'  20
      :+  'UGA'  'Uganda'  19
      :+  'VIE'  'Vietnam'  19
      :+  'ANG'  'Angola'  18
      :+  'MDA'  'Moldova'  18
      :+  'PHI'  'Philippines'  18
      :+  'ARM'  'Armenia'  17
      :+  'KGZ'  'Kyrgyzstan'  15
      :+  'QAT'  'Qatar'  14
      :+  'CYP'  'Cyprus'  13
      :+  'ERI'  'Eritrea'  12
      :+  'JOR'  'Jordan'  12
      :+  'GHA'  'Ghana'  11
      :+  'NAM'  'Namibia'  11
      :+  'BOT'  'Botswana'  10
      :+  'CRC'  'Costa Rica'  10
      :+  'CMR'  'Cameroon'  10
      :+  'LUX'  'Luxembourg'  10
      :+  'PAN'  'Panama'  10
      :+  'BAH'  'Bahamas'  9
      :+  'KUW'  'Kuwait'  9
      :+  'PNG'  'Papua New Guinea'  9
      :+  'URU'  'Uruguay'  9
      :+  'KOS'  'Kosovo'  8
      :+  'MOZ'  'Mozambique'  8
      :+  'PAK'  'Pakistan'  8
      :+  'SAM'  'Samoa'  8
      :+  'TJK'  'Tajikistan'  8
      :+  'COD'  'Democratic Republic of the Congo'  7
      :+  'MRI'  'Mauritius'  7
      :+  'SEN'  'Senegal'  7
      :+  'TKM'  'Turkmenistan'  7
      :+  'ALB'  'Albania'  6
      :+  'BAR'  'Barbados'  6
      :+  'MLT'  'Malta'  6
      :+  'NCA'  'Nicaragua'  6
      :+  'PAR'  'Paraguay'  6
      :+  'SRI'  'Sri Lanka'  6
      :+  'SYR'  'Syria'  6
      :+  'BIH'  'Bosnia and Herzegovina'  5
      :+  'BUR'  'Burkina Faso'  5
      :+  'LAO'  'Laos'  5
      :+  'COK'  'Cook Islands'  5
      :+  'NIG'  'Niger'  5
      :+  'MKD'  'North Macedonia'  5
      :+  'AFG'  'Afghanistan'  4
      :+  'ANT'  'Antigua and Barbuda'  4
      :+  'ASA'  'American Samoa'  4
      :+  'BAN'  'Bangladesh'  4
      :+  'BEN'  'Benin'  4
      :+  'CHA'  'Chad'  4
      :+  'GRN'  'Grenada'  4
      :+  'GBS'  'Guinea-Bissau'  4
      :+  'GUY'  'Guyana'  4
      :+  'IRQ'  'Iraq'  4
      :+  'LBN'  'Lebanon'  4
      :+  'MAD'  'Madagascar'  4
      :+  'RWA'  'Rwanda'  4
      :+  'LCA'  'Saint Lucia'  4
      :+  'SEY'  'Seychelles'  4
      :+  'TOG'  'Togo'  4
      :+  'TGA'  'Tonga'  4
      :+  'UAE'  'United Arab Emirates'  4
      :+  'ISV'  'Virgin Islands'  4
      :+  'IVB'  'British Virgin Islands'  3
      :+  'BDI'  'Burundi'  3
      :+  'CAM'  'Cambodia'  3
      :+  'CAY'  'Cayman Islands'  3
      :+  'CPV'  'Cape Verde'  3
      :+  'DJI'  'Djibouti'  3
      :+  'GAB'  'Gabon'  3
      :+  'GUM'  'Guam'  3
      :+  'HAI'  'Haiti'  3
      :+  'ISL'  'Iceland'  3
      :+  'KIR'  'Kiribati'  3
      :+  'LBA'  'Libya'  3
      :+  'LIE'  'Liechtenstein'  3
      :+  'OMA'  'Oman'  3
      :+  'MON'  'Monaco'  3
      :+  'SMR'  'San Marino'  3
      :+  'SUD'  'Sudan'  3
      :+  'SUR'  'Suriname'  3
      :+  'TAN'  'Tanzania'  3
      :+  'VAN'  'Vanuatu'  3
      :+  'ZIM'  'Zimbabwe'  3
      :+  'AND'  'Andorra'  2
      :+  'BIZ'  'Belize'  2
      :+  'BER'  'Bermuda'  2
      :+  'BHU'  'Bhutan'  2
      :+  'BOL'  'Bolivia'  2
      :+  'DMA'  'Dominica'  2
      :+  'ESA'  'El Salvador'  2
      :+  'GAM'  'The Gambia'  2
      :+  'GUI'  'Guinea'  2
      :+  'LES'  'Lesotho'  2
      :+  'LBR'  'Liberia'  2
      :+  'MHL'  'Marshall Islands'  2
      :+  'MAW'  'Malawi'  2
      :+  'MDV'  'Maldives'  2
      :+  'MLI'  'Mali'  2
      :+  'MYA'  'Myanmar'  2
      :+  'NEP'  'Nepal'  2
      :+  'PLE'  'Palestine'  2
      :+  'SKN'  'Saint Kitts and Nevis'  2
      :+  'STP'  'Sao Tome and Principe'  2
      :+  'SOL'  'Solomon Islands'  2
      :+  'YEM'  'Yemen'  2
      :+  'ARU'  'Aruba'  1
      :+  'BRU'  'Brunei'  1
      :+  'CAF'  'Central African Republic'  1
      :+  'COM'  'Comoros'  1
      :+  'TLS'  'East Timor'  1
      :+  'GEQ'  'Equatorial Guinea'  1
      :+  'SWZ'  'Eswatini'  1
      :+  'FSM'  'Federated States of Micronesia'  1
      :+  'NRU'  'Nauru'  1
      :+  'PLW'  'Palau'  1
      :+  'CGO'  'Republic of the Congo'  1
      :+  'VIN'  'Saint Vincent and the Grenadines'  1
      :+  'SLE'  'Sierra Leone'  1
      :+  'SOM'  'Somalia'  1
      :+  'SSD'  'South Sudan'  1
      :+  'TUV'  'Tuvalu'  1
  ==
::
++  countryfk-to-ioc
  |=  fk=@t
  ^-  @t  ~+
  =/  iso=@t
    ~|  fk=fk
    (~(got by countryfk-to-iso) fk)
  ?~  ioc=(~(get by iso-to-ioc) iso)
    ~&  [%yooo-missing-ioc iso=iso]
    iso
  ~?  &(!(~(has by members) u.ioc) !=('PRK' u.ioc))
    [%strange-not-member ioc=u.ioc]
  u.ioc
::
++  iso-to-ioc  ^~
  %-  ~(gas by *(map @t @t))
  :~
    ['SSD' 'SSD']
    ['RKS' 'KOS']
    ['ANT' 'ANT']
  ::
    ['AFG' 'AFG']
    :: ['ALA' 'XXX']
    ['ALB' 'ALB']
    ['DZA' 'ALG']
    ['ASM' 'ASA']
    ['AND' 'AND']
    ['AGO' 'ANG']
    :: ['AIA' 'XXX']
    :: ['ATA' 'XXX']
    ['ATG' 'ANT']
    ['ARG' 'ARG']
    ['ARM' 'ARM']
    ['ABW' 'ARU']
    ['AUS' 'AUS']
    ['AUT' 'AUT']
    ['AZE' 'AZE']
    ['BHS' 'BAH']
    ['BHR' 'BRN']
    ['BGD' 'BAN']
    ['BRB' 'BAR']
    ['BLR' 'BLR']
    ['BEL' 'BEL']
    ['BLZ' 'BIZ']
    ['BEN' 'BEN']
    ['BMU' 'BER']
    ['BTN' 'BHU']
    ['BOL' 'BOL']
    ['BES' 'AHO']
    ['BIH' 'BIH']
    ['BWA' 'BOT']
    :: ['BVT' 'XXX']
    ['BRA' 'BRA']
    :: ['IOT' 'XXX']
    ['VGB' 'IVB']
    ['BRN' 'BRU']
    ['BGR' 'BUL']
    ['BFA' 'BUR']
    ['BDI' 'BDI']
    ['KHM' 'CAM']
    ['CMR' 'CMR']
    ['CAN' 'CAN']
    ['CPV' 'CPV']
    ['CYM' 'CAY']
    ['CAF' 'CAF']
    ['TCD' 'CHA']
    ['CHL' 'CHI']
    ['CHN' 'CHN']
    :: ['CXR' 'XXX']
    :: ['CCK' 'XXX']
    ['COL' 'COL']
    ['COM' 'COM']
    ['COD' 'COD']
    ['COG' 'CGO']
    ['COK' 'COK']
    ['CRI' 'CRC']
    ['CIV' 'CIV']
    ['HRV' 'CRO']
    ['CUB' 'CUB']
    :: ['CUW' 'XXX']
    ['CYP' 'CYP']
    ['CZE' 'CZE']
    ['DNK' 'DEN']
    ['DJI' 'DJI']
    ['DMA' 'DMA']
    ['DOM' 'DOM']
    ['ECU' 'ECU']
    ['EGY' 'EGY']
    ['SLV' 'ESA']
    ['GNQ' 'GEQ']
    ['ERI' 'ERI']
    ['EST' 'EST']
    ['ETH' 'ETH']
    :: ['FLK' 'XXX']
    ['FRO' 'DEN']  ::NOTE  faroe recognition shenanigans
    ['FJI' 'FIJ']
    ['FIN' 'FIN']
    ['FRA' 'FRA']
    :: ['GUF' 'XXX']
    :: ['PYF' 'XXX']
    :: ['ATF' 'XXX']
    ['GAB' 'GAB']
    ['GMB' 'GAM']
    ['GEO' 'GEO']
    ['DEU' 'GER']
    ['GHA' 'GHA']
    :: ['GIB' 'XXX']
    ['GRC' 'GRE']
    :: ['GRL' 'XXX']
    ['GRD' 'GRN']
    :: ['GLP' 'XXX']
    ['GUM' 'GUM']
    ['GTM' 'GUA']
    :: ['GGY' 'XXX']
    ['GIN' 'GUI']
    ['GNB' 'GBS']
    ['GUY' 'GUY']
    ['HTI' 'HAI']
    :: ['HMD' 'XXX']
    ['HND' 'HON']
    ['HKG' 'HKG']
    ['HUN' 'HUN']
    ['ISL' 'ISL']
    ['IND' 'IND']
    ['IDN' 'INA']
    ['IRN' 'IRI']
    ['IRQ' 'IRQ']
    ['IRL' 'IRL']
    :: ['IMN' 'XXX']
    ['ISR' 'ISR']
    ['ITA' 'ITA']
    ['JAM' 'JAM']
    ['JPN' 'JPN']
    :: ['JEY' 'XXX']
    ['JOR' 'JOR']
    ['KAZ' 'KAZ']
    ['KEN' 'KEN']
    ['KIR' 'KIR']
    ['PRK' 'PRK']
    ['KOR' 'KOR']
    ['KWT' 'KUW']
    ['KGZ' 'KGZ']
    ['LAO' 'LAO']
    ['LVA' 'LAT']
    :: ['LBN' 'LIB']
    ['LBN' 'LBN']
    ['LIB' 'LIB']
    ['LSO' 'LES']
    ['LBR' 'LBR']
    ['LBY' 'LBA']
    ['LIE' 'LIE']
    ['LTU' 'LTU']
    ['LUX' 'LUX']
    :: ['MAC' 'XXX']
    ['MKD' 'MKD']
    ['MDG' 'MAD']
    ['MWI' 'MAW']
    ['MYS' 'MAS']
    ['MDV' 'MDV']
    ['MLI' 'MLI']
    ['MLT' 'MLT']
    ['MHL' 'MHL']
    :: ['MTQ' 'XXX']
    ['MRT' 'MTN']
    ['MUS' 'MRI']
    :: ['MYT' 'XXX']
    ['MEX' 'MEX']
    ['FSM' 'FSM']
    ['MDA' 'MDA']
    ['MCO' 'MON']
    ['MNG' 'MGL']
    ['MNE' 'MNE']
    :: ['MSR' 'XXX']
    ['MAR' 'MAR']
    ['MOZ' 'MOZ']
    ['MMR' 'MYA']
    ['NAM' 'NAM']
    ['NRU' 'NRU']
    ['NPL' 'NEP']
    ['NLD' 'NED']
    :: ['NCL' 'XXX']
    ['NZL' 'NZL']
    ['NIC' 'NCA']
    ['NER' 'NIG']
    ['NGA' 'NGR']
    :: ['NIU' 'XXX']
    :: ['NFK' 'XXX']
    :: ['MNP' 'XXX']
    ['NOR' 'NOR']
    ['OMN' 'OMA']
    ['PAK' 'PAK']
    ['PLW' 'PLW']
    ['PSE' 'PLE']
    ['PAN' 'PAN']
    ['PNG' 'PNG']
    ['PRY' 'PAR']
    ['PER' 'PER']
    ['PHL' 'PHI']
    :: ['PCN' 'XXX']
    ['POL' 'POL']
    ['PRT' 'POR']
    ['PRI' 'PUR']
    ['QAT' 'QAT']
    :: ['REU' 'XXX']
    ['ROU' 'ROU']
    ['RUS' 'ROC']  ::NOTE  special
    ['RWA' 'RWA']
    :: ['BLM' 'XXX']
    :: ['SHN' 'XXX']
    ['KNA' 'SKN']
    ['LCA' 'LCA']
    :: ['SPM' 'XXX']
    ['VCT' 'VIN']
    ['WSM' 'SAM']
    ['SMR' 'SMR']
    ['STP' 'STP']
    ['SAU' 'KSA']
    ['SEN' 'SEN']
    ['SRB' 'SRB']
    ['SYC' 'SEY']
    ['SLE' 'SLE']
    ['SGP' 'SGP']
    ['SIN' 'SGP']  ::  until 2016
    :: ['SXM' 'XXX']
    ['SVK' 'SVK']
    ['SVN' 'SLO']
    ['SLB' 'SOL']
    ['SOM' 'SOM']
    ['ZAF' 'RSA']
    :: ['SGS' 'XXX']
    ['ESP' 'ESP']
    ['LKA' 'SRI']
    ['SDN' 'SUD']
    ['SUR' 'SUR']
    :: ['SJM' 'XXX']
    ['SWZ' 'SWZ']
    ['SWE' 'SWE']
    ['CHE' 'SUI']
    ['SYR' 'SYR']
    ['TWN' 'TPE']
    ['TJK' 'TJK']
    ['TZA' 'TAN']
    ['THA' 'THA']
    ['TLS' 'TLS']
    ['TGO' 'TOG']
    :: ['TKL' 'XXX']
    ['TON' 'TGA']
    ['TTO' 'TTO']
    ['TUN' 'TUN']
    ['TUR' 'TUR']
    ['TKM' 'TKM']
    :: ['TCA' 'XXX']
    ['TUV' 'TUV']
    ['UGA' 'UGA']
    ['UKR' 'UKR']
    ['ARE' 'UAE']
    ['GBR' 'GBR']
    ['USA' 'USA']
    :: ['UMI' 'XXX']
    ['VIR' 'ISV']
    ['URY' 'URU']
    ['UZB' 'UZB']
    ['VUT' 'VAN']
    :: ['VAT' 'XXX']
    ['VEN' 'VEN']
    ['VNM' 'VIE']
    :: ['WLF' 'XXX']
    :: ['ESH' 'XXX']
    ['YEM' 'YEM']
    ['ZMB' 'ZAM']
    ['ZWE' 'ZIM']
  ==
::
++  countryfk-to-iso  ^~
  %-  ~(gas by *(map @t @t))
  :~
    :-  '174'  'AFG'
    :-  '71'  'ALB'
    :-  '85'  'DZA'
    :-  '193'  'ASM'
    :-  '76'  'AND'
    :-  '119'  'AGO'
    :-  '661'  'AIA'
    :-  '192'  'ATG'
    :-  '48'  'ARG'
    :-  '72'  'ARM'
    :-  '195'  'ABW'
    :-  '39'  'AUS'
    :-  '34'  'AUT'
    :-  '64'  'AZE'
    :-  '140'  'BHS'
    :-  '144'  'BHR'
    :-  '188'  'BGD'
    :-  '149'  'BRB'
    :-  '57'  'BLR'
    :-  '14'  'BEL'
    :-  '194'  'BLZ'
    :-  '131'  'BEN'
    :-  '183'  'BMU'
    :-  '189'  'BTN'
    :-  '81'  'BOL'
    :-  '681'  'BES'
    :-  '70'  'BIH'
    :-  '151'  'BWA'
    :-  '51'  'BRA'
    :-  '214'  'VGB'
    :-  '180'  'BRN'
    :-  '56'  'BGR'
    :-  '110'  'BFA'
    :-  '196'  'BDI'
    :-  '203'  'KHM'
    :-  '32'  'CMR'
    :-  '23'  'CAN'
    :-  '153'  'CPV'
    :-  '197'  'CYM'
    :-  '185'  'CAF'
    :-  '209'  'TCD'
    :-  '77'  'CHL'
    :-  '125'  'CHN'
    :-  '660'  'CXR'
    :-  '78'  'COL'
    :-  '211'  'COM'
    :-  '107'  'COG'
    :-  '202'  'COK'
    :-  '117'  'CRI'
    :-  '44'  'HRV'
    :-  '137'  'CUB'
    :-  '664'  'CUW'
    :-  '59'  'CYP'
    :-  '19'  'CZE'
    :-  '1'  'DNK'
    :-  '198'  'DJI'
    :-  '199'  'DMA'
    :-  '164'  'DOM'
    :-  '108'  'COD'
    :-  '674'  'IDN'
    :-  '653'  'TLS'
    :-  '80'  'ECU'
    :-  '31'  'EGY'
    :-  '116'  'SLV'
    :-  '2'  'GBR'
    :-  '200'  'GNQ'
    :-  '201'  'ERI'
    :-  '60'  'EST'
    :-  '210'  'SWZ'
    :-  '177'  'ETH'
    :-  '67'  'FRO'
    :-  '94'  'FJI'
    :-  '24'  'FIN'
    :-  '5'  'FRA'
    :-  '204'  'GUF'
    :-  '168'  'PYF'
    :-  '152'  'GAB'
    :-  '205'  'GMB'
    :-  '226'  'IRL'
    :-  '55'  'GEO'
    :-  '3'  'DEU'
    :-  '102'  'GHA'
    :-  '655'  'GIB'
    :-  '170'  'GBR'
    :-  '33'  'GRC'
    :-  '86'  'GRL'
    :-  '213'  'GRD'
    :-  '229'  'GLP'
    :-  '186'  'GUM'
    :-  '136'  'GTM'
    :-  '680'  'GGY'
    :-  '146'  'GIN'
    :-  '656'  'GNB'
    :-  '216'  'GUY'
    :-  '139'  'HTI'
    :-  '118'  'HND'
    :-  '128'  'HKG'
    :-  '26'  'HUN'
    :-  '69'  'ISL'
    :-  '133'  'IND'
    :-  '141'  'IDN'
    :-  '122'  'IRN'
    :-  '123'  'IRQ'
    :-  '45'  'IRL'
    :-  '679'  'IMN'
    :-  '38'  'ISR'
    :-  '4'  'ITA'
    :-  '111'  'CIV'
    :-  '112'  'JAM'
    :-  '25'  'JPN'
    :-  '659'  'JEY'
    :-  '127'  'JOR'
    :-  '129'  'KAZ'
    :-  '147'  'KEN'
    :-  '212'  'KIR'
    :-  '668'  'RKS'
    :-  '87'  'KWT'
    :-  '150'  'KGZ'
    :-  '135'  'LAO'
    :-  '61'  'LVA'
    :-  '160'  'LBN'
    :-  '175'  'LSO'
    :-  '103'  'LBR'
    :-  '98'  'LBY'
    :-  '74'  'LIE'
    :-  '66'  'LTU'
    :-  '41'  'LUX'
    :-  '228'  'MAC'
    :-  '120'  'MDG'
    :-  '109'  'MWI'
    :-  '89'  'MYS'
    :-  '161'  'MDV'
    :-  '126'  'MLI'
    :-  '54'  'MLT'
    :-  '657'  'MHL'
    :-  '138'  'MTQ'
    :-  '217'  'MRT'
    :-  '178'  'MUS'
    :-  '114'  'MEX'
    :-  '182'  'FSM'
    :-  '65'  'MDA'
    :-  '190'  'MCO'
    :-  '173'  'MNG'
    :-  '230'  'MNE'
    :-  '662'  'MSR'
    :-  '52'  'MAR'
    :-  '215'  'MOZ'
    :-  '96'  'MMR'
    :-  '105'  'NAM'
    :-  '184'  'NRU'
    :-  '176'  'NPL'
    :-  '9'  'NLD'
    :-  '187'  'ANT'
    :-  '654'  'NCL'
    :-  '93'  'NZL'
    :-  '115'  'NIC'
    :-  '207'  'NER'
    :-  '30'  'NGA'
    :-  '677'  'NIU'
    :-  '121'  'PRK'
    :-  '68'  'MKD'
    :-  '42'  'GBR'
    :-  '667'  'MNP'
    :-  '7'  'NOR'
    :-  '134'  'OMN'
    :-  '163'  'PAK'
    :-  '223'  'PLW'
    :-  '157'  'PSE'
    :-  '143'  'PAN'
    :-  '208'  'PNG'
    :-  '82'  'PRY'
    :-  '83'  'PER'
    :-  '172'  'PHL'
    :-  '47'  'POL'
    :-  '12'  'PRT'
    :-  '142'  'PRI'
    :-  '91'  'QAT'
    :-  '684'  'RUN'
    :-  '21'  'ROU'
    :-  '22'  'RUS'
    :-  '145'  'RWA'
    :-  '206'  'LCA'
    :-  '682'  'MAF'
    :-  '166'  'VCT'
    :-  '224'  'WSM'
    :-  '73'  'SMR'
    :-  '221'  'STP'
    :-  '63'  'SAU'
    :-  '15'  'GBR'
    :-  '106'  'SEN'
    :-  '20'  'SRB'
    :-  '179'  'SYC'
    :-  '104'  'SLE'
    :-  '90'  'SGP'
    :-  '678'  'SXM'
    :-  '62'  'SVK'
    :-  '17'  'SVN'
    :-  '169'  'SLB'
    :-  '219'  'SOM'
    :-  '28'  'ZAF'
    :-  '88'  'KOR'
    :-  '666'  'SSD'
    :-  '8'  'ESP'
    :-  '156'  'LKA'
    :-  '165'  'KNA'
    :-  '101'  'SDN'
    :-  '220'  'SUR'
    :-  '6'  'SWE'
    :-  '37'  'CHE'
    :-  '158'  'SYR'
    :-  '95'  'TWN'
    :-  '159'  'TJK'
    :-  '218'  'TZA'
    :-  '50'  'THA'
    :-  '99'  'TGO'
    :-  '171'  'TON'
    :-  '113'  'TTO'
    :-  '29'  'TUN'
    :-  '13'  'TUR'
    :-  '162'  'TKM'
    :-  '663'  'TCA'
    :-  '658'  'TUV'
    :-  '181'  'VIR'
    :-  '35'  'ARE'
    :-  '154'  'UGA'
    :-  '53'  'UKR'
    :-  '79'  'URY'
    :-  '16'  'USA'
    :-  '130'  'UZB'
    :-  '167'  'VUT'
    :-  '84'  'VEN'
    :-  '155'  'VNM'
    :-  '58'  'GBR'
    :-  '148'  'YEM'
    :-  '100'  'ZMB'
    :-  '665'  'TZA'
    :-  '92'  'ZWE'
  ==
--
