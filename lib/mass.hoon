::  mass: utilities for handling |mass output
::
|%
+$  mass  [nom=@t $@(siz=@ud nest)]
+$  nest  [sub=(list mass) sum=@ud]
::
++  sort
  |=  [mas=mass cmp=$-([@ud @ud] ?)]
  ^+  mas
  ?@  +.mas  mas
  =-  mas(sub -)
  %+  ^sort
    (turn sub.mas (curr sort cmp))
  |=  [a=mass b=mass]
  (cmp ?@(+.a siz.a sum.a) ?@(+.b siz.b sum.b))
::
++  mas  (knee *mass |.(~+(;~(plug ;~(sfix nom col) ;~(pose one net)))))
++  one  ;~(pfix ace siz)
++  net  ;~(plug (ifix [gap gap] (more gap mas)) ;~(pfix hep hep siz))
++  nom  ;~(pose ;~(pfix cen sym) qut (boss 256 (star ;~(less col prn))))
++  siz  ;~(pfix (punt (mask "KMGT")) (just 'B') fas dem:ag)
::
++  enjs  ::  for use with evmar/webtreemap
  |=  mas=mass
  ^-  json
  =,  enjs:format
  %-  pairs
  :-  id+s+nom.mas
  ?@  +.mas
    [size+(numb siz.mas)]~
  :~  size+(numb sum.mas)
      children+a+(turn sub.mas jsonify)
  ==
--
