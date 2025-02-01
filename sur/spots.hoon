::  spots: location tracking primitives
::
|%
+$  device  ::  tracking object
  $:  bac=(list node)  ::TODO  .log
      ::TODO  last-known monitoring mode?
      bat=(unit batt)
      now=(set region=@da)  ::TODO  ?
      ::TODO  card overlay
  ==
::
+$  region  ::  radial zone
  $:  nom=@t
      [lat=@rd lon=@rd rad=@ud]
      now=(set device=@t)  ::TODO  ?
  ==
::
+$  node  ::  location in time
  $:  spot
      wen=[gps=time msg=time]
      vel=(unit @ud)  ::TODO  in $spot?
  ==
::
+$  spot  ::  location w/ deets
  $:  lat=@rd
      lon=@rd
      acc=(unit @ud)
      [alt=(unit @ud) vac=(unit @ud)]  ::TODO  actually alt=(unit $@(@ud [alt=@ud vac=@ud]))
  ==
::
+$  batt
  [cen=@ud sat=?(%idk %run %cha %ful)]
::
::
+$  live-update
  [did=@t now=(unit node) bat=(unit batt)]
--
