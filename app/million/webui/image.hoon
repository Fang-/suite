::  million/image.hoon: landscape tile svg
::
/-  *million
/+  rudder, mg=million-webui-grid
::
^-  (page:rudder grid action)
|_  [=bowl:gall * =grid]
++  argue  |=(* 'not postable')
++  final  (alert:rudder 'tile' build)
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  ^-  reply:rudder
  |^  [%xtra hed svg]
  ++  hed
    :~  ['content-type' 'image/svg+xml']
        ['cache-control' 'public, max-age=3600, immutable']
    ==
  ++  svg
    ;svg
      =xmlns     "http://www.w3.org/2000/svg"
      =version   "1.1"
      =viewBox  "-5 -5 110 110"
      =width    "100"
      =height   "100"
      ;*  (murn ~(tap by grid) tile)
    ==
  ::
  ++  tile
    |=  [=spot =^tile]
    ^-  (unit manx)
    ?:  ?=(%unacked -.tile)
      $(tile new.tile)
    ?:  ?=(%pending -.tile)
      %-  some
      ;rect(width "1", height "1", x "{(a-co:co x.spot)}", y "{(a-co:co y.spot)}", fill "#ccc");
    ?.  ?=(%managed -.tile)  ~
    =/  color=tape  (tint:mg tint.tile)
    ?~  color  ~
    %-  some
    ;rect
      =width   "1"
      =height  "1"
      =x       "{(a-co:co x.spot)}"
      =y       "{(a-co:co y.spot)}"
      =fill    "{color}";
  --
--
