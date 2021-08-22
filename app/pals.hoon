::  pals: manual neighboring
::
::    acts as a "friendlist" of sorts, letting one add arbitrary ships to
::    arbitrary lists. upon doing so, the other party is informed of this.
::    this lets the app expose "friend requests" and mutuals, in addition
::    to user-defined sets of friends.
::
::    intended use case is as simple, bare-bones peer discovery and
::    permissioning for truly peer-to-peer applications, in place of
::    (or as supplement to) group-based peer discovery.
::    for example, a game wanting to stay abreast of high scores,
::    or filesharing service giving selective access.
::
::    webui at /pals courtesy of overengineering incorporated.
::    (it really is too elaborate for what's essentially a spa,
::    but experimenting here helps find good patterns. the current
::    implementation might almost be factored out into a generic library.)
::
::      reading
::    external applications likely want to interact with this via scries,
::    which are outlined below. finding interaction targets or mutuals to
::    poke or subscribe to, using mutual status as permission check, etc.
::    one might be tempted to use list names for namespacing (ie %yourapp
::    would only retrieve targets from the ~.yourapp list), but beware that
::    this overlaps with user-facing organizational purposes.
::
::      writing
::    poke this app with a $command.
::    %meet adds a ship. it is also added to any list names specified.
::    %part removes a ship from either all or the specified lists.
::    the ~. list name is reserved and cannot be added to.
::    managing pals without an interface that lets users control that behavior
::    is bad manners. managing pals without informing the user is evil.
::
::      scry endpoints (all %noun marks)
::    y  /                       arch        [%leeches %targets %mutuals ~]
::    y  /[status]               arch        non-empty lists listing
::
::    x  /leeches                (set ship)  foreign one-sided friendships
::    x  /targets(/[list])       (set ship)  local one-sided friendships
::    x  /mutuals(/[list])       (set ship)  mutual friendships
::
::    x  /leeches/[ship]         ?  is ship a leeche?
::    x  /targets/[list]/[ship]  ?  is ship a target? list may be ~. for all
::    x  /mutuals/[list]/[ship]  ?  is ship a mutual? list may be ~. for all
::
::TODO  subscription endpoints?
::
/-  *pals
/+  dbug, verb, default-agent,
    server
::
/~  webui  webpage  /app/pals/webui
::
|%
+$  state-0  [%0 records]
::
+$  gesture  ::  from others
  $%  [%hey ~]
      [%bye ~]
  ==
::
+$  eyre-id  @ta
+$  card  (wind note gift)
+$  gift  gift:agent:gall
+$  note  note:agent:gall
  :: $%  [%agent [ship %pals] task:agent:gall]
  ::     [%arvo %e %connect [~ %pals ~] term]
  :: ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ %pals ~] dap.bowl]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  ~&  [dap.bowl %load]
  =/  old=state-0  !<(state-0 ole)
  [~ this(state old)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
    ::  %pals-command: local app control
    ::
      %pals-command
    ?>  =(our src):bowl
    =+  !<(cmd=command vase)
    ?:  (~(has in in.cmd) ~.)
      ~|  [%illegal-empty-list-name in=-.cmd]
      !!
    ?:  =(our.bowl ship.cmd)
      [~ this]
    ::
    =/  known=?  (~(has by outgoing) ship.cmd)
    =;  [yow=? =_outgoing]
      ^-  (quip card _this)
      :_  this(outgoing.state outgoing)
      ?.  yow  ~
      =/  =gesture  ?-(-.cmd %meet [%hey ~], %part [%bye ~])
      =/  =cage     [%pals-gesture !>(gesture)]
      [%pass `wire`/[-.gesture] %agent [ship.cmd %pals] %poke cage]~
    ::
    ?-  -.cmd
        %meet
      :-  !known
      %+  ~(put by outgoing)  ship.cmd
      %-  ~(uni in in.cmd)
      (~(gut by outgoing) ship.cmd ~)
    ::
        %part
      ?:  =(~ in.cmd)
        ::  remove target entirely
        ::
        [known (~(del by outgoing) ship.cmd)]
      ::  remove from specified lists
      ::
      :-  |
      =.  outgoing
        =/  liz=(list @ta)  ~(tap in in.cmd)
        |-  ^+  outgoing
        ?~  liz  outgoing
        $(liz t.liz, outgoing (~(del ju outgoing) ship.cmd i.liz))
      ::NOTE  we could account for this above, but +del:ju is just easier there
      =?  outgoing  !(~(has by outgoing) ship.cmd)
        (~(put by outgoing) ship.cmd ~)
      outgoing
    ==
  ::
    ::  %pals-gesture: foreign %pals signals
    ::
      %pals-gesture
    ?<  =(our src):bowl
    =+  !<(=gesture vase)
    =-  [~ this(incoming -)]
    ?-  -.gesture
      %hey  (~(put in incoming) src.bowl)
      %bye  (~(del in incoming) src.bowl)
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =+  !<([=eyre-id =inbound-request:eyre] vase)
    ?>  authenticated.inbound-request
    ::  parse request url into path and query args
    ::
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    ::
    =;  [[status=@ud out=(unit manx)] caz=(list card) =_state]
      :_  this(state state)
      %+  weld  caz
      :: ;;  (list card)  ::NOTE  this is hilariously slow
      %+  give-simple-payload:app:server
        eyre-id
      :-  [status ~]
      ?~  out  ~
      `(as-octt:mimes:html (en-xml:html u.out))
    ::  405 to all unexpected requests
    ::
    ?.  &(?=(^ site) =('pals' i.site))
      [[500 `:/"unexpected route"] ~ state]
    ::
    =/  page=@ta
      ?~  t.site  %index
      i.t.site
    ?.  (~(has by webui) page)
      [[404 `:/"no such page: {(trip page)}"] ~ state]
    =*  view  ~(. (~(got by webui) page) +.state)
    ::
    ?+  method.request.inbound-request  [[405 ~] ~ state]
        %'GET'
      :_  [~ state]
      [200 `(build:view args ~)]
    ::
        %'POST'
      ?~  body.request.inbound-request  [[400 `:/"no body!"] ~ state]
      =/  args=(list [k=@t v=@t])
        (rash q.u.body.request.inbound-request yquy:de-purl:html)
      =/  cmd=(unit command)
        (argue:view args)
      ?~  cmd
        :_  [~ state]
        :-  400
        %-  some
        ::TODO  should pass on previous inputs to re-fill fields?
        %+  build:view  ^args
        `|^'Something went wrong! Did you provide sane inputs?'
      =^  caz  this
        (on-poke %pals-command !>(u.cmd))
      :_  [caz state]
      :-  200
      %-  some
      (build:view ^args `&^'Processed succesfully.')  ::NOTE  silent?
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)  [~ this]
  (on-watch:def path)
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?.  ?=([%hey ~] wire)  [~ this]
  ::  for %pals-gesture pokes, record the result
  ::TODO  should we slowly retry for nacks?
  ::TODO  verify src.bowl behaves correctly here. idk why it wouldn't, but...
  ::
  =-  [~ this(receipts -)]
  ?+  -.sign  ~|([%unexpected-agent-sign wire -.sign] !!)
    %poke-ack  (~(put by receipts) src.bowl ?=(~ p.sign))
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  |^  ?+  path  [~ ~]
        [%y ~]                 (arc %leeches %targets %mutuals ~)
        [%y %targets ~]        (arc (las targets))
        [%y %mutuals ~]        (arc (las mutuals))
        [%x %leeches ~]        (alp leeches)
        [%x %leeches @ ~]      (ask (bind (slaw %p i.t.t.path) (sin leeches)))
        [%x %targets ~]        (alp targets)
        [%x %targets ~ ~]      [~ ~]
        [%x %targets @ta ~]    (alp (lap targets i.t.t.path))
        [%x %targets @ta @ ~]  (ask (bind (wat t.t.path) (hal targets)))
        [%x %mutuals ~]        (alp mutuals)
        [%x %mutuals ~ ~]      [~ ~]
        [%x %mutuals @ta ~]    (alp (lap mutuals i.t.t.path))
        [%x %mutuals @ta @ ~]  (ask (bind (wat t.t.path) (hal mutuals)))
      ==
  ::  scry results
  ++  arc  |=  l=(list @ta)     (any `arch`~^(malt (turn l (late ~))))
  ++  alp  |=  s=(set @p)       (any s)
  ++  alf  |=  f=?              (any f)
  ++  ask  |=  u=(unit ?)  ?^(u (any u.u) [~ ~])
  ++  any  |*  n=*              ``noun+!>(n)
  ::  data wrestling
  ++  wat  |=([l=@ta p=@ta ~] ?~(p=(slaw %p p) ~ (some [l u.p])))
  ++  nab  ~(got by outgoing)
  ++  las  |=(s=(set @p) (zing (turn (sit s) |=(p=@p (sit (nab p))))))
  ++  lap  |=([s=(set @p) l=@ta] (ski s |=(p=@p ((sin (nab p)) l))))
  ++  hal  |=(s=(set @p) |=([l=@ta p=@p] ((sin ?~(l s (lap s l))) p)))
  ::  set shorthands
  ++  sin  |*(s=(set) ~(has in s))
  ++  sit  |*(s=(set) ~(tap in s))
  ++  ski  |*([s=(set) f=$-(* ?)] (sy (skim (sit s) f)))
  ::  pals
  ++  leeches  (~(dif in incoming) ~(key by outgoing))
  ++  targets  (~(dif in ~(key by outgoing)) incoming)
  ++  mutuals  (~(int in incoming) ~(key by outgoing))
  --
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
++  on-fail   on-fail:def
--

