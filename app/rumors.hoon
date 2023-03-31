::  rumors: anonymous gossip from friends of friends
::
::    fiction and falsehood, or a glimpse of the truth?
::    say it loudly enough for the whole network to hear!
::
/-  *rumors
/+  gossip, rudder, default-agent,
    markov, pals
::
/~  pages  (page:rudder [rumors @t (list @t) (map)] [~ @t])  /app/rumors/webui
::
/$  grab-rumor  %noun  %rumor
::
|%
+$  state-3
  $:  %3
      fresh=rumors  ::TODO  prune
      ditto=@t
      avoid=(list @t)
      tokes=nums:markov
  ==
::
+$  eyre-id  @ta
+$  card     card:agent:gall
--
::
=|  state-3
=*  state  -
::
%-  %+  agent:gossip
      [2 %anybody %anybody &]
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
  |^  ^-  (quip card _this)
      =/  old=state-any  !<(state-any ole)
      =?  old  ?=(%0 -.old)  (state-0-to-1 old)
      =?  old  ?=(%1 -.old)  (state-1-to-2 old)
      =?  old  ?=(%2 -.old)  (state-2-to-3 old)
      ?>  ?=(%3 -.old)
      [~ this(state old)]
  ::
  +$  state-any  $%(state-0 state-1 state-2 state-3)
  ::
  +$  state-0  [%0 fresh=rumors]
  ++  state-0-to-1
    |=  old=state-0
    ^-  state-1
    :-  %1
    %+  turn  fresh.old
    |=  r=rumor
    r(when (min when.r now.bowl))
  ::
  +$  state-1  [%1 fresh=rumors]
  ++  state-1-to-2
    |=  old=state-1
    ^-  state-2
    [%2 fresh.old '']
  ::
  +$  state-2  [%2 fresh=rumors ditto=@t]
  ++  state-2-to-3
    |=  old=state-2
    ^-  state-3
    =/  pos  (skip fresh.old |=([* r=@t] (gth (met 3 r) 1.024)))
    ::NOTE  if for some reason you run into memory trouble, delete old rumors:
    ::  =.  pos  (scag 1.000 pos)
    [%3 pos ditto.old ~ (roll (turn pos tail) tokenize:markov)]
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  =(src our):bowl
  ?+  mark  (on-poke:def mark vase)
    ::  %noun: misc bespoke self-management
    ::
      %noun
    ?+  q.vase  !!
      [%avoid ~]  [~ this(avoid ~)]
      [%avoid @]  [~ this(avoid [+>.q.vase avoid])]
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    ::TODO  it's somewhat annoying that display state and updateable state
    ::      are coupled here...
    =;  out=(quip card _+.state)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder _+.state ,[~ @t])
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
    |=  [~ new=@t]
    ^-  $@(brief:rudder [brief:rudder (list card) _+.state])
    ?:  =(ditto new)
      ['your voice echoes...' ~ +.state]
    =/  chance=@ud  (~(rad og eny.bowl) 6)
    ?:  ?&  (gth now.bowl ~2023.4.1)
            (lth now.bowl ~2023.4.2..06.00.00)
            (lth chance 3)
            !=('FOOL! ' (end 3^6 new))
        ==
      =;  wat=@t
        =/  =rumor  [now.bowl wat]
        :+  'an anomaly warps and twists your voice...'
          [(invent:gossip %rumor !>(rumor))]~
        [[rumor fresh] ditto avoid tokes]
      =+  t=(trip new)
      ?+  chance  !!
          %0
        =+  n=(cuss t)
        ?.  =(n t)  (crip n)
        (crip (cass t))
      ::
          %1
        =+  p=~(tap in (~(put in ~(leeches pals bowl)) ~zod))
        =+  w=(snag (~(rad og eny.bowl) (lent p)) p)
        =+  r=(~(rad og eny.bowl) 3)
        %-  crip
        ?+  r  !!
          %0  "{(scow %p w)} here, {t}"
          %1  "{t} - with love, from {(scow %p w)}"
          %2  "{t} - {(scow %p w)}"
        ==
      ::
          %2
        =+  f=(find " " t)
        =+  g=generate:markov
        =?  g  ?=(^ f)
          =+  n=(crip (cass (scag u.f t)))
          ?.  (~(has by tokes) n)  g
          g(p n)
        (g eny.bowl tokes)
      ==
    =/  =rumor  [now.bowl new]
    :+  'the wind carries along your careless whisper...'
      [(invent:gossip %rumor !>(rumor))]~
    [[rumor fresh] new avoid tokes]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)         [~ this]
  ?:  &(=(/rumors path) =(our src):bowl)  [~ this]
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
  ::  ignore rumors from the far future
  ::
  ?:  (gth when.rumor (add now.bowl ~h1))
    [~ this]
  ?:  (gth (met 3 what.rumor) 1.024)  ::  1.024 bytes should be enough 4 anyone
    [~ this]
  ?:  %+  levy  avoid
      |=  =@t
      ?=(^ (find (trip t) (cass (trip what.rumor))))
    [~ this]
  :-  [%give %fact [/rumors]~ %rumor !>(rumor)]~
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
  ?.  ?=([%x %rumors ~] path)  [~ ~]
  ``noun+!>(fresh)
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
