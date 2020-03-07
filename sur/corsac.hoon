::  corsac: cors access control
::
|%
+$  origin  @t
::
::TODO  per-app? maybe too granular to be nice ux though, for questionable gain
+$  action
  $%  [%request =origin]
      [%approve =origin until=(unit @da)]
      [%disavow =origin until=(unit @da)]
      ::TODO  manual expiration?
  ==
--
