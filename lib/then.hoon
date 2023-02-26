::  then: wrestling
::
/-  *then
|%
++  gild  ::  resolve to gill
  |=  [our=ship =gent]
  ^-  gill:gall
  ?^(gent gent [our gent])
::
++  whin  ::  resolve to inner thing
  |*  x=$^((made *) [@ *])
  ?@  -.x  x
  ~|  %uninflated-prefab
  form:(need have.x)
::
++  will  ::  bill from when
  |=  =when
  ^-  bill
  ?+  -.when  [-.when]~
    %peer  ~[%peer %quit]
    %fold  $(when whin.when)
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
  ?@  give  |
  ?>  =(-.take %cash)
  ?.  =(-.give %cash)  |
  ?~  what.take  &
  =(give take)
::
::TODO  move all the below into then-webui.hoon probably
::
++  de-from
  |=  =from
  ^-  @t
  ?-  -.from
    %desk  (rap 3 '%' desk.from '/' id.from ~)
    %ship  (rap 3 (scot %p ship.from) '/' id.from ~)
  ==
::
++  en-from
  |=  =cord
  ^-  (unit from)
  ::TODO  support %ship case
  (rush cord (stag %desk ;~(plug ;~(pfix cen sym) ;~(pfix fas urs:ab))))
::
++  grab-vars
  |=  [from=@t =vars args=(map @t @t)]
  =.  from  (cat 3 from '.')
  =|  gud=(list @)
  =|  bad=(list [face=term =aura =cord])
  |-  ^+  [gud=gud bad=bad]
  ?~  vars  [(flop gud) (flop bad)]
  =/  vid  (cat 3 from face.i.vars)
  ?:  =(%f aura.i.vars)
    $(gud [(~(has by args) vid) gud], vars t.vars)
  =/  arg=(unit @t)
    ?:  ?=(?(%t %ta %tas) aura.i.vars)
      `(~(gut by args) vid '')
    (~(get by args) vid)
  ?~  arg
    $(bad [[face.i.vars aura.i.vars ''] bad], vars t.vars)
  =/  art=(unit @)
    ?+  aura.i.vars  (slaw aura.i.vars u.arg)
      ?(%t %ta %tas)  ?:(((sane aura.i.vars) u.arg) `u.arg ~&(%insane ~))
      %da  !!  ::TODO  parse datetime
      %ud  (rush u.arg dum:ag)
    ==
  ?^  art
    $(gud [u.art gud], vars t.vars)
  $(bad [[face.i.vars aura.i.vars u.arg] bad], vars t.vars)
::
++  make-step
  |*  $:  step=?(%when %fold %then)
          args=(map @t @t)
          yars=(map desk yard)
          bowl=bowl:gall
          draf=flow
      ==
  ^-  $@  ?(~ @t)
      [fro=from arg=^args out=,?-(step %when when, %fold fold, %then then)]
  ?~  pid=(~(get by args) step)
    ~
  ?~  fro=(en-from u.pid)
    ~
  ?>  ?=(%desk -.u.fro)  ::TODO
  ?~  par=(~(get by +:(~(gut by yars) desk.u.fro *yard)) id.u.fro)
    ~
  ?.  =(step -.make.u.par)
    ~
  ::  easy ones are easy, take the trigger as-is
  ::
  ?:  ?=(%easy +<.make.u.par)
    :+  u.fro  ~
    ?-  step
      %when  ?>(?=(%when -.make.u.par) easy.make.u.par)
      %fold  ?>(?=(%fold -.make.u.par) easy.make.u.par)
      %then  ?>(?=(%then -.make.u.par) easy.make.u.par)
    ==
  ::  for variable ones, fetch all the args and make sure they fit
  ::
  =*  vas  vars.make.u.par
  =+  (grab-vars u.pid vars.make.u.par args)
  ::
  ?.  =(~ bad)
    %+  roll  bad
    |=  [[face=term =aura =cord] err=@t]
    =?  err  !=('' err)  (cat 3 err ', ')
    %^  cat  3  err
    %-  crip
    "'{(trip cord)}' not a valid @{(trip aura)} for %{(trip face)}"
  ::
  =/  res
    %.  [[our.bowl now.bowl eny.bowl draf] gud]
    ?-  step
      %when  ?>(?=(%when -.make.u.par) gait.make.u.par)
      %fold  ?>(?=(%fold -.make.u.par) gait.make.u.par)
      %then  ?>(?=(%then -.make.u.par) gait.make.u.par)
    ==
  ?~  res
    'Failed to construct. Are your inputs sane?'
  [u.fro gud u.res]
--
