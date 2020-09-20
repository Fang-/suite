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
::TODO  maybe +$ finf [file info]
::
::TODO  torrent file details. currently unused, so commented out
:: +$  info
::   $:  piece-length=@ud
::       pieces=@t
::       private=?
::       =mode
::   ==
:: ::
:: +$  mode
::   $%  [%single name=@t length=@ud md5sum=(unit @ux)]
::       [%multi name=@t files=(list file)]
::   ==
:: ::
:: +$  file
::   $:  length=@ud
::       md5sum=(unit @ux)
::       =path
::   ==
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
    (rsh 3 (sub m 22) (end 3 (sub m 2) ih.info-hash))
  ==
::
++  reap-info
  =,  reparse:benc
  |=  =value:benc
  :: ^-  (unit info)
  ~
  ::TODO  this is shitty. write more reparsers?
  :: ?.  ?=(%map -.value)  ~
  :: ?~  piece-length=(bind (~(get by +.value) "piece length") ud)
  ::   ~
  :: ?~  pieces=(bind (~(get by +.value) "pieces") so)
  ::   ~
  :: ?~  name=(bind (~(get by +.value) "name") so)
  ::   ~
  :: =;  mode=(unit mode)
  ::   ?~  mode  ~
  ::   %-  some
  ::   :*  u.piece-length
  ::       u.pieces
  ::       (fall (bind (~(get by +.value) "private")) |)
  ::       u.mode
  ::   ==
  :: ?~  files=(~(get by +.value) "files")
  ::   =/  deet=(unit)
  ::     %.  value
  ::     (ot (ly ~['length'^ud 'md5sum'^(mu (cu sa (curr rust hex)))]))
  ::   ?~  deet  ~
  ::   ;;  (unit mode)  ::TODO  just want better typechecks ):
  ::   `[%single u.name u.deet]
  :: =-  ~!  *mode  ~!  -  -
  :: %.  u.files
  :: %-  ar
  :: %-  ot
  :: %-  ly
  :: :~  'length'^ud
  ::     'md5sum'^(mu (cu sa (curr rust hex)))
  ::     'path'^(ar so)
  :: ==
--
