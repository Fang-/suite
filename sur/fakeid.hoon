::  fakeid: temporary local identities
::
|%
+$  session-key  @
+$  session
  $:  name=ship
      until=time
  ==
::
+$  action
  $%  [%new =session-key =session]
      [%expire who=(each ship session-key)]
  ==
--