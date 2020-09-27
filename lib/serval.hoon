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
::
++  ship-stat-total
  |=  =ship
  %+  scry
    ,[files=@ud uploaded=@ud downloaded=@ud completed=@ud seedtime=@dr]
  /stat/(scot %p ship)
::
++  ship-stat
  |=  [=ship =file-id:torn]
  %+  scry
    ::TODO  stat type into lib?
    ,[uploaded=@ud downloaded=@ud completed=? seedtime=@dr]
  /stat/(scot %p ship)/(scot %ux file-id)
--
