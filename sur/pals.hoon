::  pals: manual neighboring
::
|%
+$  records  ::  local state
  $:  outgoing=(jug ship @ta)
      incoming=(set ship)
    ::
      ::  receipts: for all outgoing, status
      ::
      ::    if ship not in receipts,  poke awaiting ack
      ::    if ship present as true,  poke acked positively
      ::    if ship present as false, poke acked negatively
      ::
      receipts=(map ship ?)
  ==
::
+$  command  ::  from ourselves
  $%  [%meet =ship in=(set @ta)]  ::  empty set allowed
      [%part =ship in=(set @ta)]  ::  empty set implies un-targeting
  ==
::
+$  webpage
  $_  ^|
  |_  records
  ++  build  |~([(list [k=@t v=@t]) (unit [? @t])] *manx)  ::  get to page
  ++  argue  |~((list [k=@t v=@t]) *(unit command))        ::  post to cmd
  --
--
