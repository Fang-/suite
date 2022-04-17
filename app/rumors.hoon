::  rumors: anonymous gossip from friends of friends
::
::    fiction and falsehood, or a glimpse of the truth?
::    say it loudly enough for the whole network to hear!
::
/-  *rumors
/+  gossip, rudder, default-agent
::
/~  pages  (page:rudder rumors [~ @t])  /app/rumors/webui
::
/$  grab-rumor  %noun  %rumor
::
|%
+$  state-0
  $:  %0
      fresh=rumors  ::TODO  prune
  ==
::
+$  eyre-id  @ta
+$  card     card:agent:gall
--
::
=|  state-0
=*  state  -
::
%-  %+  agent:gossip
      [2 %anybody %anybody]
    %+  ~(put by *(map mark $-(* vase)))
      %rumor
    |=(n=* !>((grab-rumor n)))
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
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
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =;  out=(quip card _fresh)
      [-.out this(fresh +.out)]
    %.  [bowl !<(order:rudder vase) fresh]
    %-  (steer:rudder _fresh ,[~ @t])
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder fresh)
    |=  [~ new=@t]
    ^-  $@(brief:rudder [brief:rudder (list card) _fresh])
    =/  =rumor  [now.bowl new]
    :+  'the wind carries along your careless whisper...'
      [(invent:gossip %rumor !>(rumor))]~
    [rumor fresh]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)  [~ this]
  ?.  =(/~/gossip/source path)
    (on-watch:def path)
  :_  this
  %-  flop
  =|  n=@ud
  |-
  ::TODO  how does this affect data dissemination?
  ::NOTE  not really just locally-sourced data,
  ::      but that's probably the better behavior anyway.
  ?~  fresh  ~
  ?:  (gth n 5)  ~
  :-  [%give %fact ~ %rumor !>(i.fresh)]
  $(fresh t.fresh, n +(n))
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?.  ?&  =(/~/gossip/gossip wire)
          ?=(%fact -.sign)
          =(%rumor p.cage.sign)
      ==
    ~&  [dap.bowl %strange-sign wire sign]
    (on-agent:def wire sign)
  =+  !<(=rumor q.cage.sign)
  :-  ~
  ::TODO  notify if your @p is mentioned?
  =-  this(fresh -)
  |-  ^+  fresh
  ?~  fresh  [rumor ~]
  ?:  (gte when.rumor when.i.fresh)
    [rumor fresh]
  [i.fresh $(fresh t.fresh)]
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::TODO
  ::  /x/rumors
  ::  /x/rumor ? for frontend refresh button
  ~
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
