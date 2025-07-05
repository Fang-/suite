::  header-auth: http authorization header utils
::TODO  moar
::
|%
++  extract-basic
  |=  value=@t
  ^-  (unit [user=@t pass=@t])
  ?.  =('Basic ' (end 3^6 value))  ~
  %+  biff
    (de:base64:mimes:html (rsh 3^6 value))
  |=  octs
  %+  rush  q
  ;~  (glue col)
    (cook crip (star ;~(less col next)))
    (cook crip (star next))
  ==
--
