::  graph-stream-hook: graph proxy for earthlings
::
::    makes specified chat graphs accessible over unauthenticated http
::    requests.
::    GET at /stream/graph-name.json to receive json updates as messages happen.
::    POST at /stream/graph-name with a body to send a chat message.
::
::    hands out temporary identities (using fakeid) using which stream viewers
::    can post to exposed graphs.
::    NOTE that the cookie it gives out is marked Secure and SameSite=None!
::
::    when streaming a graph, any messages sent into it (by real identities)
::    of the form "!ban ~ship" will result in an ip ban for that ship,
::    denying them posting privileges in all local streams.
::
::    usage: poke with an action. ie :graph-stream-hook [%stream %urbit-help]
::
/+  graph-store,
    default-agent, verb, dbug,
    fid=fakeid, *server
::
|%
+$  state-0
  $:  %0
      streams=(set source)
      viewers=(jug source eyre-id)
      ::TODO  we need to expire these to avoid a space-leak
      ::      probably clean up expired ids every +identity-duration
      ::TODO  shouldn't this live in fakeid-store instead? but how update?
      guests=(map ship (set address:eyre))
      banned=(set address:eyre)
  ==
::
::NOTE  we could support _streaming_ foreign graphs fairly easily,
::      but posting to them is a way different story,
::      so we just go full local-only for now.
+$  source  term
::
+$  eyre-id  @ta
::
+$  action
  $%  [%stream =source]
      [%stop =source]
      [%ban name=@p]
      [%unban =address:eyre]
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
    :~  [%pass /connect %arvo %e %connect [~ /stream] dap.bowl]
        kick-heartbeat:do
        watch-graphs:do
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
      %noun  $(mark %stream-action)
    ::
        %stream-action
      =/  =action  !<(action vase)
      =^  cards  state
        ?-  -.action
          %stream  (start-stream:do +.action)
          %stop    (stop-stream:do +.action)
          %ban     (ban-comet:do +.action)
          %unban   (unban-ip:do +.action)
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
    =/  who=eyre-id  i.t.path
    :-  ~
    =-  this(viewers -)
    ::NOTE  we really only delete from one, but we don't want to keep a
    ::      reverse lookup just for that optimization.
    %-  ~(run by viewers)
    |=  v=(set eyre-id)
    (~(del in v) who)
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?:  ?=(%poke-ack -.sign)
      ?~  p.sign  [~ this]
      %-  (slog leaf+"failed poke on {(spud wire)}" u.p.sign)
      [~ this]
    ?.  ?=([%listen ~] wire)  (on-agent:def wire sign)
    ?+  -.sign  (on-agent:def wire sign)
        %kick
      [[watch-graphs:do]~ this]
    ::
        %fact
      =*  mark  p.cage.sign
      =*  vase  q.cage.sign
      ?+  mark  (on-agent:def wire sign)
          %graph-update-2
        =^  cards  state
          (handle-graph-update:do !<(update:graph-store vase))
        [cards this]
      ==
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%eyre %bound *]
      ~?  !accepted.sign-arvo
        [dap.bowl 'bind rejected!' binding.sign-arvo]
      [~ this]
    ::
        [%behn %wake *]
      ?.  ?=([%heartbeat ~] wire)  (on-arvo:def wire sign-arvo)
      [send-heartbeat:do this]
    ==
  ::
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
+*  fakeid  ~(. fid bowl)
::
::  config
::
++  identity-duration   ~d7
++  initial-messages    25
++  max-message-length  280
++  heartbeat-timer     ~s30
::
::  card builders
::
++  kick-heartbeat
  ^-  card
  [%pass /heartbeat %arvo %b %wait (add now.bowl heartbeat-timer)]
::
++  send-heartbeat
  ^-  (list card)
  :-  kick-heartbeat
  =/  viewers=(list eyre-id)
    %~  tap  in
    %+  roll  ~(val by viewers)
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
++  watch-graphs
  ^-  card
  :*  %pass
      /listen
      %agent
      [our.bowl %graph-store]
      %watch
      /updates
  ==
::
++  send-to-viewers
  |=  [=source =json]
  ^-  (list card)
  =/  ids=(set eyre-id)
    (~(get ju viewers) source)
  ?:  =(~ ids)  ~
  :_  ~
  :*  %give
      %fact
    ::
      %+  turn  ~(tap in ids)
      |=  =eyre-id
      /http-response/[eyre-id]
    ::
      %http-response-data
      !>  ^-  (unit octs)
      %-  some
      (make-stream-data json)
  ==
::
++  make-stream-data
  |=  =json
  ^-  octs
  %-  as-octt:mimes:html
  :(weld "data:" (en-json:html json) "\0a\0a")
::
::  actions
::
++  start-stream
  |=  =source
  ^-  (quip card _state)
  ?:  ?|  ?=(~ source)
          (~(has in streams) source)
      ==
    [~ state]
  :-  ~
  state(streams (~(put in streams) source))
::
++  stop-stream
  |=  =source
  ^-  (quip card _state)
  ?.  (~(has in streams) source)
    [~ state]
  :-  ~
  %_  state
    streams  (~(del in streams) source)
    viewers  (~(del by viewers) source)
  ==
::
++  ban-comet
  |=  who=ship
  ^-  (quip card _state)
  :-  ~
  %_  state
    guests  (~(del by guests) who)
    banned  (~(uni in banned) (~(get ju guests) who))
  ==
::
++  unban-ip
  |=  =address:eyre
  ^-  (quip card _state)
  :-  ~
  %_  state
    banned  (~(del in banned) address.action)
  ==
::
::  outgoing flows
::
++  handle-graph-update
  |=  [upd=update:graph-store]
  ^-  (quip card _state)
  ?.  ?=(%add-nodes -.q.upd)
    [~ state]
  =*  source  name.resource.q.upd
  ?.  (~(has in streams) source)
    [~ state]
  ::  accept !ban commands from text messages sent by real identities
  ::
  =/  banlist=(list @p)
    %+  murn
      ~(val by nodes.q.upd)
    |=  [m=maybe-post:graph-store *]
    ?:  ?=(%| -.m)  ~
    =+  p.m
    ?.  (lte (met 3 author) 8)  ~
    ~&  contents
    ?.  ?=([[%text *] *] contents)  ~
    ?:  ?&  =('!ban' text.i.contents)
            ?=([[%mention *] *] t.contents)
        ==
      (some ship.i.t.contents)
    %+  rush  text.i.contents
    (ifix [(jest '!ban ~') (star next)] fed:ag)
  =|  cards=(list card)
  |-
  ?~  banlist
    :_  state
    %+  weld  cards
    ::  forward posts to all viewers
    ::
    %+  send-to-viewers  source
    :-  %a
    %+  murn  ~(val by nodes.q.upd)
    |=  [post=maybe-post:graph-store *]
    ^-  (unit json)
    ?:  ?=(%| -.post)  ~
    `(post:enjs:graph-store p.post)
  =^  caz  state
    (ban-comet i.banlist)
  $(banlist t.banlist, cards (weld caz cards))
::
::  incoming flows
::
++  handle-http-request
  |=  [=eyre-id =inbound-request:eyre]
  ^-  (quip card _state)
  ?+  method.request.inbound-request
    [(give-simple-payload:app eyre-id not-found:gen) state]
  ::
    %'GET'   (handle-get eyre-id inbound-request)
    %'POST'  (handle-post eyre-id inbound-request)
  ==
::
::TODO  find a better way to structure this logic
++  handle-get
  |=  [=eyre-id =inbound-request:eyre]
  ^-  (quip card _state)
  =-  =^  [card=(unit card) simple-payload:http]  state
        -
      =.  headers.response-header
        :*  'Content-Type'^'text/event-stream'
            'Cache-Control'^'no-cache'
            'Connection'^'keep-alive'
            headers.response-header
        ==
      :_  state
      =/  header=cage  [%http-response-header !>(response-header)]
      =/  data=cage    [%http-response-data !>(data)]
      =/  =path        /http-response/[eyre-id]
      :*  [%give %fact ~[path] header]
          [%give %fact ~[path] data]
        ::
          %+  weld  (drop card)
          ^-  (list ^card)
          ?:  =(200 status-code.response-header)  ~
          [%give %kick ~[path] ~]~
      ==
  ^-  [[(unit card) simple-payload:http] _state]
  =/  [[ext=(unit @ta) site=(list @t)] *]
    %-  parse-request-line
    url.request.inbound-request
  ::  ignore requests that point to unsupported resources
  ::
  ?.  &(?=([%stream @ ~] site) ?=([~ %json] ext))
    [[~ not-found:gen] state]
  =/  =source  i.t.site
  ?.  (~(has in streams) source)
    [[~ not-found:gen] state]
  ::  add eyre-id as viewer for requested source
  ::
  =.  viewers
    (~(put ju viewers) source eyre-id)
  ::  find or create session for request
  ::
  =/  who=(unit session:fakeid)
    (session-from-request:fakeid inbound-request)
  =/  [out=(unit card) =session-key:fakeid =session:fakeid]
    ?^  who  [~ *session-key:fakeid u.who]
    =<  [`card session-key session]
    (new-session:fakeid identity-duration)
  =/  =header-list:http
    ?^  who  ~
    ::TODO  don't need samesite=none in some contexts, but how can we tell?
    (set-session-cookie:fakeid session-key until.session &)
  ::  keep track of all addresses this session has connected from,
  ::  but never track localhost requests
  ::
  =?  guests  !=(.127.0.0.1 address.inbound-request)
    %+  ~(put ju guests)
      name.session
    address.inbound-request
  :_  state
  :-  out
  ::  build response from some recent messages
  ::
  ^-  simple-payload:http
  :-  [200 header-list]
  %-  some
  %-  make-stream-data
  :-  %a
  =;  recents=(list [* maybe-post:graph-store *])
    %+  murn  recents
    |=  [* m=maybe-post:graph-store *]
    ^-  (unit json)
    ?:  ?=(%| -.m)  ~
    `(post:enjs:graph-store p.m)
  =;  upd
    ?>  ?=(%add-graph +<.upd)
    %-  flop
    %+  scag  initial-messages
    (tap:orm:graph-store graph.q.upd)
  .^  update:graph-store
    %gx
    (scot %p our.bowl)
    %graph-store
    (scot %da now.bowl)
    /graph/(scot %p our.bowl)/[source]/graph-update-2
  ==
::
++  handle-post
  |=  [=eyre-id =inbound-request]
  ^-  (quip card _state)
  :_  state
  =;  [out=(unit card) =simple-payload:http]
    %+  weld  (drop out)
    (give-simple-payload:app eyre-id simple-payload)
  ::  request must have sane target
  ::
  =/  [[ext=(unit @ta) site=(list @t)] *]
    %-  parse-request-line
    url.request.inbound-request
  ?.  &(?=([%stream @ ~] site) ?=(~ ext))
    `not-found:gen
  =/  =source  i.t.site
  ::  request must have some content
  ::
  =/  body=@t
    q:(fall body.request.inbound-request *octs)
  ?:  =(~ body)
    `[[400 ~] ~]
  ::  reject requests from banned addresses
  ::
  ?:  (~(has in banned) address.inbound-request)
    `[[403 ~] `(as-octs:mimes:html 'ur banned, fool!')]
  ::  reject requests without fakeid sessions
  ::
  =/  who=(unit ship)
    (identity-from-request:fakeid inbound-request)
  ?~  who
    `[[403 ~] `(as-octs:mimes:html 'no session cookie')]
  ::
  :_  [[200 ~] ~]
  %-  some
  %^  send-message
      source
    u.who
  %-  text-to-content
  (end 3^max-message-length body)
::
++  text-to-content
  %+  curr  rash
  ::NOTE  we intentionally don't do #expression parsing
  |^  ;~  pose
        (stag %url turl)
        (stag %text text)
      ==
  ::  +turl: url parser
  ::
  ++  turl
    =-  (sear - text)
    |=  t=cord
    ^-  (unit cord)
    ?~((rush t aurf:de-purl:html) ~ `t)
  ::  +text: text message body
  ::
  ++  text
    (cook crip (plus next))
  --
::
++  send-message
  |=  [=source as=ship =content:graph-store]
  ^-  card
  :*  %pass
      /send/[source]
      %agent
      [our.bowl %graph-store]
      %poke
      %graph-update-2
    ::
      !>  ^-  update:graph-store
      ::TODO  this is api, man... move into lib or w/e
      =|  nodes=(list [index:graph-store node:graph-store])
      :-  now.bowl
      :+  %add-nodes  [our.bowl source]
      %+  ~(put by *(map index:graph-store node:graph-store))
        [now.bowl]~
      :_  [%empty ~]
      ^-  maybe-post:graph-store
      :*  %&
          as
          [now.bowl]~
          now.bowl
          [content]~
          ~
          ~
      ==
  ==
--
