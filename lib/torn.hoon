::  torn: bittorrent library
::
/+  benc
::
^?
|%
+$  info-hash
  $%  [%btih ih=@uxinfohash]
      [%btmh ih=@uxmultihash]  ::TODO  parse?
      [%both v1=@uxinfohash v2=@uxmultihash]
  ==
::
::NOTE  20-byte info-hash or truncated multi-hash
+$  file-id    @uxinfohashtruncated
::
::NOTE  bittorrent style magnets, not compatible with general magnet uri scheme
+$  magnet
  $:  =info-hash
      name=(unit @t)
      trackers=(list @t)
  ==
::
+$  metainfo
  $:  info
      announce=@t
      announce-list=(list (list @t))
      creation-date=(unit @da)
      comment=(unit @t)
      created-by=(unit @t)
      encoding=(unit @t)
  ==
::
+$  info
  $:  piece-length=@ud
      pieces=@
      private=(unit ?)
      =mode
  ==
::
+$  mode
  $%  [%single name=@t length=@ud md5sum=(unit @ux)]
      [%multi name=@t files=(list file)]
  ==
::
+$  file
  $:  length=@ud
      md5sum=(unit @ux)
      =path
  ==
::
::TODO  one day, this could be transformed into a general-purpose magnet parser
::NOTE  x.pe is technically part of the spec but we choose to ignore it..
++  parse-magnet
  =;  get-magnet
    %+  sear  get-magnet
    ;~(pfix (jest 'magnet:') yque:de-purl:html)
  |=  =quay:eyre
  ^-  (unit magnet)
  =;  hax=(unit info-hash)
    ?~  hax  ~
    %-  some
    :+  u.hax
      (get-header:http 'dn' quay)
    %+  murn  quay
    |=  [k=@t v=@t]
    ^-  (unit _v)
    ?:(=('tr' k) `v ~)
  ::  stupid logic for turning a v1, v2, or hybrid info-hash into noun
  ::
  =/  xts=_quay
    %+  skim  quay
    |=([k=@t v=@t] =('xt' k))
  ?~  xts  ~
  ?~  t.xts
    (rush q.i.xts parse-xt)
  ?^  t.t.xts  ~
  %^  clef
      (rush q.i.xts parse-xt)
    (rush q.i.t.xts parse-xt)
  |*  [a=info-hash b=info-hash]  ::NOTE  maybe |* allows us to ignore %both
  ?:  =(-.a -.b)  ~
  ?+  -.a  ~|([%unexpected-xt-parse-result a] !!)
    %btih  (some %both +.a +.b)
    %btmh  (some %both +.b +.a)
  ==
::
++  parse-xt
  ;~  pfix  (jest 'urn:')
    ;~  pose
      ;~((glue col) (perk %btih ~) hex)
      ;~((glue col) (perk %btmh ~) hex)
    ==
  ==
::
++  render-magnet
  |=  magnet
  ^-  @t
  ;:  (cury cat 3)
    'magnet:?xt=urn:'
  ::
    %-  crip
    ?-  -.info-hash
      %btih  (weld "btih:" ((x-co:co 40) ih.info-hash))
      %btmh  (weld "btmh:" ((x-co:co 68) ih.info-hash))
      %both  (weld "btih:" ((x-co:co 40) v1.info-hash))  ::TODO  render both
    ==
  ::
    ?~  name  ''
    ::TODO  less conversions
    (cat 3 '&dn=' (crip (en-urlt:html (trip u.name))))
  ::
    ?~  trackers  ''
    %-  crip
    %+  roll  `(list @t)`trackers
    |=  [t=@t all=tape]
    ::TODO  less conversions
    :(weld all "&tr=" (en-urlt:html (trip t)))
  ==
::
++  truncate-info-hash
  |=  =info-hash
  ^-  file-id
  ?-  -.info-hash
    %btih  `@`ih.info-hash
    %both  `@`v1.info-hash
  ::
      %btmh
    ::  truncate down to 20 bytes
    ::NOTE  skip past first two bytes, those are part of multi-hash format.
    ::
    =+  m=(met 3 ih.info-hash)
    (rsh [3 (sub m 22)] (end [3 (sub m 2)] ih.info-hash))
  ==
::
++  reap-metainfo
  =,  reparse:benc
  |=  =value:benc
  ^-  (unit metainfo)
  ?.  ?=(%map -.value)  ~
  |^  ?~  info=(nab "info" reap-info)  ~
      =/  announces=(unit (list (list @t)))
        (nab "announce-list" (ar (ar so)))
      =/  announce=(unit @t)
        ?^  nan=(nab "announce" so)  nan
        %+  biff  announces
        |=  [ans=(list (list @t))]
        ^-  (unit @t)
        ?~  ans    ~
        ?~  i.ans  ~
        `i.i.ans
      ?~  announce  ~
      %-  some
      :*  u.info
          u.announce
          (fall announces ~)
          (nab "creation date" (cu ud from-unix:chrono:userlib))
          (nab "comment" so)
          (nab "created by" so)
          (nab "encoding" so)
      ==
  ::
  ++  nab
    |*  [key=tape =fist]
    (biff (~(get by +.value) key) fist)
  ::
  ++  reap-info
    |=  =value:benc
    ^-  (unit info)
    ?.  ?=(%map -.value)  ~
    =.  ^value  value
    ?~  piece-length=(nab "piece length" ud)  ~
    ?~  pieces=(nab "pieces" so)              ~
    ?~  name=(nab "name" so)                  ~
    =;  mode=(unit mode)
      ?~  mode  ~
      %-  some
      :*  u.piece-length
          u.pieces
          (nab "private" bi)
          u.mode
      ==
    ?~  files=(~(get by +.value) "files")
      ?~  len=(nab "length" ud)  ~
      =+  md5=(nab "md5sum" (ci sa (curr rust hex)))
      `[%single u.name u.len md5]
    =-  (bind - (corl (lead %multi) (lead u.name)))
    ^-  (unit (list file))
    %.  u.files
    %-  ar
    |=  v=value:benc
    ^-  (unit file)
    ?.  ?=(%map -.v)              ~
    =.  ^value  v
    ?~  len=(nab "length" ud)     ~
    ?~  pax=(nab "path" (ar so))  ~
    %-  some
    :+  u.len
      (nab "md5sum" (ci sa (curr rust hex)))
    u.pax
  --
::
++  hash-info
  |=  =info
  ^-  file-id
  =+  (render:benc (benc-info info))
  (sha-1:sha (swp 3 (crip -)))
::
++  benc-info
  |=  info
  ^-  value:benc
  =,  build:benc
  %-  os
  ^-  (list [tape value:benc])
  :*  :-  "name"          (so name.mode)
      :-  "piece length"  (ud piece-length)
      :-  "pieces"        (so pieces)
    ::
      %+  weld
        ^-  (list [tape value:benc])
        ?~  private  ~
        ["private" (bi u.private)]~
      ^-  (list [tape value:benc])
      ?-  -.mode
          %single
        :*  "length"^(ud length.mode)
          ::
            ?~  md5sum.mode  ~
            ["md5sum"^byt+((x-co:co 32) u.md5sum.mode)]~
        ==
      ::
          %multi
        :_  ~
        :-  "files"
        :-  %mor
        %+  turn  files.mode
        |=  file
        %-  os
        :*  "length"^(ud length)
            "path"^((ar so) path)
          ::
            ?~  md5sum  ~
            ["md5sum"^byt+((x-co:co 32) u.md5sum)]~
        ==
  ==  ==
::
++  benc-metainfo
  |=  metainfo
  ^-  value:benc
  =*  info  +<-
  =,  build:benc
  =;  (list (unit [tape value:benc]))
    (os (murn - same))
  :~  ?~  comment     ~  :+  ~  "comment"     (so u.comment)
      ?~  created-by  ~  :+  ~  "created by"  (so u.created-by)
      ?~  encoding    ~  :+  ~  "encoding"    (so u.encoding)
    ::
      :+  ~  "announce"       (so `@t`announce)
      ?~  announce-list  ~
      :+  ~  "announce-list"  ((ar (ar so)) announce-list)
    ::
      ?~  creation-date  ~
      :+  ~  "creation date"
      (ud (div (sub u.creation-date ~1970.1.1) ~s1))
    ::
      :+  ~  "info"
      (benc-info info)
  ==
--
