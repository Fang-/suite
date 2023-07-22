::  million-tile: part of grid
::
/-  *million
::
|_  til=tile
++  grad  %noun
++  grow
  |%
  ++  noun  til
  ++  json
    =,  enjs:format
    |-  ^-  ^json
    %+  frond  -.til
    ?-  -.til
      %forsale  b+&
      %pending  s+(scot %p who.til)
      %mystery  b+&
      %unacked  (pairs 'old'^$(til old.til) 'new'^$(til new.til) ~)
    ::
        %managed
      %-  pairs
      |^  :~  'who'^s+(scot %p who.til)
              'tint'^(tint tint.til)
              'show'^(show show.til)
              'echo'^(echo echo.til)
              'link'^(link link.til)
          ==
      ::
      ++  tint
        |=  t=^tint
        ^-  ^json
        ?~  t  ~
        ?@  t  s+t
        =+  x=(x-co:co 2)
        s+(crip "#{(x r.t)}{(x g.t)}{(x b.t)}")
      ::
      ++  show
        |=  s=^show
        ^-  ^json
        ?-  -.s
          %nothing  ~
          %sourced  s+url.s
          %similar  (spot src.s)
        ==
      ::
      ++  echo
        |=  e=^echo
        ^-  ^json
        ?-  -.e
          %nothing  ~
          %display  s+txt.e
          %similar  (spot src.e)
        ==
      ::
      ++  link
        |=  l=^link
        ^-  ^json
        ?-  -.l
          %nothing  ~
          %weblink  s+url.l
          %similar  (spot src.l)
        ==
      ::
      ++  spot
        |=  s=^spot
        (pairs 'x'^(numb x.s) 'y'^(numb y.s) ~)
      --
    ==
  --
++  grab
  |%
  ++  noun  tile
  --
--
