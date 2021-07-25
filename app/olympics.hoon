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
+$  state-1
  $:  %1
      db=full-db
      last-db=@da
      last-stages=@da
    ::
      $:  doubted=(set @t)
          results=(map @t result)
      ==
    ::
      ::NOTE  event ids
      happening=(set @t)  ::  (~(dif in ~(key by started)) ~(key by results))
      started=(map @t index:graph)
      next-event-timer=(unit @da)
  ==
::
+$  action
  $%  [%test-msg ~]
      [%update-db wat=?(%full %stages %events)]
      [%update-posts ~]
  ==
::
++  rate
  |%
  ++  data     ~m20
  ++  results  ~m3
  --
::
++  group-id  `resource`[~paldev %olympics-2020]
++  live-chat  `resource`[~paldev %live-chat-6199]
++  board  `resource`[~paldev %bulletin-board-2283]
++  schedule  `@`0i170141184505143666550051279979394629632
++  scoreboard  `@`0i170141184505160187027376043256461656064
::
+$  card  card:agent:gall
--
::
=|  state-1
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
        (wait:b:sys:do /timer/results (add now.bowl results:rate))
      ::
        %+  weld  cards
        (once:talk:do live-chat 'Welcome! The Games will begin soon. A schedule will be posted to the Bulletin Board, and I will post updates here as individual events begin & conclude. Enjoy the Games!')
    ==
  ::
  ++  on-save  !>(state)
  ++  on-load
    |=  ole=vase
    ^-  (quip card _this)
    |^  =/  old=state-x  !<(state-x ole)
        =?  old  ?=(%0 -.old)  (state-0-to-1 old)
        ?>       ?=(%1 -.old)
        [~ this(state old)]
    ::
    ++  state-0-to-1
      |=  s=state-0
      ^-  state-1
      s(- %1, results [~ results.s])
    ::
    +$  state-x  $%(state-1 state-0)
    ::
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
    --
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?.  ?=(%noun mark)  (on-poke:def mark vase)
    ?>  =(our.bowl src.bowl)
    =+  !<(=action vase)
    ?-  -.action
        %test-msg
      =/  msgs=(list [index:graph @t])
        :~  [now.bowl]~^'test 1 2 3'
            [+(now.bowl)]~^'test 4 5 6'
        ==
      [(send:talk:do live-chat msgs) this]
    ::
        %update-db
      =^  cards  state
        (refresh-db:do wat.action)
      [cards this]
    ::
        %update-posts
      [~[update-schedule:do update-scoreboard:do] this]
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
          %event    on-event-timer:do
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
    =.  arg      (slop !>(~) arg)
    =*  dude     [our.bowl %spider]
    ?:  (~(has by wex.bowl) wire dude)
      ~&  [%still-running thread %not-starting]
      ~
    =/  tid=@ta  (rap 3 thread '--' (scot %uv eny.bowl) ~)
    =/  args     [~ `tid thread arg]
    :~  [%pass wire %agent dude %watch /thread-result/[tid]]
        [%pass wire %agent dude %poke %spider-start !>(args)]
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
    ^-  (list card)
    ~?  =(now.bowl *@da)
      [%hey-watch-out-------heyyyyy--xxxxx '!!!']
    %+  turn  msgs
    |=  [=index:graph msg=(list content:graph)]
    =;  upd=update:graph
      [%pass / %agent [our.bowl %graph-push-hook] %poke %graph-update-2 !>(upd)]
    ::TODO  this is api, man... move into lib or w/e
    |-  ^-  upd=update:graph
    =;  =node:graph
      :-  now.bowl
      :+  %add-nodes  resource
      (~(put by *(map index:graph node:graph)) index node)
    :_  [%empty ~]
    ^-  maybe-post:graph
    :-  %&
    :*  our.bowl
        index
        (add now.bowl 3)
        msg
        ~
        ~
    ==
  ::
  ++  once
    |=  [=resource msg=@t]
    ^-  (list card)
    (send resource [now.bowl]~^msg ~)
  ::
  ++  send
    |=  [=resource msgs=(list [=index:graph msg=@t])]
    ^-  (list card)
    %+  post  resource
    %+  turn  msgs
    |=  [=index:graph msg=@t]
    [index [%text msg]~]
  ::
  ++  replies
    |=  [=resource rep=(list [id=index:graph og=index:graph msg=@t])]
    ^-  (list card)
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
  ++  dated-events
    ^-  (list [evid=@t name=@t round=@t when=@da stid=@t])
    %+  sort  ~(tap by events.db)
    |=  [a=[evid=@t * * when=@da *] b=[evid=@t * * when=@da *]]
    ?.  =(when.a when.b)  (lth when.a when.b)
    %+  aor
      (event-name:static db evid.a)
    (event-name:static db evid.b)
  ::
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
  (wait:b:sys /timer/daily next-day)
::
++  next-day
  ^-  @da
  =-  ?:((gth - now.bowl) - (add - ~d1))
  %+  add  ~h15
  (sub now.bowl (mod now.bowl ~d1))
::
++  on-daily-timer
  ^-  (quip card _state)
  :_  state
  :~  set-daily-timer
      update-schedule
      update-scoreboard
  ==
::
++  update-schedule
  ^-  card
  %+  edit:publish  schedule
  =-  ~[[%text 'Schedule'] [%text -]]
  render-schedule
::
++  render-schedule
  ^-  @t
  =/  next=@da   next-day
  =/  from=@da   (sub next ~d1)
  =/  until=@da  (add next ~d5)
  ~&  [now=now.bowl nex=next til=until]
  %+  rap  3
  :-  'All times are in [JST (UTC+9)](https://time.is/JST).\0a\0a'
  =/  evs=(list [evid=@t * * when=@da *])
    dated-events:dab
  =|  day=@da
  =|  dil=@t
  =|  diz=(set @t)
  =|  out=(list @t)
  |^
    ?~  evs  (flop out)
    =.  when.i.evs  when.i.evs
    =,  i.evs
    ?:  (lth when from)   $(evs t.evs)
    ?:  (gth when until)  (flop out)
    =/  d=@da   (get-day when)
    =/  dis=@t  (event-discipline:static evid db)
    ?:  (lth when next)
      =?  out  !=(d day)
        :_  out
        (rap 3 '\0a\0a**' (render-day when) '**\0a' ~)
      =.  day  d
      =?  out  !=(dis dil)
        ['\0a' out]
      =.  dil  dis
      =.  out
        :_  out
        %+  rap  3
        :~  '`'
            (render-time when)
            '` '
            (event-name:static db evid)
            '\0a'
        ==
      $(evs t.evs)
    =?  out  !=(d day)
      :_  out
      (rap 3 '\0a\0a\0a**' (render-day when) '**\0a' ~)
    =?  diz  !=(d day)
      ~
    ?:  (~(has in diz) dis)
      $(evs t.evs)
    =.  diz  (~(put in diz) dis)
    =.  out
      :_  out
      (cat 3 ?:(=(d day) ', ' '') (render-discipline dis))
    =.  day  d
    $(evs t.evs)
  ::
  ++  get-day
    |=  da=@da
    ^-  @da
    =.  da  (add da ~h9)
    (sub da (mod da ~d1))
  ::
  ++  render-day
    |=  da=@da
    ^-  @t
    (scot %da (get-day da))
  ::
  ++  render-time
    |=  da=@da
    ^-  @t
    =.  da  (add da ~h9)
    (end 3^5 (rsh 3^20 (scot %da (mod da ~d1))))
  ::
  ++  render-discipline
    |=  d=@t
    =/  icon=?(@t [m=@t w=@t])
      icon:(~(got by disciplines.static) d)
    (rap 3 ?@(icon icon m.icon) ' ' d ~)
  --
::
++  update-scoreboard
  ^-  card
  %+  edit:publish  scoreboard
  =-  ~[[%text 'Fantasy Scoreboard'] [%text -]]
  render-scoreboard
::
++  render-scoreboard
  ^-  @t
  ?.  .^(? %gu /(scot %p our.bowl)/fantasy-olympics/(scot %da now.bowl))
    'Fantasy Olympics have not yet begun...'
  ~&  %counting-score
  =-  ~&  %done-counting  -
  =/  entries=(map ship (map @t @t))
    .^  (map ship (map @t @t))
      %gx
      (scot %p our.bowl)
      %fantasy-olympics
      (scot %da now.bowl)
      /entries/noun
    ==
  =/  medals=(map @t (map @t @ud))  ::  (map discipline (map country golds))
    %+  roll  ~(tap by results)
    |=  [[evid=@t r=result] m=(map @t (map @t @ud))]
    =/  dis=@t
      (event-discipline:static evid db)
    =/  counts=(map @t @ud)
      (~(gut by m) dis *(map @t @ud))
    =/  es=(list result-entry)
      ?-  -.r
        %duel  [win los ~]:r
        %rank  rank.r
        %deft  [one.r ~]
      ==
    =;  goz=(list @t)
      |-
      ?~  goz  (~(put by m) dis counts)
      =.  counts  (~(put by counts) i.goz +((~(gut by counts) i.goz 0)))
      $(goz t.goz)
    %+  murn  es
    |=  result-entry
    ?.  =(%gold medal)  ~
    %-  some
    ?-  -.participant
      %nation  country-code.participant
      %person  country-code.participant
    ==
  =/  scores=(list [=ship score=@ud])
    %+  turn  ~(tap by entries)
    |=  [w=ship e=(map @t @t)]
    :-  w
    =/  def=@t  (~(gut by e) 'default' '')
    %+  roll  ~(tap by e)
    |=  [[d=@t c=@t] s=@ud]
    ?:  =('default' d)  s
    =?  c  =('' c)  def
    %+  add  s
    ~|  d=d
    (~(gut by (~(gut by medals) d *(map @t @ud))) c 0)
  =.  scores
    %+  sort  scores
    |=([[* a=@ud] [* b=@ud]] (gth a b))
  %+  rap  3
  :-  'Updated for every gold medal.\0a\0a'
  %+  turn  scores
  |=  [=ship score=@ud]
  =-  (rap 3 '`' (crip -) ' : ' (scot %ud score) '`\0a' ~)
  =/  n=tape  (cite:title ship)
  ?.  (lth (lent n) 14)  n
  (weld (reap (sub 14 (lent n)) ' ') n)
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
  on-event-timer
::
++  on-event-timer
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
    =.  when.i.eves  when.i.eves
    ?:  (gth when.i.eves now.bowl)
      :_  (flop news)
      `when.i.eves
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
  %-  zing
  :~  ?~(msgs ~ (send:talk live-chat msgs))
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
  !>(`[(set @t) full-db]`[happening db])
::
++  on-event-results
  |=  rez=(map @t result)
  ^-  (quip card _state)
  =/  [noz=(list @t) rez=(list [evid=@t res=result])]
    ::  we may have partial ranking results. if we suspect this
    ::  is the case, wait once for refreshed results.
    ::
    =;  [noz=(list [@t result]) rez=(list [@t result])]
      [(turn noz head) rez]
    %+  skid  ~(tap by rez)
    |=  [evid=@t r=result]
    ::  only doubt once
    ?:  (~(has in doubted) evid)  |
    ::  always doubt defaults
    ?:  ?=(%deft -.r)  &
    =/  d=@t  (event-discipline:static evid db)
    ::  detect duel result in sports other than duel sports
    ?&  ?=(%duel -.r)
    ?!  ?|  =('Water polo' d)
            =('Baseball' d)
            =('Softball' d)
            =('Badminton' d)
            =('Basketball' d)
            =('3x3 basketball' d)
            =('Boxing' d)
            =('Fencing' d)
            =('Field hockey' d)
            =('Soccer' d)
            =('Handball' d)
            =('Judo' d)
            =('Karate kata' d)
            =('Karate kumite' d)
            =('Rugby sevens' d)
            =('Table tennis' d)
            =('Taekwondo' d)
            =('Tennis' d)
            =('Volleyball' d)
            =('Beach volleyball' d)
            =('Freestyle wrestling' d)
            =('Greco-Roman wrestling' d)
        ==
    ==
  :_  %_  state
        doubted  (~(gas in doubted) noz)
        results  (~(gas by results) rez)
      ==
  =;  caz=(list card)
    ::  also update the scoreboard if there were new gold medals
    ::
    =;  gold=?
      ?.  gold  caz
      [update-scoreboard caz]
    %+  lien  rez
    |=  [@t res=result]
    ?-  -.res
      %duel  ?=(%gold medal.win.res)
      %deft  ?=(%gold medal.one.res)
      %rank  ?~(rank.res | ?=(%gold medal.i.rank.res))
    ==
  =.  rez  (sort rez aor)
  =|  mez=(list [id=index:graph msg=@t])
  =/  id=@  now.bowl
  |-  ^-  (list card)
  ?~  rez  (send:talk live-chat (flop mez))
  =,  i.rez
  ::  if we already had this result somehow, ignore it
  ?:  =(`res (~(get by results) evid))
    $(rez t.rez)
  =-  $(rez t.rez, mez [- mez], id +(+(id)))
  :-  [id]~
  (result-msg evid res)
::
::  +|  %renderers
::
++  happening-msg
  |=  evid=@t
  ^-  @t
  =/  when=@da
    when:(~(got by events.db) evid)
  %+  rap  3
  :~  ?:  (lth when (sub now.bowl ~m30))
        'This happened: '
      'Happening: '
      (event-name:static db evid)
  ==
::
++  result-msg
  |=  [evid=@t res=result]
  ^-  @t
  %+  rap  3
  :~  'The results are in!\0a'
      (event-name:static db evid)
      '\0a'
      (event-result res)
  ==
::
++  event-result
  |=  res=result
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
          %gold    '**🥇 '
          %silver  '🥈 '
          %bronze  '🥉 '
        ==
      ::
        (show-participant participant.e)
      ::
        ?:(?=(%gold medal.e) '**' '')
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
      %weight    `(cat 3 (scot %ud k.s) 'kg')
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
      %person  %+  rap  3
               :-  name.p
               ?:  ?&  (~(has by members.static) country-code.p)
                       =(name.p name:(~(got by members.static) country-code.p))
                   ==
                 ~
               ~[' (' country-code.p ')']
      %nation  ?~  m=(~(get by members.static) country-code.p)
                 country-code.p
               name.u.m
    ==
  --
--
