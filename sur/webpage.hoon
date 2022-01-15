::  webpage: simple webpage core type
::
::TODO  deprecated in favor of /lib/rudder
::
|*  [dat=mold cmd=mold]
$_  ^|
|_  [bowl:gall dat]
++  build  |~([(list [k=@t v=@t]) (unit [? @t])] *manx)  ::  get to page
++  argue  |~([header-list:http (unit octs)] *(unit cmd))::  post to cmd
--
