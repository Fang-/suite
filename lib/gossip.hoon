::  gossip: data sharing with pals
::
::    automates using /app/pals for peer discovery, letting the underlying
::    agent focus on handling the data.
::
::      usage
::
::    to use this library, call its +agent arm with an initial
::    configuration, then call the resulting gate with the agent's door.
::
::    data from peers will come in through +on-agent, as %facts with
::    a /~/gossip wire.
::
::    for new incoming subscriptions, the underlying agent's +on-watch is
::    called, with /~/gossip/source, so that it may give initial results.
::
::    ::TODO  should the below all have shorthand functions?
::
::    when data originates locally and needs to be given to our peers,
::    simply produce a %fact on the /~/gossip/source path.
::    refrain from re-emitting received %facts manually. the library will
::    handle this for you, based on the current configuration.
::
::    to change the configuration after the agent has been started, emit
::    a %fact with the %gossip-xx mark on the /~/gossip/config path.
::
::    (we introduce the /~/x path prefix convention to indicate paths that
::     are for library-specific use only.
::     the advantage this has over the "mutated agent" pattern (for example,
::     /lib/shoe) is that the library consumes a normal $agent:gall, making
::     it theoretically easier to compose with other agent libraries.
::     the disavantage, of course, is that internal interaction with the
::     wrapper library isn't type-checked anymore. helper functions make
::     that less of a problem, but the developer must stay vigilant.)
::
::      wip, thoughts
::
::    we may want to include additional metadata alongside gossip facts,
::    such as a hop counter, set of informed peers, origin timestamp, etc.
::    we may want to use pokes exclusively, instead of watches/facts,
::    making it easier to exclude the src.bowl, include metadata, etc.
::
::    most important: compare against stuff we already have!
::    lib can do this: attach id, check on that
::    agent shoudl not re-emit at all! only emit sources and react
::    TODO  video walkthrough of this
::
::      configuration
::    TODO  custom cards for changing this at run-time
::    TODO  and then just only rsepect the args in first +on-init/+on-load
::
::      mode
::    %source  data originating from direct friends only
::    %gossip  (TODO) full p2p gossip
::
::      perm
::    ::TODO  rename/rewrite for consistency/usefulness
::    %leeches  let anyone listen
::    %mutuals  only targets may listen
::
::      warn
::    if true, shows debug printfs on misuse.
::    turn on for dev, not production.
::
::      internal logic
::
::    - on-init or during first on-load, watch pals for targets & leeches.
::    - if pals is not running, the watch will simply pend until it starts.
::    - if pals ever watch-nacks, we (TODO) try rewatching on a backoff timer.
::
::    - for facts produced on /~/gossip/source, we
::      - send them out as-is(?), and
::      - wrap them as %gossip-rumor to send them out on /~/gossip/gossip
::    - for new pals matching the hear mode, we watch their /~/gossip/gossip
::    - for gone pals, we leave that watch
::    - for facts on those watches
::      - ensure they're %gossip-rumors, ignoring otherwise
::      - unwrap them and +on-agent /~/gossip/gossip into the inner agent, and
::      - re-emit them as facts on /~/gossip/gossip if there are hops left
::    - for nacks on those watches, we (TODO) retry later/on-leeche
::
/-  pals
/+  lp=pals, default-agent
::
|%
++  invent
  |=  =cage
  ^-  card:agent:gall
  [%give %fact [/~/gossip/source]~ cage]
::
++  configure  ::TODO  support
  |=  =config
  ^-  card:agent:gall
  [%give %fact [/~/gossip/config]~ %gossip-config !>(config)]
::
+$  whos
  $?  %anybody
      %targets
      %mutuals
  ==
::
+$  config
  $:  hops=_1    ::  how far away gossip may travel (1 hop is pals only)
      hear=whos  ::  who to subscribe to
      tell=whos  ::  who to allow subscriptions from
  ==
::
+$  rumor
  $:  hops=_0
      when=@da
      ::TODO  from=(unit [ship life sig]) ?
      what=(cask *)
  ==
::
++  agent
  |=  $:  init=config
          grab=(map mark tube:clay)
      ==
  ^-  $-(agent:gall agent:gall)
  |^  agent
  ::
  +$  state-0
    $:  %0
        manner=config           ::  latest config
        memory=(set [@da @uv])  ::  cages seen
    ==
  ::
  +$  card  card:agent:gall
  ::
  ++  helper
    |_  [=bowl:gall state-0]
    +*  state  +<+
        pals   ~(. lp bowl)
    ++  en-cage
      |=  =(cask *)
      ^-  (unit cage)
      ::TODO  what if we defaulted to [%noun *] instead?
      ?~  to=(~(get by grab) p.cask)  ~
      `[p.cask (u.to -:!>(**) q.cask)]
    ::
    ++  de-cage
      |=(cage `(cask *)`[p q.q])
    ::
    ++  en-rumor
      |=  =cage
      ^-  rumor
      [(dec hops.manner) now.bowl (de-cage cage)]
    ::
    ++  play-card  ::  en-rumor relevant facts
      |=  =card
      ^-  (quip ^card _state)
      ?.  ?=([%give %fact *] card)  [[card]~ state]
      =/  [int=(list path) ext=(list path)]
        %+  skid  paths.p.card
        ::TODO  what about the ~ case after +on-watch?
        |=  =path
        ?=([%~.~ %gossip *] path)
      =/  caz=(list ^card)
        ?:  =(~ ext)  ~
        [card(paths.p ext)]~
      ?:  =(~ int)  [caz state]
      ::
      ::TODO  handle configuration cards
      ?>  (levy int (cury test /~/gossip/source))
      ::
      ~&  %gossipping
      =/  =rumor  (en-rumor cage.p.card)
      =.  memory  (~(put in memory) (hash-rumor rumor))
      =+  card(paths.p [/~/gossip/gossip]~, cage.p [%gossip-rumor !>(rumor)])
      [[- caz] state]
    ::
    ++  play-cards
      |=  cards=(list card)
      ^-  (quip card _state)
      =|  out=(list card)
      |-
      ?~  cards  [out state]
      =^  caz  state  (play-card i.cards)
      $(out (weld out caz), cards t.cards)
    ::
    ++  first-cards
      |=  cards=(list card)
      ^-  (quip card _state)
      =|  out=(list card)
      |-
      ?~  cards  [out state]
      ?.  ?=([%give %fact ~ *] i.cards)
        =^  caz  state  (play-card i.cards)
        $(out (weld out caz), cards t.cards)
      ~&  %first-card-detected
      =.  cage.p.i.cards
        [%gossip-rumor !>((en-rumor cage.p.i.cards))]
      $(out (snoc out i.cards), cards t.cards)
    ::
    ++  resend-rumor
      |=  =rumor
      ^-  (unit card)
      ?:  =(0 hops.rumor)  ~
      =.  hops.rumor  (dec hops.rumor)
      `[%give %fact [/~/gossip/gossip]~ %gossip-rumor !>(rumor)]
    ::
    ++  hash-rumor
      |=(rumor [when (sham what)])
    ::
    ::
    ++  watch-pals
      ^-  (list card)
      =/  =gill:gall  [our.bowl %pals]
      :~  [%pass /~/gossip/pals/targets %agent gill %watch /targets]
          [%pass /~/gossip/pals/leeches %agent gill %watch /leeches]
      ==
    ::
    ++  watching-target
      |=  s=ship
      ~&  wt=wex.bowl
      %+  lien  ~(tap by wex.bowl)
      |=  [[=wire =ship =term] [acked=? =path]]
      ?&  =(s ship)
          =(/~/gossip/gossip/(scot %p s) wire)
      ==
    ::
    ++  watch-target
      |=  s=ship
      ^-  card
      ~&  [%gossip-watch-target s]
      :+  %pass  /~/gossip/gossip/(scot %p s)
      [%agent [s dap.bowl] %watch /~/gossip/gossip]
    ::
    ++  leave-target
      |=  s=ship
      ^-  card
      ~&  [%gossip-leave-target s]
      :+  %pass  /~/gossip/gossip/(scot %p s)
      [%agent [s dap.bowl] %leave ~]
    ::
    ++  kick-target
      |=  s=ship
      ^-  card
      ~&  [%gossip-kick-target s]
      [%give %kick [/~/gossip/gossip]~ `s]
    ::
    ++  hear-changed
      |=  old=whos
      ^-  (list card)
      =*  new  hear.manner
      =/  listen=(set ship)
        ?-  new
          %anybody  (~(uni in leeches:pals) (targets:pals ~.))
          %targets  (targets:pals ~.)
          %mutuals  (mutuals:pals ~.)
        ==
      =/  hearing=(set ship)
        %-  ~(gas in *(set ship))
        %+  murn  ~(tap by wex.bowl)
        |=  [[=wire =ship =term] [acked=? =path]]
        ^-  (unit ^ship)
        ?.  =([%~.~ %gossip %gossip @ ~] wire)  ~
        `ship
      %+  weld
        (turn ~(tap in (~(dif in listen) hearing)) watch-target)
      (turn ~(tap in (~(dif in hearing) listen)) leave-target)
    ::
    ++  tell-changed
      |=  old=whos
      ^-  (list card)
      =*  new  tell.manner
      ?-  [old new]
          $?  [* %anybody]
              [%mutuals *]
          ==
        ::  perms got broader, we can just no-op
        ::
        ~
      ::
          [* ?(%targets %mutuals)]
        ::  perms got tighter, we need to kick stragglers
        ::
        =/  allowed=(set ship)
          ?-  new
            %anybody  !!
            %targets  (targets:pals ~.)
            %mutuals  (mutuals:pals ~.)
          ==
        %+  murn  ~(val by sup.bowl)
        |=  [s=ship p=path]
        ^-  (unit card)
        =;  kick=?
          ?.(kick ~ `(kick-target s))
        ?&  ?=([%~.~ %gossip %gossip ~] p)
            !(~(has in allowed) s)
        ==
      ==
    --
  ::
  ++  agent
    |=  inner=agent:gall
    =|  state-0
    =*  state  -
    ^-  agent:gall
    ::TODO  if warn then we want to sanity-check /~/gossip facts?
    ::
    |_  =bowl:gall
    +*  this    .
        pals  ~(. lp bowl)
        def   ~(. (default-agent this %|) bowl)
        og    ~(. inner bowl)
        up    ~(. helper bowl state)
    ++  on-init
      ^-  (quip card _this)
      =.  manner  init
      =^  cards   inner  on-init:og
      =^  cards   state  (play-cards:up cards)
      [(weld watch-pals:up cards) this]
    ::
    ::TODO  why does this on-save not get called?
    ++  on-save  ~&  %on-save-gossip  !>([[%gossip state] on-save:og])
    ++  on-load
      |=  ole=vase
      ^-  (quip card _this)
      ?.  ?=([[%gossip *] *] q.ole)
        ~&  [%huh -.q.ole]
        ::TODO  deduplicate with +on-init
        =.  manner  init
        =^  cards   inner   (on-load:og ole)
        ::TODO  fires too often?
        =^  cards   state  (play-cards:up cards)
        [(weld watch-pals:up cards) this]
      ::
      =+  !<([[%gossip old=state-0] ile=vase] ole)
      =.  state  old
      =^  cards  inner  (on-load:og ile)
      =^  cards  state  (play-cards:up cards)
      [cards this]
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      ?.  ?=([%~.~ %gossip *] path)
        =^  cards  inner  (on-watch:og path)
        =^  cards  state  (play-cards:up cards)
      [cards this]
      ?>  =(/gossip t.t.path)
      =^  cards  inner  (on-watch:og /~/gossip/source)
      =^  cards  state  (first-cards:up cards)
      [cards this]
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ~&  [%gossip-on-agent wire -.sign]
      ?.  ?=([%~.~ %gossip *] wire)
        =^  cards  inner  (on-agent:og wire sign)
        =^  cards  state  (play-cards:up cards)
      [cards this]
      ::
      ?+  t.t.wire  ~|([%gossip %unexpected-wire wire] !!)
          [%gossip @ ~]
        ?-  -.sign
            %fact
          =*  mark  p.cage.sign
          =*  vase  q.cage.sign
          ?.  =(%gossip-rumor mark)
            ~&  [%gossip dap.bowl %ignoring-unexpected-fact mark=mark]
            [~ this]
          =+  !<(=rumor vase)
          =+  hash=(hash-rumor:up rumor)
          ~&  [%got-rume hash]
          ?:  (~(has in memory) hash)
            ~&  %hav
            [~ this]
          =/  mage=(unit cage)
            (en-cage:up what.rumor)
          ?~  mage
            ~&  [%gossip dap.bowl %ignoring-unexpected-rumor mark=p.what.rumor hash=hash]
            [~ this]
          =^  cards  inner  (on-agent:og /~/gossip/gossip sign(cage u.mage))
          =^  cards  state  (play-cards:up cards)
          ~&  %put
          :_  this(memory (~(put in memory) hash))
          (weld (drop (resend-rumor:up rumor)) cards)
        ::
            %watch-ack
          ?~  p.sign  [~ this]
          ::TODO  should retry on timer, and/or on-leeche?
          ~&  [%gossip %no-retry-logic-yet wire]
          =/  =tank
            leaf+"gossip failed subscribe on {<dap.bowl>}{<`^wire`wire>}"
          ((slog tank u.p.sign) [~ this])
        ::
            %kick
          ::TODO  should only rewatch if still a target?
          ::      but if the rest of our logic is good, not necessary...
          [[(watch-target:up src.bowl)]~ this]
        ::
            %poke-ack
          ~&  [%gossip %unexpected-poke-ack wire]
          [~ this]
        ==
      ::
          [%pals @ ~]
        ?-  -.sign
          %poke-ack  (on-agent:def wire sign)
          %kick      [watch-pals:up this]
        ::
            %watch-ack
          ?~  p.sign  [~ this]
          ::TODO  should retry on timer? shouldn't fail though...
          ~&  [%gossip %no-retry-logic-yet wire]
          =/  =tank  leaf+"gossip failed subscribe on %pals{<wire>}"
          ((slog tank u.p.sign) [~ this])
        ::
            %fact
          =*  mark  p.cage.sign
          =*  vase  q.cage.sign
          ?.  =(%pals-effect mark)
            ~&  [%gossip %unexpected-fact-mark mark wire]
            [~ this]
          =+  !<(=effect:^pals vase)
          :_  this
          =*  ship  ship.effect
          ~&  [%hear-pals effect]
          =*  kick  ~&  %kick  [(kick-target:up ship)]~
          =*  view  ~&  %view  [(watch-target:up ship)]~
          =*  flee  ~&  %flee  [(leave-target:up ship)]~
          ~&  [-.effect hear.manner (watching-target:up ship)]
          ?-  -.effect
              %meet
            ?-  hear.manner
              %anybody  ?:((watching-target:up ship) ~ view)
              %targets  view
              %mutuals  ?:((mutual:pals ~. ship) view ~)
            ==
          ::
              %part
            %+  weld
              ?-  tell.manner
                %anybody  ~
                %targets  kick
                %mutuals  kick
              ==
            ?-  hear.manner
              %anybody  ?:((leeche:pals ship) ~ flee)
              %targets  flee
              %mutuals  flee
            ==
          ::
              %near
            ?-  hear.manner
              %anybody  ?:((watching-target:up ship) ~ view)
              %targets  ~
              %mutuals  ?:((mutual:pals ~. ship) view ~)
            ==
          ::
              %away
            %+  weld
              ?-  tell.manner
                %anybody  ~
                %targets  ~
                %mutuals  kick
              ==
            ?-  hear.manner
              %anybody  ?:((target:pals ~. ship) ~ flee)
              %targets  ~
              %mutuals  flee
            ==
          ==
        ==
      ==
    ::
    ++  on-peek
      |=  =path
      ^-  (unit (unit cage))
      ?.  ?=([%~.~ %gossip *] path)
        (on-peek:og path)
      ~  ::TODO
    ::
    ++  on-leave
      |=  path
      ^-  (quip card _this)
      =^  cards  inner  (on-leave:og +<)
      =^  cards  state  (play-cards:up cards)
      [cards this]
    ::
    ++  on-poke
      |=  cage
      ^-  (quip card _this)
      =^  cards  inner  (on-poke:og +<)
      =^  cards  state  (play-cards:up cards)
      [cards this]
    ::
    ++  on-arvo
      |=  [wire sign-arvo:agent:gall]
      ^-  (quip card _this)
      =^  cards  inner  (on-arvo:og +<)
      =^  cards  state  (play-cards:up cards)
      [cards this]
    ::
    ++  on-fail
      |=  [term tang]
      ^-  (quip card _this)
      =^  cards  inner  (on-fail:og +<)
      =^  cards  state  (play-cards:up cards)
      [cards this]
    --
  --
--
