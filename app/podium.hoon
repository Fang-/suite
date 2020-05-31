::  podium: unauthenticated gall subscriptions for outsiders
::
::    subscribes to gall applications to expose their subscription paths as sse
::    endpoints to unauthenticated http clients.
::    (because eyre's channels don't support unauthenticated clients.)
::
::    applications poke podium with [%expose %app /path], upon which podium
::    subscribes to that application on /podium/path. (use /lib/podium!)
::    when new clients first open their connection (at /podium/app/path.json)
::    podium sends the result of .^(json %gx /=app=/podium/path/json) as
::    initial data.
::    whenever the application sends a subscription update, expected to be
::    of the %json mark, that is sent to the subscribers as-is.
::
/+  *server, corsac, default-agent, verb, dbug
::
|%
+$  state-0
  $:  %0
      podium=(jug source eyre-id)
  ==
::
+$  source    [app=term =path]
+$  eyre-id   @ta
::
+$  action
  $%  [%expose source]
      [%censor source]
  ==
::
+$  card  card:agent:gall
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
::
%-  agent:corsac
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    :_  this
    :~  [%pass /connect %arvo %e %connect [~ /podium] dap.bowl]
        kick-heartbeat:do
    ==
  ::
  ++  on-save  !>(state)
  ::
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    [~ this(state !<(state-0 old))]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
      %noun  $(mark %podium-action)
    ::
        %podium-action
      =/  =action  !<(action vase)
      =^  cards  state
        ?-  -.action
          %expose  (expose:do +.action)
          %censor  (censor:do +.action)
        ==
      [cards this]
    ::
        %handle-http-request
      =^  cards  state
        %-  handle-http-request:do
        !<([=eyre-id =inbound-request:eyre] vase)
      [cards this]
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?>  ?=([@ *] wire)
    ?+  -.sign  (on-agent:def wire sign)
        %kick
      :_  this
      [(expose-card:do wire)]~
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      =/  =tank
        :-  %leaf
        "{(trip dap.bowl)}: expose failed {(scow %tas i.wire)} {(spud t.wire)}"
      %-  (slog tank u.p.sign)
      =^  cards  state
        (censor:do wire)
      [cards this]
    ::
        %fact
      :_  this
      ?:  ?=(%json p.cage.sign)
        (forward:do wire !<(json q.cage.sign))
      ~&  [dap.bowl %ignoring-fact-not-json from=i.wire on=t.wire]
      ~
    ==
  ::
  ++  on-watch
    |=  =path
    ?:  ?=([%http-response @ ~] path)
      [~ this]
    (on-watch:def path)
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ?.  ?=([%http-response @ ~] path)
      (on-leave:def path)
    =/  =eyre-id  i.t.path
    :-  ~
    this(state (handle-leave eyre-id))
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%e %bound *]
      ~?  !accepted.sign-arvo
        [dap.bowl 'bind rejected!' binding.sign-arvo]
      [~ this]
    ::
        [%b %wake *]
      ?.  ?=([%heartbeat ~] wire)  (on-arvo:def wire sign-arvo)
      [send-heartbeat:do this]
    ==
  ::
  ++  on-peek  on-peek:def
  ++  on-fail  on-fail:def
  --
::
|_  =bowl:gall
++  heartbeat-timer  ~s20
::
++  kick-heartbeat
  ^-  card
  [%pass /heartbeat %arvo %b %wait (add now.bowl heartbeat-timer)]
::
++  send-heartbeat
  ^-  (list card)
  :-  kick-heartbeat
  =/  viewers=(list eyre-id)
    ::  jug source eyre-id
    %~  tap  in
    %+  roll  ~(val by podium)
    |=  [s=(set eyre-id) o=(set eyre-id)]
    (~(uni in o) s)
  ?:  =(0 (lent viewers))  ~
  :_  ~
  :*  %give
      %fact
    ::
      %+  turn  viewers
      |=  =eyre-id
      /http-response/[eyre-id]
    ::
      %http-response-data
      !>  ^-  (unit octs)
      `[1 '\0a']
  ==
::
++  expose-card
  |=  =source
  ^-  card
  [%pass source %agent [our.bowl app.source] %watch [%podium path.source]]
::
++  expose
  |=  =source
  ^-  (quip card _state)
  :-  [(expose-card source)]~
  state(podium (~(put by podium) source ~))
::
++  censor
  |=  =source
  ^-  (quip card _state)
  :_  state(podium (~(del by podium) source))
  =;  subs=(list path)
    :~  [%pass source %agent [our.bowl app.source] %leave ~]
        [%give %kick subs ~]
    ==
  %+  turn  ~(tap in (~(get ju podium) source))
  |=  =eyre-id
  /http-response/[eyre-id]
::
++  handle-http-request
  |=  [=eyre-id =inbound-request:eyre]
  ^-  (quip card _state)
  =*  four-oh-four
    [(give-simple-payload:app eyre-id not-found:gen) state]
  ?.  ?=(%'GET' method.request.inbound-request)
    four-oh-four
  =/  [[ext=(unit @ta) site=(list @t)] *]
    %-  parse-request-line
    url.request.inbound-request
  ::  ignore requsets for invalid / unexposed resources
  ::
  ?.  &(?=([%podium @ *] site) ?=([~ %json] ext))
    four-oh-four
  =/  =source  t.site
  ?.  (~(has by podium) source)
    four-oh-four
  ::  add eyre-id as viewer for resource
  ::
  =.  podium
    (~(put ju podium) source eyre-id)
  ::TODO  maybe add fakeid session if they don't have it yet?
  :_  state
  %+  give-simple-payload:app  eyre-id
  :-  [200 ~]
  %-  some
  %-  make-stream-data
  .^  json
    %gx
    (scot %p our.bowl)
    app.source
    (scot %da now.bowl)
    %podium
    (snoc path.source %json)
  ==
::
++  handle-leave
  |=  =eyre-id
  ^+  state
  =-  state(podium -)
  ::NOTE  we really only delete from one, but we don't want to keep a
  ::      reverse lookup just for that optimization.
  %-  ~(run by podium)
  |=  v=(set ^eyre-id)
  (~(del in v) eyre-id)
::
++  forward
  |=  [=source =json]
  ^-  (list card)
  =/  audience=(set eyre-id)
    ~|  [%unregistered-source source]
    (~(got by podium) source)
  ?~  audience  ~
  :_  ~
  :*  %give
      %fact
    ::
      %+  turn  ~(tap in `(set eyre-id)`audience)
      |=  =eyre-id
      /http-response/[eyre-id]
    ::
      %http-response-data
      !>  ^-  (unit octs)
      `(make-stream-data json)
  ==
::
++  make-stream-data
  |=  =json
  ^-  octs
  %-  as-octt:mimes:html
  :(weld "data:" (en-json:html json) "\0a\0a")
--
