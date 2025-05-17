::  spots: location tracking primitives
::
|%
+$  device  ::  tracking object
  $:  log=(list node)
      ::TODO  last-known monitoring mode?
      bat=(unit batt)
      now=(set region=@da)
      ::TODO  card overlay
  ==
::
+$  region  ::  radial zone  ::TODO  $zone
  $:  nom=@t
      [lat=@rd lon=@rd rad=@ud]
      now=(set device=@t)  ::TODO  support foreign devices?
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
      [alt=(unit @sd) vac=(unit @ud)]  ::TODO  actually alt=(unit $@(@sd [alt=@sd vac=@ud]))
  ==
::
+$  batt
  [cen=@ud sat=?(%idk %run %cha %ful)]
::
::
+$  live-update
  [did=@t now=(unit node) bat=(unit batt)]
::
+$  zone-update  ::REVIEW
  [[who=@p did=@t] now=?(%enter %leave)]
--
