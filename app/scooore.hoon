::  sc'o're: chat reacts scoreboard
::
::    keep track of chat reacts you and others have received,
::    to display them in a local-perspective scoreboard.
::
::TODO  could be fun to show "rare gets", reacts that have only been given once
::
/-  chat, groups
/+  *pal, rudder,
    dbug, verb, default-agent
::
::NOTE  rudder a little bit overkill for this, since we only have
::      two read-only pages...
/~  pages  (page:rudder (mip ship feel:chat @ud) ~)  /app/scooore/webui
::
::
|%
+$  state-0
  $:  %0
      bits=(mip ship feel:chat @ud)                     ::  react tallies
      seen=(mip id:chat ship feel:chat)                 ::  known reacts
      live=(map flag:chat @da)                          ::  chats & last-heard
  ==
::
+$  card  card:agent:gall
::
++  flew
  |=  [=flag:chat last=(unit @da)]
  ^-  path
  =-  [%chat (scot %p p.flag) q.flag %updates -]
  ?~  last  /
  /(scot %da u.last)
--
::
=|  state-0
=*  state  -
::
=|  cards=(list card)
|_  =bowl:gall
+*  this  .
++  peel
  |=  =path
  [(scot %p our.bowl) %chat (scot %da now.bowl) path]
::
++  abet  [(flop cards) state]
++  emit  |=(=card this(cards [card cards]))
::
++  peer
  |=  =flag:chat
  ^+  this
  =/  =wire  /chat/(scot %p p.flag)/[q.flag]
  =/  have=?
    %-  ~(any in ~(key by wex.bowl))
    |=([w=^wire *] =(w wire))
  ?:  have  this
  %-  emit
  =;  =path
    [%pass wire %agent [our.bowl %chat] %watch path]
  =-  [%chat (scot %p p.flag) q.flag %updates -]
  =/  last=(unit @da)  (~(get by live) flag)
  ?~  last  /
  /(scot %da u.last)
::
++  init
  ^+  this
  =.  this
    %-  emit
    [%pass /eyre/bind %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  =.  this
    %-  emit
    [%pass /groups %agent [our.bowl %groups] %watch /groups]
  ::
  ~>  %bout.[0 'scooore: init']
  =/  chad=(list [=flag:chat =chat:chat])
    ?.  .^(? %gu (peel /$))  ~
    %~  tap  by
    .^((map flag:chat chat:chat) %gx (peel /chats/chats))
  ::  for every chat channel, subscribe to updates,
  ::  and accumulate reacts into :new, updating :bits only at the end
  ::
  =|  new=(map [ship feel:chat] @ud)
  =|  saw=(map [id:chat ship] feel:chat)
  |-
  ?~  chad
    %_  this
        bits
      %-  ~(rep by new)
      |=  [[[s=ship f=feel:chat] c=@ud] =_bits]
      (~(put bi bits) s f (add c (~(gut bi bits) s f 0)))
    ::
        seen
      %-  ~(rep by saw)
      |=  [[[i=id:chat s=ship] f=feel:chat] =_seen]
      (~(put bi seen) i s f)
    ==
  ::
  =*  flag=flag:chat    flag.i.chad
  =*  writs=writs:chat  wit.pact.chat.i.chad
  ::
  =/  when=@da
    =;  upd=(unit update:chat)
      (fall (bind upd head) *@da)
    (ram:log-on:chat log.chat.i.chad)
  =.  live  (~(put by live) flag when)
  =.  this  (peer flag)
  ::
  =;  [[nu=_new su=_saw] *]
    $(new nu, saw su, chad t.chad)
  %^  %-  dip:on:writs:chat
      $:  new=(map [ship feel:chat] @ud)
          saw=(map [id:chat ship] feel:chat)
      ==
      writs
    [new saw]
  |=  [[=_new =_saw] [* =writ:chat]]
  ^-  [(unit writ:chat) ? [_new _saw]]
  :+  `writ  |
  %-  ~(rep by feels.writ)
  |=  [[s=ship f=feel:chat] [=_new =_saw]]
  :_  (~(put by saw) [id.writ s] f)
  %+  ~(put by new)
    [author.writ f]
  +((~(gut by new) [author.writ f] 0))
::
++  hear
  |=  [fal=flag:chat wen=time mid=id:chat fro=ship fel=(unit feel:chat)]
  ^+  this
  =/  for=ship
    =<  author
    =;  =path  .^([time writ:chat] %gx (peel path))
    :~  %chat
        (scot %p p.fal)
        q.fal
        %writs
        %writ
        %id
        (scot %p p.mid)
        (scot %ud q.mid)
        %writ
    ==
  ::  do not count reacts given on one's own messages
  ::
  ?:  =(for fro)  this
  ::
  =/  had=(unit feel:chat)
    (~(get bi seen) mid fro)
  ?:  =(had fel)  this
  ::  if we had already counted a react from this ship on this msg,
  ::  subtract it from the tally
  ::
  =?  bits  ?=(^ had)
    =/  bat=(unit @ud)  (~(get bi bits) for u.had)
    ?-  bat
      ~       ~&([dap.bowl %strange-unseen-feel-add] bits)
      [~ %1]  (~(del bi bits) for u.had)
      [~ @]   (~(put bi bits) for u.had (dec u.bat))
    ==
  ::  if there is a new react, increment the tally
  ::
  =?  bits  ?=(^ fel)
    %^  ~(put bi bits)  for  u.fel
    +((~(gut bi bits) for u.fel 0))
  ::  always do bookkeeping
  ::
  =.  seen
    ?~  fel  (~(del bi seen) mid fro)
    (~(put bi seen) mid fro u.fel)
  =.  live
    (~(put by live) fal wen)
  ::
  ::TODO  maybe emit diff %fact?
  this
::
++  kick  peer
--
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    do    ~(. +> bowl)
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =^  cards  state
    abet:init:do
  [cards this]
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 ole))]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %noun
    ?+  q.vase  (on-poke:def mark vase)
        %re-init
      =.  bits  ~
      =.  seen  ~
      =.  live  ~
      =^  cards  state
        abet:init:do
      [cards this]
    ::
        %wipe
      =.  bits  ~
      =.  seen  ~
      [~ this]
    ==
  ::
      %handle-http-request
    =;  out=(quip card _bits)
      [-.out this]
    %.  [bowl !<(order:rudder vase) bits]
    %:  (steer:rudder _bits ,~)
      pages
      (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder bits)
      |=(~ 'unimplemented')
    ==
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  (on-agent:def wire sign)
      [%groups ~]
    :_  this
    ?-  -.sign
      %poke-ack  !!
    ::
        %kick
      [%pass /groups %agent [our.bowl %groups] %watch /groups]~
    ::
        %watch-ack
      ?~  p.sign  ~
      ((slog dap.bowl 'failed to open subscription' >wire< u.p.sign) ~)
    ::
        %fact
      ?.  ?=(%group-action-0 p.cage.sign)
        ~
      =/  =diff:groups
        q.q:!<(action:groups q.cage.sign)
      ?.  ?=([%channel [%chat *] %add *] diff)
        ~
      -:abet:(peer:do q.p.diff)
    ==
  ::
      [%chat @ @ ~]
    =/  =flag:chat
      [(slav %p i.t.wire) i.t.t.wire]
    ?-  -.sign
      %poke-ack  !!
      %kick      =^(cards state abet:kick:do [cards this])
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      %.  [~ this]
      (slog dap.bowl 'failed to open subscription' >wire< u.p.sign)
    ::
        %fact
      ?.  ?=(?(%chat-logs %chat-update-0) p.cage.sign)
        [~ this]
      =/  logs=(list [=time =diff:chat])
        ?-  p.cage.sign
          %chat-logs      (tap:log-on:chat !<(logs:chat q.cage.sign))
          %chat-update-0  [!<(update:chat q.cage.sign)]~
        ==
      =/  d  do
      |-
      ?~  logs
        =^  cards  state  abet:d
        [cards this]
      =?  d  ?=(%writs -.diff.i.logs)
        =/  dif  diff.i.logs
        =*  mid  p.p.dif
        ?+  -.q.p.dif  d
            %add-feel
          =*  fro  p.q.p.dif
          =*  new  q.q.p.dif
          (hear:d flag time.i.logs mid fro `new)
        ::
            %del-feel
          =*  fro  p.q.p.dif
          (hear:d flag time.i.logs mid fro ~)
        ==
      $(logs t.logs)
    ==
  ==
::
++  on-watch
  |=  =path
  ::TODO  maybe at some point give scoreboard updates
  ?>  ?=([%http-response @ ~] path)
  [~ this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?>  ?=([%eyre %bind ~] wire)
  ?>  ?=([%eyre %bound *] sign-arvo)
  ~?  !accepted.sign-arvo
    [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
  [~ this]
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
++  on-peek   on-peek:def
--
