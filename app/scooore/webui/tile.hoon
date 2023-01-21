::  scooore/tile.hoon: landscape tile svg
::
/+  *pal, rudder
::
^-  (page:rudder * ~)
|_  [bowl:gall * *]
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
      =viewBox  "0 0 24 24"
      ;path
        =transform  "scale(-1.2,1.2) translate(-14,-2.8) rotate(20)"
        =fill       "rgba(0,0,0,0.3)"
        =fill-rule  "evenodd"
        =clip-rule  "evenodd"
        =d          face;
      :: ;text(x "12.2", y "17.7", font-size "1pt"):"#?"
    ==
  ++  face
    """
    M6 4
    h10
    c1.3062 0 2.4175.83481 2.8293 2
    H20.9
    c-.4633-2.28224-2.481-4-4.9-4
    H6
    C3.23858 2 1 4.23858 1 7
    v10
    c0 2.7614 2.23858 5 5 5
    h10
    c2.419 0 4.4367-1.7178 4.9-4
    h-2.0707
    c-.4118 1.1652-1.5231 2-2.8293 2
    H6
    c-1.65685 0-3-1.3431-3-3
    V7
    c0-1.65685 1.34315-3 3-3
    Z
    m-.5 4
    C4.67157 8 4 8.67157 4 9.5
    v1
    c0 .8284.67157 1.5 1.5 1.5
    S7 11.3284 7 10.5
    v-1
    C7 8.67157 6.32843 8 5.5 8
    Z
    M11 9.5
    c0-.82843.6716-1.5 1.5-1.5
    s1.5.67157 1.5 1.5
    v1
    c0 .8284-.6716 1.5-1.5 1.5
    s-1.5-.6716-1.5-1.5
    v-1
    Z
    M10 15
    c0 .5523-.44772 1-1 1
    s-1-.4477-1-1 .44772-1 1-1 1 .4477 1 1
    Z
    m2 0
    c0 1.6569-1.3431 3-3 3-1.65685 0-3-1.3431-3-3
    s1.34315-3 3-3
    c1.6569 0 3 1.3431 3 3
    Z
    """
  --
--
