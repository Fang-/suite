::  face: see your friends
::
::    lets you set an image url to be shared with mutuals (pals),
::    and see the images shared by your mutuals.
::    intended to be used with self-portraits.
::
/-  pals
/+  gossip, rudder, default-agent
::
/~    pages
    (page:rudder (map ship [@da (unit cord)]) [%set (unit cord)])
  /app/face/webui
::
/$  grab-face  %noun  %face
::
|%
+$  state-1
  $:  %1
      faces=(map ship face)
  ==
::
+$  face  [@da (unit cord)]
+$  card  card:agent:gall
--
::
=|  state-1
=*  state  -
::
%-  %+  agent:gossip
      [1 %mutuals %mutuals |]
    %+  ~(put by *(map mark $-(* vase)))
      %face
    |=(n=* !>((grab-face n)))
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    pax   /(scot %p our.bowl)/pals/(scot %da now.bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this(faces (~(put by faces) our.bowl [now.bowl ~]))
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
      =/  old=state-any  !<(state-any ole)
      =^  caz  old
        ?.  ?=(%0 -.old)  [~ old]
        (state-0-to-1 old)
      ?>  ?=(%1 -.old)
      [caz this(state old)]
  ::
  +$  state-any  $%(state-1 state-0)
  +$  state-0  [%0 faces=(map ship cord)]
  ++  state-0-to-1
    |=  old=state-0
    ^-  (quip card state-1)
    :-  ::  we nuke all outgoing subs, gossip will take over
        %+  turn  ~(tap in ~(key by wex.bowl))
        |=  [w=wire t=[@p @tas]]
        [%pass w %agent t %leave ~]
    =/  new=(map ship face)
      (~(run by faces.old) |=(f=cord `face`[now.bowl `f]))
    =?  new  !(~(has by new) our.bowl)
      (~(put by new) our.bowl [now.bowl ~])
    [%1 new]
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+  mark  (on-poke:def mark vase)
    ::  %noun: misc utilities
    ::
      %noun
    ?+  q.vase  (on-poke:def mark vase)
        [%set-face (unit cord)]
      =*  new  +.q.vase
      ?:  =(new +:(~(got by faces) our.bowl))
        [~ this]
      :-  [(invent:gossip %face !>(`face`[now.bowl new]))]~
      this(faces (~(put by faces) our.bowl [now.bowl new]))
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =;  out=(quip card _faces)
      [-.out this(faces +.out)]
    %.  [bowl !<(order:rudder vase) faces]
    %-  (steer:rudder _faces ,[%set (unit cord)])
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder faces)
    |=  [%set new=(unit cord)]
    ^-  $@(brief:rudder [brief:rudder (list card) _faces])
    =*  success  'Processed succesfully.'
    ?:  =(new (~(get by faces) our.bowl))
      [success ~ faces]
    =^  cards  this
      (on-poke %noun !>([%set-face new]))
    [success cards faces]
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
    [%give %fact ~ %face !>((~(got by faces) our.bowl))]~
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
      =+  !<(=face vase)
      [~ this(faces (~(put by faces) src.bowl face))]
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

