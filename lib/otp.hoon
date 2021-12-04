::  otp: one-time passwords
::
::NOTE  https://github.com/google/google-authenticator/wiki/Key-Uri-Format
::  otpauth://totp/UrbitFoundation:sample@pal.dev?secret=LKSYSPGMO3A5P6S6&issuer=UrbitFoundation&algorithm=SHA1&digits=6&period=30
::
=+  hash=`?(%sha1 %sha256 %sha512)`%sha1
=+  size=6
=+  step=30
=+  dawn=0
::
|%
+$  label  [issuer=@t id=@t]
+$  secret
  $:  key=@  ::TODO  maybe byts
      alg=$~(%sha1 ?(%sha1 %sha256 %sha512))
      len=_6
    ::
      $=  wat
      $~  [%totp 30]
      $%  [%hotp counter=_0]
          [%totp period=_30]
      ==
  ==
::
++  xotp
  |=  [secret now=@da]
  ^-  @ud
  =.  hash  alg
  =.  size  len
  =?  step  ?=(%totp -.wat)  period.wat
  ?-  -.wat
    %hotp  (hotp key counter.wat)
    %totp  (totp key now)
  ==
::
::TODO  matches totp.danhersam.com but not the test vectors in rfc6238...
++  totp
  |=  [k=$@(@ byts) now=@da]
  ^-  @ud
  %+  hotp  k
  (div (sub (unt:chrono:userlib now) dawn) step)
::
++  hotp
  |=  [k=$@(@ byts) c=@]
  ^-  @ud
  =+  k=?@(k [(met 3 k) k] k)
  =/  h
    %.  [k 8^c]
    ?-  hash
      %sha1    hmac-sha1l:hmac:crypto
      %sha256  hmac-sha256l:hmac:crypto
      %sha512  hmac-sha512l:hmac:crypto
    ==
  =+  t=(end 0^31 (cut 3 [(sub 16 (end 2 h)) 4] h))
  (mod t (pow 10 size))
::
++  bask  ::  parse base32 key
  =-  (bass 32 (plus -))
  ;~  pose
    (cook |=(a=@ (sub a 65)) (shim 'A' 'Z'))
    (cook |=(a=@ (sub a 24)) (shim '2' '7'))
  ==
::
++  puri  ::  parse otp uri
  =,  de-purl:html
  %+  sear
    |=  [wat=?(%hotp %totp) acc=$@(@t [is=@t id=@t]) arg=(map @t @t)]
    ^-  (unit [=label =secret])
    ?.  (~(has by arg) 'secret')  ~
    =/  key=(unit @)
      (rush (~(got by arg) 'secret') bask)
    ?~  key  ~
    ?:  &(?=(%hotp wat) !(~(has by arg) 'counter'))
      ~
    %-  some
    :-  ?^  acc  acc
        [(~(gut by arg) 'issuer' '') acc]
    =|  =secret
    ::
    =.  key.secret  u.key
    ::
    =?  alg.secret  (~(has by arg) 'secret')
      =-  (fall - alg.secret)
      %+  rush  (~(got by arg) 'secret')
      ;~  pose
        (cold %sha1 (jest 'SHA1'))
        (cold %sha256 (jest 'SHA256'))
        (cold %sha512 (jest 'SHA512'))
        (easy %sha1)
      ==
    ::
    =?  len.secret  (~(has by arg) 'digits')
      =-  (fall - len.secret)
      (rush (~(got by arg) 'digits') dum:ag)
    ::
    =?  wat.secret  &(?=(%totp wat) (~(has by arg) 'period'))
      =-  (fall - wat.secret)
      (rush (~(got by arg) 'period') (stag %totp dum:ag))
    ::
    =?  wat.secret  ?=(%hotp wat)
      =-  (fall - [%hotp 1])
      (rush (~(got by arg) 'counter') (stag %hotp dum:ag))
    secret
  |^  ;~(pfix (jest 'otpauth://') purr)
  ++  purr  ;~(plug (perk %hotp %totp ~) ;~(pfix fas labe) ;~(pfix wut parm))
  ++  labe  ;~(pose ;~((glue col) corp smeg) smeg)
  ++  corp  (cook crip (star ;~(less col pcar:de-purl:html)))
  ++  parm  (cook ~(gas by *(map @t @t)) yquy:de-purl:html)
  --
--
