::  fafa/mod.hoon: rename & delete factors
::
/-  *fafa
/+  rudder
::
^-  (page:rudder (map label secret) action)
|_  [bowl:gall * keys=(map label secret)]
++  argue  |=(* 'not postable')
++  final  (alert:rudder 'tile' build)
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  ^-  reply:rudder
  |^  [%xtra hed svg]
  ++  hed
    :~  ['content-type' 'image/svg+xml']
        ['cache-control' 'public, max-age=604800, immutable']
    ==
  ++  svg
    ;svg
      =xmlns     "http://www.w3.org/2000/svg"
      =version   "1.1"
      =width     "100"
      =height    "100"
      =viewport  "0 0 100 100"
      ;rect(width "100%", height "100%", fill "#1a1a2a");
      ;g(style "stroke-width: 6;", transform "rotate(40 50 50)")
        :: ;g(style "stroke: goldenrod;", transform "rotate(25 50 60)")
        ::   ;*  (key |)
        :: ==
        ;g(style "stroke: gold;")
          ;*  (key &)
        ==
      ==
    ==
  ++  key
    |=  ring=?
    ^-  (list manx)
    :*  ;line(x1 "50", y1 "25", x2 "50", y2 "55");
        ;line(style "stroke-width: 4;", x1 "50", y1 "27", x2 "60", y2 "27");
        ;line(style "stroke-width: 4;", x1 "50", y1 "35", x2 "60", y2 "35");
      ::
        ?.  ring  ~
        [;circle(style "fill: none;", cx "50", cy "60", r "8");]~
    ==
  --
--
