::  benc: bencoding library
::
^?
|%
+$  value
  $~  [%byt ~]
  $%  [%int @sd]
      [%byt tape]
      [%mor (list value)]
      [%map (map tape value)]
  ==
::
++  render
  |=  =value
  ^-  tape
  ?-  -.value
    %byt  "{((d-co:co 1) (lent +.value))}:{+.value}"
    %int  =-  "i{-}e"
          %+  weld
            ?:((syn:si +.value) "" "-")
          ((d-co:co 1) (abs:si +.value))
    %mor  =-  "l{-}e"
          %+  roll  +.value
          |=  [v=^value t=tape]
          (weld t (render v))
    %map  =-  "d{-}e"
          %+  roll
            %+  sort  ~(tap by +.value)
            |=  [[a=tape *] [b=tape *]]
            (aor a b)
          |=  [[k=tape v=^value] t=tape]
          :(weld t (render [%byt k]) (render v))
  ==
::
++  parse
  |^
  %+  knee  *value  |.  ~+
  ;~  pose
    %+  stag  %int
    %+  ifix  [i e]
    %+  cook  new:si
    %+  pick  dim:ag
    ;~(pfix hep dim:ag)
  ::
    %+  stag  %byt
    bytz
  ::
    %+  stag  %mor
    %+  ifix  [l e]
    (star parse)
  ::
    %+  stag  %map
    %+  ifix  [d e]
    %+  cook  ~(gas by *(map tape value))
    (star ;~(plug bytz parse))
  ==
  ::
  ++  d  (just 'd')
  ++  i  (just 'i')
  ++  l  (just 'l')
  ++  e  (just 'e')
  ::
  ++  bytz
    %^  lean  dim:ag  col
    |=  size=@ud
    (stun [size size] next)
  ::
  ::TODO  stdlib?
  ++  lean
    |*  [measure=rule separate=rule parse=$-(@ud rule)]
    |=  =nail
    =/  edge=(like @)  (;~(sfix measure separate) nail)
    ?~  q.edge  edge
    =*  size  p.u.q.edge
    =*  rest  q.u.q.edge
    ((parse size) rest)
  --
::
++  reparse
  =>  |%  ++  fist  $-(value (unit *))
      --
  |%
  ++  ar                                                ::  list as list
    |*  =fist
    |=  =value
    ?.  ?=(%mor -.value)  ~
    (zl (turn +.value fist))
  ::
  ++  at                                                ::  list as tuple
    |*  in=(list fist)
    |=  =value
    ?.  ?=(%mor -.value)  ~
    ?.  =((lent in) (lent +.value))  ~
    =+  raw=((at-raw in) +.value)
    ?.((za raw) ~ (some (zp raw)))
  ::TODO  broken?
  ++  at-raw
    |*  in=(list fist)
    |=  mor=(list value)
    ?~  in  ~
    ?~  mor  [~ ~]
    :-  (i.in i.mor)
    ((at-raw t.in) t.mor)
    :: $(in t.in, mor t.mor)
  ::
  ++  bi                                                ::  int as bool
    |=  =value
    ?.  ?=(%int -.value)  ~
    ?:  =(--0 +.value)  (some |)
    ?:  =(--1 +.value)  (some &)
    ~
  ::
  ++  cu                                                ::  transform
    |*  [=fist =gate]
    |=  =value
    (bind (fist value) gate)
  ::
  ++  nu                                                ::  default to
    |*  [=fist default=*]
    |=  =value
    (some (fall (fist value) default))
  ::
  :: ++  af
  ::   |*  [either=fist or=fist]
  ::   |=  =value
  ::   ?^  r=(either value)  r
  ::   ?^  r=(or value)      r
  ::   ~
  ::
  ++  mu                                                ::  optional
    |*  =fist
    |=  =value
    (some (fist value))
  ::
  ++  ot                                                ::  map as tuple
    |*  in=(list [key=@t =fist])
    |=  =value
    ?.  ?=(%map -.value)  ~
    =+  raw=((ot-raw in) +.value)
    ?.((za raw) ~ (some (zp raw)))
  ::
  ++  ot-raw
    |*  in=(list [key=@t =fist])
    |=  mep=(map tape value)
    ?~  in  ~
    =+  val=(~(get by mep) (trip key.i.in))
    :-  ?~(val ~ (fist.i.in u.val))
    $(in t.in)
  ::
  ++  sa
    |=  =value
    ?.  ?=(%byt -.value)  ~
    (some +.value)
  ::
  ++  so
    |=  =value
    ?.  ?=(%byt -.value)  ~
    (some (crip +.value))
  ::
  ++  sd                                                ::  signed integer
    |=  =value
    ^-  (unit @sd)
    ?.  ?=(%int -.value)  ~
    (some +.value)
  ::
  ++  ud                                                ::  positive integer
    |=  =value
    ^-  (unit @ud)
    ?.  ?=(%int -.value)  ~
    ?.  (syn:si +.value)  ~
    (some (abs:si +.value))
  ::
  ::NOTE  cargo-culted from dejs-soft
  ::
  ++  za                                              ::  full unit pole
    |*  pod/(pole (unit))
    ?~  pod  &
    ?~  -.pod  |
    (za +.pod)
  ::
  ++  zl                                              ::  collapse unit list
    |*  lut/(list (unit))
    ?.  |-  ^-  ?
        ?~(lut & ?~(i.lut | $(lut t.lut)))
      ~
    %-  some
    |-
    ?~  lut  ~
    [i=u:+.i.lut t=$(lut t.lut)]
  ::
  ++  zp                                              ::  unit tuple
    |*  but/(pole (unit))
    ?~  but  !!
    ?~  +.but
      u:->.but
    [u:->.but (zp +.but)]
  :: ::
  :: ++  zm                                              ::  collapse unit map
  ::   |*  lum/(map term (unit))
  ::   ?:  (~(rep by lum) |=({{@ a/(unit)} b/_|} |(b ?=(~ a))))
  ::     ~
  ::   (some (~(run by lum) need))
  --
--