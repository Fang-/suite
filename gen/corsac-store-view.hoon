::  +corsac-store-view: print list of pending cors requests
::
/-  *corsac
:-  %say
|=  [[now=@da eny=@uvJ =beak] ~ ~]
:-  %tang
^-  tang
%-  flop  ::TODO  messed-up print order
=*  our  p.beak
|^  ;:  weld
      requests
      approved
      rejected
    ==
::
++  scry
  |*  [=mold =path]
  .^(mold %gx (scot %p our) %corsac-store (scot %da now) (snoc path %noun))
::
++  requests
  ^-  tang
  =/  pending=(list origin)
    %~  tap  in
    (scry (set origin) /requests)
  =/  count=@ud
    (lent pending)
  ?:  =(0 count)
    [leaf+"no pending cors requests"]~
  :-  leaf+"{(scow %ud count)} pending cors request(s):"
  %+  turn  pending
  |=  =origin
  ^-  tank
  [%leaf ' ' ' ' (trip origin)]
::
++  approved
  ^-  tang
  =/  approved
    %~  tap  by
    (scry (map origin (unit @da)) /approvals)
  =/  count=@ud
    (lent approved)
  ?:  =(0 count)
    [leaf+"no approved cors origins"]~
  :-  leaf+"{(scow %ud count)} approved cors origin(s):"
  (turn approved print-config)
::
++  rejected
  ^-  tang
  =/  rejected
    %~  tap  by
    (scry (map origin (unit @da)) /rejections)
  =/  count=@ud
    (lent rejected)
  ?:  =(0 count)
    [leaf+"no rejected cors origins"]~
  :-  leaf+"{(scow %ud count)} rejected cors origin(s):"
  (turn rejected print-config)
::
++  print-config
  |=  [=origin until=(unit @da)]
  ^-  tank
  :-  %leaf
  %+  weld  [' ' ' ' (trip origin)]
  ?~  until  ~
  =*  t  u.until
  " (expires {(scow %da (sub t (mod t ~s1)))})"
--
