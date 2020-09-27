::  serval: interacting with the simple http/s bittorrent tracker
::
/+  torn
^?
|_  =bowl:gall
++  scry
  |*  [=mold =path]
  .^(mold %gx (scot %p our.bowl) %serval (scot %da now.bowl) path)
::
++  announce-path
  |=  =ship
  (scry path /announce/(scot %p ship)/path)
::
++  seeder-count
  |=  =file-id:torn
  (scry @ud /file/(scot %ux file-id)/seeders/atom)
::
++  leecher-count
  |=  =file-id:torn
  (scry @ud /file/(scot %ux file-id)/leechers/atom)
::
++  completed-count
  |=  =file-id:torn
  (scry @ud /file/(scot %ux file-id)/completed/atom)
--
