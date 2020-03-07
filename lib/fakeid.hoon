::  fakeid: temporary local identities
::
::    this lib provides helpers for interacting with the fakeid-store.
::    they build cards, make scries, and do data extraction for you.
::
/-  *fakeid
::
|_  =bowl:gall
+*  card  card:agent:gall
::
::  store usage helpers
::
++  new-session
  |=  duration=@dr
  ^-  [=card =session-key =session]
  |^  =/  =session-key  (shas %fakeid-key eny.bowl)
      =/  name=ship     (get-comet our.bowl session-key)
      =/  until=time    (add now.bowl duration)
      =/  =session      [name until]
      :_  [session-key session]
      :*  %pass
          /fakeid/poke/new-session
          %agent
          [our.bowl %fakeid-store]
          %poke
          %fakeid-action
          !>(`action`[%new session-key session])
      ==
  ::  +get-comet: get a random comet, with its last syllables matching :ship's
  ::
  ++  get-comet
    |=  [=ship eny=@]
    ^-  @p
    ::  pre-scramble the ship into its displayed value,
    ::  because comet values don't get scrambled, but we do want visual
    ::  consistency with :ship.
    ::
    =.  ship  (fein:ob ship)
    ::  then overlay the ship name at the end of a random comet
    ::
    %^  cat  3  ship
    %^  rsh  3  (met 3 ship)
    %-  ~(rad og eny)
    ~fipfes-fipfes-fipfes-fipfes--fipfes-fipfes-fipfes-fipfes
  --
::
++  expire-session
  |=  who=(each ship session-key)
  ^-  card
  :*  %pass
      /fakeid/poke/expire-session
      %agent
      [our.bowl %fakeid-store]
      %poke
      %fakeid-action
      !>(`action`[%expire who])
  ==
::
++  get-session
  |=  =session-key
  .^  (unit session)
    %gx
    (scot %p our.bowl)
    %fakeid-store
    (scot %da now.bowl)
    %session
    (scot %uv session-key)
    /noun
  ==
::
::  http server helpers
::
++  cookie-name  "fakeid-{(slag 1 (scow %p our.bowl))}"
::
++  set-session-cookie
  |=  [=session-key until=time]
  ^-  header-list:http
  :_  ~
  :-  'Set-Cookie'
  %-  crip
  %+  weld
    "{cookie-name}={(scow %uv session-key)}; Expires="
  (dust:chrono:userlib (yore until))
::
++  identity-from-request
  |=  =inbound-request:eyre
  ^-  (unit ship)
  ?:  authenticated.inbound-request
    `src.bowl
  =/  session  (session-from-request inbound-request)
  ?~  session  ~
  `name.u.session
::
++  session-from-request
  |=  =inbound-request:eyre
  ^-  (unit session)
  =/  cookies=(map tape tape)
    (cookies-from-request inbound-request)
  =/  session-cookie  (~(get by cookies) cookie-name)
  ?~  session-cookie  ~
  (get-session (slav %uv (crip u.session-cookie)))
::
::TODO  into /lib/server
++  cookies-from-request
  |=  =inbound-request:eyre
  ^-  (map tape tape)
  =/  headers
    ::TODO  support multiple 'Cookie' headers, as allowed by http2
    %-  ~(gas by *(map cord cord))
    header-list.request.inbound-request
  %+  rash  (~(gut by headers) 'cookie' '')
  %+  cook
    ~(gas by *(map tape tape))
  %+  more  mic
  ::TODO  this is a little bit dumb
  =/  text  (plus ;~(less mic tis next))
  ;~(plug text ;~(pfix tis text))
--
