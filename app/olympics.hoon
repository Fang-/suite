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
/+  static=enetpulse-static,
    dbug, verb, default-agent
::
|%
+$  state-0
  $:  %0
      db=full-db
      last-db=@da
      last-stages=@da
    ::
      results=(map @t *)  ::TODO
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
  ++  results  ~m5
  --
::
::TODO  update!!
++  group-id  `resource`[~sun %olympics-2020]
++  live-chat  `resource`[~sun %live-chat-7774]
++  board  `resource`[~sun %schedule-2803]
++  schedule  `@`0i170141184505140271778156779315402899456
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
    :+  set-daily-timer:do
      (once:talk:do live-chat 'greetings!')
    cards
  ::
  ++  on-save  !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    :_  this(state !<(state-0 old))
    [(once:talk:do live-chat 'reloaded!')]~
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
      [[(reply:talk:do live-chat [msg.action]~ [now.bowl]~ 'bye')]~ this]
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
          ::TODO
          !!
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
  ++  reply
    |=  [=resource og=index:graph id=index:graph msg=@t]
    ::TODO test
    ^-  card
    %+  post  resource
    [id ~[[%reference %graph group-id resource og] [%text msg]]]~
  --
::
++  publish
  |%
  ++  next-rev
    |=  notenum=@
    ^-  @
    =/  =update:graph
      .^  update:graph
        %gx
        (scot %p our.bowl)
        %graph-store
        (scot %da now.bowl)
        %node
        (scot %p entity:board)
        name:board
        (scot %ud notenum)
        /1/graph-update-2
      ==
    ?>  ?=(%add-nodes -.q.update)
    =/  =node:graph  (~(got by nodes.q.update) ~[notenum 1])
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
    :: const newRev: Post = {
    ::   author: `~${window.ship}`,
    ::   index: `/${noteId.toString()}/1/${rev}`,
    ::   'time-sent': now,
    ::   contents: [{ text: title }, ...tokenisedBody],
    ::   hash: null,
    ::   signatures: []
    :: };
    :: const nodes = {
    ::   [newRev.index]: {
    ::     post: newRev,
    ::     children: null
    ::   }
    :: };
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
  ~&  [%would-fetch-results ~(wyt in happening)]
  ~
  :: ?~  happening  ~
  :: %^  start-thread:spider
  ::     /results
  ::   %enetpulse-results
  :: !>(`(set @t)`happening)
::
++  on-event-results
  |=  (map @t *)  ::TODO
  !!
::
::  +|  %renderers
::
++  happening-msg
  |=  evid=@t
  ^-  @t
  %+  rap  3
  :~  'Happening: '
      (event-name evid)
      ' ('
      evid
      ')'
  ==
::
++  result-msg
  |=  evid=@t
  ^-  @t
  (cat 3 'The results are in: ' (event-result evid))
::
++  event-name
  |=  evid=@t
  ^-  @t
  =/  event=[name=@t round=@t when=@da stid=@t]
    (~(got by events.db) evid)
  =/  stage=[name=@t gene=gender toid=@t]
    (~(got by stages.db) stid.event)
  =/  sport=@t
    %-  ~(got by sports.static)  =<  spid
    %-  ~(got by templates.db)   =<  teid
    %-  ~(got by tourneys.db)        toid.stage
  =?  sport  ?=(~ (find "Olympic" (trip name.stage)))
    name.stage  ::TODO  mistake? sucks for boxing, sailing etc
  (rap 3 sport ': ' name.event ' (' round.event ')' ~)
  ::TODO  if ev name contains men's or women's, leave as is
  ::      if ev name contains male or female, replace with men's or women's
  ::      if ev name contains neither, finds gender, prepend if necessary
  ::TODO  should get "semi/finals" etc from stage name?
  ::      could also parse from "round" property in event results
::
++  event-result
  |=  evid=@t
  ^-  @t
  ::TODO
  'its complicated...'
--