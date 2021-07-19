::  olympics: manage a group surrounding live olympics data
::
::    we should post live updates to a "live discussion (spoilers)" chat
::    with results as replies to the event start msg
::
::    once we have that, we should maintain a "schedule" post containing
::    all known events (or just today and after)
::
::TODO  "daily" timer that fires daily after events have ended
::      gotta find the right hour offset
::
/-  *enetpulse,
    *resource, graph=graph-store
/+  static=enetpulse-static, gr=graph, pal,
    dbug, verb, default-agent
::
|%
+$  state-0
  $:  %0
      db=full-db
      last-db=@da
      last-stages=@da
    ::
      results=(map @t result)
    ::
      ::NOTE  event ids
      happening=(set @t)  ::  (~(dif in ~(key by started)) ~(key by results))
      started=(map @t index:graph)
      next-event-timer=(unit @da)
  ==
::
+$  action
  $%  [%test-msg ~]
      [%test-reply msg=@]
      [%test-update-post ~]
  ==
::
++  rate
  |%
  ++  data     ~m15
  ++  results  ~m2
  --
::
::TODO  update!!
++  group-id  `resource`[~zod %muholympics]
++  live-chat  `resource`[~zod %live-1224]
++  board  `resource`[~zod %board-4663]
++  schedule  `@`0i170141184505159259090517052396438290432
::
+$  card  card:agent:gall
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
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    =^  cards  state  on-data-timer:do
    :_  this
    :*  set-daily-timer:do
        (once:talk:do live-chat 'greetings!')
        (wait:b:sys:do /timer/results (add now.bowl results:rate))
        cards
    ==
  ::
  ++  on-save  !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    =^  caz  this
      :_  this(state !<(state-0 old))
      [(once:talk:do live-chat 'I\'ve freshened up!')]~
    =.  results  ~
    [caz this]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?.  ?=(%noun mark)  (on-poke:def mark vase)
    ?>  =(our.bowl src.bowl)
    =+  !<(=action vase)
    ?-  -.action
        %test-msg
      ~&  now.bowl
      [[(once:talk:do live-chat 'hello')]~ this]
    ::
        %test-reply
      [[(replies:talk:do live-chat [[msg.action]~ [now.bowl]~ 'bye']~)]~ this]
    ::
        %test-update-post
      =-  [[-]~ this]
      %+  edit:publish:do  schedule
      :~  [%text 'title lol']
          [%text 'this is the body:']
          [%text (scot %da now.bowl)]
          [%text 'over and\0aout!!!']
      ==
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    |^  ?+  wire  (on-agent:def wire sign)
            [%db ?(%full %stages %events) ~]
          :: =*  part  i.t.wire
          (spider-event full-db on-full-db:do)
        ::
            [%results ~]
          (spider-event (map @t result) on-event-results:do)
        ==
    ::
    ++  spider-event
      |*  [res=mold on-res=$-(* (quip card _state))]
      ^-  (quip card _this)
      ~&  [%spider-event wire -.sign]
      ?-  -.sign
          %poke-ack
        ?~  p.sign
          %-  (slog leaf+"{(spud wire)} thread started successfully" ~)
          [~ this]
        %-  (slog leaf+"couldn't start thread {(spud wire)}" u.p.sign)
        :_  this
        [(leave:spider:do wire)]~
      ::
          %watch-ack
        ?~  p.sign
          [~ this]
        =/  =tank  leaf+"couldn't watch thread {(spud wire)}"
        %-  (slog tank u.p.sign)
        [~ this]
      ::
          %kick
        [~ this]
      ::
          %fact
        ?+  p.cage.sign  (on-agent:def wire sign)
            %thread-fail
          =+  !<([=term =tang] q.cage.sign)
          %-  (slog leaf+"{(spud wire)} thread failed" leaf+<term> tang)
          [~ this]
        ::
            %thread-done
          =+  !<(=res q.cage.sign)
          =^  cards  state
            (on-res res)
          [cards this]
        ==
      ==
    --
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  wire  (on-arvo:def wire sign-arvo)
        [%timer ?(%daily %data %event %results) ~]
      ?>  ?=(%wake +<.sign-arvo)
      =^  cards  state
        ?-  i.t.wire
          %daily    on-daily-timer:do
          %data     on-data-timer:do
          %event    publish-started-events:do
          %results  on-results-timer:do
        ==
      [cards this]
    ==
  ::
  ++  on-fail
    |=  [=term =tang]
    ^-  (quip card _this)
    ~&  [dap.bowl %failed term]
    (on-fail:def term tang)
  ::
  ++  on-peek   on-peek:def
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  --
::
|_  =bowl:gall
+*  g  ~(. gr bowl)
::TODO  /lib/sys.hoon?
++  sys
  |%
  ++  b
    |%
    ++  wait
      |=  [=wire =time]
      ^-  card
      [%pass wire %arvo %b %wait time]
    ::
    ++  rest
      |=  [=wire =time]
      ^-  card
      [%pass wire %arvo %b %rest time]
    --
  --
::TODO  /lib/spider.hoon?
++  spider
  |%
  ++  start-thread
    |=  [=wire thread=term arg=vase]
    ^-  (list card)
    =.  arg  (slop !>(~) arg)
    =/  tid=@ta  (rap 3 thread '--' (scot %uv eny.bowl) ~)
    =/  args     [~ `tid thread arg]
    :~  [%pass wire %agent [our.bowl %spider] %watch /thread-result/[tid]]
        [%pass wire %agent [our.bowl %spider] %poke %spider-start !>(args)]
    ==
  ::
  ++  leave
    |=  =path
    ^-  card
    [%pass path %agent [our.bowl %spider] %leave ~]
  --
::
::  +talk: graph card creation
::
++  talk
  |%
  ++  post
    |=  [=resource msgs=(list [=index:graph msg=(list content:graph)])]
    ^-  card
    =;  upd=update:graph
      [%pass / %agent [our.bowl %graph-push-hook] %poke %graph-update-2 !>(upd)]
    ::TODO  this is api, man... move into lib or w/e
    =|  nodes=(list [index:graph node:graph])
    |-  ^-  upd=update:graph
    ?~  msgs
      :-  now.bowl
      :+  %add-nodes  resource
      (~(gas by *(map index:graph node:graph)) nodes)
    =;  =node:graph
      $(nodes [[index.i.msgs node] nodes], msgs t.msgs)
    :_  [%empty ~]
    ^-  maybe-post:graph
    :-  %&
    :*  our.bowl
        index.i.msgs
        now.bowl
        msg.i.msgs
        ~
        ~
    ==
  ::
  ++  once
    |=  [=resource msg=@t]
    ^-  card
    (send resource [now.bowl]~^msg ~)
  ::
  ++  send
    |=  [=resource msgs=(list [=index:graph msg=@t])]
    ^-  card
    %+  post  resource
    %+  turn  msgs
    |=  [=index:graph msg=@t]
    [index [%text msg]~]
  ::
  ++  replies
    |=  [=resource rep=(list [id=index:graph og=index:graph msg=@t])]
    ^-  card
    %+  post  resource
    %+  turn  rep
    |=  [id=index:graph og=index:graph msg=@t]
    [id ~[[%reference %graph group-id resource og] [%text msg]]]
  --
::
++  publish
  |%
  ++  next-rev
    |=  notenum=@
    ^-  @
    =/  =node:graph  (got-node:g board ~[notenum 1])
    ?>  ?=(%graph -.children.node)
    +((roll ~(tap in ~(key by p.children.node)) max))
  ::
  ++  edit
    |=  [notenum=@ contents=(list content:graph)]
    ^-  card
    =/  revnum=@  (next-rev notenum)
    =;  upd=update:graph
      [%pass / %agent [our.bowl %graph-push-hook] %poke %graph-update-2 !>(upd)]
    ::TODO  this is api, man... move into lib or w/e
    =;  =node:graph
      :-  now.bowl
      :+  %add-nodes  board
      =/  nodes=(list [index:graph node:graph])
        :~  :-  ~[notenum 1 revnum]  node
        ==
      (~(gas by *(map index:graph node:graph)) nodes)
    :_  [%empty ~]
    ^-  maybe-post:graph
    :-  %&
    :*  our.bowl
        ~[notenum 1 revnum]
        now.bowl
        contents
        ~
        ~
    ==
  --
::
++  dab
  |%
  ++  unstarted-events
    ^-  (list [evid=@t name=@t round=@t when=@da stid=@t])
    =>  [started=started events=events.db ..zuse]
    ~+
    %+  sort
      %+  skim  ~(tap by events)
      |=  [evid=@t *]
      !(~(has by started) evid)
    |=([[* * * a=@da *] [* * * b=@da *]] (lth a b))
  ::
  ++  happening-events
    ^-  (set @t)
    ::TODO  sanity-check dif logic
    =>  [started=started results=results ..zuse]
    ~+
    (~(dif in ~(key by started)) ~(key by results))
  --
::
++  refresh-db
  |=  part=?(%full %stages %events)
  ^-  (quip card _state)
  :_  =?  last-db       ?=(%full part)    now.bowl
      =?  last-stages  !?=(%events part)  now.bowl
      state
  %^  start-thread:spider
      [%db part ~]
    %enetpulse-db
  !>  ^-  full-db
  ?-  part
    %full    *full-db
    %stages  db(stages ~, events ~)
    %events  db(events ~)
  ==
::
++  on-data-timer
  ^-  (quip card _state)
  =^  cards  state
    %-  refresh-db
    ?:  (lte ~d1 (sub now.bowl last-db))
      %full
    ?:  (lte ~h4 (sub now.bowl last-stages))
      %stages
    %events
  :_  state
  :_  cards
  (wait:b:sys /timer/data (add now.bowl data:rate))
::
++  set-daily-timer
  ^-  card
  %+  wait:b:sys  /timer/daily
  =-  ?:((gth - now.bowl) - (add - ~d1))
  %+  add  ~h15
  (sub now.bowl (mod now.bowl ~d1))
::
++  on-daily-timer
  ^-  (quip card _state)
  ::TODO  actually do daily things
  ::  - update schedule
  ::  - update fantasy scoreboard
  [[set-daily-timer]~ state]
::
::  +|  %data-flow
::
::  on-full-db: process a db update
::
::    add to the existing/known db,
::    set timer for next event, if not already set
::
++  on-full-db
  |=  new=full-db
  ^-  (quip card _state)
  =.  db
    :*  (~(uni by templates.db) templates.new)
        (~(uni by tourneys.db) tourneys.new)
        (~(uni by stages.db) stages.new)
        (~(uni by events.db) events.new)
    ==
  publish-started-events
::
++  publish-started-events
  ::  posts "started" msgs for newly started events,
  ::  and stores the posted node indices in state
  ::
  ^-  (quip card _state)
  =/  [next=(unit @da) news=(list @t)]
    =/  eves=(list [evid=@t * * when=@da *])
      unstarted-events:dab
    =|  news=(list @t)
    |-  ::NOTE  assumes sorted eves
    ?~  eves  [~ (flop news)]
    ?:  (gth when.i.eves now.bowl)
      :_  (flop news)
      ?~(t.eves ~ `when.i.t.eves)
    $(news [evid.i.eves news], eves t.eves)
  ::
  =|  msgs=(list [=index:graph body=@t])
  |-
  ?^  news
    =/  msg=@t        (happening-msg i.news)
    =/  =index:graph  [now.bowl]~
    =.  msgs     (snoc msgs [index msg])
    =.  started  (~(put by started) i.news index)
    $(now.bowl +(now.bowl), news t.news)
  ::
  :_  state(next-event-timer next)
  =*  nite  next-event-timer
  ~&  [%post-publish-started-evs next=next started=(lent msgs)]
  %-  zing
  :~  ?~(msgs ~ ~[(send:talk live-chat msgs)])
      ?~(nite ~ ~[(rest:b:sys /timer/event u.next-event-timer)])
      ?~(next ~ ~[(wait:b:sys /timer/event u.next)])
  ==
::
++  on-results-timer
  ^-  (quip card _state)
  :_  state
  :-  (wait:b:sys /timer/results (add now.bowl results:rate))
  =/  happening=(set @t)
    happening-events:dab
  ?~  happening  ~
  %^  start-thread:spider
      /results
    %enetpulse-results
  !>(`(set @t)`happening)
::
++  on-event-results
  |=  rez=(map @t result)
  ^-  (quip card _state)
  :_  state(results (~(uni by results) rez))
  =/  rez=(list [evid=@t res=result])
    (sort ~(tap by rez) aor)
  ~&  [%results n=(lent rez)]
  =|  mez=(list [id=index:graph og=index:graph msg=@t])
  =/  id=@  now.bowl
  :_  ~
  |-  ^-  card
  ?~  rez  (replies:talk live-chat (flop mez))
  =,  i.rez
  ::  if we already had this result somehow, ignore it
  ?:  =(`res (~(get by results) evid))
    $(rez t.rez)
  =-  $(rez t.rez, mez [- mez], id +(id))
  :+  [id]~
    ?~  og=(~(get by started) evid)
      ~&  [%yooo-wtf-missing-started-msg evid]
      [0]~
    u.og
  (result-msg res)
::
::  +|  %renderers
::
++  happening-msg
  |=  evid=@t
  ^-  @t
  %+  rap  3
  :~  'Happening: '
      (event-name:static db evid)
  ==
::
++  result-msg
  |=  res=result
  ^-  @t
  (cat 3 'The results are in!\0a' (event-result res))
::
++  event-result
  |=  res=result
  =-  ~&  [%res-to res -]  -
  ^-  @t
  |^  ?-  -.res
          %duel
        %+  rap  3
        :~  (show-entry win.res)
            ' won against '
            (show-entry los.res)
            '.'
        ==
      ::
          %rank
        %+  rap  3
        %+  snoc
          %+  turn  (fuse:pal (gulf 1 3) (scag 3 rank.res))
          |=  [n=@ud e=result-entry]
          ^-  @t
          %+  rap  3
          :~  (scot %ud n)
              '. '
              (show-entry e)
              '\0a'
          ==
        ?:((gth (lent rank.res) 3) '...' '')
      ::
          %deft
        (rap 3 (show-entry one.res) ' won by default.' ~)
      ==
  ::
  ++  show-entry
    |=  e=result-entry
    ^-  @t
    %+  rap  3
    :~  ?-  medal.e
          ~        ''
          %gold    '🥇 '
          %silver  '🥈 '
          %bronze  '🥉 '
        ==
      ::
        (show-participant participant.e)
      ::
        ?~  s=(show-score [score record]:e)  ''
        (rap 3 ' (' u.s ')' ~)
    ==
  ::
  ++  show-score
    |=  [s=score r=?(%or %wr ~)]
    ^-  (unit @t)
    =;  t=(unit @t)
      ?~  t  ~
      ?~  r  t
      ?-  r
        %or  `(cat 3 u.t ', **OR!**')
        %wr  `(cat 3 u.t ', **WR!!**')
      ==
    ?+  -.s  `+.s
      %time      `?:(?=(~ (find ":" (trip t.s))) (cat 3 t.s 's') t.s)
      %weight    `(cat 3 k.s 'kg')
      %distance  `?:(?=(~ (find "m" (trip m.s))) (cat 3 m.s 'm') m.s)
      %errors    `(cat 3 e.s ' errors')
    ::
      %wl        ~
    ::
      %dns       `'did not start'
      %dnf       `'did not finish'
      %nm        `'no measured result'
      %dq        `'disqualified'
      %elim      `'eliminated'
      %lap       `'lapped'
    ::
      %unknown   ~
    ==
  ::
  ++  show-participant
    |=  p=participant
    ^-  @t
    ?-  -.p
      %person  (rap 3 name.p ' (' country-code.p ')' ~)
      %nation  ?~  m=(~(get by members.static) country-code.p)
                 country-code.p
               name.u.m
    ==
  --
--
