::
::
|%
+$  full-db
  $:  templates=templates-db
      tourneys=tourneys-db
      stages=stages-db
      events=events-db
  ==
::
+$  templates-db  (map @t [name=@t gene=gender spid=@t])
+$  tourneys-db   (map @t [name=@t teid=@t])  ::NOTE  name copied from template
+$  stages-db     (map @t [name=@t gene=gender toid=@t])
+$  events-db     (map @t [name=@t round=@t when=@da stid=@t])
::
+$  gender  ?(%male %female %mixed)
::
::NOTE  do not count medals for losses, as in 2355688
+$  result
  $%  [%duel win=result-entry los=result-entry]
      [%rank rank=(list result-entry)]
      [%deft one=result-entry]
  ==
::
+$  result-entry
  $:  =participant
      record=?(%or %wr ~)
      =score
      =medal
  ==
::
+$  medal  ?(%gold %silver %bronze ~)
::
+$  participant
  $%  [%nation country-code=@t]
      [%person name=@t country-code=@t]
  ==
::
+$  score
  $%  [%points n=@t]  ::TODO  account for draws? such as 2217778?
      [%time t=@t]  ::NOTE  append s if doesn't contain :
      [%weight k=@ud]
      [%distance m=@t]
      [%errors e=@t]
      [%par d=@t]
    ::
      [%wl ?(%w %l)]
    ::
      [%dns ~]  ::  did not start
      [%dnf ~]  ::  did not finish
      [%nm ~]  ::  no measured result
      [%dq ~]  ::  disqualified
      [%elim ~]  ::  eliminated
      [%lap ~]  ::  lapped/hd (too slow, forced to stop before finishing)
      ::TODO
      [%running t=@t]
      [%unknown r=(map @t @t)]
  ==
--
