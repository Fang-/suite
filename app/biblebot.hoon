::  biblebot: post verses when they're mentioned
::
::    usage:
::    - :biblebot [%watch ~host %chatname], but requires that you're already
::      subscribed to that resource (ie via landscape)
::
/-  graph=graph-store, graph-view
/+  word, re=resource, dbug, verb, default-agent
::
|%
++  state-0
  $:  %0
      watching=(set resource:re)
  ==
::
+$  query
  %-  list
  [book=term chap=@ud vers=$@(@ud [@ud @ud])]
::
+$  action
  $%  [%watch reid=resource:re]
      [%leave reid=resource:re]
  ==
::
+$  card  card:agent:gall
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
     ^-  (quip card _this)
     [[listen:talk:do]~ this]
  ::
  ++  on-save   !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    =.  state  !<(state-0 old)
    [~ this]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
      %noun  $(mark %biblebot-action)
    ::
        %biblebot-action
      =/  =action  !<(action vase)
      ?-  -.action
        %watch  [~ this(watching (~(put in watching) reid.action))]
        %leave  [~ this(watching (~(del in watching) reid.action))]
      ==
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  (on-agent:def wire sign)
        [%listen ~]
      ?-  -.sign
        %poke-ack  (on-agent:def wire sign)
        %kick      [[listen:talk:do]~ this]
      ::
          %watch-ack
        ?~  p.sign  [~ this]
        =/  msg=tape
          "{(trip dap.bowl)} failed to watch graph-store"
        %-  (slog leaf+msg u.p.sign)
        ::TODO  this _shouldn't_ happen, right?
        [~ this]
      ::
          %fact
        ?+  p.cage.sign  (on-agent:def wire sign)
            %graph-update
          =/  upd  !<(update:graph q.cage.sign)
          =^  cards  state
            (process-graph-update:do q.upd)
          [cards this]
        ==
      ==
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
::  +talk: graph card creation
::
++  talk
  |%
  ++  listen
    ^-  card
    [%pass /listen %agent [our.bowl %graph-store] %watch /updates]
  ::
  ++  send
    |=  [reid=resource:re msgs=(list @t)]
    ^-  card
    ::TODO  this is api, man... move into lib or w/e
    =;  upd=update:graph
      =-  [%pass / %agent [our.bowl -] %poke %graph-update !>(upd)]
      ?:  =(entity.reid our.bowl)
        %graph-store
      %graph-push-hook
    =|  nodes=(list [index:graph node:graph])
    |-  ^-  upd=update:graph
    ?~  msgs
      :+  %0  now.bowl
      :+  %add-nodes  reid
      (~(gas by *(map index:graph node:graph)) nodes)
    =.  now.bowl  +(now.bowl)  ::NOTE  so we don't re-use indices
    =-  $(nodes [- nodes], msgs t.msgs)
    :-  [now.bowl]~
    :_  [%empty ~]
    ^-  post:graph
    :*  our.bowl
        [now.bowl]~
        now.bowl
        [%text i.msgs]~
        ~
        ~
    ==
  --
::  +process-graph-update: per-response logic
::
++  process-graph-update
  |=  upd=update-0:graph
  ^-  (quip card _state)
  :_  state
  ::  relevancy and sanity checks
  ::
  ?.  ?=(%add-nodes -.upd)
    ~
  =*  reid  resource.upd
  =/  msgs=(list [=index:graph node:graph])  ~(tap by nodes.upd)
  =|  out=(list @t)
  |-
  ?~  msgs
    ?~  out  ~
    [(send:talk reid out)]~
  =;  new=(list @t)
    $(out (weld out new), msgs t.msgs)
  =*  post  post.i.msgs
  =*  ship  author.post
  ?:  =(our.bowl ship)
    ~
  ?.  (~(has in watching) reid)
    ~
  ::  find requested verses
  ::
  =/  text=@t  (fold-post-content contents.post)
  =/  =query   (parse-response text)
  %+  murn  query
  |=  [book=term chap=@ud vers=$@(@ud [@ud @ud])]
  ^-  (unit @t)
  ?:  &(?=(^ vers) (gth vers))  ~
  ?.  (~(has by lookup:word) book)  ~
  =/  chaz  (~(got by lookup:word) book)
  ?:  (gth chap (lent chaz))  ~
  =/  chat  (snag (dec chap) chaz)
  ?:  (gth ?@(vers vers -.vers) (lent chat))  ~
  =*  ud  (cork (d-co:co 1) crip)
  %-  some
  %+  rap  3
  :*  '*'  book  ' '  (ud chap)  ':'
      ?@(vers (ud vers) :((cury cat 3) (ud -.vers) '-' (ud +.vers)))
      '*\0a'
      %+  join  '\0a'
      ?@  vers  [(snag (dec vers) chat)]~
      (swag [(dec -.vers) +((sub +.vers -.vers))] chat)
  ==
::  +fold-post-content: collapse into @t post body
::
++  fold-post-content
  |=  contents=(list content:graph)
  ^-  @t
  %+  rap   3
  %+  join  ' '
  %+  turn  contents
  |=  c=content:graph
  ?+  -.c  ''
    %text     text.c
    %mention  (scot %p ship.c)
    %url      url.c
  ==
::  +parse-response: reply from post body
::
++  parse-response
  |=  text=@t
  |^  ^-  query
      =-  ~!  -  -
      (fall (rest pointers) ~)
  ::
  ++  rest    |*(r=rule (rust (cass (trip text)) r))
  ::
  ++  pointers
    =-  (ifix [- -] (more - pointer))
    (star ;~(less book next))
  ::
  ++  pointer
    ;~((glue (star ;~(pose ace com col))) book verses)
  ::
  ++  book
    ;~  pose
      (numbered 2 (jest 'samuel'))
      (numbered 2 (jest 'kings'))
      (numbered 2 (jest 'chronicles'))
    ::
      (numbered 2 (jest 'maccabees'))
      (numbered 2 (jest 'esdras'))
    ::
      (numbered 2 (jest 'corinthians'))
      (numbered 2 (jest 'thessalonians'))
      (numbered 2 (jest 'timothy'))
      (numbered 2 (jest 'peter'))
      (numbered 3 (jest 'john'))
    ::
      (cold %song-of-solomon (jest 'song of solomon'))
      (cold %wisdom (jest 'wisdom of solomon'))
      %+  cold  %sirach
      ;~  pose
        (jest 'ecclesiasticus')
        (jest 'wisdom of sirach')
      ==
      (cold %bel-and-the-dragon (jest 'bel and the dragon'))
      %+  cold  %prayer-of-azariah
      ;~  pose
        (jest 'prayer of azariah')
        (jest 'azariah')
        (jest 'song of the three holy children')
        (jest 'pr azar')
      ==
      %+  cold  %prayer-of-manasseh
      ;~  pose
        (jest 'prayer of manasseh')
        (jest 'manasseh')
      ==
    ::
      :: (perk titles:word)  ::TODO  why doesn't this just work?
      (jest 'genesis')
      (jest 'exodus')
      (jest 'leviticus')
      (jest 'numbers')
      (jest 'deuteronomy')
      (jest 'joshua')
      (jest 'judges')
      (jest 'ruth')
      (jest 'ezra')
      (jest 'nehemiah')
      (jest 'esther')
      (jest 'job')
      (jest 'psalms')
      (jest 'proverbs')
      (jest 'ecclesiastes')
      (jest 'isaiah')
      (jest 'jeremiah')
      (jest 'lamentations')
      (jest 'ezekiel')
      (jest 'daniel')
      (jest 'hosea')
      (jest 'joel')
      (jest 'amos')
      (jest 'obadiah')
      (jest 'jonah')
      (jest 'micah')
      (jest 'nahum')
      (jest 'habakkuk')
      (jest 'zephaniah')
      (jest 'haggai')
      (jest 'zechariah')
      (jest 'malachi')
    ::
      (jest 'tobit')
      (jest 'judith')
      (jest 'wisdom')
      (jest 'sirach')
      (jest 'baruch')
      (jest 'azariah')
      (jest 'susanna')
      (jest 'bel-and-the-dragon')
      (jest 'prayer-of-manasseh')
    ::
      (jest 'matthew')
      (jest 'mark')
      (jest 'luke')
      (jest 'john')
      (jest 'acts')
      (jest 'romans')
      (jest 'galatians')
      (jest 'ephesians')
      (jest 'philippians')
      (jest 'colossians')
      (jest 'titus')
      (jest 'philemon')
      (jest 'hebrews')
      (jest 'james')
      (jest 'jude')
      (jest 'revelation')
    ==
  ::
  ++  numbered
    |*  [m=@ud r=rule]
    %+  cook
      |=  [n=@ud t=term]
      :((cury cat 3) (rep 3 (reap n 'i')) '-' t)
    ;~  (glue ace)
      ;~(pose num (cook lent (stun [1 m] (just 'i'))))
      r
    ==
  ::
  ++  verses
    ;~  (glue col)
      num
    ::
      ;~  pose
        ;~((glue hep) num num)
        num
      ==
    ==
  ::
  ++  num
    (sear |=(a=@ ?:(=(0 a) ~ (some a))) dum:ag)
  --
--
