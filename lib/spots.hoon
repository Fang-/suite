::  spots: location utilities
::
/-  *spots
/+  math
::
|%
++  distance  ::  haversine
  |=  [[a=[lat=@rd lon=@rd]] b=[lat=@rd lon=@rd]]
  ^-  @rd  ::  km
  =,  rd:math
  |^  =;  x=@rd
        %+  mul
          .~3956.752  ::  km radius of earth
        (mul .~2 (atan2 (sqt x) (sqt (sub .~1 x))))
      %+  add
        (pow-n (sin (div (deg2rad (abs (sub lat.a lat.b))) .~2)) .~2)
      %+  mul
        (cos (deg2rad lat.a))
      %+  mul
        (cos (deg2rad lat.b))
      (pow-n (sin (div (deg2rad (abs (sub lon.a lon.b))) .~2)) .~2)
  ::
  ++  deg2rad
    |=  x=@rd
    (div (mul x pi) .~180)
  --
::
++  enjs
  =,  enjs:format
  |%
  ++  bums
    |=  =^bums
    %-  pairs
    ::TODO  exclude stale/expired bums?
    %+  turn  ~(tap by bums)
    |=  [did=@t nom=@t pas=@t node bat=(unit batt)]
    :-  did
    %-  pairs
    :~  'nom'^s+nom
        'lat'^n+(rsh 3^2 (scot %rd lat))
        'lon'^n+(rsh 3^2 (scot %rd lon))
        'acc'^?~(acc ~ (numb u.acc))
        'bat'^?~(bat ~ (numb cen.u.bat))
        'wen'^s+(scot %da msg.wen)
    ==
  --
--
