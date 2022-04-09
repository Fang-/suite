::  gossip: data sharing with pals
::
::    automates using /app/pals for peer discovery, letting the underlying
::    agent focus on handling the data.
::
::      usage
::
::    to use this library, call its +agent arm with an initial
::    configuration and a map of noun->mark convertors,
::    then call the resulting gate with the agent's door.
::
::    data from peers will come in through +on-agent, as %facts with
::    a /~/gossip wire.
::    the mark convertors ensure that this library can reconstitute the
::    appropriate vases from the (cask *)s it sends around internally.
::    if a mark conversion for a received datum isn't available, then
::    the library will inject a %fact with a %gossip-unknown mark instead,
::    containing a (cask *).
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
::    a %fact with the %gossip-config mark on the /~/gossip/config path.
::    the current configuration can be scries out using the +read-config
::    helper.
::
::    (we introduce the /~/etc path prefix convention to indicate paths
::     that are for library-specific use only.
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
::      internal logic
::
::    - on-init or during first on-load, watch pals for targets & leeches.
::    - if pals is not running, the watch will simply pend until it starts.
::    - if pals ever watch-nacks, we (TODO) try rewatching on a backoff timer.
::
::    - for facts produced on /~/gossip/source, we
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
++  configure
  |=  =config
  ^-  card:agent:gall
  [%give %fact [/~/gossip/config]~ %gossip-config !>(config)]
::
++  read-config
  |=  bowl:gall
  ^-  config
  .^(config %gx /(scot %p our)/[dap]/(scot %da now)/~/gossip/config/noun)
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
  $:  [kind=@ meta=*]
      when=@da
      data=(cask *)
  ==
+$  meta-0  hops=_0
::TODO  support signing & verifying rumors
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
        future=(list rumor)     ::  rumors of unknown kinds
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
      ^-  cage
      ?^  to=(~(get by grab) p.cask)
        [p.cask (u.to -:!>(**) q.cask)]
      ~&  [%gossip %no-mark p.cask]
      [%gossip-unknown !>(cask)]
    ::
    ++  de-cage
      |=(cage `(cask *)`[p q.q])
    ::
    ++  en-rumor  ::NOTE  assumes !=(0 hops.manner)
      |=  =cage
      ^-  rumor
      :_  [now.bowl (de-cage cage)]
      ~|  [%en-rumor initial-hops=hops.manner]
      [%0 `meta-0`(dec hops.manner)]
    ::
    ++  play-card  ::  en-rumor relevant facts, handle config changes
      |=  =card
      ^-  (quip ^card _state)
      ?.  ?=([%give %fact *] card)  [[card]~ state]
      ?:  =(~ paths.p.card)  [[card]~ state]
      =/  [int=(list path) ext=(list path)]
        %+  skid  paths.p.card
        |=  =path
        ?=([%~.~ %gossip *] path)
      =/  caz=(list ^card)
        ?:  =(~ ext)  ~
        [card(paths.p ext)]~
      ?:  ?=(~ int)  [caz state]
      =*  path  i.int
      ::  there may only be one gossip-internal path per card
      ::
      ?.  =(~ t.int)
        ~&  [%gossip %too-many-internal-targets int]
        ~|([%too-many-internal-targets int] !!)
      ?:  =(/~/gossip/config path)
        ~|  [%weird-fact-on-config p.cage.p.card]
        ?>  =(%gossip-config p.cage.p.card)
        =/  old=config  manner
        =.  manner  !<(config q.cage.p.card)
        :_  state
        ;:  weld
          (hear-changed hear.old)
          (tell-changed tell.old)
          caz
        ==
      ~|  [%strange-internal-target path]
      ?>  =(/~/gossip/source path)
      ::  if hops is configured at 0, we don't broadcast at all.
      ::
      ~&  %gossipping
      =.  memory  (~(put in memory) [now.bowl (sham (de-cage cage.p.card))])
      ?:  =(0 hops.manner)  [caz state]
      =-  [[- caz] state]
      =/  =rumor  (en-rumor cage.p.card)
      card(paths.p [/~/gossip/gossip]~, cage.p [%gossip-rumor !>(rumor)])
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
    ++  play-first-cards
      |=  cards=(list card)
      ^-  (quip card _state)
      =|  out=(list card)
      |-
      ?~  cards  [out state]
      ?.  ?=([%give %fact ~ *] i.cards)
        =^  caz  state  (play-card i.cards)
        $(out (weld out caz), cards t.cards)
      ~&  %first-card-detected
      ::  if hops is set to 0, we block even the initial response
      ::
      ?:  =(0 hops.manner)  $(cards t.cards)
      =.  cage.p.i.cards
        [%gossip-rumor !>((en-rumor cage.p.i.cards))]
      $(out (snoc out i.cards), cards t.cards)
    ::
    ++  resend-rumor
      |=  =rumor
      ^-  (unit card)
      ?>  =(%0 kind.rumor)  ::NOTE  should have been checked for already
      ?~  meta=((soft ,hops=@ud) meta.rumor)  ~
      =*  hops  hops.u.meta
      ?:  =(0 hops)  ~
      =.  meta.rumor  (dec hops)
      `[%give %fact [/~/gossip/gossip]~ %gossip-rumor !>(rumor)]
    ::
    ++  hash-rumor
      |=(rumor [when (sham data)])
    ::
    ++  may-watch
      |=  who=ship
      ?-  tell.manner
        %anybody  &
        %targets  (~(has in (targets:pals ~.)) who)
        %mutuals  (~(has in (mutuals:pals ~.)) who)
      ==
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
      %-  ~(has by wex.bowl)
      [/~/gossip/gossip/(scot %p s) s dap.bowl]
    ::
    ++  want-target
      %~  has  in
      ?-  hear.manner
        %anybody  (~(uni in leeches:pals) (targets:pals ~.))
        %targets  (targets:pals ~.)
        %mutuals  (mutuals:pals ~.)
      ==
    ::
    ++  retry-timer
      |=  [t=@dr p=path]
      ^-  card
      ~&  [%gossip-await-retry p t]
      :+  %pass  [%~.~ %gossip %retry p]
      [%arvo %b %wait (add now.bowl t)]
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
      ?:  =(old new)  ~
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
        ?.  ?=([%~.~ %gossip %gossip @ ~] wire)  ~
        `ship
      %+  weld
        (turn ~(tap in (~(dif in hearing) listen)) leave-target)
      (turn ~(tap in (~(dif in listen) hearing)) watch-target)
    ::
    ++  tell-changed
      |=  old=whos
      ^-  (list card)
      =*  new  tell.manner
      ?:  =(old new)  ~
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
      ::TODO  for later versions, add :future retry logic
      [cards this]
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      ?.  ?=([%~.~ %gossip *] path)
        =^  cards  inner  (on-watch:og path)
        =^  cards  state  (play-cards:up cards)
      [cards this]
      ::  /~/gossip/gossip
      ?>  =(/gossip t.t.path)
      ?.  (may-watch:up src.bowl)
        ~|(%gossip-forbidden !!)
      =^  cards  inner  (on-watch:og /~/gossip/source)
      =^  cards  state  (play-first-cards:up cards)
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
          ?.  =(%0 kind.rumor)
            ~&  [%gossip dap.bowl %delaying-unknown-rumor-kind kind.rumor]
            [~ this(future [rumor future])]
          =/  mage=cage     (en-cage:up data.rumor)
          =^  cards  inner  (on-agent:og /~/gossip/gossip sign(cage mage))
          =^  cards  state  (play-cards:up cards)
          ~&  %put
          :_  this(memory (~(put in memory) hash))
          (weld (drop (resend-rumor:up rumor)) cards)
        ::
            %watch-ack
          :_  this
          ?~  p.sign  ~
          ::  30 minutes might cost us some responsiveness when the other
          ::  party changes their local config, but in return we save both
          ::  ourselves and others from a lot of needless retries.
          ::  (notably, "do we still care" check also lives in %wake logic.)
          ::
          ~&  %gossip-watch-nack
          [(retry-timer:up ~m1 /watch/(scot %p src.bowl))]~  ::TODO  m30
        ::
            %kick
          :_  this
          ::  to prevent pathological kicks from exploding, we always
          ::  wait a couple seconds before resubscribing.
          ::  perhaps this is overly careful, but we cannot tell the
          ::  difference between "clog" kicks and "missing mark" kicks,
          ::  so we cannot take more accurate/appropriate action here.
          ::  (notably, "do we still care" check also lives in %wake logic.)
          ::
          ~&  %gossip-kick
          [(retry-timer:up ~s15 /watch/(scot %p src.bowl))]~
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
          :_  this
          ?~  p.sign  ~
          %-  (slog 'gossip: failed to subscribe on %pals!!' u.p.sign)
          [(retry-timer:up ~m1 t.t.wire)]~
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
      ?.  ?=([@ %~.~ %gossip *] path)
        (on-peek:og path)
      ?.  ?=(%x i.path)  [~ ~]
      ?+  t.t.t.path  [~ ~]
        [%config ~]  ``noun+!>(manner)
      ==
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
      |=  [=wire sign=sign-arvo:agent:gall]
      ^-  (quip card _this)
      ?.  ?=([%~.~ %gossip *] wire)
        =^  cards  inner  (on-arvo:og wire sign)
        =^  cards  state  (play-cards:up cards)
        [cards this]
      ?>  ?=([%retry *] t.t.wire)
      ?>  ?=(%wake +<.sign)
      ?+  t.t.t.wire  ~|(wire !!)
          [%pals *]
        ::NOTE  this might result in subscription wire re-use,
        ::      but if we hit this path we should be loud anyway.
        [watch-pals:up this]
      ::
          [%watch @ ~]
        :_  this
        =/  target=ship  (slav %p i.t.t.t.t.wire)
        ?.  ?&  !(watching-target:up target)
                (want-target:up target)
            ==
          ~&  %skip
          ~
        ~&  %actual-retry
        [(watch-target:up target)]~
      ==
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
