::  owntracks-location: %location message constructor
::
/+  ot=owntracks
::
:-  %say
|=  $:  ::  environment
        ::
        [now=@da eny=@uvJ bec=beak]
        ::  inline required arguments
        ::
        args=[lat=@rd lon=@rd ~]
        ::  named optional arguments
        ::
        [[user=_'user' pass=_'pass'] did=_'did' location:ot ~]
    ==
:-  %owntracks-request
^-  request:ot
:+  [user pass]  did
%-  some
:*  %location
  acc
  alt
  batt
  bs
  cog
  lat.args
  lon.args
  rad
  t
  tid
  `@da`?:(=(*@da tst) now tst)
  vac
  vel
  p
  poi
  conn
  tag
  topic
  inregions
  inrids
  ssid
  bssid
  created-at
  m
  id
==
