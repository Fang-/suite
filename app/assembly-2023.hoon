::  assembly 2023: schedule browser & manager, map, peer discovery
::
::    within the app, all date-times are in the local (lisbon) timezone
::
::NOTE  rushjob code herein, pls don't use as reference material
::
/+  *assembly-2023,  events=assembly-2023-events,
    gossip, rudder,
    dbug, verb
::
/~  pages   (page:rudder state action)  /app/assembly-2023
::
|%
++  host-ship  ~bitdeg
+$  card  $+(card card:agent:gall)
--
::
::
::
%-  %+  agent:gossip
      [1 %mutuals %mutuals |]
    %+  ~(put by *(map mark $-(* vase)))
      %a23-rsvp
    |=(n=* !>(;;([=vid yes=?] n)))
::
:: %-  %^  agent:negotiate  |
::       [[%a23 0] ~ ~]
::     [[%assembly-2023 [[%a23 0] ~ ~]] ~ ~]
::
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
::
^-  $+(agent agent:gall)
::
|_  =bowl:gall
+*  this  .
::
++  on-init
  ^-  (quip card _this)
  =.  database
    (~(gas by database) all:events)
  :_  this
  :-  [%pass /eyre/connect %arvo %e %connect [~ /assembly] dap.bowl]
  ?:  =(host-ship our.bowl)  ~
  ::NOTE  technically unnecessary if we're just gonna edit /lib/a23/events...
  ::NOTE  but now also used for message passing
  [%pass /events %agent [host-ship dap.bowl] %watch /events]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
      =/  old  !<(state-any ole)
      =?  old  ?=(%0 -.old)  (state-0-to-1 old)
      ?>  ?=(%1 -.old)
      =.  state  old
      =.  database  (~(gas by *(map @ event)) all:events)  ::NOTE  beware
      [~ this]
  ::
  +$  state-any  $%(state-0 state-1)
  ::
  ++  state-0-to-1
    |=  s=state-0
    ^-  state-1
    =-  s(- %1, messages -)
    %+  sort
      ~(tap in (~(gas in *(set [@p @da @t])) messages.s))
    |=  [[@p a=@da @t] [@p b=@da @t]]
    (gth a b)
  ::
  +$  state-0
    $:  %0
        database=(map vid event)
        crowding=(map vid (each (set @p) @ud))  :: %&: host-only
      ::
        calendar=(set vid)
        groupies=[a=(jug @p vid) b=(jug vid @p)]  ::  pals & us
      ::
        messages=(list [who=@p wen=@da wat=@t])
        ruffians=(set @p)
    ==
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  ~&([dap.bowl %unexpected-mark mark] !!)
      %noun
    ?>  =(src our):bowl
    ?+  q.vase  !!
        [%reject @p]
      =.  ruffians  (~(put in ruffians) +.q.vase)
      =.  messages  (skip messages |=([who=@p *] =(who +.q.vase)))
      :_  this
      [%give %fact [/events]~ %a23-update !>([%reject +.q.vase])]~
    ::
        [%revive @p]
      =.  ruffians  (~(del in ruffians) +.q.vase)
      [~ this]
    ==
  ::
      %a23-action
    ?>  =(src our):bowl
    =+  !<(act=action vase)
    ?-  -.act
        %coming
      ?>  (~(has by database) vid.act)
      =.  calendar
        ?:  yes.act
          (~(put in calendar) vid.act)
        (~(del in calendar) vid.act)
      ::
      =?  groupies  yes.act
        =.  a.groupies  (~(put ju a.groupies) our.bowl vid.act)
        =.  b.groupies  (~(put ju b.groupies) vid.act our.bowl)
        groupies
      =?  groupies  !yes.act
        =.  a.groupies  (~(del ju a.groupies) our.bowl vid.act)
        =.  b.groupies  (~(del ju b.groupies) vid.act our.bowl)
        groupies
      ::
      :_  this
      =/  =cage  [%a23-command !>(act)]
      :~  [%pass /rsvp %agent [host-ship dap.bowl] %poke cage]
          (invent:gossip %a23-rsvp !>([vid.act yes.act]))
      ==
    ::
        %advice
      =.  messages  [[our.bowl (ut-to-pt now.bowl) wat.act] messages]
      :_  this
      =/  =cage  [%a23-command !>(act)]
      [%pass /message %agent [host-ship dap.bowl] %poke cage]~
    ==
  ::
      %a23-command
    ?>  =(our.bowl host-ship)
    =+  !<(cmd=to-host vase)
    ?-  -.cmd
        %coming
      ?.  (~(has by database) vid.cmd)
        [~ this]
      =/  old=(set @p)
        =<  ?>(?=(%& -) +)
        (~(gut by crowding) vid.cmd &+~)
      =/  new=(set @p)
        ?:  yes.cmd  (~(put in old) src.bowl)
        (~(del in old) src.bowl)
      ?:  =(old new)  [~ this]
      =.  crowding  (~(put by crowding) vid.cmd &+new)
      :_  this
      =/  =update  [%coming vid.cmd ~(wyt in new)]
      [%give %fact [/events]~ %a23-update !>(update)]~
    ::
        %advice
      ?:  (~(has in ruffians) src.bowl)
        [~ this]
      ?:  =(%pawn (clan:title src.bowl))
        [~ this]
      =/  bad=?  (gth (met 3 wat.cmd) 1.024)
      ?:  bad  [~ this]
      =/  now=@da  (ut-to-pt now.bowl)
      =/  new      [src.bowl now wat.cmd]
      =.  messages  [new messages]
      :_  this
      [%give %fact [/events]~ %a23-update !>([%advice [new]~])]~
    ==
  ::
      %handle-http-request
    =;  out=(quip card _state)
      [-.out this(state +.out)]
    %.  [bowl !<(order:rudder vase) state]
    %-  (steer:rudder _state action)
    :^    pages
        (point:rudder /assembly & ~(key by pages))
      (fours:rudder state)
    |=  act=action
    ^-  $@  brief:rudder
        [brief:rudder (list card) _state]
    =^  caz  this
      (on-poke %a23-action !>(act))
    ['Processed succesfully.' caz state]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    [~ this]
  ?:  =(/events path)
    ?>  =(our.bowl host-ship)
    :_  this
    ::NOTE  for now, we're just editing the /lib/a23/events file for this
    :: :-  [%give %fact ~ %a23-update !>([%events &+database])]
    =;  crowds=(map vid @ud)
      :~  [%give %fact ~ %a23-update !>([%crowds crowds])]
          [%give %fact ~ %a23-update !>([%advice (scag 50 messages)])]
      ==
    %-  ~(run by crowding)
    |=  a=(each (set @p) @ud)
    ^-  @ud
    ~?  ?=(%| -.a)  [%uh crowding]
    ?>  ?=(%& -.a)
    ~(wyt in p.a)
  ?:  =(/~/gossip/source path)
    :_  this
    %+  turn  ~(tap in (~(get ju a.groupies) our.bowl))
    |=  =vid
    [%give %fact ~ %a23-rsvp !>([vid &])]
  ~&  [dap.bowl %bad-watch path]
  !!
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  ~|([dap.bowl %unexpected-wire wire] !!)
      [%rsvp ~]
    ?>  ?=(%poke-ack -.sign)
    ?:  ?=(^ p.sign)  ((slog 'rsvp-poke-not-ok' u.p.sign) [~ this])
    [~ this]
  ::
      [%message ~]
    ?>  ?=(%poke-ack -.sign)
    ~?  ?=(^ p.sign)  %message-poke-not-ok
    [~ this]
  ::
      [%events ~]
    ?<  =(our.bowl host-ship)
    ?-  -.sign
        %poke-ack
      ~&  [%unexpected-poke-ack wire=wire sign]
      [~ this]
    ::
        %kick
      :_  this
      [%pass /events %agent [host-ship dap.bowl] %watch /events]~
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      ~&  [dap.bowl %watch-rejected-by-host-ship]
      [[%pass /events/retry %arvo %b %wait (add now.bowl ~m30)]~ this]
    ::
        %fact
      ?>  =(%a23-update p.cage.sign)
      =+  !<(upd=update q.cage.sign)
      ?-  -.upd
          %events
        ?:  ?=(%& -.dab.upd)
          [~ this(database p.dab.upd)]
        ?^  ven.p.dab.upd
          [~ this(database (~(put by database) [vid u.ven]:p.dab.upd))]
        =*  vid  vid.p.dab.upd
        =.  database  (~(del by database) vid)
        =.  crowding  (~(del by crowding) vid)
        =.  calendar  (~(del in calendar) vid)
        =.  groupies
          =/  had=(set @p)  (~(get ju b.groupies) vid)
          :_  (~(del by b.groupies) vid)
          %+  roll  ~(tap in had)
          |=  [who=@p =_a.groupies]
          (~(del ju a) who vid)
        [~ this]
      ::
          %crowds
        =.  crowding  (~(run by nus.upd) (lead %|))
        [~ this]
      ::
          %coming
        =.  crowding  (~(put by crowding) [vid |+num]:upd)
        [~ this]
      ::
          %advice
        =.  vas.upd
          %+  skip  vas.upd
          |=  m=[who=@p @da @t]
          ?|  =(who.m our.bowl)
              ::  we might get dupes in resubscribe scenarios
              ?=(^ (find [m]~ messages))
          ==
        =.  messages  (weld vas.upd messages)
        [~ this]
      ::
          %reject
        =.  messages  (skip messages |=([who=@p *] =(who who.upd)))
        [~ this]
      ==
    ==
  ::
      [%~.~ %gossip %gossip ~]
    ?>  ?=(%fact -.sign)
    ?>  =(%a23-rsvp p.cage.sign)
    =+  !<([=vid yes=?] q.cage.sign)
    =?  groupies  yes
      =.  a.groupies  (~(put ju a.groupies) src.bowl vid)
      =.  b.groupies  (~(put ju b.groupies) vid src.bowl)
      groupies
    =?  groupies  !yes
      =.  a.groupies  (~(del ju a.groupies) src.bowl vid)
      =.  b.groupies  (~(del ju b.groupies) vid src.bowl)
      groupies
    [~ this]
  ==
::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ?+  wire  ~|([dap.bowl %unexpected-wire wire] !!)
      [%events %retry ~]
    ?>  ?=([%behn %wake ~] sign)
    [[%pass /events %agent [host-ship dap.bowl] %watch /events]~ this]
  ::
      [%eyre %connect ~]
    [~ this]
  ==
::
++  on-peek  |=(=path `(unit (unit cage))`~)
++  on-leave  |=(=path `(quip card _this)`[~ this])
++  on-fail
  |=  [=term =tang]
  ^-  (quip card _this)
  %-  (slog 'assembly-2023 on-fail' term tang)
  [~ this]
--
