::  chat-stream-hook: chat proxy for earthlings
::
::    makes specified chat channels accessible over unauthenticated http
::    requests.
::    GET at /stream/chat-name.json to receive json updates as messages happen.
::    POST at /stream/chat-name with a body to send a chat message.
::
::    hands out temporary identities (using fakeid) using which stream viewers
::    can post to exposed
::
::    when streaming a chat, any messages sent into it (by real identities)
::    of the form "!ban ~ship" will result in an ip ban for that ship,
::    denying them posting privileges in all local streams.
::
::    usage: poke with an action. ie :chat-stream-hook [%stream /urbit-help]
::
/-  *chat-store
/+  default-agent, verb, dbug,
    fakeid, *server, chat-json
::
|%
+$  state-0
  $:  %0
      streams=(set source)
      viewers=(jug source eyre-id)
      tmp=(set eyre-id)
      ::TODO  we need to expire these to avoid a space-leak
      guests=(map ship (set address:eyre))
      banned=(set address:eyre)
  ==
::
::NOTE  we could support _streaming_ foreign chats fairly easily,
::      but posting to them is a way different story,
::      so we just go full local-only for now.
+$  source  path
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
    [%pass /connect %arvo %e %connect [~ /stream] dap.bowl]~
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
    =-  this(viewers -, tmp (~(del in tmp) who))
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
    ?.  ?=([%chat-updates ^] wire)  (on-agent:def wire sign)
    ?-  -.sign
        %kick
      [[(watch-source:do t.wire)]~ this]
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      =/  =tank  leaf+"{(trip dap.bowl)} failed subscribe. stream disabled!"
      %-  (slog tank u.p.sign)
      =^  cards  state
        (stop-stream:do t.wire)
      [cards this]
    ::
        %fact
      =*  mark  p.cage.sign
      =*  vase  q.cage.sign
      ?+  mark  (on-agent:def wire sign)
        %chat-initial  [~ this]
      ::
          %chat-update
        =^  cards  state
          (handle-chat-update:do t.wire !<(chat-update vase))
        [cards this]
      ==
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?.  ?=([%e %bound *] sign-arvo)
      (on-arvo:def wire sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl 'bind rejected!' binding.sign-arvo]
    [~ this]
  ::
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
+*  dofid  ~(. fakeid bowl)
::
::  config
::
++  identity-duration   ~d7
++  initial-messages    25
++  max-message-length  280
::
::  card builders
::
++  watch-source
  |=  =source
  ^-  card
  :*  %pass
      [%chat-updates source]
      %agent
      [our.bowl %chat-store]
      %watch
      [%mailbox (scot %p our.bowl) source]
  ==
::
++  leave-source
  |=  =source
  ^-  card
  :*  %pass
      [%chat-updates source]
      %agent
      [our.bowl %chat-store]
      %leave
      ~
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
      %-  as-octt:mimes:html
      (en-json:html json)
  ==
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
  :-  [(watch-source source)]~
  state(streams (~(put in streams) source))
::
++  stop-stream
  |=  =source
  ^-  (quip card _state)
  ?.  (~(has in streams) source)
    [~ state]
  :-  [(leave-source source)]~
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
++  handle-chat-update
  |=  [=source upd=chat-update]
  ^-  (quip card _state)
  ?.  ?=(?(%message %messages) -.upd)
    [~ state]
  ::  accept !ban commands from text messages sent by real identities
  ::
  =/  banlist=(list @p)
    %+  murn
      ?-  -.upd
        %message   [envelope.upd]~
        %messages  envelopes.upd
      ==
    |=  envelope
    ?.  ?=(%text -.letter)      ~
    ?.  (lte (met 3 author) 8)  ~
    %+  rush  text.letter
    (ifix [(jest '!ban ~') (star next)] fed:ag)
  =|  cards=(list card)
  |-
  ?~  banlist
    :_  state
    %+  weld  cards
    ::  forward update to all viewers
    ::
    %+  send-to-viewers  source
    (update-to-json:chat-json upd)
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
  ?.  &(?=([%stream *] site) ?=([~ %json] ext))
    [[~ not-found:gen] state]
  =/  =source  t.site
  ?.  (~(has in streams) source)
    [[~ not-found:gen] state]
  ::  add eyre-id as viewer for requested source
  ::
  =.  viewers
    (~(put ju viewers) source eyre-id)
  ::  find or create session for request
  ::
  =/  who=(unit session:fakeid)
    (session-from-request:dofid inbound-request)
  =/  [out=(unit card) =session-key:fakeid =session:fakeid]
    ?^  who  [~ *session-key:fakeid u.who]
    =<  [`card session-key session]
    (new-session:dofid identity-duration)
  =/  =header-list:http
    ?^  who  ~
    (set-session-cookie:dofid session-key until.session)
  ::  keep track of all addresses this session has connected from
  ::
  =.  guests
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
  %-  as-octt:mimes:html
  %-  en-json:html
  %-  update-to-json:chat-json
  :-  %messages
  :^  source  *@ud  *@ud
  .^  (list envelope)  ::  oldest first
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    %envelopes
    (scot %s (new:si | initial-messages))
    ~.0
    (scot %p our.bowl)
    (snoc source %noun)
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
  ?.  &(?=([%stream *] site) ?=(~ ext))
    `not-found:gen
  =/  =source  t.site
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
  %-  send-message
  :+  source
    u.who
  %-  text-to-letter
  (end 3 max-message-length body)
::
++  text-to-letter
  %+  curr  rash
  ::TODO  below largely copied from chat-cli
  ::NOTE  we intentionally don't do #expression parsing
  |^  ;~  pose
        (stag %url turl)
        (stag %me ;~(pfix vat text))
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
  |=  [=source as=ship =letter]
  ^-  card
  :*  %pass
      [%send source]
      %agent
      [our.bowl %chat-store]
      %poke
      %chat-action
    ::
      !>  ^-  chat-action
      :-  %message
      :-  [(scot %p our.bowl) source]
      ^-  envelope
      ::NOTE  this would be rudimentary spam protection...
      ::      if only chat-store rejected duplicate uid messages
      ::      (at least chat-cli doesn't render such messages)
      :-  (shax (jam (div now.bowl ~m5) as letter))
      [*@ as now.bowl letter]
  ==
--