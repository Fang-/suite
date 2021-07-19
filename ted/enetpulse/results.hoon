::  enetpulse/results: fetch results for events
::
/-  *enetpulse
/+  static=enetpulse-static,
    strandio
::
|=  args=vase
=+  !<([~ events=(set @t)] args)
=/  events=(list @t)  ~(tap in events)
=/  m  (strand:strandio ,vase)
?:  =(~ events)  (pure:m !>(~))
|^
  ;<  results=(map @t (map @t json))  bind:m
    (fetch-all-results events)
  %-  pure:m
  !>  ^-  (map @t result)
  %-  ~(urn by results)
  |=  [evid=@t res=(map @t json)]
  (parse-result evid res)
::
++  parse-result
  |=  [evid=@t res=(map @t json)]
  ^-  result
  ~|  evid
  =/  properties=(map @t @t)
    %-  ~(gas by *(map @t @t))
    ?~  p=(~(get by res) 'property')  ~
    %.  u.p
    =,  dejs:format
    (or (ot 'name'^so 'value'^so ~))
  =/  pt=?(%team %person)
    ?.  (~(has by properties) 'ParticipantType')
      ::TODO  base off sport? for example, 2349071
      ::      or is that _just_ for beach volley? it's a weird one...
      %person
    =/  type=@t  (~(got by properties) 'ParticipantType')
    ?:  =('team' type)
      %team
    ?:  =('athlete' type)
      %person
    ~&  [%strange-pt evid (~(got by properties) 'ParticipantType')]
    %person
  =/  participants=(list [nr=@t [name=@t country-fk=@t type=@t] res=(map @t @t)])
    ~|  res
    ?~  p=(~(get by res) 'event_participants')  ~
    =,  dejs:format
    %.  u.p
    %-  or-soft  ::NOTE  skip if no 'result' field, for pair sports, eg 2349071
    |=  jon=json
    ?.  ?=([%o *] jon)  ~
    ?.  (~(has by p.jon) 'result')  ~
    %-  some
    %.  jon
    %-  ot
    :~  'number'^so
        'participant'^(ot 'name'^so 'countryFK'^so 'type'^so ~)
        'result'^(cu ~(gas by *(map @t @t)) (or (ot 'result_code'^so 'value'^so ~)))
    ==
  =/  duel=?  =(2 (lent participants))
  :: ~&  [%got-participants evid participants]
  =/  entries=(list result-entry)
    =-  (turn - (cork tail tail))
    %+  sort
      %+  turn  participants
      |=  [nr=@t [name=@t country-fk=@t type=@t] res=(map @t @t)]
      ^-  [nr=@t rank=@ud result-entry]
      ~|  res
      =/  country-code=@t
        ?:  =('11' country-fk)
          ?:  =(name 'ROC')  'ROC'
          ?:  =(name 'EOR')  'EOR'
          ~&  [%hmmm evid name]
          ::TODO  this is just a guess! that's bad!
          ::      we need to do a participant request for organizationFK
          'ROC'
        ~|  name
        (countryfk-to-ioc:static country-fk)
      :-  nr
      ::NOTE  assumes all have a rank if one has it
      ::TODO  report if only some non-zero?
      :-  ?.  (~(has by res) 'rank')  999.999
          (rash (~(got by res) 'rank') dum:ag)
      :: :-  ~|  country-code
      ::     ?:  =('team' type)
      ::       [%nation country-code]
      ::     ~?  !=('athlete' type)
      ::       [%weird-participant-type type]
      ::     [%person name country-code]
      :-  ?:  ?=(%team pt)  [%nation country-code]
          [%person name country-code]
      :-  =/  com=(unit @t)  (~(get by res) 'comment')
          ?:  =(`'WR' com)  ~&  [%record-wr evid]  %wr
          ?:  =(`'OR' com)  ~&  [%record-or evid]  %or
          ~
      :_  ?.  (~(has by res) 'medal')  ~
          (rash (~(got by res) 'medal') (perk %gold %silver %bronze ~))
      ?:  (~(has by res) 'finalresult')
        =/  final=@t  (~(got by res) 'finalresult')
        ?:  =('won' final)   wl+%w
        ?:  =('lost' final)  wl+%l
        points+final
      ?:  (~(has by res) 'points')
        points+(~(got by res) 'points')
      ?:  (~(has by res) 'duration')
        ~|  (~(got by res) 'duration')
        time+(~(got by res) 'duration')
      ?:  (~(has by res) 'distance')
        distance+(~(got by res) 'distance')
      ?:  (~(has by res) 'weight')
        weight+(rash (~(got by res) 'weight') dum:ag)
      ?:  (~(has by res) 'errors')
        errors+(~(got by res) 'errors')
      ?:  (~(has by res) 'par')
        par+(~(got by res) 'par')
      ?:  (~(has by res) 'comment')
        =/  comment=@t  (~(got by res) 'comment')
        ?:  =('DNF' comment)  dnf+~
        ?:  =('Retired' comment)  dnf+~
        ?:  =('DNS' comment)  dns+~
        ?:  =('Withdrawn' comment)  dns+~
        ?:  =('NM' comment)   nm+~
        ?:  =('DQ' comment)   dq+~
        ?:  =('DSQ' comment)  dq+~
        ?:  =('Disq.' comment)  dq+~
        ?:  =('Disqualified' comment)  dq+~
        ?:  =('Relegated' comment)  dq+~
        ?:  =('Eliminated' comment)  elim+~
        ?:  =('LAP' comment)  lap+~
        ?:  =('HD' comment)  lap+~
        ~?  !=('Q' comment)
          [%weird-comment evid comment]
        ?:  (~(has by res) 'runningscore')
          running+(~(got by res) 'runningscore')
        unknown+res
      ?:  (~(has by res) 'runningscore')
        running+(~(got by res) 'runningscore')
      :: ~?  !=(`'0' (~(get by res) 'runningscore'))
      ::   [%unknown-score res]
      unknown+res
    |=  [[na=@t ra=@ud ea=result-entry] [nb=@t rb=@ud eb=result-entry]]
    ?.  =(ra rb)  (lth ra rb)
    ?:  &(?=([%wl %w] score.ea) ?=([%wl %l] score.eb))  &
    ?:  &(?=([%wl %w] score.eb) ?=([%wl %l] score.ea))  |
    ?:  ?=(?(%dns %dnf %nm %dq %elim %lap) -.score.eb)  |
    ?:  ?=(?(%dns %dnf %nm %dq %elim %lap) -.score.ea)  &
    ?:  &(?=(%points -.score.ea) ?=(%points -.score.eb))
      !(aor n.score.ea n.score.eb)
    ?:  &(?=(%time -.score.ea) ?=(%time -.score.eb))
      (aor t.score.ea t.score.eb)  ::TODO  broken, fix me!
    ?:  &(?=(%distance -.score.ea) ?=(%distance -.score.eb))
      !(aor m.score.ea m.score.eb)  ::TODO  sanity-check
    ?:  &(?=(%errors -.score.ea) ?=(%errors -.score.eb))
      (aor e.score.ea e.score.eb)
    ?:  &(duel (~(has by properties) 'Winner'))
      =/  winner=@t  (~(got by properties) 'Winner')
      ?|  &(=('1' na) =('Home' winner))
          &(=('2' na) =('Away' winner))
      ==
    ?:  !=(medal.ea medal.eb)
      ?:  ?=(~ medal.eb)  &
      ?:  ?=(~ medal.ea)  |
      ?:  ?=(%bronze medal.eb)  &
      ?:  ?=(%bronze medal.ea)  |
      ?:  ?=(%silver medal.eb)  &
      ?:  ?=(%silver medal.ea)  |
      ~&  [%wth-medals medal.ea medal.eb]
      &
    ?:  !=(999.999 ra)
      ::NOTE  tie, likely
      &
    ~&  [%strange-compare evid ~(key by properties) ra=ra rb=rb a=ea b=eb]
    &
  ?:  =(1 (lent entries))
    [%deft (snag 0 entries)]
  ?:  duel
    [%duel (snag 0 entries) (snag 1 entries)]
  [%rank entries]
::
++  or-soft
  |*  wit=fist:dejs-soft:format
  |=  jon=json
  ?>  ?=([%o *] jon)
  ~|  ~(val by p.jon)
  (murn ~(val by p.jon) wit)
::
++  or  ::TODO  ++or:dejs object values as list  into stdlib
  |*  wit=fist:dejs:format
  |=  jon=json
  ?>  ?=([%o *] jon)
  ~|  ~(val by p.jon)
  (turn ~(val by p.jon) wit)
::
++  fetch-all-results
  |=  evs=(list @t)
  =|  res=(map @t (map @t json))
  =/  m  (strand:strandio _res)
  |-  ^-  form:m
  ?~  evs  (pure:m res)
  =*  next  $(evs t.evs)
  ;<  ver=(unit (map @t json))  bind:m
    (fetch-result i.evs)
  ?~  ver
    :: ~&  [%no-such-event i.evs]
    next
  =.  res  (~(put by res) i.evs u.ver)
  ;<  ~  bind:m
    (sleep:strandio ~s0..5000)
  next
::
++  fetch-result
  |=  evid=@t
  =*  x  %fetch-result
  =/  m  (strand:strandio (unit (map @t json)))
  ;<  jon=json  bind:m
    %-  fetch  ^~
    %-  zing
    :~  "/event/details/"
        "?id={(trip evid)}"
        :: "&includeExtendedResults=yes"
        "&includeFirstLastName=yes"
        "&includeCountryCodes=yes"
        "&tf=U"
    ==
  ::TODO  factor the below out into standdalone function so we dont' have
  ::      to dick around with :m all the time
  ?.  ?=([%o *] jon)
    ~&  [%res-not-obj x evid jon]
    (pure:m ~)
  ?.  (~(has by p.jon) 'event')
    ~&  [%res-weird-keys x evid p.jon]
    (pure:m ~)
  =+  jon=(~(got by p.jon) 'event')
  ?.  ?=([%o *] jon)
    ~&  [%res-res-not-obj x evid jon]
    (pure:m ~)
  ?.  (~(has by p.jon) evid)
    ~&  [%res-no-evid evid ~(key by p.jon)]
    (pure:m ~)
  =+  jon=(~(got by p.jon) evid)
  ?.  ?=([%o *] jon)
    ~&  [%res-res-res-not-obj x evid jon]
    (pure:m ~)
  ?.  =(s+'finished' (~(got by p.jon) 'status_type'))
    :: ~&  [%event-not-finished evid]
    (pure:m ~)
  (pure:m `p.jon)
  ::TODO
  ::  if status_type == 'finished', proceed
  ::  trawl each event_participants entry's results for a result_code:'medal'
  ::  "{name.participant} from {country_name.participant} wins xx"
  ::  xx = "the {medal} medal in {sport}"
  ::  xx = "name vs name??"
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
--
