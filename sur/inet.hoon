::  inet: types
::
|%
+$  state
  $:  start=@da
      timer=(unit @da)
      sprouts=(list @t)
      library=(map index story)
      volumes=(jar @ud index)    ::  newest first
      authors=(jar @p index)     ::  newest first
  ==
::
+$  index  [author=@p id=@]
::
+$  story
  $:  author=@p
      echoed=?  ::  known to host; only relevant to sender
      likes=(set @p)
    ::
      sprout=@ud
      date=@da
      body=@t
  ==
::
+$  action
  $%  [%pre ~]
      [%add id=@ sprout=@ud date=@da body=@t]
      [%del id=@]
      [%luv =index]
  ==
::
+$  update
  $%  [%sprouts sprouts=(list @t)]
      [%stories changes=(list [author=@p =action])]
  ==
--
