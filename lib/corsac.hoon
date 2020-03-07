::  corsac: cors access control
::
::    this lib provides helpers for working with http cors requests and the
::    corsac-store.
::
::    primarily, it provides a wrapper agent for dealing with cors requests.
::    for approved origins, the agent handles preflight cors requests, and
::    injects cors headers into response-headers sent directly in response to
::    cors requests. the app using this is free to ignore cors entirely.
::    the cors responses sent here allow all request methods, headers, and
::    allow credentials to be sent.
::
::    if you want more fine-grained control over corsac usage and general
::    cors handling, use the helper functions yourself.
::
/-  *corsac
/+  server
::
|_  =bowl:gall
+$  card  card:agent:gall
::
++  agent
  |=  =agent:gall
  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      ag    ~(. agent bowl)
  ::
  ++  on-poke
    =.  ^bowl  bowl
    |=  [=mark =vase]
    ^-  (quip card agent:gall)
    ?.  ?=(%handle-http-request mark)
      =^  cards  agent  (on-poke:ag mark vase)
      [cards this]
    ::
    ::TODO  do we maybe want to keep state, so we can keep requests pending,
    ::      in the hope that approval comes soon enough?
    ::      doesn't that mean we'd need to watch corsac-store though?
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =/  req-headers=(map @t @t)
      (~(gas by *(map @t @t)) header-list.request.inbound-request)
    ::  orn: origin header, if provided
    ::
    =/  orn=(unit origin)
      %^  hunt  |=(* &)
        (~(get by req-headers) 'Origin')
      (~(get by req-headers) 'origin')
    ::  if no origin header provided, not a cors request: pass through
    ::
    ?~  orn
      =^  cards  agent  (on-poke:ag mark vase)
      [cards this]
    =*  origin  u.orn
    ::  if origin not allowed, do nothing: pass through
    ::
    ?.  (is-approved origin)
      =^  cards  agent  (on-poke:ag mark vase)
      :_  this
      ::  if origin not known yet, make request for it
      ::
      ?:  (is-known origin)
        cards
      [(store-request origin) cards]
    ::
    =/  options=?  ?=(%'OPTIONS' method.request.inbound-request)
    =/  methead=?  (~(has by req-headers) 'Access-Control-Request-Method')
    =/  preflight=?  &(options methead)
    =/  headers=header-list:http
      :-  'Access-Control-Allow-Origin'^origin  ::TODO  what about 'null' case?
      :-  'Access-Control-Allow-Credentials'^'true'
      ?.  preflight  ~
      ::NOTE  for now, we just allow all methods and headers over cors
      :~  'Access-Control-Allow-Method'^'*'
          'Access-Control-Allow-Headers'^'*'
          'Access-Control-Max-Age'^'86400'
      ==
    ?:  preflight
      ::  provide preflight response
      ::
      :_  this
      (give-simple-payload:app:server eyre-id [[200 headers] ~])
    ::  else, pass through to inner agent, but tack on cors headers in response
    ::
    =^  cards  agent  (on-poke:ag mark vase)
    =.  cards
      %+  turn  cards
      |=  =card
      ::  find appropriate card to insert cors headers into
      ::
      ?.  ?&  ?=([%give %fact * %http-response-header *] card)
              =([/http-response/[eyre-id]]~ paths.p.card)
          ==
        card
      =/  =response-header:http
        !<(response-header:http q.cage.p.card)
      =/  new-headers  ::TODO  roll set-header?
        %+  weld  headers
        headers.response-header
      card(q.cage.p !>(response-header(headers new-headers)))
    [cards this]
  ::
  ++  on-init
    ^-  (quip card:agent:gall agent:gall)
    =^  cards  agent  on-init:ag
    [cards this]
  ::
  ++  on-save   on-save:ag
  ::
  ++  on-load
    |=  old-state=vase
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-load:ag old-state)
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-watch:ag path)
    [cards this]
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-leave:ag path)
    [cards this]
  ::
  ++  on-peek  on-peek:ag
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-agent:ag wire sign)
    [cards this]
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-arvo:ag wire sign-arvo)
    [cards this]
  ::
  ++  on-fail
    |=  [=term =tang]
    ^-  (quip card agent:gall)
    =^  cards  agent  (on-fail:ag term tang)
    [cards this]
  --
::
++  is-approved
  |=  =origin
  ^-  ?
  .^  ?
    %gx
    (scot %p our.bowl)
    %corsac-store
    (scot %da now.bowl)
    /approved/(scot %t origin)/noun
  ==
::
++  is-known
  |=  =origin
  ^-  ?
  .^  ?
    %gx
    (scot %p our.bowl)
    %corsac-store
    (scot %da now.bowl)
    /known/(scot %t origin)/noun
  ==
::
++  store-request
  |=  =origin
  ^-  card
  =+  !>(`action`[%request origin])
  [%pass /corsac/request %agent [our.bowl %corsac-store] %poke %corsac-action -]
--
