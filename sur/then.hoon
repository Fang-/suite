::  then: structures
::
^?
|%
+$  xxxx
  [flows=(map @ta flow) parts=(map [desk @ta] part)]
::  +|  %outsides
::
+$  task
  $%  [%start nom=@ta nam=@t wen=when den=then]
      [%pause nom=@ta]
      [%erase nom=@ta]
      [%crank nom=@ta dat=vase]
  ==
::
+$  beep
  $%  [%status nom=@ta wat=?(%live %stop %fail)]
      [%change nom=@ta nam=@t wen=when den=then]
      [%notify nom=@ta wat=tang]
  ==
::
::  +|  %whenthen
::
+$  flow                                                ::  local script:
  $:  name=@t                                           ::  descriptor
      live=$@(?(%stop %fail) then)                      ::  next logic
      logs=(list [when=@da what=tang])                  ::  run outputs
      [=when =then]                                     ::  trigger & script
  ==                                                    ::
::
::TODO  store setup state (timer, sub state) inside this?
+$  when                                                ::  triggers:
  $~  [%kick ~]                                         ::
  $%  [%kick ~]                                         ::  manual %crank
      [%time from=@da reap=(unit @dr)]                  ::  at time, repeat
      [%peer =gent =path]                               ::  gall subscription
      [%test =when =make]                               ::  conditional
      [%make =make have=(unit when)]                    ::  dynamic
  ==                                                    ::
::
+$  fact                                                ::  trigger output:
  $%  [%kick =vase]                                     ::  %crank
      [%time ~]                                         ::  timer fired
      [%peer =cage]                                     ::  subscription fact
    ::                                                  ::
      [%reap ~]                                         ::  subscription kick
      [%quit =tang]                                     ::  subscription nack
  ==                                                    ::
::
+$  then                                                ::  actions:
  $~  [%none ~]                                         ::
  $%  [%poke =gent =cage]  ::TODO await ack y/n?        ::  send poke
      [%talk what=tank]                                 ::  dill output
      [%none ~]                                         ::  no-op
      [%kill ~]                                         ::  disable self
    ::
      [%make =make ~]                                   ::  dynamic
      [%both this=then that=then]                       ::  multiple
  ==                                                    ::
::
+$  gent  $@(dude:gall gill:gall)
::
::  +|  %drop-ins
::
+$  part  ::  prefab components
  $:  name=@t
      desc=@t
  $=  what
  $%  [%when =when]
      [%then =then]
  ==  ==
::
::  +|  %usercode
::
+$  hole  [=aura face=term desc=@t]
::
+$  make  ::TODO  $soup?
  $:  vars=(list hole)
      args=(list @)
      code=@t
      nock=(each nock tang)
      ::NOTE  nock is a gate, depending:
      ::  $when %test: $-(fact ?)
      ::  $when %make: $-(~ when)
      ::  $then %make: $-(fact then)
  ==
::
+$  self
  $:  our=@p
      now=@da
      eny=@uvJ
      why=flow
  ==
--
