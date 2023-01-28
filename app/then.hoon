::  then: trigger, condition, action, and so on
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
::       a) super dumb minimal prefabs for all default behaviors in this desk
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
/~  pages  (page:rudder xxxx.sur task.sur)  /app/then/webui
::
=,  sur
::
|%
+$  state-0
  $:  %0
      xxxx
  ==
::
--
::
::  +|  %helpfuls
::
|%
++  gild  ::  resolve to gill
  |=  [our=ship =gent]
  ^-  gill:gall
  ?^(gent gent [our gent])
::
++  whin  ::  resolve to inner when
  |=  =when
  ^+  when
  ?+  -.when  when
    %test  $(when when.when)
  ==
::  +mk: usercode building
::
++  mk
  |%
  ++  context
    |=  [=make =self]
    ^-  vase
    %-  slop
    :_  !>([self=self sur ..zuse])
    =/  v=vase  !>(~)
    |-
    ?~  vars.make  v
    ::TODO  bunting args somewhat questionable, probably prevent reaching this
    =?  args.make  ?=(~ args.make)
      ~&  [%then %oops-arg-bunt [face desc]:i.vars.make]
      ?:  =(%da aura.i.vars.make)  [*@da ~]
      [0 ~]
    ?>  ?=(^ args.make)
    (slop [[%atom aura.i.vars.make ~] i.args.make] v)
  ::
  ++  build  ::  and validate
    |=  =make
    ^-  (each nock tang)
    ::  parse & mint the hoon
    ::
    =/  tonk=(each (pair type nock) hair)
      =/  vex
        ((full vest) [0 0] (trip code.make))
      ?~  q.vex  |+p.vex
      &+(~(mint ut -:(context make *self)) %noun p.u.q.vex)
    ?:  ?=(%| -.tonk)
      |+~[leaf+"\{{<p.p.tonk>} {<q.p.tonk>}}" 'syntax error']
    ::  type-check the result
    ::TODO  can we type-check to make sure it accepts a fact?
    ::
    =/  tout=type  (slit p.p.tonk -:!>(*fact))
    ?:  (~(nest ut -:!>(*then)) | tout)
      &+q.p.tonk
    |+~['nest-fail']  ::TODO  we can't get the need & have out, can we?
  ::
  ++  execute
    |*  prod=mold
    |=  [=make =self simp=*]
    ^-  (unit prod)
    ::TODO  will this +soft be dangerously slow?
    ::TODO  what if this produces a %make? (forbidden rn, but what if...)
    %-  (soft prod)
    =-  (slum - simp)
    .*(+:(context make self) ?>(?=(%& -.nock.make) p.nock.make))
  ::
  ++  inflate-when
    |=  =when
    ^-  [? _when]
    ?+  -.when  &^when
      %test  ?:  ?=(%& -.nock.make.when)  &^when  ::NOTE  trusts the plan
             =/  nok  (build make.when)
             [-.nok when(nock.make nok)]
      %make  ?:  ?=(%& -.nock.make.when)  &^when  ::NOTE  trusts the plan
             =/  nok  (build make.when)
             [-.nok when(nock.make nok)]
    ==
  ::
  ++  inflate-then
    |=  =then
    ^-  [? _then]
    ?+  -.then  &^then
      %make  ?:  ?=(%& -.nock.make.then)  &^then  ::NOTE  trusts the plan
             =/  nok  (build make.then)
             [-.nok then(nock.make nok)]
      :: %wait  then(then $(then then.then))
      %both  =/  l  $(then this.then)
             =/  r  $(then that.then)
             [&(-.l -.r) then(this +.l, that +.r)]
    ==
  ::
  ++  deflate-when
    |=  =when
    ^+  when
    ?+  -.when  when
      %test  when(nock.make |+~)
      %make  when(nock.make |+~)
    ==
  ::
  ++  deflate-then
    |=  =then
    ^+  then
    ?+  -.then  then
      %make  then(nock.make |+~)
      :: %wait  then(then $(then then.then))
      %both  then(this $(then this.then), that $(then that.then))
    ==
  --
--
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
::
::  +|  %business
::
=|  caz=(list card:agent:gall)
|_  [state-0 =bowl:gall]
+*  this   .
    state  +<-
::
++  abet
  ^-  (quip card:agent:gall _state)
  [(flop caz) state]
::
++  emit
  |=  =card:agent:gall
  this(caz [card caz])
::
++  pluk
  |=  =wire
  ^-  [@ta ^wire]
  ?>(?=([@ *] wire) [i t]:wire)
::
++  want
  |=  [=when =fact]
  ^-  ?
  ?-  -.when
    %kick  ?=(%kick -.fact)
    %time  ?=(%time -.fact)
    %peer  ?=(?(%peer %reap %quit) -.fact)
    %test  $(when when.when)
    %make  &(?=(^ have.when) $(when u.have.when))
  ==
::
++  init
  ^+  this
  =~  (emit %pass /clay/tire %arvo %c %tire `~)
      (emit %pass /eyre/bind %arvo %e %connect [~ /[dap.bowl]] dap.bowl)
  ==
::
++  load
  ^+  this
  =/  foz  ~(tap by flows)
  |-
  ?~  foz  this
  =*  f  q.i.foz
  =^  w  when.f  (inflate-when:mk when.f)
  =^  t  then.f  (inflate-then:mk then.f)
  ?:  &(w t)
    =.  flows  (~(put by flows) p.i.foz f)
    $(foz t.foz)
  =.  this  fo-abet:~(fo-halt fo i.foz)
  $(foz t.foz)
::
++  call
  |=  =task
  ^+  this
  ?-  -.task
      %start
    =,  task
    =?  this  (~(has by flows) nom)
      (call %erase nom)
    fo-abet:fo-boot:(fo-apex:fo nom `flow`[nam %stop ~ wen den])
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
++  take
  |=  [=wire =fact]
  ^+  this
  =^  nom  wire  (pluk wire)
  ?~  fow=(~(get by flows) nom)  this
  ?.  (want when.u.fow fact)
    ~&  [dap.bowl %dropping-unexpected-take flow=nom when=make take=fact]
    this
  fo-abet:(~(fo-take fo nom u.fow) wire fact)
::
::  +fo: flow engine
::
++  fo
  |_  [name=@ta =flow]
  +*  fo    .
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
    ::TODO  =.  live.flow  %fail
    fo-shut:(fo-note 'failed to (re)compile' tang)
  ::
  ++  fo-boot  ::  set up
    ^+  fo
    =.  live.flow  then.flow
    ?-  -.when.flow
      %kick  fo
      %peer  =/  =gill:gall  (gild our.bowl gent.when.flow)
             (fo-pass /when %agent gill %watch path.when.flow)
      %time  (fo-pass /when %arvo %b %wait from.when.flow)
      %test  =/  orig=when  when.flow
             =.  fo
               =/  fo  fo-boot(when.flow when.when.flow)
               =>(fo(when.flow orig) ?>(?=(%test -.when.flow) .))
             fo(when.flow orig)
      %make  =/  orig=when  when.flow
             =.  fo
               =/  fo  fo-boot(when.flow (need have.when.flow))
               =>(fo(when.flow orig) ?>(?=(%make -.when.flow) .))
             fo(when.flow orig)
    ==
  ::
  ++  fo-shut  ::  tear down
    ^+  fo
    =.  live.flow  %stop
    ?-  -.when.flow
      %kick  fo
      %peer  (fo-pass /when %agent (gild our.bowl gent.when.flow) %leave ~)
      %time  (fo-pass /when %arvo %b %rest from.when.flow)
      %test  =/  orig  when.flow
             =.  fo
               =/  fo  fo-shut(when.flow when.when.flow)
               =>(fo(when.flow orig) ?>(?=(%test -.when.flow) .))
             fo(when.flow orig)
      %make  =/  orig  when.flow
             =.  fo
               =/  fo  fo-shut(when.flow (need have.when.flow))
               =>(fo(when.flow orig) ?>(?=(%make -.when.flow) .))
             fo(when.flow orig(have ~))
    ==
  ::
  ++  fo-heal  ::  set up for new cycle
    ^+  fo
    ?+  -.when.flow
      ::  re-set the flow
      ::
      fo(live.flow then.flow)
    ::
        %time
      ?~  reap.when.flow
        ::  disable one-off timer flows when done
        ::
        fo(live.flow %stop)
      ::  re-set the flow & its recurring timer
      ::
      =;  nex=@da
        =.  flow  flow(from.when nex, live then.flow)
        (fo-pass /when %arvo %b %wait nex)
      ::  the next timer that's in the future
      ::
      %+  add  now.bowl
      =*  inc=@dr  u.reap.when.flow
      (sub inc (mod (sub now.bowl from.when.flow) inc))
    ::
        %make
      =.  live.flow  then.flow
      =/  orig=when  when.flow
      =/  next=(unit when)
        ::  compute the next trigger
        ::
        ::NOTE  we don't inflate, producing a new %make illegal for now
        %-  (execute:mk when)
        [make.when.flow fo-self ~]
      ?~  next
        (fo-fail 'dynamic trigger not valid')
      ::  if the new trigger is different, re-do the setup
      ::
      ?:  =(have.when.flow next)
        fo
      =.  fo
        ::  i hate this compiler-enforced pattern...
        =/  fo  fo-shut(when.flow (need have.when.flow))
        =>(fo(when.flow orig) ?>(?=(%make -.when.flow) .))
      fo-boot(have.when.flow next)
    ==
  ::
  ++  fo-take
    |=  [=wire =fact]
    ^+  fo
    ?@  live.flow  fo
    =/  =when  (whin when.flow)
    ::  if subscription got killed, kill the flow
    ::
    ?:  &(?=(%quit -.fact) ?=(%peer -.when))
      fo-shut:(fo-note 'subscription nacked; disabling flow' tang.fact)
    ::  if subscription got kicked, repair it
    ::
    ?:  &(?=(%reap -.fact) ?=(%peer -.when))
      =/  =gill:gall  (gild our.bowl gent.when)
      (fo-pass /when %agent gill %watch path.when)
    ::  if needed, filter
    ::
    ?:  ?=(%test -.when.flow)
      =/  good=(unit ?)
        ((execute:mk ?) make.when.flow fo-self fact)
      ?~  good
        (fo-fail 'dynamic filter not valid')
      ?.  u.good  fo
      (fo-step live.flow fact)
    ::  otherwise, simply trigger
    ::
    (fo-step live.flow fact)
  ::
  ::TODO  would really rather inline this in +fo-take,
  ::      but the type information from the ?- propagates up to the |-
  ::      it would be under, making $ recursion nearly impossible
  ++  fo-step
    |=  [=then =fact]
    ^+  fo
    ?-  -.then
      %poke  fo-done:(fo-poke [gent cage]:then)
      %talk  fo-done:(fo-talk what.then)
      %none  fo-done
      %kill  fo-shut:(fo-note 'disabled by self' ~)
    ::
      %make  =/  next=(unit ^then)
               ::NOTE  we don't inflate, producing a new %make illegal for now
               %-  (execute:mk ^then)
               [make.then fo-self fact]
             ?~  next
               (fo-fail 'dynamic action not valid')
             $(then u.next)
      %both  =/  next=^then  that.then
             =.  fo  $(then this.then)
             ?:  |(?=(@ live.flow) =(live.flow then.flow))
               $(then next)
             $(then [%both live.flow next])
    ==
  ::
  ::  +|  actions
  ::
  ++  fo-poke
    |=  [=gent =cage]
    (fo-pass /then/poke %agent (gild our.bowl gent) %poke cage)
  ::
  ++  fo-talk
    |=  what=tank
    ?@  what
      (fo-pass /then %arvo %d %text (trip what))
    (fo-pass /then/talk %arvo %d %talk what)
  ::
  ++  fo-wait
    |=  wait=@dr
    (fo-pass /then/wait %arvo %b %wait (add now.bowl wait))
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
  =.  flows
    %-  ~(run by flows)
    |=  f=flow
    %_  f
      when  (deflate-when:mk when.f)
      then  (deflate-then:mk then.f)
    ==
  !>(state)
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
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
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
      %kick       abet:(take:main t.wire %reap ~)
    ==
  [caz this]
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?:  ?=([%clay %tire ~] wire)
    ~&  [%would-clay-tire sign-arvo]
    [~ this]
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
++  on-peek   on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
