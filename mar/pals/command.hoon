::  pals-command: friend management
::
/-  *pals
::
|_  cmd=command
++  grad  %noun
++  grow
  |%
  ++  noun  cmd
  --
++  grab
  |%
  ++  noun  command
  ++  json
    ^-  $-(^json command)
    =,  dejs:format
    |^  (of meet+arg part+arg ~)
    ++  arg
      (ot 'ship'^(su fed:ag) 'in'^(as so) ~)
    --
  --
--
