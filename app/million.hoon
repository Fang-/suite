::  million: the million dollar urbit app
::
::    a million pixels. $1 per pixel. sold in blocks of 10x10 pixels.
::    get yours today!
::
::    possible use cases for a "map of owned space" include:
::    - advertising space in the style of the million dollar homepage
::    - spatial web content sharing in the style of ~hanfel-dovned's %board
::    - room shape & contents for a dungeon crawler or mud style game
::    - ???
::
::    the general flow is as follows:
::    - everyone subscribes to ~paldev for grid updates.
::    - clients may send $action pokes to ~paldev to request grid updates,
::      and locally set the tile to %unacked, for optimistic rendering.
::    - ~paldev may nack or ack the poke.
::      - if it nacks, the client is expected to revert the change.
::      - if it acks, it will also send a matching update fact to subscribers.
::
::    (yes, initial implementation was a little bit of a rushjob. we'll
::    clean it up eventually!)
::
/-  *million
/+  rudder, dbug, verb
::
/~  pages  (page:rudder grid action)  /app/million/webui
::
|%
+$  state-0
  $:  %0
      grid=grid
  ==
::
+$  card  $+(card card:agent:gall)
::
++  host  ~paldev
++  aide  ~palfun-foslup
::
++  en-spol
  |=  spol=(list spot)
  ^-  wire
  %-  flop
  %+  roll  spol
  |=  [=spot =wire]
  [(scot %ud y.spot) (scot %ud x.spot) wire]
::
++  de-spol
  |=  =wire
  ^-  (list spot)
  ?~  wire  ~
  ?>  ?=([@ @ *] wire)
  :-  [(slav %ud i.wire) (slav %ud i.t.wire)]
  $(wire t.t.wire)
::
++  bust  ::  canonical tile contents
  |=  =tile
  ^+  tile
  ?+  -.tile  tile
    %unacked  $(tile old.tile)
  ==
::
++  apply  ::  validate & apply client action (as host)
  |=  [=bowl:gall =grid =action]
  ^-  [new=^grid =_grid]
  ?-  -.action
      %buy
    =/  spol=(list spot)  ~(tap in spos.action)
    ~?  !=(src.bowl ship.action)  %illicit-buy
    ?>  =(src.bowl ship.action)
    ?>  %+  levy  spol
        |=  s=spot
        =([%forsale ~] (~(gut by grid) s *tile))
    %+  roll  spol
    |=  [=spot new=^grid =_grid]
    ?>  &((lte x.spot size) (lte y.spot size))
    =/  =tile  [%pending ship.action]
    ?:  =(`tile (~(get by grid) spot))  [new grid]
    :-  (~(put by new) spot tile)
    (~(put by grid) spot [%pending ship.action])
  ::
      %giv
    ?<  =(ship.action src.bowl)
    %+  roll  ~(tap in spos.action)
    |=  [=spot new=^grid =_grid]
    ?>  &((lte x.spot size) (lte y.spot size))
    =/  =tile  (~(gut by grid) spot *tile)
    ?.  ?=(%managed -.tile)
      ?>  =(host src.bowl)
      ?>  ?=(%pending -.tile)
      =/  =^tile  [%managed ship.action *body]
      :-  (~(put by new) spot tile)
      (~(put by grid) spot tile)
    ?>  |(=(who.tile src.bowl) =(host src.bowl))
    =.  tile  tile(who ship.action)
    :-  (~(put by new) spot tile)
    (~(put by grid) spot tile)
  ::
      %set
    ?>  &((lte x.spot.action size) (lte y.spot.action size))
    =/  =tile  (~(gut by grid) spot.action *tile)
    ?>  ?=(%managed -.tile)
    ?:  =(+>.tile body.action)  [~ grid]
    =.  tile  tile(+> body.action)
    :-  [spot.action^tile ~ ~]
    (~(put by grid) spot.action tile)
  ==
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
::
|_  =bowl:gall
+*  this  .
::
::  lifecycle
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :-  [%pass /eyre %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  ?:  =(host our.bowl)
    [%pass /back %arvo %b %wait (add now.bowl ~d1)]~
  [%pass /grid %agent [host dap.bowl] %watch /0/grid]~
::
++  on-save  !>(state)
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 ole))]
::
::  host logic
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)  [~ this]
  ::TODO  must be legible to other agents!
  ?.  =([host /0/grid] [our.bowl path])  !!
  :_  this
  [%give %fact ~ %million-update !>(`update`[%ful grid])]~
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  ~|([dap.bowl %unexpected-poke mark=mark] !!)
      %noun
    ::  debug & management commands
    ::
    ?>  =(host our.bowl)
    ?+  q.vase  !!
        %resend
      :_  this
      [%give %fact [/0/grid]~ %million-update !>(`update`[%ful grid])]~
    ::
        [%force *]
      =/  new=^grid  ;;(^grid +.q.vase)
      ?>  !(levy ~(tap in ~(key by new)) |=(spot |((gte x size) (gte y size))))
      :_  this(grid (~(uni by grid) new))
      [%give %fact [/0/grid]~ %million-update !>(`update`[%new new])]~
    ::
        [?(%approve %reject) @]
      =/  who=ship  ;;(@p +.q.vase)
      =/  new=^grid
        %-  ~(gas by *(map spot tile))
        %+  murn  ~(tap by grid)
        |=  [s=spot t=tile]
        ?.  =([%pending who] t)  ~
        %-  some
        ?:  ?=(%reject -.q.vase)  [s %forsale ~]
        [s %managed who %*(. *body tint %k)]
      :_  this(grid (~(uni by grid) new))
      [%give %fact [/0/grid]~ %million-update !>(`update`[%new new])]~
    ==
  ::
      %handle-http-request
    =;  out=(quip card _grid)
      [-.out this(grid +.out)]
    %.  [bowl !<(order:rudder vase) grid]
    %-  (steer:rudder _grid action)
    :^    pages
        |=  trail:rudder
        ^-  (unit place:rudder)
        ?~  site=(decap:rudder /[dap.bowl] site)  ~
        ?+  u.site  ~
          ~           `[%page !=(host our.bowl) %index]
          [%image ~]  `[%page !=(host our.bowl) %image]
          [@ ~]  ?:((~(has by pages) i.u.site) `[%page & i.u.site] ~)
        ==
      (fours:rudder grid)
    |=  =action
    ^-  $@  brief:rudder
        [brief:rudder (list card) _grid]
    =/  res=(each (quip card _this) tang)
      %-  mule  |.
      (on-poke %million-action !>(action))
    ?:  ?=(%| -.res)  'invalid action'
    =^  caz  this  p.res
    :_  [caz grid]
    ?+  -.action  ~
      %buy  (crip "Our sales representative, {(scow %p aide)}, will reach out to you within 24 hours. Please watch your DMs.")
    ==
  ::
      %million-action
    =/  =action  !<(action vase)
    ::  host logic (validate & apply & emit changes)
    ::
    ?:  =(host our.bowl)
      =^  new  grid  (apply bowl grid action)
      :_  this
      :-  [%give %fact [/0/grid]~ %million-update !>(`update`[%new new])]
      ::  if it's a buy action, notify the sales rep via dm
      ::
      ?.  &(=(host our.bowl) ?=(%buy -.action))  ~
      ::NOTE  we dont' really want the /sur/chat dependency, and this is
      ::      host-only logic anyway, so keeping this untyped is Fine™
      =/  content
        ~[ship+ship.action 'wants to buy' code+(crip <~(tap in spos.action)>)]
      ~&  >  content
      =;  cage=(unit cage)
        ?~  cage  ~
        [%pass /notify %agent [our.bowl %chat] %poke u.cage]~
      ?.  .^(? %gu /(scot %p our.bowl)/channels/(scot %da now.bowl)/$)
        ::  interact with the old (pre-2024) chat
        ::
        =-  `[%dm-action !>(-)]
        [aide [our now]:bowl %add ~ our.bowl now.bowl %story ~ content]
      ?:  =-  =(`%0 (~(get by -) ~.chat-dms))
          .^  (map @ta *)
              %gx
              (scot %p our.bowl)
              %chat
              (scot %da now.bowl)
              /~/negotiate/version/noun
          ==
        ::  we're post-upgrade, and know the version of chat we're talking to,
        ::  send a %chat-dm-action with the appropriate content
        ::
        =-  `[%chat-dm-action !>(-)]
        [aide [our now]:bowl %add [[%inline content]~ our.bowl now.bowl] ~ ~]
      ::  we don't know what version chat is running at, and so cannot
      ::  interact with it reliably
      ::
      ~&  >>>  content
      ~
    ::  local logic (apply as %unacked, send to host)
    ::
    ::XX  below assumed good
    ?>  =(our src):bowl
    :-  =/  spol=(list spot)
          ?-  -.action
            %buy  ~(tap in spos.action)
            %giv  ~(tap in spos.action)
            %set  [spot.action]~
          ==
        =/  =wire  [%action (en-spol spol)]
        [%pass wire %agent [host dap.bowl] %poke %million-action !>(action)]~
    =-  this(grid -)
    ?-  -.action
        %buy
      =/  spol=(list spot)  ~(tap in spos.action)
      %+  roll  spol
      |=  [=spot =_grid]
      ?>  &((lte x.spot size) (lte y.spot size))
      %+  ~(put by grid)  spot
      :+  %unacked
        =/  old  (bust (~(gut by grid) spot *tile))
        ?>(?=(%forsale -.old) old)
      new=[%pending ship.action]
    ::
        %set
      ?>  &((lte x.spot.action size) (lte y.spot.action size))
      =/  =tile  (bust (~(gut by grid) spot.action *tile))
      ?>  ?=(%managed -.tile)
      ?>  =(who.tile our.bowl)
      %+  ~(put by grid)  spot.action
      [%unacked tile [%managed our.bowl body.action]]
    ::
        %giv
      =/  spol=(list spot)  ~(tap in spos.action)
      %+  roll  spol
      |=  [=spot =_grid]
      ?>  &((lte x.spot size) (lte y.spot size))
      =/  =tile  (bust (~(gut by grid) spot *tile))
      ?>  ?=(%managed -.tile)
      ?>   =(who.tile our.bowl)
      %+  ~(put by grid)  spot
      :+  %unacked
        old=tile
      new=tile(who ship.action)
    ==
  ==
::
::  client logic
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ~|  [wire -.sign]
  ?+  wire  ~|(%unexpected-wire !!)
      [%grid ~]
    ?+  -.sign  !!
      %kick  [[%pass /grid %agent [host dap.bowl] %watch /0/grid]~ this]
    ::
        %watch-ack
      ?~  p.sign  [~ this]
      %-  (slog dap.bowl 'setup failed, watch-nack' u.p.sign)
      ::TODO  retry?
      [~ this]
    ::
        %fact
      ?.  ?=(%million-update p.cage.sign)
        ~|([%unexpected-mark p.cage.sign] !!)
      =+  !<(=update q.cage.sign)
      =.  grid
        ?-  -.update
          %ful  grid.update
          %new  (~(uni by grid) grid.update)
        ==
      ::TODO  maybe notify if we newly own a tile?
      [~ this]
    ==
  ::
      [%action *]
    ?.  ?=(%poke-ack -.sign)  !!
    ::  no longer unacked
    ::
    =-  [~ this(grid -)]
    %+  roll  (de-spol t.wire)
    |=  [=spot =_grid]
    %+  ~(put by grid)  spot
    =/  =tile  (~(gut by grid) spot *tile)
    ?.  ?=(%unacked -.tile)  tile
    ::  in case of nack, revert to the old.
    ::  in case of ack, canonize the new.
    ?~(p.sign new.tile old.tile)
  ::
      [%back ~]
    ?.  ?=(%poke-ack -.sign)  !!
    ?~  p.sign  [~ this]
    ((slog dap.bowl 'backup failed' u.p.sign) [~ this])
  ::
      [%notify ~]
    ?.  ?=(%poke-ack -.sign)  !!
    ?~  p.sign  [~ this]
    ((slog dap.bowl 'notify failed' u.p.sign) [~ this])
  ==
::
::  etc
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
      [%x %tile @ @ ~]
    ?~  x=(slaw %ud i.t.t.path)           [~ ~]
    ?~  y=(slaw %ud i.t.t.t.path)         [~ ~]
    ?:  |((gte u.x size) (gte u.y size))  [~ ~]
    =/  =tile  (~(gut by grid) [u.x u.y] *tile)
    ``million-tile+!>(tile)
  ==
::
++  on-fail
  |=  [=term =tang]
  ^-  (quip card _this)
  %-  (slog (rap 3 '%' dap.bowl ': on-fail, ' term ~) tang)
  ?.  =(%fact term)  [~ this]
  ::  %fact handling crashed. we should only have a single /grid subscription
  ::  outstanding, so we know the crash was there. resubscribing should
  ::  get us a full grid fact, bringing us back up to speed safely.
  ::
  ?:  (~(has by wex.bowl) [/grid host dap.bowl])
    ~&(%still-standing [~ this])
  ~&  %reestablishing
  [[%pass /grid %agent [host dap.bowl] %watch /0/grid]~ this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ~|  wire
  ?+  wire  !!
    [%eyre ~]  [~ this]
  ::
      [%back ~]
    :_  this
    :~  [%pass /back %arvo %b %wait (add now.bowl ~d1)]
      ::
        =/  =path  /[dap.bowl]/(scot %da (sub now.bowl (mod now.bowl ~d1)))/jam
        =/  =cage  [%drum-put !>([path (jam grid)])]
        [%pass /back %agent [our.bowl %hood] %poke cage]
    ==
  ==
::
++  on-leave  |=(* [~ this])
--
