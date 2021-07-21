::  ppm: utilities for dealing with ppm image data
::
/-  *ppm
::
|%
++  from-greyscale
  |=  f=(list (list @uE))
  ^-  frame
  %+  turn  f
  |=  r=(list @uE)
  %+  turn  r
  |=  p=@uE
  [p p p]
::
++  to-greyscale
  |=  f=frame
  ^-  (list (list @uE))
  %+  turn  f
  |=  r=(list pixel)
  %+  turn  r
  |=  pixel
  (div :(add r g b) 3)
--
