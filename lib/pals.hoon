::  pals: manual peer discovery
::
|_  bowl:gall
++  leeches                        (s (set ship) /leeches)
++  targets  |=  list=@ta          (s (set ship) %targets ?~(list / /[list]))
++  mutuals  |=  list=@ta          (s (set ship) %mutuals ?~(list / /[list]))
++  leeche   |=  =ship             (s _| /leeches/(scot %p ship))
++  target   |=  [list=@ta =ship]  (s _| /mutuals/[list]/(scot %p ship))
++  mutual   |=  [list=@ta =ship]  (s _| /mutuals/[list]/(scot %p ship))
::
++  base     ~+  /(scot %p our)/pals/(scot %da now)
++  running  ~+  .^(? %gu base)
::
++  s
  |*  [=mold =path]  ~+
  ?.  running  *mold
  .^(mold %gx (weld base (snoc `^path`path %noun)))
--