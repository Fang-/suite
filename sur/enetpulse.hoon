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
+$  result
  $%  [%duel win=result-entry los=result-entry]
      [%rank rank=(list result-entry)]
  ==
::
+$  result-entry
  $:  =participant
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
  $%  [%simple n=@ud]
      [%time t=@dr]
      ::TODO
      [%unknown j=(map @t json)]
  ==
--
