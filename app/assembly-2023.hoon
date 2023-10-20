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
/~  pages   (page:rudder state-0 action)  /app/assembly-2023
::
|%
++  host-ship  ~bitdeg
+$  card  $+(card card:agent:gall)
--
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
=|  state-0
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
  :-  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ?:  =(host-ship our.bowl)  ~
  ::NOTE  technically unnecessary if we're just gonna edit /lib/a23/events...
  [%pass /events %agent [host-ship dap.bowl] %watch /events]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  =.  state  !<(state-0 ole)
  =.  database  (~(gas by *(map @ event)) all:events)  ::TODO  only on-init
  [~ this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  ~&([dap.bowl %unexpected-mark mark] !!)
      %a23-action
    ?>  =(src our):bowl
    =+  !<(act=action vase)
    ?-  -.act
        %enlist
      ?>  (~(has by database) vid.act)
      =.  calendar
        ?:  yes.act
          (~(put in calendar) vid.act)
        (~(del in calendar) vid.act)
      [~ this]
    ::
        %coming
      ?>  (~(has by database) vid.act)
      =?  groupies  yes.act
        =.  a.groupies  (~(put ju a.groupies) our.bowl vid.act)
        =.  b.groupies  (~(put ju b.groupies) vid.act our.bowl)
        groupies
      =?  groupies  !yes.act
        =.  a.groupies  (~(del ju a.groupies) our.bowl vid.act)
        =.  b.groupies  (~(del ju b.groupies) vid.act our.bowl)
        groupies
      :_  this
      =/  =cage  [%a23-command !>(act)]
      :~  [%pass /rsvp %agent [host-ship dap.bowl] %poke cage]
          (invent:gossip %a23-rsvp !>([vid.act yes.act]))
      ==
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
    ==
  ::
      %handle-http-request
    =;  out=(quip card _state)
      [-.out this(state +.out)]
    %.  [bowl !<(order:rudder vase) state]
    %-  (steer:rudder _state action)
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
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
      [%give %fact ~ %a23-update !>([%crowds crowds])]~
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
    ~?  ?=(^ p.sign)  %rsvp-poke-not-ok
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
