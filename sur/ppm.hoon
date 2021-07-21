::  ppm: types for ppm image data
::
::NOTE  @uE because ppm *officially* doesn't support >2 bytes per value,
::      but urbit ppm tooling generally shouldn't care.
::
|%
+$  image  [max=@uE pix=frame]
+$  frame  (list (list pixel))  ::  (rows (cols pixel))
+$  pixel  [r=@uE g=@uE b=@uE]
--
