::  sc'o're: chat reacts scoreboard
::
::    keep track of chat reacts you and others have received,
::    to display them in a local-perspective scoreboard.
::
::TODO  could be fun to show "rare gets", reacts that have only been given once
::
/-  channels, groups
/+  *pal, rudder, negotiate,
    dbug, verb, default-agent
::
::NOTE  rudder a little bit overkill for this, since we only have
::      two read-only pages...
/~  pages  (page:rudder (mip ship react:channels @ud) ~)  /app/scooore/webui
::
|%
+$  state-1
  $:  %1
      bits=(mip ship react:channels @ud)                ::  react tallies
      seen=(mip mixed-id ship react:channels)           ::  known reacts
      live=(map nest:channels @da)  ::NOTE  unused rn   ::  last-heard per chan
  ==
::
+$  mixed-id
  $%  [%post id=id-post:channels]
      [%reply op=id-post:channels id=id-reply:channels]
  ==
::
+$  card  card:agent:gall
--
::
%-  %-  agent:negotiate
    :+  &
      ~
    [%channels^[~.channels^%1 ~ ~] ~ ~]
::
%-  agent:dbug
%+  verb  |
::
=|  state-1
=*  state  -
::
=>
::
=|  cards=(list card)
|_  =bowl:gall
+*  this  .
++  peel
  |=  [=dude:gall =path]
  [(scot %p our.bowl) dude (scot %da now.bowl) path]
::
++  abet  [(flop cards) state]
++  emit  |=(=card this(cards [card cards]))
::
++  peer
  |=  [=wire =dude:gall =path]
  =/  have=?
    (~(has by wex.bowl) wire our.bowl dude)
  ?:  have  this
  (emit %pass wire %agent [our.bowl dude] %watch path)
::
++  peer-channels
  (peer /channels %channels /)
::
++  init
  =.  this
    %-  emit
    [%pass /eyre/bind %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  =.  this
    %-  emit
    [%pass /groups %agent [our.bowl %groups] %watch /groups]
  ::NOTE  once this subscription gives us an ack, we will call +count-all.
  ::      that way, we know we're talking to a matching/expected version.
  peer-channels
::
++  count-all
  ^+  this
  ::
  ~>  %bout.[0 'scooore: counting all reacts']
  =/  chad=(list nest:channels)
    ?.  .^(? %gu (peel %channels /$))  ~
    %~  tap  in
    %~  key  by
    .^(channels:channels %gx (peel %channels /channels/channels))
  ::  for every channel, accumulate reacts into :new,
  ::  updating :bits only at the end
  ::
  =|  new=(map [ship react:channels] @ud)
  =|  saw=(map [mixed-id ship] react:channels)
  |-
  ?~  chad
    %_  this
        bits
      %-  ~(rep by new)
      |=  [[[s=ship f=react:channels] c=@ud] =_bits]
      (~(put bi bits) s f (add c (~(gut bi bits) s f 0)))
    ::
        seen
      %-  ~(rep by saw)
      |=  [[[i=mixed-id s=ship] f=react:channels] =_seen]
      (~(put bi seen) i s f)
    ==
  ::
  =*  nest=nest:channels  i.chad
  =/  =posts:channels
    =<  posts
    .^  paged-posts:channels
      %gx  (scot %p our.bowl)  %channels  (scot %da now.bowl)
      =,  nest
      ::TODO  tune? could /newer/[gut-by-live]/9.999/post instead, maybe
      /[kind]/(scot %p ship)/[name]/posts/newest/9.999/post/channel-posts
    ==
  ::
  =.  live  (~(put by live) nest now.bowl)
  ::
  =;  [[nu=_new su=_saw] *]
    $(new nu, saw su, chad t.chad)
  %^    %-  dip:on-posts:channels
        $:  new=(map [ship react:channels] @ud)
            saw=(map [mixed-id ship] react:channels)
        ==
      posts
    [new saw]
  |=  [[=_new =_saw] [pid=id-post:channels post=(unit post:channels)]]
  ^-  [(unit _post) ? [_new _saw]]
  :+  `post  |
  ?~  post  [new saw]
  =/  [nn=_new ss=_saw]
    %-  ~(rep by reacts.u.post)
    |=  [[s=ship r=react:channels] [=_new =_saw]]
    :_  (~(put by saw) [[%post pid] s] r)
    %+  ~(put by new)
      [author.u.post r]
    +((~(gut by new) [author.u.post r] 0))
  =.  new  nn
  =.  saw  ss
  =<  [new saw]
  %^    %-  dip:on-replies:channels
        $:(=_new =_saw)
      replies.u.post
    [new saw]
  |=  [[=_new =_saw] [rid=id-reply:channels =reply:channels]]
  ^-  [(unit _reply) ? [=_new =_saw]]
  :+  `reply  |
  %-  ~(rep by reacts.reply)
  |=  [[s=ship r=react:channels] [=_new =_saw]]
  :_  (~(put by saw) [[%reply pid rid] s] r)
  %+  ~(put by new)
    [author.reply r]
  +((~(gut by new) [author.reply r] 0))
::
++  hear
  |=  [=nest:channels wen=time mid=mixed-id fro=ship fel=(unit react:channels) for=ship]
  ^+  this
  ::  do not count reacts given on one's own messages
  ::
  ?:  =(for fro)  this
  ::
  =/  had=(unit react:channels)
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
    (~(put by live) nest wen)
  ::
  ::TODO  maybe emit diff %fact?
  this
::
++  hear-many  ::  run +hear for added & removed reacts
  |=  [=nest:channels wen=time mid=mixed-id for=(unit ship) rez=(map ship react:channels)]
  ^+  this
  =/  for=ship
    ?^  for  u.for
    (fetch-author nest mid)
  =;  dif=(list [=ship rec=(unit react:channels)])
    |-
    ?~  dif  this
    =.  this
      (hear nest wen mid ship.i.dif rec.i.dif for)
    $(dif t.dif)
  =/  had=(map ship react:channels)
    (~(gut by seen) mid ~)
  %+  murn  ~(tap by (~(uni by had) rez))
  |=  [s=ship r=react:channels]
  ^-  (unit [ship (unit react:channels)])
  ?~  o=(~(get by had) s)  `[s `r]
  ?.    (~(has by rez) s)  `[s ~]
  ?.  =(u.o r)             `[s `r]
  ~
::
++  fetch-author
  |=  [=nest:channels mid=mixed-id]
  ^-  ship
  ?-  -.mid
      %post
    =<  author
    =;  =path  .^(post:channels %gx (peel %channels path))
    :~  kind.nest
        (scot %p ship.nest)
        name.nest
        %posts
        %post
        (scot %ud id.mid)
        %noun
    ==
  ::
      %reply
    =;  =path
      ::NOTE  stupid hack to account for LAND-1531,
      ::      channels returns a v-reply at the time of writing,
      ::      but writing it this way is forward-compatible.
      =+  +:.^($^(reply:channels v-reply:channels) %gx (peel %channels path))
      ?-  -
        [@ * @ @]  author  ::  v-reply
        [* @ @]    author  ::  reply
      ==
    :~  kind.nest
        (scot %p ship.nest)
        name.nest
        %posts
        %post
        %id
        (scot %ud op.mid)
        %replies
        %reply
        %id
        (scot %ud id.mid)
        %noun
    ==
  ==
::
++  kick  peer-channels
--
::
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
  |^  ^-  (quip card _this)
      =+  !<(old=state-any ole)
      =|  cards=(list card)
      ?:  ?=(%0 -.old)
        ::  fully replace the pre-channels state
        ::
        on-init
      ?>  ?=(%1 -.old)
      [~ this(state old)]
  ::
  +$  state-any  $%(state-1 state-0)
  ::
  +$  state-0  [%0 *]
  --
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
      [%groups ~]  ::NOTE  from previous version of scooore
    :_  this
    [%pass wire %agent [our.bowl %groups] %leave ~]~
  ::
      [%chat @ @ ~]  ::NOTE  from previous version of scooore
    :_  this
    [%pass wire %agent [our.bowl %chat] %leave ~]~
  ::
      [%channels ~]
    ?-  -.sign
      %poke-ack  !!
      %kick      =^(cards state abet:kick:do [cards this])
    ::
        %watch-ack
      ?~  p.sign
        ::TODO  could keep the existing state, after tuning +count-all
        =.  bits  ~
        =.  seen  ~
        =.  live  ~
        =^  cards  state  abet:count-all:do
        [cards this]
      %.  [~ this]
      (slog dap.bowl 'failed to open subscription' >wire< u.p.sign)
    ::
        %fact
      ?.  ?=(%channel-response p.cage.sign)
        [~ this]
      =+  !<([=nest:channels res=$%([%pending *] r-channel:channels)] q.cage.sign)
      =/  d  do
      =;  =_d
        =^  cards  state  abet:d
        [cards this]
      |-  ^+  d
      ?+  res  d
          [%posts *]
        ?~  posts.res  d
        =.  d  $(posts.res l.posts.res)
        =.  d  $(posts.res r.posts.res)
        $(res [%post key %set val]:n.posts.res)
      ::
          [%post * %set *]
        =*  mid     [%post id.res]
        ?~  post.r-post.res
          ::  the post was deleted. from the fact, we don't know the author,
          ::  and we can't scry out the post (or its replies) anymore to
          ::  retrieve the reacts or author either. it will give a slight(?)
          ::  inaccuracy, but our only option here is to no-op on deletions.
          ::
          d
        =*  reacts  reacts.u.post.r-post.res
        =*  author  author.u.post.r-post.res
        (hear-many:d nest now.bowl mid `author reacts)
      ::
          [%post * %reacts *]
        =*  mid     [%post id.res]
        =*  reacts  reacts.r-post.res
        (hear-many:d nest now.bowl mid ~ reacts)
      ::
          [%post * %reply * * %set *]
        =*  mid     [%reply id.res id.r-post.res]
        ?~  reply.r-reply.r-post.res
          ::  the reply was deleted. from the fact, we don't know the author,
          ::  and we can't scry out the reply anymore to retrieve the reacts
          ::  or author either. it will give a slight inaccuracy, but our only
          ::  option here is to no-op on deletions.
          ::
          d
        =*  reacts  reacts.u.reply.r-reply.r-post.res
        =*  author  author.u.reply.r-reply.r-post.res
        (hear-many:d nest now.bowl mid `author reacts)
      ::
          [%post * %reply * * %reacts *]
        =*  mid     [%reply id.res id.r-post.res]
        =*  reacts  reacts.r-reply.r-post.res
        (hear-many:d nest now.bowl mid ~ reacts)
      ==
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
