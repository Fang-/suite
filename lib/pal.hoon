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
++  snug                                                ::  unitized snag
  |*  [a=@ b=(list)]
  |-  ^-  (unit _?>(?=(^ b) i.b))
  ?~  b  ~
  ?:  =(0 a)  (some i.b)
  $(b t.b, a (dec a))
::
::  unit operations
::
++  sink                                                ::  any of units
  |*  [a=(unit) b=(unit)]
  ?^(a a b)
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
  ++  key
    |*  b=*
    ~(key by (~(gut by a) b ~))
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
::
++  lean                                                ::  measure to parse
  |*  [measure=rule separate=rule parse=$-(* rule)]
  |=  =nail
  =/  edge=(like @)  (;~(sfix measure separate) nail)
  ?~  q.edge  edge
  =*  size  p.u.q.edge
  =*  rest  q.u.q.edge
  ((parse size) rest)
::
::  randomness
::
++  wild                                                ::  weighted choice
  |=  [eny=@ all=(list @ud)]
  =/  sum=@ud  (roll all add)
  =+  rad=(~(rad og eny) sum)
  =|  v=@ud
  =|  i=@ud
  |-
  ?~  all  i
  =.  v  (add v i.all)
  ?:  (gth v rad)  i
  $(i +(i), all t.all)
--
