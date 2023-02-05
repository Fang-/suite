::  then: when trigger, then action
::
::    "ifttt but for urbit" is, of course, a more interesting pitch than
::    ifttt themselves could ever provide.
::
::    architecturally, we provide system-level primitives: usercode within
::    flows can only operate in terms of these primitives. most userspace
::    tasks and some kernel tasks can be specified this way.
::
::TODO  2023-01-07
::    1) import prefab files from installed desks
::       - prefabs should be able to take user arguments to adjust their behavior
::       - super dumb minimal prefabs for all default behaviors in this desk?
::    2) present those and their arg fields in the ui
::    3) ???
::    4) profit
::
::TODO  so what's the angle here? do we want to actively prevent footguns,
::      or just go for max freedom for powerusers?
::
::TODO  in order:
::  - minimally viable triggers & actions
::  - minimally viable templates
::    - take a (list [=aura name=@t desc=@t]), to get a list of @ values,
::      which we then inject into the subject under the given names
::    - cache compilation, stub out in +on-save
::    - "the four steps are ream, mint, .*, and slam, and most of the helper functions do more than one, but you should think of them individually"
::      - "you can cache the first three, then slam as necessary"
::      - ream                @t -> hoon
::      - mint:ut    [type hoon] -> [type nock]
::      - .*         [subj nock] -> *
::      - slam       [gatv samv] -> vase
::
::NOTE  examples:
::  - when msg in channel, if contains word, create notification
::  - when timer, if hoon code, post msg
::  - when pal, if name is x, add pal
::  - when msg in channel, then timer, then xx
::  - when clay file changes
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
::NOTE  approach:
::  after talking to wicdev, probably amazing to let other apps/desks bring their own prefabs.
::  then distinguish between internal built-ins (for system (kernel) and system (then) level actions and prefabs.
::  only thing that goes over the network are examples?
::
::TODO  would be cool to implement parts of this in itself,
::      for example "when prefab file changes, load in new prefab"
::
/-  sur=then
/+  rudder, dbug, verb, default-agent
:: /~  pages  (page:rudder xxxx.sur task.sur)  /app/then/webui
::
=,  sur
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
++  gild  ::  resolve to gill
  |=  [our=ship =gent]
  ^-  gill:gall
  ?^(gent gent [our gent])
::
++  whin  ::  resolve to inner thing
  |*  x=$^((made *) [@ *])
  ?@  -.x  x
  ~|  %uninflated-prefab
  (need made.x)
::
++  will  ::  bill from when
  |=  =when
  ^-  bill
  ?+  -.when  [-.when]~
    %peer  ~[%peer %quit]
    %fold  $(when when.when)
  ==
::
++  till  ::  bill for then
  |=  =then
  ^-  bill
  ?+  -.then  ~
    %take  bill.then
  ==
::
++  pays  ::  fact fits bill?
  |=  [=fact =bill]
  ^-  ?
  ?:  =(~ bill)  &
  =-  (fits - bill)
  ?.  ?=(%cash -.fact)  [-.fact]~
  [%cash (turn +.fact head)]~
::
++  fits  ::  chainable bills?
  |=  [give=bill take=bill]
  ^-  ?
  ?:  =(~ take)  &
  %+  lien  give
  |=  give=debt
  %+  lien  take
  |=  take=debt
  ?@  take  =(give take)
  ?>  =(-.take %cash)
  ?.  =(-.give %cash)  |
  ?~  what.take  &
  =(give take)
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
  |=  =card:agent:gall
  this(caz [card caz])
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
  =-  state(flows -)
  %-  ~(run by flows)
  |=  f=flow
  f  ::TODO  deflate gates out of made components?
  ::TODO  deflate usercode
::
++  load
  ^+  this
  ::TODO  inflate gates in made components?
  this
  :: =/  foz  ~(tap by flows)
  :: |-
  :: ?~  foz  this
  :: =*  f  q.i.foz
  :: =^  w  when.f  (inflate-when:mk when.f)
  :: =^  t  then.f  (inflate-then:mk then.f)
  :: ?:  &(w t)
  ::   =.  flows  (~(put by flows) p.i.foz f)
  ::   $(foz t.foz)
  :: =.  this  fo-abet:~(fo-halt fo i.foz)
  :: $(foz t.foz)
::
++  surf
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
++  wree
  |=  [=desk =riot:clay]
  ^+  this
  ::  if we get any result, always request the next result
  ::
  =/  =case:clay  ?~(riot da+now.bowl q.p.u.riot)
  =/  =rave:clay  [%next %a case /app/then/yard/hoon]
  =/  =wire       /clay/yard/[desk]
  =.  emit        (emit %pass wire %arvo %c %warp our.bowl desk `rave)
  ::
  ?~  riot
    ::TODO  disable flows that depended on this
    this(yards (~(del by yards) desk))
  ?>  ?=(%vase p.r.u.riot)
  =+  !<(=vase q.r.u.riot)
  ?.  (~(nest ut -:!>(*yard)) | p.vase)
    ~&  'that aint no yard my man'
    this
  =+  !<(=yard vase)
  ~&  %got-yard-yess
  ::TODO  try updating flows that depended on this
  this(yards (~(put by yards) desk yard))
::
++  call
  |=  =task
  ^+  this
  ?-  -.task
      %start
    =,  task
    =?  this  (~(has by flows) nom)
      (call %erase nom)
    fo-abet:fo-boot:(fo-apex:fo nom `flow`[nam %stop ~ rop])
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
    ::TODO  =.  live.flow  %fail, probably also fo-shut if running
    fo-shut:(fo-note 'failed to (re)compile' tang)
  ::
  ++  fo-boot  ::  set up
    ^+  fo
    =.  live.flow  %live
    =/  =when  (whin when.flow)
    |-
    ?-  -.when
      %kick  fo
      %peer  (fo-peer +.when)
      %time  (fo-wait from.when)
      %fold  $(when when.when)
    ==
  ::
  ++  fo-shut  ::  tear down
    ^+  fo
    =.  live.flow  %stop
    =/  =when  (whin when.flow)
    |-
    ?-  -.when
      %kick  fo
      %peer  (fo-pass /when/peer %agent (gild our.bowl gent.when) %leave ~)
      %time  (fo-pass /when/wait %arvo %b %rest from.when)
      %fold  $(when when.when)
    ==
  ::
  ++  fo-heal  ::  set up for new cycle
    ^+  fo
    =/  =when  (whin when.flow)
    ::TODO  if prefab, do we want to re-compute the trigger?
    ::      a little bit weird wrt recurring timers, but not that bad?
    |-
    ?+  -.when  fo
      %fold  $(when when.when)
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
        (sub inc (mod (sub now.bowl from.when) inc))
      ::  re-set the flow & its recurring timer
      ::
      =.  from.when  nex
      =.  when.flow
        ?@  -.when.flow  when
        ?>  ?=(^ made.when.flow)
        when.flow(u.made when)
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
      ?.  (pays fact give.fold)
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
      %talk  fo:(fo-talk tank.then)
      %none  fo
      %kill  fo-shut:(fo-note 'disabled by self' ~)
    ::
        %take
      ::  should have been checked by caller
      ?>  (pays fact bill.then)
      =/  that=(unit ^then)  (gait.then fo-self fact)
      ?~  that  fo
      $(then u.that)
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
    |=  =tank
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
    ~&  %lo
    =;  out=(quip card:agent:gall xxxx)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder xxxx task)
    :^    ~ ::pages
        (point:rudder /[dap.bowl] & ~(key by ~)) ::pages))
      (fours:rudder +.state)
    |=  =task
    ^-  $@(brief:rudder [brief:rudder (list card:agent:gall) xxxx])
    'not implemented lol'  ::TODO
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
  ?:  ?=([%clay %tire ~] wire)
    ?>  ?=([%clay %tire *] sign-arvo)
    =/  waz=(list wave:tire:clay)
      ?-  -.p.sign-arvo
        %&  (walk:tire:clay tires p.p.sign-arvo)
        %|  [p.p.sign-arvo]~
      ==
    =^  caz  state  abet:(surf:main waz)
    [caz this]
  ?:  ?=([%clay %yard @ ~] wire)
    =*  desk  i.t.t.wire
    ?>  ?=([%clay %writ *] sign-arvo)
    ~&  >  [%got-yard-res ?=(^ p.sign-arvo)]
    =^  caz  state  abet:(wree:main desk p.sign-arvo)
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
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
