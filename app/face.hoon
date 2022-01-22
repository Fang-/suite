::  face: see your friends
::
::    lets you set an image url to be shared with mutuals (pals),
::    and see the images shared by your mutuals.
::    intended to be used with self-portraits.
::
/-  webpage, pals
/+  gossip, server, dbug, verb, default-agent
::
/~  webui  (webpage (map ship cord) (unit cord))  /app/face/webui
::
/$  grab-face  %noun  %face
::
|%
+$  state-0
  $:  %0
      faces=(map ship cord)
  ==
::
+$  card  card:agent:gall
::
+$  eyre-id  @ta
--
::
=|  state-0
=*  state  -
::
%-  %+  agent:gossip
      [1 %mutuals %mutuals]
    %+  ~(put by *(map mark tube:clay))
      %face
    |=  =vase
    !>((grab-face !<(* vase)))
%-  agent:dbug
%+  verb  |
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    pax   /(scot %p our.bowl)/pals/(scot %da now.bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ==
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  [~ this(state old)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::  %noun: misc utilities
    ::
      %noun
    ?+  q.vase  (on-poke:def mark vase)
        [%set-face (unit @t)]
      =*  new  +.q.vase
      ?:  =(new (~(get by faces) our.bowl))
        [~ this]
      :-  [%give %fact [/face/(scot %p our.bowl)]~ %face !>(`(unit cord)`new)]~
      =-  this(faces -)
      ?~  new  (~(del by faces) our.bowl)
      (~(put by faces) our.bowl u.new)
    ::
        [%watch-face @p]
      =*  who  +.q.vase
      :_  this
      =/  =path  /face/(scot %p who)
      [%pass path %agent [who dap.bowl] %watch path]~
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =,  mimes:html
    =+  !<([=eyre-id =inbound-request:eyre] vase)
    ?.  authenticated.inbound-request
      :_  this
      ::TODO  probably put a function for this into /lib/server
      ::      we can't use +require-authorization because we also update state
      %+  give-simple-payload:app:server
        eyre-id
      =-  [[307 ['location' -]~] ~]
      %^  cat  3
        '/~/login?redirect='
      url.request.inbound-request
    ::  parse request url into path and query args
    ::
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    ::
    =;  [payload=simple-payload:http caz=(list card) =_state]
      :_  this(state state)
      %+  weld  caz
      %+  give-simple-payload:app:server
        eyre-id
      payload
    ::  405 to all unexpected requests
    ::
    ?.  &(?=(^ site) =(dap.bowl i.site))
      [[[500 ~] `(as-octs 'unexpected route')] ~ state]
    ::
    =/  page=@ta
      ?~  t.site  %index
      i.t.site
    =;  [[status=@ud out=(unit manx)] caz=(list card) =_state]
      :_  [caz state]
      ^-  simple-payload:http
      :-  :-  status
          ?~  out  ~
          ['content-type'^'text/html']~
      ?~  out  ~
      `(as-octt (en-xml:html u.out))
    ::TODO  pattern copied from pals etc, dedupe!
    ::
    ?.  (~(has by webui) page)
      [[404 `:/"no such page: {(trip page)}"] ~ state]
    =*  view  ~(. (~(got by webui) page) bowl faces)
    ::
    ::TODO  switch higher up: get should never change state!
    ?+  method.request.inbound-request  [[405 ~] ~ state]
        %'GET'
      :_  [~ state]
      [200 `(build:view args ~)]
    ::
        %'POST'
      ?~  body.request.inbound-request  [[400 `:/"no body!"] ~ state]
      =/  new=(unit (unit cord))
        (argue:view [header-list body]:request.inbound-request)
      ?~  new
        :_  [~ state]
        :-  400
        %-  some
        %+  build:view  args
        `|^'Something went wrong! Did you provide sane inputs?'
      =*  success
        ::NOTE  deferred expression of this is important,
        ::      it needs to render with updated state.
        [200 (some (build:view args `&^'Processed succesfully.'))]
      ?:  =(u.new (~(get by faces) our.bowl))
        [success ~ state]
      =^  cards  this
        (on-poke %noun !>([%set-face u.new]))
      [success cards state]
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ::
      [%~.~ %gossip %source ~]
    :_  this
    [%give %fact ~ %face !>(`(unit cord)`(~(get by faces) our.bowl))]~
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
      [%~.~ %gossip %gossip ~]
    ?+  -.sign  ~|([%unexpected-gossip-sign -.sign] !!)
        %fact
      =*  mark  p.cage.sign
      =*  vase  q.cage.sign
      ?.  =(%face mark)
        ~&  [dap.bowl %unexpected-mark-fact mark wire=wire]
        [~ this]
      =+  !<(face=(unit cord) vase)
      =.  faces
        ?~  face  (~(del by faces) src.bowl)
        (~(put by faces) src.bowl u.face)
      [~ this]
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  sign-arvo  (on-arvo:def wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
::
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--

