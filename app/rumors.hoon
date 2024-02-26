::  rumors: anonymous gossip from friends of friends
::
::    fiction and falsehood, or a glimpse of the truth?
::    say it loudly enough for the whole network to hear!
::
::    to scry all known rumors out of this agent:
::    .^((list [when=@da what=@t]) %gx /=rumors=/rumors/noun)
::
::    to be notified of new rumors as they come in, %watch on /rumors.
::    %facts will have the %rumor mark, unpack to [when=@da what=@t].
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
=<
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
      :_  this(state old)
      ?~  fresh.old  ~
      (update-widget bowl what.i.fresh.old)
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
      [%avoid @]  [~ this(avoid [+.q.vase avoid])]
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
    ?:  ?&  (gth now.bowl ~2024.4.1)
            (lth now.bowl ~2024.4.2..06.00.00)
            (lth chance 3)
            !=('FOOL! ' (end 3^6 new))
        ==
      =;  wat=@t
        =/  =rumor  [now.bowl wat]
        :+  'an anomaly warps and twists your voice...'
          [(invent:gossip %rumor !>(rumor)) (update-widget bowl new)]
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
      [(invent:gossip %rumor !>(rumor)) (update-widget bowl new)]
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
  ~|  wire
  ?:  ?=([%profile %widget @ ~] wire)
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  p.sign  [~ this]
    %.  [~ this]
    (slog (cat 3 'rumors: failed to update widget %' i.t.t.wire) u.p.sign)
  ::
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
  ::  1.024 bytes should be enough for anyone
  ::
  ?:  (gth (met 3 what.rumor) 1.024)
    [~ this]
  ::  ignore rumors that contain content from the avoid-list
  ::
  ?:  ?:  =(~ avoid)  |
      %+  levy  avoid
      |=  =@t
      ?=(^ (find (cass (trip t)) (cass (trip what.rumor))))
    [~ this]
  :-  [[%give %fact [/rumors]~ %rumor !>(rumor)] (update-widget bowl what.rumor)]
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
::
|%
++  update-widget
  |=  [=bowl:gall rumor=@t]
  ^-  (list card)
  ?.  .^(? %gu /(scot %p our.bowl)/profile/(scot %da now.bowl)/$)
    ~
  =;  widget=[%0 desc=@t %marl marl]
    =/  =cage  noun+!>([%command %update-widget %rumors %latest widget])
    [%pass /profile/widget/latest %agent [our.bowl %profile] %poke cage]~
  :^  %0  'Most recently overheard rumor'  %marl
  :~  =;  keyframes=cord
        ;style:"{(trip keyframes)}"
      '''
      #rumors--latest {
        border-radius: 40px;
        overflow: hidden;
      }
      @-webkit-keyframes rumorsbg {
        0%{background-position:51% 0%}
        50%{background-position:50% 100%}
        100%{background-position:51% 0%}
      }
      @-moz-keyframes rumorsbg {
        0%{background-position:51% 0%}
        50%{background-position:50% 100%}
        100%{background-position:51% 0%}
      }
      @keyframes rumorsbg {
        0%{background-position:51% 0%}
        50%{background-position:50% 100%}
        100%{background-position:51% 0%}
      }
      '''
    ::
      ;div
        =style  """
                position: absolute;
                top: 0.5em;
                width: 100%;
                text-align: center;
                color: white;
                opacity: 0.5;
                font-size: 0.8em;
                """
        ; rumor has it that...
      ==
    ::
      ;div
        =style  """
                padding: 30px 30px 15px;

                color: #fff0ff;
                font-family: sans-serif;
                text-shadow: 1px 1px 3px rgb(0 0 0 / 15%);
                letter-spacing: 0.1px;
                text-align: center;

                background-image: linear-gradient(345deg, #df7bdf, #847bde, #e5a0a0, #8199dc);
                background-size: 800% 800%;
                background-attachment: fixed;

                -webkit-animation: rumorsbg 60s ease infinite;
                -moz-animation: rumorsbg 60s ease infinite;
                animation: rumorsbg 60s ease infinite;
                """
        ;span:"{(trip rumor)}"
      ==
  ==
--
