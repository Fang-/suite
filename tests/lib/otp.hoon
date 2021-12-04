::  tests for the otp lib
::
::  test vectors from here:
::  https://datatracker.ietf.org/doc/html/rfc4226#appendix-D
::
/+  *test, otp
|%
++  test-hotp
  =/  k=byts
    20^(swp 3 '12345678901234567890')
  =/  v=(list [c=@ p=@])
    :~  [0 755.224]
        [1 287.082]
        [2 359.152]
        [3 969.429]
        [4 338.314]
        [5 254.676]
        [6 287.922]
        [7 162.583]
        [8 399.871]
        [9 520.489]
    ==
  %-  zing
  %+  turn  v
  |=  [c=@ p=@]
  %+  expect-eq
    !>  p
    !>  (hotp:otp k c)
--
