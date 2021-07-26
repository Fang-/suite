::  enetpulse/results: fetch results for events
::
/-  *enetpulse
/+  static=enetpulse-static,
    strandio
::
|=  args=vase
=+  !<([~ events=(set @t) db=full-db] args)
=/  events=(list @t)  ~(tap in events)
=/  m  (strand:strandio ,vase)
?:  =(~ events)  (pure:m !>(~))
|^
  ;<  results=(map @t (map @t json))  bind:m
    (fetch-all-results events)
  %-  pure:m
  !>  ^-  (map @t result)
  %-  ~(gas by *(map @t result))
  %+  murn  ~(tap by results)
  |=  [evid=@t res=(map @t json)]
  (bind (parse-result evid res) (lead evid))
::
++  parse-result
  |=  [evid=@t res=(map @t json)]
  :: =/  m  (strand:strandio ,result)
  ^-  (unit result)
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
  =/  participants=(list [nr=@t [name=@t id=@t country-fk=@t type=@t] res=(map @t @t)])
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
        'participant'^(ot 'name'^so 'id'^so 'countryFK'^so 'type'^so ~)
        'result'^(cu ~(gas by *(map @t @t)) (or (ot 'result_code'^so 'value'^so ~)))
    ==
  ?:  =(~ participants)  ~
  %-  some
  =/  duel=?  =(2 (lent participants))
  :: ~&  [%got-participants evid participants]
  ::TODO  if 4 participants and badminton (or tennis? or other?), it's doubles
  =/  entries=(list result-entry)
    =-  (turn - (cork tail tail))
    %+  sort
      %+  turn  participants
      |=  [nr=@t [name=@t id=@t country-fk=@t type=@t] res=(map @t @t)]
      ^-  [nr=@t rank=@ud result-entry]
      ~|  res
      =/  country-code=@t
        ?:  =('11' country-fk)
          ?:  =(name 'ROC')  name
          ?:  =(name 'EOR')  name
          ::TODO  ids by filtering https://eapi.enetpulse.com/tournament/participants/?id=16367&includeCountryCodes=yes&includeProperties=yes&participantType=athlete&username=paldevapiusr&token=fb5706db03c473ae89d9d5f6cdb5753f for appropriate organizationFK manually. should be kept up to date?
          ::  EOR = 865529
          ::  ROC = 921001
          ?:  ?=(^ (find [id]~ ~['3630908' '3640721' '3641181' '3642765' '3642766' '3643196' '3643355' '3644152' '3644154' '3644156' '3644162' '3644163' '3644164' '3644165' '3644166' '3644167' '3644169' '3644170' '3644172' '3644174' '3644180' '3644194' '3644195' '3644196' '3644197' '3644198' '3644199']))
            ~&  %eor-gottem
            'EOR'
          ?:  ?=(^ (find [id]~ ~['3627990' '3628040' '3631251' '3631288' '3631628' '3631793' '3631851' '3632229' '3632441' '3632536' '3632559' '3632764' '3632832' '3632837' '3632847' '3632852' '3633226' '3633230' '3633241' '3633245' '3633246' '3633247' '3633248' '3633249' '3633420' '3633421' '3633422' '3633423' '3635195' '3635196' '3635210' '3635211' '3635275' '3635276' '3640790' '3640826' '3640834' '3640887' '3640911' '3640917' '3640922' '3640980' '3640991' '3641008' '3641032' '3641048' '3641122' '3641149' '3641186' '3641233' '3641290' '3641313' '3641337' '3641369' '3641415' '3641440' '3641479' '3641521' '3641620' '3641728' '3641731' '3641732' '3641968' '3641970' '3641971' '3642356' '3642357' '3642367' '3642370' '3642552' '3642554' '3642556' '3642570' '3642572' '3642574' '3642575' '3642576' '3642703' '3642770' '3642771' '3642773' '3642775' '3643079' '3643199' '3643274' '3643357' '3643509' '3643593' '3643597' '3643717' '3643909' '3643925' '3643926' '3643927' '3643928' '3643929' '3643930' '3643931' '3644633' '3644654' '3644709' '3644760' '3644761' '3645026' '3645123' '3645258' '3645325' '3645513' '3645514' '3645518' '3645529' '3645532' '3645535' '3645536' '3645537' '3645539' '3645548' '3645549' '3645551' '3645553' '3645554' '3645556' '3645557' '3645560' '3645561' '3645611' '3645648' '3645694' '3645774' '3645810' '3645852' '3645875' '3645927' '3645973' '3646012' '3646050' '3646097' '3646127' '3647607' '3647725' '3647733' '3649442' '3649449' '3649452' '3649456' '3649459' '3649468' '3649537' '3649561' '3649566' '3649580' '3649588' '3649623' '3649629' '3649632' '3651361' '3651365' '3651368' '3651370' '3652011' '3652012' '3652013' '3652014' '3652015' '3652016' '3652017' '3652018' '3652019' '3652020' '3652021' '3652022' '3652023' '3652024' '3652026' '3652027' '3652028' '3652029' '3652030' '3652031' '3652032' '3652033' '3652034' '3652035' '3652036' '3652038' '3652039' '3652040' '3652041' '3652042' '3652043' '3652044' '3652045' '3652046' '3652047' '3653434' '3653435' '3653436' '3653437' '3653439' '3653440' '3653442' '3653515' '3653518' '3653531' '3653601' '3653668' '3653680' '3653743' '3653811' '3653941' '3654285' '3654874' '3654883' '3654891' '3654906' '3654918' '3654932' '3654954' '3654963' '3654974' '3654978' '3654987' '3655001' '3655010' '3655027' '3655032' '3655050' '3655055' '3655058' '3655757' '3655759' '3655854' '3655999']))
            ~&  %roc-gottem
            'ROC'
          ~&  [%guessing-roc-very-bad evid=evid pid=id name]
          ::TODO  uhhh
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
          ?:  |(=(`'WR' com) =(`'WB' com))  %wr
          ?:  |(=(`'OR' com) =(`'OB' com))  %or
          ~
      :_  ?.  (~(has by res) 'medal')  ~
          =-  (fall - ~)
          (rush (~(got by res) 'medal') (perk %gold %silver %bronze ~))
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
    ::NOTE  early-out
    ?:  =(score.ea score.eb)  &
    ?:  &(?=([%wl %w] score.ea) ?=([%wl %l] score.eb))  &
    ?:  &(?=([%wl %w] score.eb) ?=([%wl %l] score.ea))  |
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
    ?:  ?=(?(%dns %dnf %nm %dq %elim %lap) -.score.eb)  |
    ?:  ?=(?(%dns %dnf %nm %dq %elim %lap) -.score.ea)  &
    ?:  ?&  ?=(%points -.score.ea)  ?=(%points -.score.eb)
            ?=(^ (rush n.score.ea dum:ag))  ?=(^ (rush n.score.eb dum:ag))
        ==
      (gth (rash n.score.ea dum:ag) (rash n.score.eb dum:ag))
    ?:  &(?=(%time -.score.ea) ?=(%time -.score.eb))
      ~&  [%questionable-result-ordering score.ea score.eb]
      (aor t.score.ea t.score.eb)  ::TODO  broken, fix me!
    ?:  &(?=(%distance -.score.ea) ?=(%distance -.score.eb))
      ~&  [%questionable-result-ordering score.ea score.eb]
      !(aor m.score.ea m.score.eb)  ::TODO  sanity-check
    ?:  &(?=(%errors -.score.ea) ?=(%errors -.score.eb))
      ~&  [%questionable-result-ordering score.ea score.eb]
      (aor e.score.ea e.score.eb)
    ?:  !=(999.999 ra)
      ::NOTE  tie, likely
      &
    ::TODO  maybe don't produce a result if we hit this for all entries?
    ~&  [%strange-compare evid ~(key by properties) ra=ra rb=rb a=ea b=eb]
    &
  ?:  =(1 (lent entries))
    [%deft (snag 0 entries)]
  ?:  duel
    [%duel (snag 0 entries) (snag 1 entries)]
  ::  handle 2v2 results specially
  ?.  ?&  =(4 (lent entries))
        ::
          =/  d=@t  (event-discipline:static evid db)
          ?|  =(d 'Badminton')
              =(d 'Beach volleyball')
              =(d 'Table tennis')
              =(d 'Tennis')
          ==
      ==
    [%rank entries]
  =|  win=[c=@t s=score m=medal]
  =|  los=[c=@t s=score m=medal]
  =*  don  [%duel [nation+c ~ s m]:win [nation+c ~ s m]:los]
  |-
  ?~  entries
    ~&  [%so-strange evid=evid]
    don
  =/  cc=@t
    ?-  -.participant.i.entries
      %nation  country-code.participant.i.entries
      %person  country-code.participant.i.entries
    ==
  ?:  =('' c.win)
    =.  win  [cc [score medal]:i.entries]
    $(entries t.entries)
  ?:  &(=('' c.los) !=(cc c.win))
    =.  los  [cc [score medal]:i.entries]
    don
  $(entries t.entries)
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
    :: ~&  [%res-res-not-obj x evid jon]
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
