::  bard: interactive story-teller
::
::    minimal engine for running interactive fiction.
::    intended to run on a host ship that supplies content, then used by others
::    through |link ~host %bard.
::    pins session state to @p, rather than sole session.
::
::TODO  short-term
::      - write actual content
::      - /sur
::      - story import mechanism
::      - implement elaborate lobby menu
::      - improve node type
::
::TODO  long-term
::      - custom file format w/ parser
::      - lobby chat?
::      - consider implementing the lobby/entire app as a tale
::
::TODO  story inspo
::      - ~tocrex's galaxy girls
::      - esports vs dolphins
::      - group survival, nomads
::
/+  shoe, verb, dbug, default-agent
::
|%
+$  state-0
  $:  %0
      tales=(map term tale)
      heros=(map ship savefile)
      panes=(jug ship @ta)
  ==
::
+$  savefile
  $:  ::TODO  stats?
      =savestate
  ==
::
+$  savestate
  $%  [%lobby =area]
      [%story tale=term =told true=(list told)]  ::TODO  smarter history storing
  ==
::
+$  area
  ?(%intro %menu %recent %unplayed %all)
::
+$  tale
  $:  title=@t
      brief=@t
      start=term
      nodes=(map term node)
  ==
::
+$  told
  $:  stack=(lest node)  ::  upcoming
      store=(list term)  ::  memories
  ==
::
::TODO  separate renderable from logic nodes explicitly? for what purpose?
+$  node
  $~  [%end ~]
  $%  [%end ~]
      [%text text=@t =next]
      [%flow texts=(lest @t) =next]
      [%choice text=@t options=(lest [[pick=@t text=@t] =next])]
      [%both one=next two=next]  ::TODO  enforce both renderable?
      ::  secret: display node. if parse go (find res). if fail, node's behavior
      :: [%secret =node parser=rule find=$-(* (unit next))]
      [%store store-op]
  ==
::
+$  next  $~(~ ?(~ term node))
::
+$  store-op
  $%  [[%put =term] =next]                                ::  add
      [[%del =term] =next]                                ::  delete one
      [[%dal =term] =next]                                ::  delete all
      [[%hav =term] yes=next no=next]                     ::  have, go next
      [[%han =term] yes=next no=next]                     ::  have not, go next
      [[%set all=(list term)] =next]                      ::  replace all
      ::TODO  have all, have any
  ==
::
+$  command
  $%  [%next choice=(unit @t)]
      [%show ~]
      [%back ~]
      [%exit ~]
  ==
::
+$  card  card:shoe
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
^-  agent:gall
%-  (agent:shoe command)
^-  (shoe:shoe command)
=<
  |_  =bowl:gall
  +*  this  .
      do    +>
      def   ~(. (default-agent this %|) bowl)
      des   ~(. (default:shoe this command) bowl)
  ::
  ++  on-init
     ^-  (quip card _this)
     =.  tales  (~(put by tales) %test example-tale:content)
     [~ this]
  ::
  ++  on-save   !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    ~&  [dap.bowl %load-lmao]
    =.  state  !<(state-0 old)
    =.  tales  (~(put by tales) %test example-tale:content)
    [~ this]
  ::
  ++  on-poke   on-poke:def
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  ::
  ++  command-parser
    |=  sole-id=@ta
    ^+  |~(nail *(like [? command]))
    ~(parser do bowl sole-id)
  ::
  ++  on-command
    |=  [sole-id=@ta =command]
    ^-  (quip card _this)
    =^  cards  state
      (~(run-command do bowl sole-id) command)
    [cards this]
  ::
  ++  can-connect
    |=  sole-id=@ta
    ^-  ?
    &
  ::
  ++  on-connect
    |=  sole-id=@ta
    ^-  (quip card _this)
    =?  heros  !(~(has by heros) src.bowl)
      ~&  [%new-player src.bowl]
      %+  ~(put by heros)  src.bowl
      %*(. *savefile savestate [%lobby %intro])
    =-  [[-]~ this]
    %-  show-state:~(display do bowl sole-id)
    savestate:(~(got by heros) src.bowl)
  ::
  ++  tab-list
    |=  sole-id=@ta
    ^-  (list [@t tank])
    ~(completions do bowl sole-id)
  ++  on-disconnect   on-disconnect:des
  --
::
|_  [=bowl:gall sole-id=@ta]
+*  who  src.bowl
::
++  parser
  =/  ,savefile  (~(got by heros) who)
  |^  =-  ;~(pose perma-parser -)
      ?-  -.savestate
        %lobby  (lobby-parser +.savestate)
        %story  (story-parser +.savestate)
      ==
  ::
  ++  perma-parser
    %+  pick
      ::  keypress commands
      ::
      (full ;~(pose show exit))
    ::  write-out commands
    ::
    fail
  ::
  ++  show  (cold [%show ~] dot)
  ++  back  (cold [%back ~] gal)
  ++  exit  (cold [%exit ~] zap)
  ++  next  ;~(pose (cold [%next ~] ace) (easy [%next ~]))
  ::
  ++  lobby-parser
    |=  =area
    %+  pick
      ::  keypress commands
      ::
      ?+  area  back
        %intro  next
      ==
    ::  write-out commands
    ::
    %+  stag  %next
    %+  stag  ~
    ?+  area  fail
      %menu  (park ~(tap in ~(key by tales)))
    ==
  ::
  ++  story-parser
    |=  [tale=term =told true=(list told)]
    =*  node  i.stack.told
    %+  pick
      ::  keypress commands
      ::
      %-  full
      ;~  pose
        ?^(true back fail)
      ::
        ?+  -.node  next
          ?(%choice %end)  fail
        ==
      ==
    ::  write-out commands
    ::
    ;~  pose
      exit
    ::
      ?+    -.node
          fail
      ::
          %choice
        %+  stag  %next
        %+  stag  ~
        %-  park
        %+  turn  options.node
        (cork head head)
      ==
    ==
  ::
  ++  park  ::NOTE  kinda like +perk, but for non-literals
    |=  l=(list @t)
    ?~  l  fail
    %+  knee  *@t  |.  ~+
    ;~  pose
      (jest i.l)
      (park t.l)
    ==
  --
::
++  completions
  ^-  (list [@t tank])
  %+  weld
    :~  ['.' leaf+"-> reprint the last text/prompt"]
        ['<' leaf+"-> go backwards"]
        ['!' leaf+"exit to story selection"]
    ==
  =+  (~(got by heros) who)
  ?-  -.savestate
      %lobby
    ?.  ?=(%menu area.savestate)  ~
    %+  turn  ~(tap by tales)
    |=  [=term tale]
    [term leaf+"play {(trip title)}"]
  ::
      %story
    =*  node  i.stack.told.savestate
    ?+  -.node  [' ' leaf+"-> proceed"]~
        %choice
      %+  turn  options.node
      |=  [[pick=@t text=@t] next]
      [pick leaf+(trip (cat 3 pick text))]
    ==
  ==
::
::TODO  %clr command?
++  run-command
  |=  =command
  ^-  (quip card _state)
  =;  =savefile
    :-  [(show-state:display savestate.savefile)]~
    state(heros (~(put by heros) who savefile))
  =/  =savefile  (~(got by heros) who)
  ?-  -.command
    %show  savefile
  ::
      %next
    ?-  -.savestate.savefile
        %lobby
      ?+  area.savestate.savefile  !!
        %intro  savefile(area.savestate %menu)
      ::
          %menu
        =/  =term  (need choice.command)
        =/  ,tale  (~(got by tales) term)
        =/  =node  (~(got by nodes) start)
        =/  =told  %*(. *told stack [node]~)
        savefile(savestate [%story term told ~])
      ==
    ::
        %story
      =-  savefile(savestate -)
      ^-  savestate
      =,  savestate.savefile
      ~|  [%tale tale]
      :^  %story  tale
        %^  go-next:reader
            nodes:(~(got by tales) tale)
          told
        choice.command
      [told true]
    ==
  ::
      %back
    ?-  -.savestate.savefile
        %lobby
      ?:  ?=(%intro area.savestate.savefile)  savefile
      savefile(area.savestate %intro)
    ::
        %story
      =,  savestate.savefile
      %_  savefile
        told.savestate  (snag 0 true)
        true.savestate  (slag 1 true)
      ==
    ==
  ::
      %exit
    savefile(savestate [%lobby %menu])
  ==
::
++  reader
  |%
  ::  +unpack-next: produce the next node, if any
  ::
  ++  unpack-next
    |=  [=next nodes=(map term node)]
    ^-  (unit node)
    ?~  next  ~
    %-  some
    ?^  next  next
    ~|  [%no-such-node next]
    (~(got by nodes) next)
  ::  +proceed-into: add :next to the stack if it exists, %end if empty stack
  ::
  ++  proceed-into
    |=  [=next nodes=(map term node) stack=(list node)]
    ^-  (lest node)
    ?^  n=(unpack-next next nodes)
      [u.n stack]
    ?~  stack  [%end ~]~
    stack
  ::  +descend: pop the stack until top node is renderable
  ::
  ::TODO  also produce the sequence of nodes that was popped off, so that it
  ::      can be passed into a +inverse function, for an inverse node to push
  ::      onto the "undo stack", or whatever kind of stack you want to be able
  ::      to just move back on top of the current stack (& run to next renderable)
  ::      in order to recreate past state
  ::
  ++  descend
    |=  [nodes=(map term node) told]
    ^-  told
    =*  node  i.stack
    ?+  -.node  [stack store]
      %end  [[node]~ store]
    ::
        %both
      =-  $(stack -)
      ::TODO  this is a bit weird. maybe instead unpack all, welp one two t.stack?
      %+  welp
        (drop (unpack-next one.node nodes))
      (proceed-into two.node nodes t.stack)
    ::
        %store
      =;  [=next =_store]
        $(stack (proceed-into next nodes t.stack), store store)
      ?-  +<-.node
          ?(%put %del %dal %set)
        :-  next.node
        ?-  +<-.node
          %put  [term.node store]
          %del  ?~  i=(find [term.node]~ store)  store
                (oust [u.i 1] store)
          %dal  (skip store |=(t=term =(t term.node)))
          %set  all.node
        ==
      ::
          ?(%hav %han)
        :_  store
        =;  yes=?
          ?:(yes yes.node no.node)
        ?-  +<-.node
          %hav  ?=(^ (find [term.node]~ store))
          %han  ?=(~ (find [term.node]~ store))
        ==
      ==
    ==
  ::  +ascend: reverse descend
  ::
  ++  ascend
    !!
  ::  +go-next: find the next node and descend into it
  ::
  ++  go-next
    |=  [nodes=(map term node) told choice=(unit @t)]
    ^-  told
    =*  node  i.stack
    =;  =next
      (descend nodes (proceed-into next nodes t.stack) store)
    ?+  -.node  ~|([%no-step-on -.node] !!)
      %text  next.node
    ::
        %flow
      ?~  t.texts.node  next.node
      node(texts t.texts.node)
    ::
        %choice
      ?:  ?=(~ choice)  ~|([%no-choice text.node] !!)
      |-
      =*  option  i.options.node
      ?:  =(u.choice pick.option)  next.option
      ?~  t.options.node  ~|([%bad-choice u.choice] !!)
      $(options.node t.options.node)
    ==
  ::  +go-back: find the last step in history and ascend back up it
  ::
  ++  go-back
    |=  [nodes=(map term node) told]
    ^-  told
    !!
  --
::
++  display
  |%
  ++  intro-text
    '''
    The bonfire crackles and puffs. Sparks float up into the night sky and
    pretend to be stars.

    You join a group near the bonfire. A bard is telling tall tales. Noticing
    your arrival, a small child walks over to hand you a flyer. You read it:

      At any time, you can press:
      - space or return to continue,
      - . to re-print the last piece of text,
      - < to step backward, like undo,
      - tab to be reminded of these, and perhaps others things you can do.

    '''
  ::
  ::TODO  motd
  ++  lobby-text
    'Having finished the story, the bard asks you which one he should tell next.\0a'
  ::
  ++  end-text
    '''
    You have reached the end of this story.
    Tune in next week for another thrilling tale!
    Press ! to go back to the lobby.
    '''
  ::
  ++  show-state
    |=  =savestate
    ^-  card
    :+  %shoe  [sole-id]~
    :+  %sole  %mor
    :-  txt+""
    :-  (show-prompt savestate)
    ?-  -.savestate
      %lobby  (show-lobby +.savestate)
      %story  (show-node i.stack.told.savestate)
    ==
  ::
  ++  show-prompt
    |=  =savestate
    ^-  sole-effect:shoe
    :-  %pro
    ^-  sole-prompt:shoe
    |^  ?-  -.savestate
          %lobby  [& %lobby (pre ['lobby> ']~)]
          %story  [& tale.savestate (pre [(cat 3 tale.savestate '> ')]~)]
        ==
    ::
    ++  pre
      |=  =styx
      [':' styx]
    --
  ::
  ++  show-lobby
    |=  =area
    ^-  (list sole-effect:shoe)
    ?+  area  !!
        %intro
      (lines-as-txts intro-text)
    ::
        %menu
      :-  txt+(trip lobby-text)
      %+  turn  ~(tap by tales)
      |=  [=term tale]
      :-  %klr
      :~  '  '
          [[`%br ~ ~] term ~]
          ' ] '
          title
          ': '
          brief
      ==
    ==
  ::
  ++  show-node
    |=  =node
    ^-  (list sole-effect:shoe)
    :_  ~
    ^-  sole-effect:shoe
    |^  ?-  -.node
          %end     (lines end-text)
          %text    (lines text.node)
          %flow    (lines i.texts.node)
          %both    ~|([dap.bowl %cannot-show -.node] !!)
          :: %many    ~|([dap.bowl %cannot-show -.node] !!)
          %store   ~|([dap.bowl %cannot-show -.node] !!)
          %choice  [%mor (lines text.node) (choices options.node)]
        ==
    ::
    ++  lines
      |=  lines=@t
      :-  %mor  ::TODO  don't newlines auto-print? yes, but maybe not at correct indent. want manual newlines always for max render control
      %+  turn
        %+  rash  lines
        %+  more  (just '\0a')
        (star ;~(less (just '\0a') ^next))
      |=(t=tape [%txt t])
    ::
    ++  choices
      |=  options=(lest [[pick=@t text=@t] =next])
      ^-  (list sole-effect:shoe)
      :_  ?~  t.options  ~
          $(options t.options)
      :-  %klr
      =,  i.options
      :~  '  ) '
          [[`%br ~ ~] pick ~]
          text
      ==
    --
  ::
  ++  simple-wrap
    |=  [txt=tape wid=@ud]
    ^-  (list tape)
    ?~  txt  ~
    =/  [end=@ud nex=?]
      =/  ret  (find "\0a" (scag +(wid) `tape`txt))
      ?^  ret  [u.ret &]
      ?:  (lte (lent txt) wid)
        [(lent txt) &]
      =/  ace  (find " " (flop (scag +(wid) `tape`txt)))
      ?~  ace  [wid |]
      [(sub wid u.ace) &]
    :-  (tufa (scag end `(list @)`txt))
    $(txt (slag ?:(nex +(end) end) `tape`txt))
  --
::
++  content
  |%
  ++  build-tale
    |=  [title=@t brief=@t nodes=(list [=term =node])]
    ^-  tale
    :+  title  brief
    ?~  nodes
      ~|  %empty-tale
      !!
    :-  term.i.nodes
    (~(gas by *(map term node)) nodes)
  ::
  ++  example-tale
    ^~
    %^  build-tale  'Doomo'
      'A short demo story.'
    ^-  (list [term node])
    :~
      :-  %intro  ::TODO  build into engine
      :+  %text
        'you are a traveler. your clothes needs replacing.'
      %crossroads
    ::
      :-  %crossroads
      :+  %both
        :^  %store  [%hav %rebirth]
          [%text 'the sun is shining brightly.' ~]
        :+  %text  'the sun is about to set.'
        :^  %store  [%han %soaked]
          ~
        [%text 'you are soaking wet.' ~]
      :+  %choice
        'you stand at the crossroads. which way do you go?'
      :~
        :-  ['go north' ', into the mountains']  %mt-teal-foot
        :-  ['go south' 'ish, to the pole']      %south-pole-ferry
        :-  ['go west' ', to azure lake']        %azure-lake
      ==
    ::
      :-  %mt-teal-foot
      :+  %text
        'a mountain troll eats you.'
      [%end ~]
    ::
      :-  %azure-lake
      :+  %text
        'you arrive at azure lake. the water tempts you, and you fall in!'
      :+  %choice
        'you are floating on azure lake. what do you do?'
      :~
        :-  ['swim' ' south']
        [%text 'the lake is too big to swim across. you lose.' %end ~]
      ::
        :-  ['give up' '']
        :+  %text
          'you put your life in fate\'s hands and sink to the bottom of the lake'
        :+  %text
          '...'
        :+  %store  [%put %rebirth]
        :+  %choice
          '''
          you wake up on the lakeshore.
          your clothes are gone. thick scales cover your skin!
          what now?
          '''
        :~
          :-  ['despair' '']
          :+  %text
            'you spend the rest of your days regretting your fate. you lose.'
          [%end ~]
        ::
          [['return' ' from whence you came'] %crossroads]
        ==
      ::
        :-  ['get out' ' and head back']
        :+  %store  [%put %soaked]
        %crossroads
      ==
    ::
      :-  %south-pole-ferry
      :+  %text
        'you arrive at the southish pole.'
      :^  %store  [%hav %soaked]
        [%text 'you die of hypothermia. you lose.' %end ~]
      :+  %text
        '''
        you hear the sound of snow falling.
        near the water's edge, a man waves at you.
        '''
      :+  %choice
        'the ferryman greets you. \'where to, traveler?\''
      :~
        :-  ['further' ' south']             %offer
        :-  ['back' ' where you came from']  %crossroads
      ==
    ::
      :-  %offer
      :+  %text
        'you get aboard the ferry and set off.'
      :+  %both
        :^  %store  [%hav %rebirth]
          ~
        :+  %choice
          'the ferryman offers to give you new clothes.'
        :~
          :-  ['accept' ' the clothes']   [%store [%put %debt] ~]
          :-  ['reject' ' his offer']     ~
        ==
      :+  %text
        'the ferry arrives in the land of the dead.'
      :^  %store  [%hav %debt]
        :+  %text
          'in return for the clothes, the ferryman takes your soul. you lose.'
        [%end ~]
      :+  %text
        'you venture into the land of the dead.'
      :^  %store  [%han %rebirth]
        :+  %text
          'you have no protection, and get eaten by a ghoul. you lose.'
        [%end ~]
      :+  %text
        'a ghoul tries to eat you, but can\'t bite through your scales.'
      :+  %text
        '''
        among the dead, you find your dog.
        you are reunited at last.
        '''
      [%end ~]
    ==
  --
::
::
++  lines-as-txts
  |=  =cord
  ^-  (list sole-effect:shoe)
  %+  rash  cord
  %+  more  (just '\0a')
  %+  stag  %txt
  %-  star
  ;~(less (just '\0a') ^next)
--
