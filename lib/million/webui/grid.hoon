::  million webui: drawing the grid
::
::NOTE  changed here by themselves don't trigger rebuild,
::      make sure to change affected page files also.
::
::TODO  this may not be the most suitable rendering method forever...
::
/-  *million
::
|^  |=  [=grid lazy=?]
|^  ^-  (list manx)
    (murn ~(tap by grid) tile)
::
++  tile
  |=  [=spot =^tile]
  ^-  (unit manx)
  ?:  ?=(%unacked -.tile)
    $(tile new.tile)
  =*  style  "top:{(a-co:co (mul 10 y.spot))};left:{(a-co:co (mul 10 x.spot))};"
  ?:  ?=(%pending -.tile)
    %-  some
    ;div.tile.pending(style style, title "pending sale to {(scow %p who.tile)}");
  ?.  ?=(%managed -.tile)
    ~
  %-  some
  ;div.tile
      =style  "{style}background:{(show [tint show]:tile)};"
    ;*  ^-  (list manx)
        ?:  lazy  ~
        %-  drop
        %+  bind  (echo echo.tile)
        |=  e=@t
        =;  c=tape  ;div(class c):"{(trip e)}"
        ;:  weld
          "tip "
          ?:((gte x.spot 50) "x " "")
          ?:((gte y.spot 95) "y " "")
        ==
    ;*  ^-  (list manx)
        ?:  lazy  ~
        %-  drop
        %+  bind  (link link.tile)
        |=  l=@t
        ::TODO  if unauthed, and url starts with /, alert instead
        ;a(href "{(trip l)}", target "_blank");
  ==
::
++  link
  |=  l=^link
  ^-  (unit @t)
  =|  p=(set spot)
  |-
  ?-  -.l
    %nothing  ~
    %weblink  `url.l
  ::
      %similar
    ?:  (~(has in p) src.l)  ~
    =/  =^tile  (~(gut by grid) src.l *^tile)
    ?.  ?=(%managed -.tile)  ~
    $(p (~(put in p) src.l), l link.tile)
  ==
::
++  show
  |=  [t=^tint s=^show]
  ^-  tape
  =;  bg=tape  "{bg}, {(tint t)}"
  =|  p=(set spot)
  |-
  ?-  -.s
    %nothing  "none"
    %sourced  "0/cover url('{(trip url.s)}')"
  ::
      %similar
    ?:  (~(has in p) src.s)  "none"
    =/  =^tile  (~(gut by grid) src.s *^tile)
    ?.  ?=(%managed -.tile)  "none"
    $(p (~(put in p) src.s), s show.tile)
  ==
::
++  echo  ::  tooltip text
  |=  e=^echo
  ^-  (unit @t)
  =|  p=(set spot)
  |-
  ?-  -.e
    %nothing  ~
    %display  `txt.e
  ::
      %similar
    ?:  (~(has in p) src.e)  ~
    =/  =^tile  (~(gut by grid) src.e *^tile)
    ?.  ?=(%managed -.tile)  ~
    $(p (~(put in p) src.e), e echo.tile)
  ==
::
--
::
++  tint  ::  background color
  |=  t=^tint
  ?+  t  "rgb({(a-co:co r.t)},{(a-co:co g.t)},{(a-co:co b.t)})"
    ~  "transparent"   %r  "red"    %c  "cyan"
    %w  "white"        %g  "green"  %m  "magenta"
    %k  "black"        %b  "blue"   %y  "yellow"
  ==
--
