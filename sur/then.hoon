::  then: structures
::
::      general flow
::    scripts are made up of a trigger, transforms, actions. the datum that
::    flows through them is caled a fact.
::    triggers ($when) describe the thing that will cause the script to run.
::    this can be a timer, a subscription, or manual user input.
::    transforms ($fold) take the fact output by a trigger and transform it.
::    any number of transforms may be applied in sequence, and transforms may
::    opt to produce no output in order to act as a filter.
::    actions ($then) take the transformed fact and produce an effect.
::    any number of actions may be performed based on a single trigger/output.
::
::      bills
::    a $bill describes potential shapes of a fact.
::    triggers and transforms may specify the shape(s) of facts they may
::    produce. if they produce facts outside of this specification, the script
::    will be halted.
::    transforms and actions may specify the shape(s) of facts they accept.
::    in combination with the output specifications, this can be used to help
::    the user figure out which components can be chained together.
::
::      components
::    pre-fabricated, user-configurable components ($part) can be supplied by
::    apps the user has installed. they are loaded from /app/then/yard.hoon.
::    evaluating this file should produce a $yard.
::    the $parts therein can be static or user-configurable. a $vars describes
::    the input fields a user will be presented with. the $part provides a
::    function that takes the inputs as an $args (list @), and produces an
::    appropriate result based on that.
::
::      design notes
::    the two most important properties this aims to achieve is that it's easy
::    for developers to create components for their apps, and that it's easy
::    for users to slot these together to create configurable automation flows.
::    poweruser customization takes a back seat, but can still be served well
::    through that first aim.
::    the %fold $when, for example, primarily exists so that developers can
::    provide simple outputs directly from their triggers. (but maybe that's
::    a design smell?)
::
::      todo
::    formalize logging
::    figure out how to handle usercode. probably same as $part, somehow?
::    some way to run the action on every item in the _list_ input
::    mb we want stateful flows at some point?
::
^?
|%
::
::  +|  %stateful
::
+$  xxxx
  $+  xxxx
  $:  flows=(map @ta flow)                              ::  primary product
      draft=draft
      ::TODO  story=(list [from=?(~ @ta) when=@da =tang])  ::  logs
      tires=rock:tire:clay                              ::  watched outsides
      yards=(map desk yard)                             ::  outside suppliers
      ::TODO  codes=(map ship (map @ta code))           ::  usercode
      ::TODO  plans=(map ship (map @ta hint))           ::  flow descriptions
  ==
::
+$  draft
  $:  have=@ta
      step=$~(%when ?(%when %fold %then %last))
      flow  ::TODO  just rope?
  ==
::
::  +|  %outsides
::
+$  task
  $~  [%draft *draft]
  $%  [%build nom=@ta nam=@t rop=rope]
      [%pause nom=@ta]
      [%start nom=@ta]
      [%erase nom=@ta]
      [%crank nom=@ta dat=vase]
      [%draft daf=draft]
      [%multi taz=(list task)]
  ==
::
+$  beep
  $%  [%status nom=@ta wat=?(%live %stop %fail)]
      [%change nom=@ta nam=@t rop=rope]
      [%notify nom=@ta wat=tang]
  ==
::
::  +|  %whenthen
::
+$  flow                                                ::  script:
  $:  name=@t                                           ::  descriptor
      live=?(%live %stop %fail)                         ::  run status
      ::TODO  maybe log as what=?(%ran tang) etc
      logs=(list [when=@da what=tang])                  ::  run outputs
      rope                                              ::  body
      ::TODO  could be made to carry state              ::
  ==                                                    ::
+$  rope                                                ::  script body:
  $:  when=(made when)                                  ::  trigger
      fold=(list (made fold))                           ::  transformations
      then=(list (made then))                           ::  actions
  ==                                                    ::
::
::TODO  need to track trigger state somewhere, like %peer status
::NOTE  output bill deduced from tag, except for %fold
+$  when                                                ::  triggers:
  $~  [%kick ~]
  $%  [%kick ~]                                         ::  on-demand (%crank)
      [%time from=@da reap=(unit @dr)]                  ::  at time, repeat
      [%peer =gent =path]                               ::  gall subscription
      [%fold =whin fold=(gait fact fact) =bill]         ::  transform included
  ==                                                    ::
+$  whin  $~([%kick ~] $<(%fold when))                  ::  static $when
::
::TODO  allow producing (list fact) instead?
+$  fold                                                ::  transformation:
  $:  ~  ::TODO  %fold ?
      take=bill                                         ::  input shape(s)
      gait=(gait fact fact)                             ::  logic
      give=bill                                         ::  output shape(s)
  ==                                                    ::
::
::NOTE  input bill is ~, except for %take
+$  then                                                ::  action:
  $%  [%poke =gent =cage]                               ::  poke agent
      [%none ~]                                         ::  nothing
      ::TODO  [%hush ~]                                 ::  logless no-op ?
      [%talk talk=(list tank)]                          ::  display output
      [%kill =$+(tang tang)]                            ::  disable self
      [%take =bill =(gait fact thin)]                   ::  dynamic $<(%take $)
      [%many thes=(list thin)]                          ::  do many
      ::TODO  %log ?
  ==                                                    ::
+$  thin  $~([%none ~] $<(%take then))                  ::  static $then
::
+$  fact                                                ::  in/output:
  $%  [%kick =vase]                                     ::  user input (%crank)
      [%time ~]                                         ::  timer fired
      [%peer =cage]                                     ::  subscription fact
      [%quit =tang]                                     ::  subscription nack
      [%cash cash]                                      ::  scripted values
      ::TODO  [%many =fact] ?
  ==                                                    ::
::
+$  debt                                                ::  in/output spec:
  $?  %kick  %time  %peer  %quit                        ::  $>(. fact)
      [%cash what=(list aura)]                          ::  ~ for all cash
  ==                                                    ::
+$  bill  (list debt)                                   ::  viable in/output(s)
::NOTE  empty bill means any fact valid
::
::  +|  %variable
::
+$  hole  [=aura face=term desc=@t]                     ::  variable spec
+$  vars  (list hole)                                   ::  full config spec
+$  args  (list @)                                      ::  user values
+$  cent  [aura @]                                      ::  faceless dime
+$  cash  (pole cent)                                   ::  faceless inputs
::
::  +|  %pre-fabs
::
+$  from                                                ::  source:
  $%  [%desk =desk id=@ta]                              ::  installed app yard
      [%ship =ship id=@ta]                              ::  external author
  ==                                                    ::
::
+$  yard  [%0 (map @ta part)]                           ::  scrapyard
::
+$  part                                                ::  building block:
  $:  name=@t                                           ::  descriptor
      desc=@t                                           ::  details
      ::TODO  pers:gall required perms?                 ::
  $=  make                                              ::  part builder
  $%  [%when (make when)]                               ::
      [%fold (make fold)]                               ::
      [%then (make then)]                               ::
  ==  ==                                                ::
::
++  make                                                ::  block builder:
  |$  give                                              ::  result
  $%  [%easy easy=give]                                 ::  static, or
  $:  %vary                                             ::  configurable:
      =bill                                             ::  compatible inputs
      =vars                                             ::  config spec
      =(gait args give)                                 ::  builder
  ==  ==                                                ::
::
++  gait                                                ::  builder gate
  |$  [take give]
  $+  gait
  $-([self take] (unit give))
::
+$  self                                                ::  execution context:
  $:  our=@p                                            ::  home
      now=@da                                           ::  time
      eny=@uvJ                                          ::  rand
      why=flow                                          ::  meta
  ==
::
::  +|  %usercode
::
::TODO  cache original $part in here or elsewhere?
::TODO  "made" is way overloaded, used in three ways. fix!
++  made                                                ::  configured prefab:
  |$  what                                              ::  kind
  $:  from=from                                         ::  source
      ::TODO  hash=@uv  ::  version?
      ::TODO  cache original bill for if we can not auto-upgrade?
      args=args                                         ::  user config
      have=(unit [tone=?(%good %weak) form=what])       ::  build result
  ==                                                    ::
::
::TODO  should this be implemented as $part instead?
+$  code                                                ::  user program:
  $:  vars=vars                                         ::  config spec
      code=@t                                           ::  literal code
      nock=(each nock tang)                             ::  build result
      ::NOTE  nock is a gate, depending:
      ::  $when %code: (gait null when)
      ::  $then %code: (gait fact then)
  ==
::
::  +|  %minimals
::
+$  gent  $@(dude:gall gill:gall)                       ::  easy agent
--
