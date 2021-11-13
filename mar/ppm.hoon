::  ppm: portable pixel map, lowest common denominator color image file format
::
::    reference spec: http://davis.lbl.gov/Manuals/NETPBM/doc/ppm.html
::
::NOTE  for parsing from mime:
::      - only parses P6-variant ppm files
::      - does not support comments
::      - requires that contents match the given width/height
::      - supports maxvals > 2 bytes
::
::NOTE  for growing to mime:
::      - does not sanity check frame shape (ie consistent row width),
::      - and uses the first row to determine the width
::      - also does not sanity-check pixel values against the maxval,
::      - but will truncate values to be of a matching bytelength
::      - supports maxvals > 2 bytes
::
::TODO  resolve the sanity-check mismatch in the above.
::      files generated on the urbit should be parsable by the urbit!
::
/-  *ppm
/+  pal
::
|_  =image
++  grab
  |%
  ++  noun  ^image
  ::
  ++  mime
    |=  (pair mite octs)
    ^-  ^image
    ~|  [p.q `@ux`q.q]
    =/  fil=(list @)  (rip 3 q.q)
    ::  reclaim trailing zeroes
    ::TODO  stdlib?
    =.  fil  (weld fil (reap (sub p.q (lent fil)) 0))
    %+  scan  fil
    |^  %+  ifix  [;~(plug (jest 'P6') wit) (punt wit)]
        %^  lean:pal  dum:ag  wit
        |=  wid=@ud
        %^  lean:pal  dum:ag  wit
        |=  hyd=@ud
        %^  lean:pal  dum:ag  wit
        |=  max=@ud
        ;~  plug
          (easy max)
          (mate wid hyd max)
        ==
    ::
    ++  wit  (plus (mask ' ' '\09' '\0d' '\0a' ~))
    ::
    ++  mate
      |=  [w=@ud h=@ud m=@ud]
      =;  p
        (stun [h h] (stun [w w] ;~(plug p p p)))
      %+  cook  (cury rep 3)
      (stun [. .]:(met 3 m) (shim 0 m))
    --
  --
::
++  grow
  |%
  ++  noun  image
  ::
  ++  mime
    :-  /image/x-portable-pixmap
    ^-  octs
    =.  max.image  (max 1 max.image)
    =;  byz=(list byts)
      [(roll (turn byz head) add) (can 3 byz)]
    |^  ^-  (list byts)
    :*
      ::  ppm image's magic number is the two characters "P6"
      1^'P'  1^'6'
      1^'\0a'
      ::  a width, formatted as ascii characters in decimal
      (deci ?~(pix.image 0 (lent i.pix.image)))
      1^' '
      ::  a height, again in ascii decimal
      (deci (lent pix.image))
      1^'\0a'
      :: the maximum color value, must be 0 < maxval < 65536
      (deci max.image)
      1^'\0a'
    ::
      ::TODO  could be more efficient wrt assembly?
      %-  zing
      ^-  (list (list byts))
      ::  a raster of height rows, in order from top to bottom
      %+  turn  pix.image
      |=  r=(list pixel)
      ^-  (list byts)
      ::  each row consists of width pixels, in order from left to right
      %+  turn  r
      |=  p=pixel
      ^-  byts
      =+  m=(met 3 max.image)
      ::  each pixel is a triplet of red, green, and blue samples
      ::  each sample is represented in pure binary
      (mul 3 m)^(can 3 (turn ~[r g b]:p (lead m)))
    ==
    ::
    ++  deci
      |=  a=@ud
      ^-  byts
      =+  b=((d-co:co 1) a)
      :-  (lent b)
      (rep 3 b)
    --
  --
::
++  grad  %mime
--
