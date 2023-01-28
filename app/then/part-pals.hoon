::  /pkg/pals/app/then/part.hoon: %then prefab components for pals
::
/-  *pals, then
::
%-  ~(gas by *(map @ta part:then))
:~
  :-  'add-pal'
  :+  'Add pal'
    'Adds the given ship as a pal.'
  :-  %then
  =;  =make:then  [%make make ~]
  :+  [%p %who 'ship to add as pal']~
    ~
  :_  |+~
  !,  *hoon
  !!
::
  :-  'dm-self'
  :+  'DM yourself'
    'Send a DM with the given contents to yourself.'
  :-  %then
  =;  =make:then  [%make make ~]
  :+  [%t %what 'DM contents']~
    ~
  :_  |+~
  !,  *hoon
  :+  %poke  %chat-store
  :-  %chat-action
  !>([%send our txt+what])
==


