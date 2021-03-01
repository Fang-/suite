::  benc: bencoding library
::
/+  pal
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
++  build
  |%
  ++  ar
    |*  b=$-(* value)
    |*  l=(list)
    [%mor (turn l b)]
  ::
  ++  bi
    |=  f=?
    [%int ?:(f --1 --0)]
  ::
  ++  os
    |=  o=(list [tape value])
    [%map (~(gas by *(map tape value)) o)]
  ::
  ++  ud
    |=  a=@ud
    [%int (new:si & a)]
  ::
  ++  so
    |=  t=@t
    [%byt (trip t)]
  --
::
++  brief
  |=  =value
  ?-  -.value
    %byt  [%byt (lent +.value) `@p`(mug +.value)]
    %int  [%int +.value]
    %mor  ?:  (gth (lent +.value) 10)  [%mor `(list @p)`(turn +.value mug)]
          [%mor (turn +.value brief)]
    %map  ?:  (gth ~(wyt by +.value) 10)
            [%map `(map tape @p)`(~(run by +.value) mug)]
          [%map `(map tape _$)`(~(run by +.value) brief)]
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
    %+  ifix  [d e]
    %+  cook  os:build
    (star ;~(plug bytz parse))
  ==
  ::
  ++  d  (just 'd')
  ++  i  (just 'i')
  ++  l  (just 'l')
  ++  e  (just 'e')
  ::
  ++  bytz
    %^  lean:pal  dim:ag  col
    |=  size=@ud
    (stun [size size] next)
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
  ++  ci                                                ::  unit transform
    |*  [=fist =gate]
    |=  =value
    (biff (fist value) gate)
  ::
  ++  cu                                                ::  value transform
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
    (some (rep 3 +.value))
  ::
  ++  sd                                                ::  signed integer
    |=  =value
    ^-  (unit @sd)
    ?.  ?=(%int -.value)  ~
    (some +.value)
  ::
  ++  ud                                                ::  positive integer
    |=  =value
    ^-  (unit @)
    ?.  ?=(%int -.value)  ~
    ?.  (syn:si +.value)  ~
    (some (abs:si +.value))
  ::
  ::NOTE  cargo-culted from dejs-soft
  ::
  ++  za                                              ::  full unit pole
    |*  pod=(pole (unit))
    ?~  pod  &
    ?~  -.pod  |
    (za +.pod)
  ::
  ++  zl                                              ::  collapse unit list
    |*  lut=(list (unit))
    ?.  |-  ^-  ?
        ?~(lut & ?~(i.lut | $(lut t.lut)))
      ~
    %-  some
    |-
    ?~  lut  ~
    [i=u:+.i.lut t=$(lut t.lut)]
  ::
  ++  zp                                              ::  unit tuple
    |*  but=(pole (unit))
    ?~  but  !!
    ?~  +.but
      u:->.but
    [u:->.but (zp +.but)]
  :: ::
  :: ++  zm                                              ::  collapse unit map
  ::   |*  lum=(map term (unit))
  ::   ?:  (~(rep by lum) |=([[@ a=(unit)] b=_|] |(b ?=(~ a))))
  ::     ~
  ::   (some (~(run by lum) need))
  --
--