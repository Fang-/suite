::  scooore/tile.hoon: landscape tile svg
::
/+  *pal, rudder
::
^-  (page:rudder * ~)
|_  [bowl:gall * *]
++  argue  |=(* 'not postable')
++  final  (alert:rudder 'back' build)
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
      =height    "200"
      =viewBox  "0 0 48 48"
      ;defs
        ;path
          =id         "face"
          =fill-rule  "evenodd"
          =clip-rule  "evenodd"
          =d          face;
      ==
      ;use/"#face";
      ;use/"#face"(transform "translate(24 24)");
    ==
  ++  face
    """
    M7 4
    h10
    c1.6569 0 3 1.34315 3 3
    v10
    c0 1.6569-1.3431 3-3 3
    H7
    c-1.65685 0-3-1.3431-3-3
    V7
    c0-1.65685 1.34315-3 3-3
    Z
    m10-2
    H7
    C4.23858 2 2 4.23858 2 7
    v10
    c0 2.7614 2.23858 5 5 5
    h10
    c2.7614 0 5-2.2386 5-5
    V7
    c0-2.76142-2.2386-5-5-5
    Z
    M8.5 8
    C7.67157 8 7 8.67157 7 9.5
    v1
    c0 .8284.67157 1.5 1.5 1.5
    s1.5-.6716 1.5-1.5
    v-1
    C10 8.67157 9.32843 8 8.5 8
    Z
    M14 9.5
    c0-.82843.6716-1.5 1.5-1.5
    s1.5.67157 1.5 1.5
    v1
    c0 .8284-.6716 1.5-1.5 1.5
    s-1.5-.6716-1.5-1.5
    v-1
    Z
    M13 15
    c0 .5523-.4477 1-1 1
    s-1-.4477-1-1 .4477-1 1-1 1 .4477 1 1
    Z
    m2 0
    c0 1.6569-1.3431 3-3 3
    s-3-1.3431-3-3 1.3431-3 3-3 3 1.3431 3 3
    Z

    """
  --
--
