::  gossip: data sharing with pals
::TODO  alternatively: buzz (with fizz & buzz for source & gossip)
::
::    automates using /app/pals for peer discovery, letting the underlying
::    application focus on handling the data.
::
::      usage
::
::    to use this library, call its +agent arm with a configuration,
::    then call the resulting gate with the application's agent door.
::    data from peers will come in through +on-agent, as %facts with
::    a /~/gossip wire.
::    to give data to peers through this library, simply produce a fact
::    on a /~/gossip/source path (if the data originated locally) or
::    on a /~/gossip/gossip path (if the data came in from elsewhere).
::    be careful when sending gossip facts! doing so when no new information
::    was obtained will likely result in networing loops.
::
::    (the networking efficiency of this library isn't great to begin with.
::     receiving any new datum likely results in sending gossip facts,
::     which in turn will result in _receiving_ gossip facts from any mutuals.
::     while this isn't a deal-breaker, it suggests a naive gossip
::     implementation should be considered merely a prototype...)
::
::    we introduce the /~/x path prefix convention to indicate paths that
::    are for library-specific use only.
::    with that in mind, giving facts on the /~/gossip/gossip path when
::    the app is configured for %source listening only is generally a no-op.
::    while the app is free to not send /~/gossip/gossip facts at all,
::    developers might want to keep in mind future upgradability, user
::    modification, and whether or not they want to support other applications
::    flaunting the convention and subscribing to it anyway. the applicability
::    of all that might also vary per use case.
::
::      wip, thoughts
::
::    actual gossiping behavior remains unimplemented. for reasons mentioned
::    above (and others) a naive gossip implementation is sub-optimal and
::    risks infinite networking loops.
::    we may want to include additional metadata alongside gossip facts,
::    such as a hop counter, set of informed peers, etc.
::    we may want to use pokes exclusively, instead of watches/facts,
::    making it easier to exclude the src.bowl, include metadata, etc.
::
::      configuration
::
::      mode
::    %source  data originating from direct friends only
::    %gossip  (TODO) full p2p gossip
::
::      perm
::    %leeches  let anyone listen
::    %mutuals  only targets may listen
::
::      warn
::    if true, shows debug printfs on misuse.
::    turn on for dev, not production.
::
::      internal logic
::
::    - on-init or during first on-load, watch pals for targets.
::    - if pals is not running, the watch will simply pend until it starts.
::    - if pals ever watch-nacks, we (TODO) try rewatching on a backoff timer.
::
::    (note that this describes logic for %source mode only. %gossip is TODO.)
::    - for new targets, we watch their dap.bowl on /~/gossip/source.
::    - for gone targets, we leave that watch.
::    - for facts on those watches, we +on-agent them into the inner agent.
::    - for nacks on those watches, we (TODO) retry later/on-leeche.
::
|%
++  invent
  |=  =cage
  ^-  card:agent:gall
  [%give %fact [/~/gossip/source]~ cage]
::
++  spread
  |=  =cage
  ^-  card:agent:gall
  [%give %fact [/~/gossip/gossip]~ cage]
::
+$  mode  ?(%source %gossip)
+$  perm  ?(%leeches %mutuals)
::
++  agent
  |=  $:  =mode
          =perm
          warn=?
      ==
  ?>  =(%source mode)  ::TODO  implement %gossip
  |^  agent
  ::
  +$  state-0
    $:  %0
        $=  prev
        $:  =mode
            =perm
        ==
    ==
  ::TODO  maybe we should wrap _anyway_ to add a "hops" counter,
  ::      and put a max on that?
  ::     ++  transform
  ::       |*  [caz=(list card:agent:gall) app=*]
  ::       [(turn caz transform-card) app]
  ::     ::
  ::     ++  transform-card
  ::       |=  =card:agent:gall
  ::       ^+  card
  ::       ?.  ?=([%give %fact *] card)
  ::         card
  ::       ?.  ?=([[%~.~gossip * ~] ~] paths.card)
  ::         ~?  &(warn (lien paths.card |=(p=path ?=([%~.~gossip *] p))))
  ::           [%gossip %strange-fact-paths [p.cage paths]:card]
  ::         card
  ::       card(paths ~[/~/gossip/source /~/gossip/gossip])
  ::       :: =/  deets  [from=our mark=p.cage]
  ::       :: =/  =vase  (slop !>(deets) q.cage)
  ::       :: ::TODO  or just nested vase? a la !>([deets q.cage])
  ::       :: [%give %fact ~[/~/gossip/source /~/gossip/gossip] %gossip-wrapper vase]
  ++  agent
    |=  inner=agent:gall
    =>  |%
        ++  watch-pals
          ^-  card:agent:gall
          ::TODO  also watch leeches?
          [%pass /~/gossip/pals %agent [our.bowl %pals] %watch /targets]
        ::
        ++  watch-target
          |=  s=ship
          ^-  (list card:agent:gall)
          =*  gill  [s dap.bowl]
          :*  [%pass /~/gossip/source %agent gill %watch /~/gossip/source]
            ::
              ~
              ::TODO  for gossip, we may or may not want watch-based logic
              :: ?.  =(%gossip mode)  ~
              :: [%pass /~/gossip/gossip %agent gill %watch /~/gossip/gossip]~
          ==
        ::
        ++  leave-target
          |=  s=ship
          ^-  (list card:agent:gall)
          =*  gill  [s dap.bowl]
          :*  [%pass /~/gossip/source %agent gill %leave ~]
            ::
              ~
              ::TODO  for gossip, we may or may not want watch-based logic
              :: ?.  =(%gossip mode)  ~
              :: [%pass /~/gossip/gossip %agent gill %leave ~]~
          ==
        ::
        ++  mode-changed
          |=  [old=mode new=mode]
          ^-  (list card:agent:gall)
          ::TODO  implement %gossip
          ?+  [old new]  ~&([%gossip %strange-mode-change old new] ~)
              [%source %gossip]
            !!
          ::
              [%gossip %source]
            !!
          ==
        ::
        ++  perm-changed
          |=  [old=perm new=perm our=@p now=@da sub=(list [ship path])]
          ^-  (list card:agent:gall)
          ?+  [old new]  ~&([%gossip %strange-perm-change old new] ~)
              [%leeches %mutuals]
            ::  perms got broader, we can just no-op
            ::
            ~
          ::
              [%mutuals %leeches]
            ::  perms got tighter, we need to kick stragglers
            ::
            =/  targets=(set ship)
              =/  base=path  /(scot %p our.bowl)/pals/(scot %da now)
              ?.  .^(? %gu base)  ~
              .^((set ship) %gx (snoc base %targets))
            %+  murn  sub
            |=  [s=ship p=path]
            ^-  (unit card:agent:gall)
            =;  kick=?
              ?.(kick ~ `[%give %kick [p]~ `s])
            ?&  ?=([%~.~ %gossip *] p)
                !(~(has in targets) s)
            ==
          ==
        --
    =|  state-0
    =*  state  -
    ::TODO  if warn then we want to sanity-check /~/gossip facts?
    |_  =bowl:gall
    +*  og  ~(. inner bowl)
    ++  on-init
      ^-  (quip card:agent:gall agent:gall)
      =^  cards  inner
        on-init:og
      =.  prev  [mode perm]
      [[watch-pals cards] this]
    ::
    ++  on-save  !>([[%gossip state] on-save:og])
    ++  on-load
      |=  ole=vase
      ^-  (quip card:agent:gall agent:gall)
      ?.  ?=([[%gossip *] *] q.ole)
        =^  og-cards  inner  (on-load:og ole)
        ::TODO  deduplicate with +on-init
        =.  prev  [mode perm]
        [[watch-pals og-cards] this]
      ::
      =+  !<([[%gossip old=state-0] ile=vase] ole)
      =^  cards  inner  (on-load:og ile)
      =?  cards  !=(mode mode.prev.old)
        (weld card (mode-changed mode.prev.old mode))
      =?  cards  !=(perm perm.prev.old)
        (weld card (perm-changed perm.prev.old perm ~(val by sup.bowl)))
      [cards this]
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card:agent:gall agent:gall)
      ?.  ?=([%~.~ %gossip *] path)
        (on-watch:og path)
      ::
      ?:  ?=([%source ~] t.path)  ::TODO  implement %gossip
        [~ this]
      ~|  [%gossip %unexpected-path path]
      !!
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?.  ?=([%~.~ %gossip *] wire)
        =^  cards  inner  (on-agent:og wire sign)
        [cards this]
      ::
      ?-  t.t.wire  ~|([%gossip %unexpected-wire wire] !!)
          [%source ~]
        ?-  -.sign
            %fact
          =^  cards  inner  (on-agent:og /~/gossip sign)
          [cards this]
        ::
            %watch-ack
          ?~  p.sign  [~ this]
          ::TODO  should retry on timer, and/or on-leeche?
          ~&  [%gossip %no-retry-logic-yet wire]
          =/  =tank  leaf+"gossip failed subscribe on {<dap.bowl>}{<wire>}"
          ((slog tank u.p.sign) [~ this])
        ::
            %kick
          ::TODO  careful, change when you implement %gossip
          ::TODO  should only rewatch if still a target?
          [(watch-target src.bowl) this]
        ::
            %poke-ack
          ~&  [%gossip %unexpected-poke-ack wire]
          [~ this]
        ==
      ::
          [%pals ~]
        ?-  -.sign
            %fact
          =*  mark  p.cage.sign
          =*  vase  q.cage.sign
          ?.  =(%pals-effect mark)
            ~|  [%gossip %unexpected-fact mark wire]
            !!
          =+  !<(=effect:pals vase)
          :_  this
          ?-  -.effect
            %meet  (watch-target ship.effect)
            %part  (leave-target ship.effect)
          ::
            %near  !!  ::TODO  maybe retry nacked watch?
            %away  !!
          ==
        ::
            %watch-ack
          ?~  p.sign  [~ this]
          ::TODO  should retry on timer?
          ~&  [%gossip %no-retry-logic-yet wire]
          =/  =tank  leaf+"gossip failed subscribe on %pals{<wire>}"
          ((slog tank u.p.sign) [~ this])
        ::
            %kick
          [[watch-pals]~ this]
        ::
            %poke-ack
          ~&  [%gossip %unexpected-poke-ack wire]
          [~ this]
      ==
    ::
    ++  on-leave  on-leave:og
    ++  on-poke   on-poke:og
    ++  on-peek   on-peek:og
    ++  on-arvo   on-arvo:og
    ++  on-fail   on-fail:og
    --
  --
--
