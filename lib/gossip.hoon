::  gossip: data sharing with pals
::
::      v1.1.0: sneaky whisper
::
::    automates using /app/pals for peer & content discovery,
::    letting the underlying agent focus on handling the data.
::
::      usage
::
::    to use this library, call its +agent arm with an initial
::    configuration and a map of, per mark, noun->vase convertors,
::    then call the resulting gate with the agent's door.
::
::    data from peers will come in through +on-agent, as %facts with
::    a /~/gossip wire.
::    the mark convertors ensure that this library can reconstitute the
::    appropriate vases from the (cask *)s it sends around internally.
::    if a mark conversion for a received datum isn't available, then
::    the library will inject a %fact with a %gossip-unknown mark instead,
::    containing a (cask *). the agent may either store it for later use,
::    or handle it directly.
::
::    for new incoming subscriptions, the underlying agent's +on-watch is
::    called, with /~/gossip/source, so that it may give initial results.
::TODO  but this is somewhat wrong for multi-hop subscriptions, right?
::      /source is only intended to give _locally originating_ data.
::      if hops are >1, should we do both /source and /gossip?
::      doesn't this result in a lot of traffic, for know-a-lot cases?
::
::    when data originates locally and needs to be given to our peers,
::    simply produce a normal %fact on the /~/gossip/source path.
::    the +invent helper can be used to do this.
::    refrain from re-emitting received %facts manually. the library will
::    handle this for you, based on the current configuration.
::
::    to change the configuration after the agent has been started, emit
::    a %fact with the %gossip-config mark on the /~/gossip/config path.
::    the +configure helper can be used to do this.
::    the +read-config helper scries out the current configuration.
::    setting hops to 1 distributes the data to direct pals only.
::    setting hops to 0 prevents emission of any gossip data at all,
::    even during initial subscription setup.
::    setting pass to true causes 50% of locally-originating data to be
::    proxied through a random "tell" peer. note that the proxy will have
::    a 50% chance of proxying in turn. for low amounts of hops, data could
::    escape the local social graph entirely.
::
::    (we introduce the /~/etc path prefix convention to indicate paths
::     that are for library-specific use only.
::     the advantage this has over the "mutated agent" pattern (for example,
::     /lib/shoe) is that the library consumes a normal $agent:gall, making
::     it theoretically easier to compose with other agent libraries.
::     the disavantage, of course, is that internal interaction with the
::     wrapper library isn't type-checked anymore. helper functions make
::     that less of a problem, but the developer must stay vigilant about
::     casting all the relevant outputs.)
::
::    when considering the types of data to be sent through gossip, keep
::    in mind that the library keeps track of (hashes of) all the individual
::    datums it has heard. as such, if your data is of the shape @t, and we
::    hear a 'hello' once, we will completely ignore any 'hello' that come
::    afterward, even if they originate from distinct events.
::    if this is a problem for your use case, consider including a timestamp
::    or other source of uniqueness with each distinct datum.
::
::    note that this library and its protocol are currently not in the
::    business of providing anonymized gossip. any slightly motivated actor
::    will have no problem modifying this library to detect and record
::    sources of data with good accuracy.
::
::      wip, libdev thoughts
::
::    we may want to include additional metadata alongside gossip facts,
::    such as a hop counter, set of informed peers, origin timestamp, etc.
::    we may want to use pokes exclusively, instead of watches/facts,
::    making it easier to exclude the src.bowl, include metadata, etc.
::
::    we currently only emit every rumor as a fact once at most. but we might
::    receive it again later, with a higher hop count. if we want to try for
::    maximum reach within the given hops, we should re-send if we receive a
::    known rumor with higher hop counter. but this may not be worth the added
::    complexity...
::
::    what if this was a userspace-infrastructure app instead of a wrapper?
::    how would ensuring installation of this app-dependency work?
::    it gains us... a higher chance of peers having this installed.
::    what if it was just part of pals?
::    would let us more-reliably poke mutuals and leeches, if we wanted to do
::    a proxy-broadcast thing.
::
::    when considering adding features like rumor signing, keep in mind that
::    this library is mostly in the business of ferrying casks. perhaps
::    features like signing should be left up to applications themselves.
::
::      internal logic
::
::    - on-init or during first on-load, watch pals for targets & leeches.
::    - if pals is not running, the watch will simply pend until it starts.
::    - if pals ever watch-nacks (it shouldn't), we try rewatching after ~m1.
::
::    - for facts produced on /~/gossip/source, we
::      - 50% chance to redirect into the "pass flow" (see below)
::      - wrap them as %gossip-rumor to send them out on /~/gossip/gossip
::    - for new pals matching the hear mode, we watch their /~/gossip/gossip
::    - for gone pals, we leave that watch
::    - for facts on those watches
::      - ensure they're %gossip-rumors, ignoring otherwise
::      - unwrap them and +on-agent /~/gossip/gossip into the inner agent, and
::      - re-emit them as facts on /~/gossip/gossip if there are hops left
::    - for nacks on those watches, we retry after ~m30
::
::    - other gossip instances may poke us with rumors directly
::    - the inner agent learns the rumor normally, as if it came from a fact
::    - based on randomness (50/50), we do one of two things:
::      - publish the rumor as a fact to our subscribers, like the above
::      - poke a randomly selected peer (in the "tell" set) with the rumor
::    - when poking, store the rumor until we receive a poke-ack
::    - upon receiving a positive poke-ack, delete the local datum
::    - upon receiving a negative poke-ack, do the 50/50 again
::    - if we do not receive a poke-ack within some time, do the 50/50 again
::
/-  pals
/+  lp=pals, dbug, verb
::
|%
+$  rumor
  $:  [kind=@ meta=*]
      data=(cask *)
  ==
+$  meta-0  hops=_0
::
+$  hash    @uv
::
+$  whos
  $?  %anybody  ::  any ship discoverable through pals
      %targets  ::  any ship we've added as a pal
      %mutuals  ::  any mutual pal
  ==
::
+$  config
  $:  hops=_1    ::  how far away gossip may travel
                 ::  (1 hop is pals only, 0 stops exposing data at all)
      hear=whos  ::  who to subscribe to
      tell=whos  ::  who to allow subscriptions from
      pass=?     ::  whether to (50/50) emit through proxy
  ==
::
++  pass-timeout  ~s30
::
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
++  agent
  |=  $:  init=config
          grab=(map mark $-(* vase))
      ==
  ^-  $-(agent:gall agent:gall)
  |^  agent
  ::
  +$  state-1
    $:  %1
        manner=config                  ::  latest config
        memory=(set hash)              ::  datums seen (by inner agent)
        shared=(set hash)              ::  datums shared (as fact)
        passed=(map hash [rumor @da])  ::  pending relays & timeouts
        future=(list rumor)            ::  rumors of unknown kinds
    ==
  ::
  +$  card  card:agent:gall
  ::
  ++  helper
    |_  [=bowl:gall state-1]
    +*  state  +<+
        pals   ~(. lp bowl)
    ++  en-cage
      |=  =(cask *)
      ^-  cage
      ?^  to=(~(get by grab) p.cask)
        ::TODO  +soft or otherwise virtualize? don't want to risk crashes, right?
        [p.cask (u.to q.cask)]
      ~&  [gossip+dap.bowl %no-mark p.cask]
      [%gossip-unknown !>(cask)]
    ::
    ++  de-cage
      |=(cage `(cask *)`[p q.q])
    ::
    ++  en-rumor  ::NOTE  assumes !=(0 hops.manner)
      |=  =cage
      ^-  rumor
      :_  (de-cage cage)
      ~|  [%en-rumor initial-hops=hops.manner]
      [%0 `meta-0`(dec hops.manner)]
    ::
    ++  en-hash
      |=  rumor
      (sham data)
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
        ~&  [gossip+dap.bowl %too-many-internal-targets int]
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
      =/  =rumor  (en-rumor cage.p.card)
      =.  memory  (~(put in memory) (en-hash rumor))
      ?:  =(0 hops.manner)
        [caz state]
      =^  cas  state  (emit-rumor rumor)
      [(weld cas caz) state]
    ::
    ++  emit-rumor  ::  gossip a rumor as-is
      |=  =rumor
      ^-  (quip card _state)
      =/  =hash  (en-hash rumor)
      =*  fact
        :-  [%give %fact [/~/gossip/gossip]~ %gossip-rumor !>(rumor)]~
        %_  state
          passed  (~(del by passed) hash)
          shared  (~(put in shared) hash)
        ==
      ::  if we don't want to proxy, always send as fact
      ::
      ?.  pass.manner
        fact
      ::  if we want to proxy, do so 50% of the time
      ::
      ?.  =(0 (~(rad og eny.bowl) 2))
        fact
      ::  if we're proxying, but there's no reasonable targets, send as fact
      ::
      =/  aides=(set ship)
        ::  reasonable targets do not include ourselves, or whoever
        ::  caused us to want to (re)send this rumor
        ::
        =-  (~(del in (~(del in -) our.bowl)) src.bowl)
        ?-  tell.manner
          %anybody  (~(uni in (targets:pals ~.)) leeches:pals)
          %targets  (targets:pals ~.)
          %mutuals  (mutuals:pals ~.)
        ==
      =/  count=@ud  ~(wyt in aides)
      ?:  =(0 count)
        fact
      ::  poke a randomly chosen proxy with the rumor
      ::
      =/  proxy=ship  (snag (~(rad og +(eny.bowl)) count) ~(tap in aides))
      =/  =time       (add now.bowl pass-timeout)
      =.  passed      (~(put by passed) hash [rumor time])
      :_  state
      =/  =wire  /~/gossip/passed/(scot %uv hash)
      =/  =cage  gossip-rumor+!>(rumor)
      :~  [%pass wire %agent [proxy dap.bowl] %poke cage]
          [%pass wire %arvo %b %wait time]
      ==
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
      ::  if hops is set to 0, we block even the initial response
      ::
      ?:  =(0 hops.manner)  $(cards t.cards)
      =.  cage.p.i.cards
        [%gossip-rumor !>((en-rumor cage.p.i.cards))]
      $(out (snoc out i.cards), cards t.cards)
    ::
    ++  jump-rumor  ::  relay a rumor if we haven't yet
      |=  =rumor
      ^-  (quip card _state)
      =/  =hash  (en-hash rumor)
      ?:  (~(has in shared) hash)  [~ state]
      ?>  =(%0 kind.rumor)  ::NOTE  should have been checked for already
      ?~  meta=((soft ,hops=@ud) meta.rumor)  [~ state]
      =*  hops  hops.u.meta
      ?:  =(0 hops)  [~ state]
      =.  meta.rumor  (dec hops)
      :-  [%give %fact [/~/gossip/gossip]~ %gossip-rumor !>(rumor)]~
      state(shared (~(put in shared) (en-hash rumor)))
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
      :+  %pass  [%~.~ %gossip %retry p]
      [%arvo %b %wait (add now.bowl t)]
    ::
    ++  watch-target
      |=  s=ship
      ^-  (list card)
      ?:  (watching-target s)  ~
      :_  ~
      :+  %pass  /~/gossip/gossip/(scot %p s)
      [%agent [s dap.bowl] %watch /~/gossip/gossip]
    ::
    ++  leave-target
      |=  s=ship
      ^-  card
      :+  %pass  /~/gossip/gossip/(scot %p s)
      [%agent [s dap.bowl] %leave ~]
    ::
    ++  kick-target
      |=  s=ship
      ^-  card
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
      ^-  (list card)
      (zing (turn ~(tap in (~(dif in listen) hearing)) watch-target))
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
    =|  state-1
    =*  state  -
    %+  verb  |
    %-  agent:dbug
    ^-  agent:gall
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
    ++  on-save  !>([[%gossip state] on-save:og])
    ++  on-load
      |=  ole=vase
      ^-  (quip card _this)
      ?.  ?=([[%gossip *] *] q.ole)
        =.  manner  init
        =^  cards   inner  (on-load:og ole)
        =^  cards   state  (play-cards:up cards)
        [(weld watch-pals:up cards) this]
      ::
      |^  =+  !<([[%gossip old=state-any] ile=vase] ole)
          =?  old  ?=(%0 -.old)  (state-0-to-1 old)
          ?>  ?=(%1 -.old)
          =.  state  old
          =^  cards  inner  (on-load:og ile)
          =^  cards  state  (play-cards:up cards)
          ::TODO  for later versions, add :future retry logic as needed
          [cards this]
      ::
      +$  state-any  $%(state-0 state-1)
      ::
      +$  state-0    [%0 manner=config-0 memory=(set hash) future=(list rumor)]
      +$  config-0   [hops=_1 hear=whos tell=whos]
      ++  state-0-to-1
        |=  state-0
        ^-  state-1
        [%1 (config-0-to-1 manner) memory memory ~ future]
      ++  config-0-to-1
        |=  config-0
        ^-  config
        [hops hear tell pass.init]
      --
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
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ::TODO  gossip config pokes
      ?.  =(%gossip-rumor mark)
        =^  cards  inner  (on-poke:og +<)
        =^  cards  state  (play-cards:up cards)
        [cards this]
      ?.  (want-target:up src.bowl)
        ~|(%gossip-rejected !!)
      =+  !<(=rumor vase)
      ::TODO  dedupe with +on-agent %fact
      =/  =hash  (en-hash:up rumor)
      ?:  (~(has in memory) hash)
        [~ this]
      ?.  =(%0 kind.rumor)
        ~&  [gossip+dap.bowl %delaying-unknown-rumor-kind kind.rumor]
        [~ this(future [rumor future])]
      =.  memory        (~(put in memory) hash)
      =/  mage=cage     (en-cage:up data.rumor)
      =^  cards  inner  (on-agent:og /~/gossip/gossip %fact mage)
      =^  caz1   state  (play-cards:up cards)
      =^  caz2   state  (emit-rumor:up rumor)
      [(weld caz1 caz2) this]
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?.  ?=([%~.~ %gossip *] wire)
        =^  cards  inner  (on-agent:og wire sign)
        =^  cards  state  (play-cards:up cards)
        [cards this]
      ::
      ?+  t.t.wire  ~|([%gossip %unexpected-wire wire] !!)
          [%gossip @ ~]
        ~|  t.t.wire
        ?>  =(src.bowl (slav %p i.t.t.t.wire))
        ?-  -.sign
            %fact
          =*  mark  p.cage.sign
          =*  vase  q.cage.sign
          ?.  =(%gossip-rumor mark)
            ~&  [gossip+dap.bowl %ignoring-unexpected-fact mark=mark]
            [~ this]
          ::TODO  de-dupe with +on-poke
          =+  !<(=rumor vase)
          =/  =hash  (en-hash:up rumor)
          ?:  (~(has in memory) hash)
            =^  cards  state  (jump-rumor:up rumor)
            [cards this]
          ?.  =(%0 kind.rumor)
            ~&  [gossip+dap.bowl %delaying-unknown-rumor-kind kind.rumor]
            [~ this(future [rumor future])]
          =.  memory        (~(put in memory) hash)
          =/  mage=cage     (en-cage:up data.rumor)
          =^  cards  inner  (on-agent:og /~/gossip/gossip sign(cage mage))
          =^  caz1   state  (play-cards:up cards)
          =^  caz2   state  (jump-rumor:up rumor)
          [(weld caz1 caz2) this]
        ::
            %watch-ack
          :_  this
          ?~  p.sign  ~
          ::  30 minutes might cost us some responsiveness when the other
          ::  party changes their local config, but in return we save both
          ::  ourselves and others from a lot of needless retries.
          ::  (notably, "do we still care" check also lives in %wake logic.)
          ::
          [(retry-timer:up ~m30 /watch/(scot %p src.bowl))]~
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
          [(retry-timer:up ~s15 /watch/(scot %p src.bowl))]~
        ::
            %poke-ack
          ~&  [gossip+dap.bowl %unexpected-poke-ack wire]
          [~ this]
        ==
      ::
          [%passed @ ~]
        ?.  ?=(%poke-ack -.sign)
          ~&  [gossip+dap.bowl %unexpected-sign wire -.sign]
          [~ this]
        ~|  t.t.wire
        =/  =hash  (slav %uv i.t.t.t.wire)
        ?~  rum=(~(get by passed) hash)
          [~ this]
        ::NOTE  emitting rest is cute, but doesn't actually work reliably,
        ::      due to userspace duct shenanigans. %wake logic will have to
        ::      be defensive...
        =/  rest=card   [%pass wire %arvo %b %rest +.u.rum]
        ?~  p.sign      [[rest]~ this(passed (~(del by passed) hash))]
        =^  caz  state  (emit-rumor:up -.u.rum)
        [[rest caz] this]
      ::
          [%pals @ ~]
        ?-  -.sign
          %poke-ack  ~&([gossip+dap.bowl %unexpected-poke-ack wire] [~ this])
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
            ~&  [gossip+dap.bowl %unexpected-fact-mark mark wire]
            [~ this]
          =+  !<(=effect:^pals vase)
          :_  this
          =*  ship  ship.effect
          =*  kick  [(kick-target:up ship)]~
          =*  view   (watch-target:up ship)
          =*  flee  [(leave-target:up ship)]~
          ?-  -.effect
              %meet
            ?-  hear.manner
              %anybody  view
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
              %anybody  view
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
      ?:  =(/x/whey path)
        :+  ~  ~
        :-  %mass
        !>  ^-  (list mass)
        :-  %gossip^&+state
        =/  dat  (on-peek:og path)
        ?:  ?=(?(~ [~ ~]) dat)  ~
        (fall ((soft (list mass)) q.q.u.u.dat) ~)
      ?:  =(/x/dbug/state path)
        ``noun+(slop on-save:og !>(gossip=state))
      ?.  ?=([@ %~.~ %gossip *] path)
        (on-peek:og path)
      ?.  ?=(%x i.path)  [~ ~]
      ?+  t.t.t.path  [~ ~]
        [%config ~]  ``noun+!>(manner)
      ==
    ::
    ++  on-leave
      |=  =path
      ^-  (quip card _this)
      ?:  ?=([%~.~ %gossip *] path)
        [~ this]
      =^  cards  inner  (on-leave:og path)
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
      ?+  t.t.wire  ~|(wire !!)
          [%passed @ ~]
        =/  =hash  (slav %uv i.t.t.t.wire)
        ?~  rum=(~(get by passed) hash)  [~ this]
        ?:  (gth +.u.rum now.bowl)       [~ this]
        =^  cards  state  (emit-rumor:up -.u.rum)
        [cards this]
      ::
          [%retry *]
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
          ?.  (want-target:up target)  ~
          (watch-target:up target)
        ==
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
