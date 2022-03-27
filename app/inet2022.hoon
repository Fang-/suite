::  invisible networks: daily flash-fiction prompts event
::
::    event by ~tocrex-holpen, powered by ~paldev
::
/-  *inet
/+  rudder, dbug, verb, default-agent
/~  pages  (page:rudder state action)  /app/inet/webui
::
|%
++  host   ~tocrex-holpen
+$  state-0  [%0 state]
+$  card   card:agent:gall
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
::
=<
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    =.  start  ~2022.3.20  ::TODO
    =.  sprouts
      :~  'slime computation'
          'psyche-sort'
          'goblin marketplace'
          'kafka\'s metaverse'
          'composite memory palace'
          'witch hunter, witch gatherer'
          'onion-based design framework'
          'keyboards in unusual places'
          'swordle'
          'friendweb 🕷'
          'unskippable 30 hour advertisement'
          'online->oncube'
          'machine yearning'
          'at the end of the infinite feed'
        ::
          'clippy\'s dreamtime'
          'OOmscrolling'
          'credit spore'
          'approval miasma'
          'tamagotchi soul'
      ==
    :_  this
    :-  [%pass /eyre/connect %arvo %e %connect [~ /invisible-networks] dap.bowl]
    ?:  =(host our.bowl)  ~
    [%pass /host %agent [host dap.bowl] %watch /all]~
  ::
  ++  on-save  !>(state)
  ::
  ++  on-load
    |=  ole=vase
    ^-  (quip card _this)
    =/  old=state-0  !<(state-0 ole)
    =.  start.old  ~2022.3.20  ::TODO
    [~ this(state old)]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
        %inet-action
      =+  !<(act=action vase)
      =*  upd  `update`[%stories [src.bowl act]~]
      ?-  -.act
        %pre  [~ this]
      ::
          %add
        ?:  =(host our.bowl)
          :_  this(state (put-story src.bowl & +.act))
          [%give %fact [/all]~ %inet-update !>(upd)]~
        ?>  =(src our):bowl
        :_  this(state (put-story our.bowl | +.act))
        :_  ~
        :+  %pass  /submit/(scot %ud id.act)
        [%agent [host dap.bowl] %poke %inet-action !>(act)]
      ::
          %del
        ?:  =(host our.bowl)
          :_  this(state (del-story src.bowl +.act))
          [%give %fact [/all]~ %inet-update !>(upd)]~
        ?>  =(src our):bowl
        :_  this(library (~(del by library) our.bowl id.act))
        [%pass /delete %agent [host dap.bowl] %poke %inet-action !>(act)]~
      ::
          %luv
        ?:  =(host our.bowl)
          ?.  (~(has by library) index.act)  [~ this]
          :_  this(state (luv-story index.act src.bowl))
          [%give %fact [/all]~ %inet-update !>(upd)]~
        ?>  =(src our):bowl
        :_  this(state (luv-story index.act our.bowl))
        [%pass /like %agent [host dap.bowl] %poke %inet-action !>(act)]~
      ==
    ::
      ::  %handle-http-request: incoming from eyre
      ::
        %handle-http-request
      =;  out=(quip card _+.state)
        [-.out this(+.state +.out)]
      %.  [bowl !<(order:rudder vase) +.state]
      %-  (steer:rudder _+.state action)
      :^    pages
          (point:rudder /invisible-networks & ~(key by pages))
        (fours:rudder +.state)
      |=  act=action
      ^-  $@  brief:rudder
          [brief:rudder (list card) _+.state]
      ?-  -.act
        %pre  [~ ~ +.state]
      ::
          %add
        :-  ~
            :: ?:  =(host our.bowl)
            ::   'thank you for your submission'
            :: 'thank you for your submission, it will appear shortly'
        =^  caz  this  (on-poke %inet-action !>(act))
        [caz +.state]
      ::
          %del
        =*  index  [src.bowl id.act]
        ?.  (~(has by library) index)
          'no such story'
        :-  ~
            :: ?:  =(host our.bowl)
            ::   'your submission has been deleted'
            :: 'your submission will be deleted shortly'
        =^  caz  this  (on-poke %inet-action !>(act))
        [caz +.state]
      ::
          %luv
        :-  ~
        =^  caz  this  (on-poke %inet-action !>(act))
        [caz +.state]
      ==
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?:  ?=([%submit @ ~] wire)
      ?.  &(?=(%poke-ack -.sign) ?=(~ p.sign))
        ~&  [dap.bowl %failed-submit wire]
        (on-agent:def wire sign)
      =/  =index  [our.bowl (slav %ud i.t.wire)]
      =?  library  (~(has by library) index)
        %+  ~(jab by library)  index
        |=(=story story(echoed &))
      [~ this]
    ?.  =(/host wire)  (on-agent:def wire sign)
    ?<  =(host our.bowl)
    ?-  -.sign
      %poke-ack  (on-agent:def wire sign)
      %kick      [[%pass /host %agent [host dap.bowl] %watch /all]~ this]
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      %-  (slog 'watch-nack, will resub in ~m2' u.p.sign)
      :_  this
      [%pass /host %arvo %b %wait (add now.bowl ~m2)]~
    ::
        %fact
      ?.  =(%inet-update p.cage.sign)
        ~&  [dap.bowl %unexpected-mark p.cage.sign]
        [~ this]
      =+  !<(upd=update q.cage.sign)
      ?-  -.upd
        %sprouts  [~ this(sprouts sprouts.upd)]
      ::
          %stories
        |-
        ?~  changes.upd  [~ this]
        =*  change  i.changes.upd
        ::NOTE  ugly hack lol, but at least we avoid code duplication
        =^  *  this
          %-  on-poke(our.bowl host, src.bowl author.change)
          [%inet-action !>(action.change)]
        $(changes.upd t.changes.upd)
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+  path  (on-watch:def path)
      [%http-response *]  [~ this]
    ::
        [%all ~]
      =;  stories=(list [@p action])
        :_  this
        :~  :: [%give %fact ~ %inet-update !>(`update`[%sprouts sprouts])]
            [%give %fact ~ %inet-update !>(`update`[%stories stories])]
        ==
      %+  turn  ~(tap by library)
      |=  [index =story]
      [author.story %add id +>+.story]
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
    ::
        [%behn %wake *]
      ?>  ?=([%host ~] wire)
      :_  this
      [%pass /host %agent [host dap.bowl] %watch /all]~
    ==
  ::
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
::
|%
++  put-story
  |=  [author=@p echoed=? id=@ sprout=@ud date=@da body=@t]
  ^+  state
  =*  index  `^index`[author id]
  ?:  (~(has by library) index)
    =-  state(library -)
    =-  (~(put by library) index [author echoed ~ sprout date body])
    likes:(~(got by library) index)
  %_  state
    library  (~(put by library) index [author echoed ~ sprout date body])
    volumes  (~(add ja volumes) sprout index)
    authors  (~(add ja authors) author index)
  ==
::
++  del-story
  |=  =index
  ^+  state
  ?.  (~(has by library) index)  state
  =+  (~(got by library) index)
  %_  state
    library  (~(del by library) index)
  ::
      volumes
    %+  ~(put by volumes)  sprout
    =/  l=(list ^index)  (~(get ja volumes) sprout)
    (oust [(need (find [index]~ l)) 1] l)
  ::
      authors
    ?>  =(author author.index)
    %+  ~(put by authors)  author
    =/  l=(list ^index)  (~(get ja authors) author)
    (oust [(need (find [index]~ l)) 1] l)
  ==
::
++  luv-story
  |=  [=index who=@p]
  =-  state(library -)
  %+  ~(jab by library)  index
  |=  s=story
  s(likes (~(put in likes.s) who))
--
