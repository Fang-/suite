::  enetpulse/results: fetch results for events
::
/-  *enetpulse
/+  strandio
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
  =/  properties=(map @t @t)
    %-  ~(gas in *(map @t @t))
    ?~  p=(~(get by res) 'property')  ~
    ?.  ?=([%o *] u.p)  ~
    %+  turn  ~(tap by p.u.p)
    |=  [k=@t j=json]
    =,  dejs:format
    ((ot 'name'^so 'value'^so ~) j)
  =/  pt=?(%team %person)
    ?.  (~(has by properties) 'ParticipantType')
      %person
    =/  type=@t  (~(got by properties) 'ParticipantType')
    ?:  =('team' type)
      %team
    ?:  =('athlete' type)
      %person
    ~&  [%strange-pt evid (~(got by properties) 'ParticipantType')]
    %person
  *result
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
    ~&  [%no-such-event i.evs]
    next
  =.  res  (~(put by res) i.evs u.ver)
  ;<  ~  bind:m
    (sleep:strandio ~s0..4000)  ::TODO  what if two threads run at once?
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
    ~&  [%event-not-finished evid]
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
