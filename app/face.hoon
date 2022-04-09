::  face: see your friends
::
::    lets you set an image url to be shared with mutuals (pals),
::    and see the images shared by your mutuals.
::    intended to be used with self-portraits.
::
/-  pals
/+  gossip, rudder, dbug, verb, default-agent
::
/~  pages  (page:rudder (map ship cord) [%set (unit cord)])  /app/face/webui
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

