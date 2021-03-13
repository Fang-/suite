::  png:  wip png mark enhancements
::
/+  pal
::
|%
+$  png-file
  $:  (list chunk)
  ==
::
+$  chunk
  $%  [%ihdr wid=@ud hyt=@ud etc=@ux]
      [%rest nom=@t dat=[wid=@ud dat=@ux]]
  ==
::
++  test
  |=  dat=@
  ^-  png-file
  =/  das=(list @)  (rip 3 dat)
  %+  scan  das
  |^  %+  qfix:pal  (jest (swp 3 0x8950.4e47.0d0a.1a0a))
      %-  plus
      %^  lean:pal  (n-byte-atom 4)  (easy ~)
      |=  wid=@ud
      %^  lean:pal  (n-byte-cord 4)  (easy ~)
      |=  nom=@t
      =-  ;~(sfix - (n-byte-atom 4))  ::TODO  verify checksum
      ?.  =('IHDR' nom)
        %+  stag  %rest
        %+  stag  nom
        (stag wid (n-byte-atom wid))
      %+  stag  %ihdr
      ;~  plug
        (n-byte-atom 4)
        (n-byte-atom 4)
        (n-byte-atom 5)
      ==
  ::
  ++  n-byte-cord
    |=  n=@ud
    (cook (cury rep 3) (stun [4 4] next))
  ::
  ++  n-byte-atom
    |=  n=@ud
    =-  (cook - (stun [n n] next))
    |=  caz=(list @)
    (rep 3 (flop caz))
  --
--
