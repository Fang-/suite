::  /lib/pal: friendly helper library
::
|%
::  list operations
::
++  fuse                                                ::  cons contents
  |*  [a=(list) b=(list)]
  :: ^-  (list _?>(?=([^ ^] [a b]) [i.a i.b]))  ::TODO  why does this not work?
  ^-  (list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
  ?~  a  ~
  ?~  b  ~
  :-  [i.a i.b]
  $(a t.a, b t.b)
::
::  functional toys
::
::TODO  from stdlib
++  lead  |*(* |*(* [+>+< +<]))                         ::  put head
++  late  |*(* |*(* [+< +>+<]))                         ::  put tail
::
::  data structures
::
++  mip                                                 ::  map of maps
  |$  [kex key value]
  (map kex (map key value))
::
++  bi                                                  ::  mip engine
  =|  a=(map * (map))
  |@
  ++  del
    |*  [b=* c=*]
    =+  d=(~(gut by a) b ~)
    =+  e=(~(del by d) c)
    ?~  e
      (~(del by a) b)
    (~(put by a) b e)
  ::
  ++  get
    |*  [b=* c=*]
    (~(get by (~(gut by a) b ~)) c)
  ::
  ++  got
    |*  [b=* c=*]
    (need (get b c))
  ::
  ++  gut
    |*  [b=* c=* d=*]
    (~(gut by (~(gut by a) b ~)) c d)
  ::
  ++  put
    |*  [b=* c=* d=*]
    %+  ~(put by a)  b
    %.  [c d]
    %~  put  by
    (~(gut by a) b ~)
  ::
  ++  tap
    ::NOTE  naive turn-based implementation find-errors ):
    =<  $
    =+  b=`_?>(?=(^ a) *(list [x=_p.n.a _?>(?=(^ q.n.a) [y=p v=q]:n.q.n.a)]))`~
    |.  ^+  b
    ?~  a
      b
    $(a r.a, b (welp (turn ~(tap by q.n.a) (lead p.n.a)) $(a l.a)))
  --
::
::  parsers
::
++  opt                                                 ::  rule or ~
  |*  =rule
  (may rule ~)
::
++  may                                                 ::  rule or constant
  |*  [=rule else=*]
  ;~(pose rule (easy else))
::
++  qfix                                                ::  singular prefix
  |*  [p=rule r=rule]
  ;~(pfix p r)
--
