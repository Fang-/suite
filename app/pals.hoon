::  pals: manual peer discovery
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
::    external applications likely want to read from this via scries or
::    watches, both of which are outlined below.
::    finding interaction targets or mutuals to poke or subscribe to, using
::    mutual status as permission check, etc.
::    libraries for handling generalizable behavior are in the works.
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
::TODO  consider removing /mutuals, only meaningful to ui ...right?
::      or do apps want it to avoid permission-based poke/watch nacks?
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
::      subscription endpoints (local ship only, all %pals-effect marks)
::    /targets   target-effect   effect for every addition/removal
::    /leeches   leeche-effect   effect for every addition/removal
::
::
/-  *pals
/+  rudder, dbug, verb, default-agent
::
/~  pages  (page:rudder records command)  /app/pals/webui
::
|%
+$  state-0  [%0 records]
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
  =^  cards  this
    (on-poke %pals-command !>(`command`[%meet ~paldev ~]))
  =-  [[- cards] this]
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
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
      :~  =/  =gesture  ?-(-.cmd %meet [%hey ~], %part [%bye ~])
          =/  =cage     [%pals-gesture !>(gesture)]
          [%pass /[-.gesture] %agent [ship.cmd %pals] %poke cage]
        ::
          =/  =effect   ?-(-.cmd %meet [- ship]:cmd, %part [- ship]:cmd)
          =/  =cage     [%pals-effect !>(effect)]
          [%give %fact [/targets]~ cage]
      ==
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
    =*  ship  src.bowl
    =+  !<(=gesture vase)
    =/  [yow=? =_incoming]
      =*  has  (~(has in incoming) ship)
      ?-  -.gesture
        %hey  :-  !has  (~(put in incoming) ship)
        %bye  :-   has  (~(del in incoming) ship)
      ==
    :_  this(incoming.state incoming)
    ?.  yow  ~
    =/  =effect  ?-(-.gesture %hey [%near ship], %bye [%away ship])
    =/  =cage    [%pals-effect !>(effect)]
    [%give %fact [/leeches]~ cage]~
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =;  out=(quip card _+.state)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder _+.state command)
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
    |=  cmd=command
    ^-  $@  brief:rudder
        [brief:rudder (list card) _+.state]
    =^  caz  this
      (on-poke %pals-command !>(cmd))
    ['Processed succesfully.' caz +.state]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ::
      [%targets ~]
    :_  this
    %+  turn  ~(tap in ~(key by outgoing))
    |=(=@p [%give %fact ~ %pals-effect !>(`effect`[%meet p])])
  ::
      [%leeches ~]
    :_  this
    %+  turn  ~(tap in incoming)
    |=(=@p [%give %fact ~ %pals-effect !>(`effect`[%near p])])
  ==
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
  ?>  =(our src):bowl
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
  ++  arc  |=  l=(list @ta)  ``noun+!>(`arch`~^(malt (turn l (late ~))))
  ++  alp  |=  s=(set @p)    ``noun+!>(s)
  ++  alf  |=  f=?           ``noun+!>(f)
  ++  ask  |=  u=(unit ?)  ?^(u (alf u.u) [~ ~])
  ::  data wrestling
  ++  wat  |=([l=@ta p=@ta ~] ?~(p=(slaw %p p) ~ (some [l u.p])))
  ++  nab  ~(got by outgoing)
  ++  las  |=(s=(set @p) (zing (turn (sit s) |=(=@p (sit (nab p))))))
  ++  lap  |=([s=(set @p) l=@ta] (ski s |=(=@p ((sin (nab p)) l))))
  ++  hal  |=(s=(set @p) |=([l=@ta =@p] ((sin ?~(l s (lap s l))) p)))
  ::  set shorthands
  ++  sin  |*(s=(set) ~(has in s))
  ++  sit  |*(s=(set) ~(tap in s))
  ++  ski  |*([s=(set) f=$-(* ?)] (sy (skim (sit s) f)))
  ::  pals
  ++  leeches  incoming
  ++  targets  ~(key by outgoing)
  ++  mutuals  (~(int in targets) leeches)
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

