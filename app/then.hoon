::  then: when trigger, then action
::
::    "ifttt but for urbit" is, of course, a more interesting pitch than
::    ifttt themselves could ever provide.
::
::    architecturally, we provide system-level primitives: usercode within
::    flows can only operate in terms of these primitives. most userspace
::    tasks and some kernel tasks can be specified this way.
::
::TODO  prefabs:
::  - listen to chat channel
::  - send chat message
::    - send dm?
::  - send notification
::  - write to clay
::
::TODO  once permissions are in, make everything we could use optional,
::      but pause/block flows if they are missing any possibly-needed perms.
::
::TODO  would be cool to implement parts of this in itself,
::      for example "when prefab file changes, load in new prefab"
::      that's quite complicated maybe, but we could certainly ship with some
::      components & flows out of the box that say "send a notification when a
::      flow gets halted, or its build status changes"
::
/+  lib=then
/+  rudder, dbug, verb, default-agent
/~  pages  (page:rudder xxxx.lib task.lib)  /app/then/webui
::
=,  lib
::
|%
+$  state-0  [%0 xxxx]
+$  card     $+(card card:agent:gall)
--
::
::  +|  %helpfuls
::
|%
++  pluk
  |=  =wire
  ^-  [@ta ^wire]
  ?>(?=([@ *] wire) wire)
::
:: ::  +mk: usercode building
:: ::
  :: ++  mk
  ::   |%
  ::   ++  context
  ::     |=  [=make =self]
  ::     ^-  vase
  ::     %-  slop
  ::     :_  !>([self=self sur ..zuse])
  ::     =/  v=vase  !>(~)
  ::     |-
  ::     ?~  vars.make  v
  ::     ::TODO  bunting args somewhat questionable, probably prevent reaching this
  ::     =?  args.make  ?=(~ args.make)
  ::       ~&  [%then %oops-arg-bunt [face desc]:i.vars.make]
  ::       ?:  =(%da aura.i.vars.make)  [*@da ~]
  ::       [0 ~]
  ::     ?>  ?=(^ args.make)
  ::     (slop [[%atom aura.i.vars.make ~] i.args.make] v)
  ::   ::
  ::   ++  build  ::  and validate
  ::     |=  =make
  ::     ^-  (each nock tang)
  ::     ::  parse & mint the hoon
  ::     ::
  ::     =/  tonk=(each (pair type nock) hair)
  ::       =/  vex=(like hoon)
  ::         ?^  code.make  [*hair `[code.make *nail]]
  ::         ((full vest) [0 0] (trip code.make))
  ::       ?~  q.vex  |+p.vex
  ::       &+(~(mint ut -:(context make *self)) %noun p.u.q.vex)
  ::     ?:  ?=(%| -.tonk)
  ::       |+~[leaf+"\{{<p.p.tonk>} {<q.p.tonk>}}" 'syntax error']
  ::     ::  type-check the result
  ::     ::TODO  can we type-check to make sure it accepts a fact?
  ::     ::
  ::     =/  tout=type  (slit p.p.tonk -:!>(*fact))
  ::     ?:  (~(nest ut -:!>(*then)) | tout)
  ::       &+q.p.tonk
  ::     |+~['nest-fail']  ::TODO  we can't get the need & have out, can we?
  ::   ::
  ::   ++  execute
  ::     |*  prod=mold
  ::     |=  [=make =self simp=*]
  ::     ^-  (unit prod)
  ::     ::TODO  will this +soft be dangerously slow?
  ::     ::TODO  what if this produces a %make? (forbidden rn, but what if...)
  ::     %-  (soft prod)
  ::     =-  (slum - simp)
  ::     .*(+:(context make self) ?>(?=(%& -.nock.make) p.nock.make))
  ::   ::
  ::   ++  inflate-when
  ::     |=  =when
  ::     ^-  [? _when]
  ::     ?+  -.when  &^when
  ::       %test  ?:  ?=(%& -.nock.make.when)  &^when  ::NOTE  trusts the plan
  ::              =/  nok  (build make.when)
  ::              [-.nok when(nock.make nok)]
  ::       %make  ?:  ?=(%& -.nock.make.when)  &^when  ::NOTE  trusts the plan
  ::              =/  nok  (build make.when)
  ::              [-.nok when(nock.make nok)]
  ::     ==
  ::   ::
  ::   ++  inflate-then
  ::     |=  =then
  ::     ^-  [? _then]
  ::     ?+  -.then  &^then
  ::       %make  ?:  ?=(%& -.nock.make.then)  &^then  ::NOTE  trusts the plan
  ::              =/  nok  (build make.then)
  ::              [-.nok then(nock.make nok)]
  ::       :: %wait  then(then $(then then.then))
  ::       %both  =/  l  $(then this.then)
  ::              =/  r  $(then that.then)
  ::              [&(-.l -.r) then(this +.l, that +.r)]
  ::     ==
  ::   ::
  ::   ++  deflate-when
  ::     |=  =when
  ::     ^+  when
  ::     ?+  -.when  when
  ::       %test  when(nock.make |+~)
  ::       %make  when(nock.make |+~)
  ::     ==
  ::   ::
  ::   ++  deflate-then
  ::     |=  =then
  ::     ^+  then
  ::     ?+  -.then  then
  ::       %make  then(nock.make |+~)
  ::       :: %wait  then(then $(then then.then))
  ::       %both  then(this $(then this.then), that $(then that.then))
  ::     ==
  ::   --
  :: --
  ::
  ::  +|  %builtins
  ::
  :: |%
  :: ++  if
  ::   ^-  (list [@ta part])
  ::   :~
  ::     :+  'new mutual pal'
  ::       'fires if new mutual pal'
  ::     :-  %when
  ::     :+  %test
  ::       [%peer []]

  ::   ==
  :: --
--
::
::  +|  %business
::
=|  caz=(list card:agent:gall)
|_  [state-0 =bowl:gall]
+*  this   .
    state  +<-
::
::  +|  %aides
::
++  abet
  ^-  (quip card:agent:gall _state)
  [(flop caz) state]
::
++  emit
  |=  =card
  this(caz [card caz])
::
++  emil
  |=  cars=(list card)
  this(caz (weld (flop cars) caz))
::
::  +|  %cycle
::
++  init
  ^+  this
  =~  (emit %pass /clay/tire %arvo %c %tire `~)
      (emit %pass /eyre/bind %arvo %e %connect [~ /[dap.bowl]] dap.bowl)
  ==
::
++  save
  ^+  state
  %_  state
      flows
    %-  ~(run by flows)
    |=  f=flow
    %_  f
      have.when  ~
      fold  (turn fold.f |=(m=(made fold) m(have ~)))
      then  (turn then.f |=(m=(made then) m(have ~)))
    ==
  ::
      yards
    (~(run by yards) |=(* 0+~))
  ==
::
++  load
  ^+  this
  =-  (anew(yards -) ~)
  %-  ~(urn by yards)
  |=  [=desk =yard]
  ?>  =(0+~ yard)
  ::  this should never crash, because if we have a yard entry, and we only
  ::  have that if latest change affecting the yard file resulted in a
  ::  successful build.
  ::  of course, this assumes the yard type didn't change, so we'll have
  ::  to be careful here around type upgrades. we have a version tag at the
  ::  head, that should be sufficient for the foreseeable future.
  ::
  ~&  [dap.bowl %load-yardd desk]
  !<  ^yard
  .^  vase
    %ca
    (scot %p our.bowl)
    desk
    (scot %da now.bowl)
    /app/then/yard/hoon
  ==
::
++  wash
  |=  waz=(list wave:tire:clay)
  ^+  this
  ?~  waz  this
  =.  tires  (wash:tire:clay tires i.waz)
  ?.  ?=(%zest -.i.waz)  $(waz t.waz)
  =.  this
    ::  start yard reads for live apps, stop them for not-running ones
    =*  desk  desk.i.waz
    =/  =rave:clay  [%sing %a da+now.bowl /app/then/yard/hoon]
    =/  =wire       /clay/yard/[desk]
    ?-  zest.i.waz
      %live           (emit %pass wire %arvo %c %warp our.bowl desk `rave)
      ?(%held %dead)  (emit %pass wire %arvo %c %warp our.bowl desk ~)
    ==
  $(waz t.waz)
::
++  writ
  |=  [=desk =riot:clay]
  ^+  this
  ::  if we get any result, always request the next result
  ::
  =/  =case       ?~(riot da+now.bowl q.p.u.riot)
  =/  =rave:clay  [%next %a case /app/then/yard/hoon]
  =/  =wire       /clay/yard/[desk]
  =.  emit        (emit %pass wire %arvo %c %warp our.bowl desk `rave)
  ::
  ?~  riot
    ::TODO  mark flows that depend on this as weak? or disable fully?
    this(yards (~(del by yards) desk))
  ?>  ?=(%vase p.r.u.riot)
  =+  !<(=vase q.r.u.riot)
  ?.  (~(nest ut -:!>(*yard)) | p.vase)
    ~&  >>  ['that aint no yard my man' desk]
    this
  =+  !<(=yard vase)
  ~&  >  [%got-yard-for desk]
  ::TODO  if map is different, rebuild flows that depended on it.
  ::      don't nuke flows with removed components, but do mark them %weak
  this(yards (~(put by yards) desk yard))
::
++  anew
  |=  dif=(set from)
  |^  ^+  this
      this(flows (~(urn by flows) try))
  ::
  ++  new
    |=  =from
    |(=(~ dif) (~(has in dif) from))
  ::
  ++  nab
    |*  [what=?(%when %fold %then) have=(unit [tone=?(%good %weak) form=*])]
    |=  [=from =self =args]
    ^+  have
    ?.  (new from)  have
    =?  have  ?=(^ have)  have(tone.u %weak)
    ?>  ?=(%desk -.from)
    ?~  yard=(~(get by yards) desk.from)   have
    ?~  part=(~(get by +.u.yard) id.from)  have
    ?.  =(what -.make.u.part)              have
    =-  (bind - (lead %good))
    ?:  ?=(%easy +<.make.u.part)
      :-  ~
      ?-  what
        %when  ?>(?=(%when -.make.u.part) easy.make.u.part)
        %fold  ?>(?=(%fold -.make.u.part) easy.make.u.part)
        %then  ?>(?=(%then -.make.u.part) easy.make.u.part)
      ==
    ?-  what
      %when  ?>(?=(%when -.make.u.part) (gait.make.u.part self args))
      %fold  ?>(?=(%fold -.make.u.part) (gait.make.u.part self args))
      %then  ?>(?=(%then -.make.u.part) (gait.make.u.part self args))
    ==
  ::
  ++  try
    |=  [id=@ta =flow]
    =/  =self  ~(fo-self fo id flow)
    =.  have.when.flow
      %+  (nab %when have.when.flow)
        from.when.flow
      [self args.when.flow]
    ::
    =.  fold.flow
      %+  turn  fold.flow
      |=  fold=(made fold)  ::TODO  dedupe with when
      =-  fold(have -)
      ((nab %fold have.fold) from.fold self args.fold)
    ::
    =.  then.flow  ::TODO  dedupe with fold
      %+  turn  then.flow
      |=  then=(made then)
      =-  then(have -)
      ((nab %then have.then) from.then self args.then)
    ::
    flow
    ::TODO  deduce build status summary, give update fact if changed
    :: =;  bad=?
    ::   ::TODO  if bad, and was live, make not live
    ::   ::TODO  but we need to know _what_ was live if we want to clean up??
    ::   flow(make ?:(bad %fail %good))
    :: ?|  ?=(~ have.when.flow)
    ::     (levy fold.flow |=(m=(made fold) ?=(~ have.m)))
    ::     (levy then.flow |=(m=(made then) ?=(~ have.m)))
    :: ==
  --
::
++  call
  |=  =task
  ^+  this
  ?-  -.task
      %build
    =,  task
    =?  this  (~(has by flows) nom)
      (call %erase nom)
    fo-abet:fo-boot:(fo-apex:fo nom `flow`[nam %stop ~ rop])
  ::
      %start
    fo-abet:fo-boot:(fo-apex:fo nom.task (~(got by flows) nom.task))
  ::
      ?(%pause %erase)
    =/  f  ~(fo-shut fo nom.task (~(got by flows) nom.task))
    ?-  -.task
      %pause  fo-abet:f
      %erase  fo-ares:f
    ==
  ::
      %crank
    (take /[nom.task]/kick %kick dat.task)
  ::
      %draft
    this(draft daf.task)
  ::
      %multi
    |-
    ?~  taz.task  this
    =.  this  (call i.taz.task)
    $(taz.task t.taz.task)
  ==
::
++  reap
  |=  =wire
  =^  nom  wire  (pluk wire)
  ?~  fow=(~(get by flows) nom)
    ~&  [dap.bowl %reap-on-nonexistent-flow nom -.fact]
    this
  fo-abet:(~(fo-reap fo nom u.fow) wire)
::
++  take
  |=  [=wire =fact]
  ^+  this
  =^  nom  wire  (pluk wire)
  ?~  fow=(~(get by flows) nom)
    ~&  [dap.bowl %take-on-nonexistent-flow nom -.fact]
    this
  fo-abet:(~(fo-take fo nom u.fow) wire fact)
::
::  +fo: flow engine
::
++  fo
  |_  [name=@ta =flow]
  +*  fo  .
  ::
  ::  +|  engine lifecycle
  ::
  ++  fo-apex
    |=  [nom=@ta fow=^flow]
    ^+  fo
    fo(name nom, flow fow) :: fow(then (inflate-then:mk then.fow)))
  ::
  ++  fo-abet
    ^+  this
    this(flows (~(put by flows) name flow))
  ::
  ++  fo-ares
    ^+  this
    this(flows (~(del by flows) name))
  ::
  ::  +|  emission & helpers
  ::
  ++  fo-emit
    |=  cad=card:agent:gall
    fo(caz [cad caz])
  ::
  ++  fo-pass  ::TODO  maybe fo-action type to restrict more strongly?
    |=  [=wire =note:agent:gall]
    (fo-emit %pass [%flow name wire] note)
  ::
  ++  fo-note
    |=  =tang
    ::TODO  if now.bowl already an entry, pre/append?
    fo(logs.flow [[now.bowl tang] logs.flow])
  ::
  ++  fo-self
    ^-  self
    [our.bowl now.bowl eny.bowl flow]
  ::
  ::  +|  flow lifecycle
  ::
  ++  fo-fail  ::  cycle ended w/ msg
    |=  msg=@t
    fo-heal:(fo-note msg ~)
  ::
  ++  fo-done  ::  cycle ended silently
    fo-heal:(fo-note ~)
  ::
  ++  fo-halt  ::  failed to inflate
    |=  =tang
    =.  fo  fo-shut:(fo-note 'failed to (re)compile' tang)
    fo(live.flow %fail)
  ::
  ++  fo-boot  ::  set up
    ^+  fo
    ?<  =(%live live.flow)
    =.  live.flow  %live
    =/  =when  (whin when.flow)
    |-
    ?-  -.when
      %kick  fo
      %peer  (fo-peer +.when)
      %time  (fo-wait from.when)
      %fold  $(when whin.when)
    ==
  ::
  ++  fo-shut  ::  tear down
    ^+  fo
    ?.  =(%live live.flow)
      ~&  [dap.bowl %strange-shut name live.flow]
      fo
    =.  live.flow  %stop
    =/  =when  (whin when.flow)
    |-
    ?-  -.when
      %kick  fo
      %peer  (fo-pass /when/peer %agent (gild our.bowl gent.when) %leave ~)
      %time  (fo-pass /when/wait %arvo %b %rest from.when)
      %fold  $(when whin.when)
    ==
  ::
  ++  fo-heal  ::  set up for new cycle
    ^+  fo
    =/  =when  (whin when.flow)  ::TODO  =whin
    ::TODO  if prefab, do we want to re-compute the trigger?
    ::      a little bit weird wrt recurring timers, but not that bad?
    |-
    ?+  -.when  fo
      %fold  $(when whin.when)
    ::
        %time
      ?~  reap.when
        ::  disable one-off timer flows when done
        ::
        fo(live.flow %stop)
      ::  the next timer that's in the future
      ::
      =/  nex=@da
        %+  add  now.bowl
        =*  inc=@dr  u.reap.when
        ~|  [inc=inc from=from.when now=now.bowl]
        (sub inc (mod (sub now.bowl from.when) inc))
      ::  re-set the flow & its recurring timer
      ::
      =.  from.when  nex
      =.  when.flow
        ?>  ?=(^ have.when.flow)
        when.flow(form.u.have when)
      (fo-wait nex)
    ==
  ::
  ++  fo-reap
    |=  =wire
    ?.  =(%live live.flow)  fo
    =/  =when  (whin when.flow)
    ?.  ?=(%peer -.when)  fo
    ::TODO  what if it's for an old subscription?
    (fo-peer +.when)
  ::
  ::TODO  logging and lifecycle management is split apart between +fo-take,
  ::      +fo-wave and +fo-then. lifecycle management is maybe fine, but do
  ::      need to be careful. logging clearly needs reform.
  ++  fo-take
    |=  [=wire =fact]
    ^+  fo
    ~|  [flow=name wire]
    ?.  ?=([%when *] wire)
      ~|  todo+wire
      !!
    ?.  =(%live live.flow)
      ~&  [dap.bowl %dropping-take-on-dead-flow name -.fact]
      fo
    =?  fo  =(%live live.flow)
      (fo-wave fact)
    ::  if subscription got killed, kill the flow
    ::
    ::TODO  %peer check here necessary as guard against mismatching/late nack?
    ::TODO  what if it's for an old subscription?
    ?:  &(?=(%quit -.fact) ?=(%peer -.when))
      fo-shut:(fo-note 'subscription nacked; disabling flow' tang.fact)
    ::
    ?:  =(%live live.flow)
      fo-done
    fo
  ::
  ++  fo-wave
    |=  =fact
    ^+  fo
    ::  ensure the fact lines up with the trigger
    ::
    =/  =when  (whin when.flow)
    ?.  (pays fact (will when))
      ?:  ?=(%quit -.fact)  fo  ::TODO  just a lil sus
      ::TODO  kind want to render took=%cash in full
      ~|  [%strange-fact flow=name xpec=(will when) took=-.fact]
      !!
    ::  apply all the transformations, but stop if the input doesn't match
    ::
    =/  fols  fold.flow
    |-  ^+  fo
    ?^  fols
      =/  =fold  (whin i.fols)
      ?.  (pays fact take.fold)
        fo  ::TODO  may want to store metadata about how far we got
      =/  felt=(unit ^fact)  (gait.fold fo-self fact)
      ?~  felt
        fo  ::TODO  may want to store metadata about how far we got
      ?.  (pays u.felt give.fold)
        (fo-fail 'unexpected output by fold')  ::TODO  more deets
      $(fols t.fols, fact u.felt)
    ::  run all the actions for which the final fact matches
    ::
    =/  thes  then.flow
    |-  ^+  fo
    ?^  thes
      =/  =then  (whin i.thes)
      ?.  (pays fact (till then))
        fo
      =.  fo  (fo-then then fact)
      $(thes t.thes)
    fo
  ::
  ::TODO  would really rather inline this in +fo-take,
  ::      but the type information from the ?- propagates up to the |-
  ::      it would be under, making $ recursion nearly impossible
  ++  fo-then
    |=  [=then =fact]
    ^+  fo
    ?-  -.then
      %poke  fo:(fo-poke [gent cage]:then)
      %talk  fo:(fo-talk talk.then)
      %none  fo
      %kill  fo-shut:(fo-note 'disabled by self' ~)
    ::
        %take
      ::  should have been checked by caller
      ?>  (pays fact bill.then)
      =/  that=(unit ^then)  (gait.then fo-self fact)
      ?~  that  fo
      $(then u.that)
    ::
        %many
      ?~  thes.then  fo
      =.  fo  (fo-then i.thes.then fact)
      $(thes.then t.thes.then)
    ==
  ::
  ::  +|  triggers
  ::
  ++  fo-wait
    |=  when=@da
    (fo-pass /when/wait %arvo %b %wait when)
  ::
  ++  fo-peer
    |=  [=gent =path]
    =/  =gill:gall  (gild our.bowl gent)
    (fo-pass /when/peer %agent gill %watch path)
  ::
  ::  +|  actions
  ::
  ++  fo-poke
    |=  [=gent =cage]
    (fo-pass /then/poke %agent (gild our.bowl gent) %poke cage)
  ::
  ++  fo-talk
    |=  talk=(list tank)
    ^+  fo
    ?~  talk  fo
    =*  tank  i.talk
    =-  $(fo -, talk t.talk)
    ?@  tank
      (fo-pass /then %arvo %d %text (trip tank))
    (fo-pass /then/talk %arvo %d %talk tank ~)
  --
--
::
::  +|  %gallside
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
::
|_  =bowl:gall
+*  this  .
    main  ~(. +>+ state bowl)
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card:agent:gall _this)
  =^  caz  state
    abet:init:main
  [caz this]
::
++  on-save
  ^-  vase
  !>(save:main)
::
++  on-load
  |=  old=vase
  ^-  (quip card:agent:gall _this)
  =.  state  !<(state-0 old)
  =^  caz  state
    abet:load:main
  [caz this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card:agent:gall _this)
  ?>  =(our src):bowl
  ?+  mark  (on-poke:def mark vase)
      %noun
    =^  caz  state  abet:(call:main !<(task vase))
    [caz this]
  ::
      %handle-http-request
    =;  out=(quip card:agent:gall xxxx)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder xxxx task)
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
    |=  =task
    ^-  $@(brief:rudder [brief:rudder (list card:agent:gall) xxxx])
    =^  caz  this  (on-poke %noun !>(task))
    [~ caz +.state]
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card:agent:gall _this)
  ?.  ?=([%flow *] wire)
    ~|  [%unexpected-wire wire]
    !!
  =^  caz  state
    ?-  -.sign
      %poke-ack   [~ state]  :: abet:(take:main t.wire %poke p.sign)
      %fact       abet:(take:main t.wire %peer cage.sign)
      %watch-ack  ?~  p.sign  [~ state]
                  abet:(take:main t.wire %quit u.p.sign)
      %kick       abet:(reap:main t.wire)
    ==
  [caz this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  ~|  on-arvo-wire=wire
  ?:  ?=([%clay %tire ~] wire)
    ?>  ?=([%clay %tire *] sign-arvo)
    =/  waz=(list wave:tire:clay)
      ?-  -.p.sign-arvo
        %&  (walk:tire:clay tires p.p.sign-arvo)
        %|  [p.p.sign-arvo]~
      ==
    =^  caz  state  abet:(wash:main waz)
    [caz this]
  ?:  ?=([%clay %yard @ ~] wire)
    =*  desk  i.t.t.wire
    ?>  ?=([%clay %writ *] sign-arvo)
    =^  caz  state  abet:(writ:main desk p.sign-arvo)
    [caz this]
  ?:  ?=([%eyre %bind ~] wire)
    ?>  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ?.  ?=([%flow *] wire)
    ~|  [%unexpected-wire wire]
    !!
  =^  caz  state
    ?+  +<.sign-arvo  ~|([%unexpected-sign +<.sign-arvo] !!)
      %wake  abet:(take:main t.wire %time ~)
    ==
  [caz this]
::
++  on-watch
  |=  =path
  ^-  (quip card:agent:gall _this)
  ?.  ?=([%http-response *] path)  (on-watch:def path)
  ?>  =(our.bowl src.bowl)
  [~ this]
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  [~ ~]
    [%x %dbug %state ~]  ``noun+!>(save:main)
  ==
::
++  on-fail
  |=  [=term =tang]
  %-  (slog leaf+"{(trip dap.bowl)}: on-fail" term tang)
  [~ this]
::
++  on-leave  on-leave:def
--
