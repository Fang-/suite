::  sigil: @p svg generation
::
::    usage: do a named import, then invoke as a function:
::      (sigil ~zod)
::
::    optionally modify configuration parameters:
::      %.  ~paldev
::      %_  sigil
::        size    25
::        fg      "black"
::        bg      "#2aa779"
::        margin  |
::        icon    &
::      ==
::
::NOTE  below, some positional calculations assume a canvas size of 256x256.
::TODO  should we refactor to make use of svg-internal coordinate system?
::      might make logic look cleaner.
::
/+  sigil-symbols
::
::  config
::
=/  fg=tape   "white"
=/  bg=tape   "black"
=/  size=@ud  256
=/  margin=?  &
=/  icon=?    |
::
::
~%  %sigil  ..part  ~
=/  who=ship  ~zod
=/  syc=@ud   1
|^  |=  =ship
    ^-  manx
    ::
    =.  who  ship
    =/  syz  (simp who)
    =.  syc  (lent syz)
    ::
    =/  sire=@rd  (sun:rd size)
    =/  tr=tape
      ::TODO  render transform inside +sigil:svg?
      %+  transform:svg
        ?.  margin  ~
        =+  grid:pos
        `[(gird:pos x) (gird:pos y)]
      `(div:rd (mul:rd sire span:pos) .~128)
    =/  sw=@rd  ::TODO
      ?:  icon  .~0.8  ::TODO  scale with size?
      (add:rd .~0.33 (div:rd sire .~128))
    ::
    %+  outer:svg  size
    %^  sigil:svg  [size margin icon]
      [tr sw]
    (symbols:svg syz icon)
::
++  pos
  |%
  ++  span  ::  symbol scale (relative to full canvas)
    ^-  @rd
    ::TODO  accounting for margin here feels a bit ugly?
    ?+  syc  !!
      %1        ?:(margin .~0.4 .~1)
      ?(%2 %4)  ?:(margin .~0.4 .~0.5)
    ==
  ::
  ++  grid  ::  size in symbols
    ^-  [x=@ud y=@ud]
    ?+  syc  !!
      %4  [2 2]
      %2  [2 1]
      %1  [1 1]
    ==
  ::
  ++  gird  ::  calculate margin
    |=  n=@ud
    ^-  @rd
    =-  (div:rd - .~2)         ::  / sides
    %+  sub:rd  (sun:rd size)  ::  size -
    %+  mul:rd  (sun:rd n)     ::  symbols *
    %+  mul:rd  span:pos       ::  symbol scale *
    (sun:rd size)              ::  size
  ::
  ++  plan  ::  as translation on 256x256 canvas
    |=  i=@ud
    ^-  [x=@ud y=@ud]
    ?+  [syc i]  !!
      [%4 %0]  [0 0]
      [%4 %1]  [128 0]
      [%4 %2]  [0 128]
      [%4 %3]  [128 128]
    ::
      [%2 %0]  [0 0]
      [%2 %1]  [128 0]
    ::
      [%1 %0]  [0 0]
    ==
  --
::
++  svg
  |%
  ++  outer
    |=  [size=@ud inner=manx]
    ^-  manx
    =/  s=tape  ((d-co:co 1) size)
    ;svg
      =style  "display: block;"  ::  prevent bottom margin on svg tag
      =viewBox  "0 0 {s} {s}"
      =version  "1.1"
      =xmlns  "http://www.w3.org/2000/svg"
      ::TODO  additional attributes from config arg?
      ;rect
        =fill  bg
        =width  s
        =height  s;
      ;+  inner
    ==
  ::
  ::TODO  should it be possible to get these svg elements out of this lib?
  ++  sigil
    |=  [[size=@ud margin=? icon=?] [tr=tape sw=@rd] symbols=(list manx)]
    ^-  manx
    ;g
      =transform  tr
      =stroke-width  (say-rd sw)
      =stroke-linecap  "square"
      =fill  fg
      =stroke  bg
      ::NOTE  unfortunately, vector-effect cannot be inherited,
      ::      so it gets inlined in the symbol elements instead
      :: =vector-effect  "non-scaling-stroke"
      ;*  symbols
    ==
  ::
  ++  symbols
    |=  [noms=(list @t) icon=?]
    ^-  (list manx)
    =|  i=@ud
    =/  l=@ud  (lent noms)
    =/  sym    ~(got by (sigil-symbols fg bg))
    |-
    ?~  noms  ~
    :_  $(noms t.noms, i +(i))
    ::TODO  exclude if both 0
    =+  (plan:pos i)
    ;g(transform (transform `[(sun:rd x) (sun:rd y)] ~))
      ;*  =+  (sym i.noms)
          ?.(icon - (scag 1 -))
    ==
  ::
  ::
  ++  transform  ::TODO  take manx instead so we can omit attr entirely?
    |=  [translate=(unit [x=@rd y=@rd]) scale=(unit @rd)]
    ^-  tape
    %-  zing
    ^-  (list tape)
    ::TODO  make cleaner
    =-  ?:  ?=(?(~ [* ~]) -)  -
        (join " " `(list tape)`-)
    ^-  (list tape)
    :~  ?~  translate  ~
        ?:  =([0 0] u.translate)  ~
        "translate({(say-rd x.u.translate)} {(say-rd y.u.translate)})"
      ::
        ?~  scale  ~
        "scale({(say-rd u.scale)})"
    ==
  --
::
++  simp
  |=  =ship
  ^-  (list @t)
  ::  split into phonemes
  ::
  =/  noms=(list @t)
    =/  nom=@t
      (rsh 3 (scot %p ship))
    |-  ?~  nom  ~
    |-  ?:  =('-' (end 3 nom))
          $(nom (rsh 3 nom))
    :-  (end 3^3 nom)
    ^$(nom (rsh 3^3 nom))
  ::  fill leading empties with 'zod'
  ::
  =/  left=@ud
    =-  (sub - (lent noms))
    %-  bex
    ?-  (clan:title ship)
      %czar  0
      %king  1
      %duke  2
      %earl  3
      %pawn  4
    ==
  |-
  ?:  =(0 left)  noms
  $(noms ['zod' noms], left (dec left))
::
++  rd  ~(. ^rd %n)
++  say-rd
  |=  n=@rd
  ^-  tape
  =/  =dn          (drg:rd n)
  ?>  ?=(%d -.dn)
  =/  [s=? m=@ud]  (old:si e.dn)
  =/  x=@ud        (pow 10 m)
  %+  weld
    %-  (d-co:co 1)
    ?:(s (mul a.dn x) (div a.dn x))
  ?:  s  ~
  ['.' ((d-co:co m) (mod a.dn x))]
--
