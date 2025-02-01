::NOTE  this is landscape's lib/contacts but with the c0 import
::      and its dependents removed, because this desk only needs
::      this library for its $contact wrangling utilities.
::
/-  *contacts
|%
+|  %fake-imports
++  g
  |%
  +$  flag  (pair ship term)
  --
::
+|  %contact
::  +is-value-empty: is value considered empty
::
++  is-value-empty
  |=  val=value
  ^-  ?
  ?+  -.val  |
    %text  =('' p.val)
    %look  =('' p.val)
    %set   ?=(~ p.val)
  ==
::  +cy: contact map engine
::
++  cy
  |_  c=contact
  ::  +typ: enforce type if value exists
  ::
  ++  typ
    |*  [key=@tas typ=value-type]
    ^-  ?
    =/  val=(unit value)  (~(get by c) key)
    ?~  val  &
    ?~  u.val  |
    ?-  typ
      %text  ?=(%text -.u.val)
      %numb  ?=(%numb -.u.val)
      %date  ?=(%date -.u.val)
      %tint  ?=(%tint -.u.val)
      %ship  ?=(%ship -.u.val)
      %look  ?=(%look -.u.val)
      %flag  ?=(%flag -.u.val)
      %set   ?=(%set -.u.val)
    ==
  ::  +get: typed get
  ::
  ++  get
    |*  [key=@tas typ=value-type]
    ^-  (unit _p:*$>(_typ value))
    =/  val=(unit value)  (~(get by c) key)
    ?~  val  ~
    ?~  u.val  !!
    ~|  "{<typ>} expected at {<key>}"
    ?-  typ
      %text  ?>(?=(%text -.u.val) (some p.u.val))
      %numb  ?>(?=(%numb -.u.val) (some p.u.val))
      %date  ?>(?=(%date -.u.val) (some p.u.val))
      %tint  ?>(?=(%tint -.u.val) (some p.u.val))
      %ship  ?>(?=(%ship -.u.val) (some p.u.val))
      %look  ?>(?=(%look -.u.val) (some p.u.val))
      %flag  ?>(?=(%flag -.u.val) (some p.u.val))
      %set   ?>(?=(%set -.u.val) (some p.u.val))
    ==
  ::  +ges: get specialized to typed set
  ::
  ++  ges
    |*  [key=@tas typ=value-type]
    ^-  (unit (set $>(_typ value)))
    =/  val=(unit value)  (~(get by c) key)
    ?~  val  ~
    ?.  ?=(%set -.u.val)
      ~|  "set expected at {<key>}"  !!
    %-  some
    %-  ~(run in p.u.val)
      ?-  typ
        %text  |=(v=value ?>(?=(%text -.v) v))
        %numb  |=(v=value ?>(?=(%numb -.v) v))
        %date  |=(v=value ?>(?=(%date -.v) v))
        %tint  |=(v=value ?>(?=(%tint -.v) v))
        %ship  |=(v=value ?>(?=(%ship -.v) v))
        %look  |=(v=value ?>(?=(%look -.v) v))
        %flag  |=(v=value ?>(?=(%flag -.v) v))
        %set   |=(v=value ?>(?=(%set -.v) v))
      ==
  ::  +gos: got specialized to typed set
  ::
  ++  gos
    |*  [key=@tas typ=value-type]
    ^-  (set $>(_typ value))
    =/  val=value  (~(got by c) key)
    ?.  ?=(%set -.val)
      ~|  "set expected at {<key>}"  !!
    %-  ~(run in p.val)
      ?-  typ
        %text  |=(v=value ?>(?=(%text -.v) v))
        %numb  |=(v=value ?>(?=(%numb -.v) v))
        %date  |=(v=value ?>(?=(%date -.v) v))
        %tint  |=(v=value ?>(?=(%tint -.v) v))
        %ship  |=(v=value ?>(?=(%ship -.v) v))
        %look  |=(v=value ?>(?=(%look -.v) v))
        %flag  |=(v=value ?>(?=(%flag -.v) v))
        %set   |=(v=value ?>(?=(%set -.v) v))
      ==
  ::  +gut: typed gut with default
  ::
  ++  gut
    |*  [key=@tas def=value]
    ^+  +.def
    =/  val=value  (~(gut by c) key ~)
    ?~  val
      +.def
    ~|  "{<-.def>} expected at {<key>}"
    ?-  -.val
      %text  ?>(?=(%text -.def) p.val)
      %numb  ?>(?=(%numb -.def) p.val)
      %date  ?>(?=(%date -.def) p.val)
      %tint  ?>(?=(%tint -.def) p.val)
      %ship  ?>(?=(%ship -.def) p.val)
      %look  ?>(?=(%look -.def) p.val)
      %flag  ?>(?=(%flag -.def) p.val)
      %set   ?>(?=(%set -.def) p.val)
    ==
  ::  +gub: typed gut with bunt default
  ::
  ++  gub
    |*  [key=@tas typ=value-type]
    ^+  +:*$>(_typ value)
    =/  val=value  (~(gut by c) key ~)
    ?~  val
      ?+  typ  !!
        %text  *@t
        %numb  *@ud
        %date  *@da
        %tint  *@ux
        %ship  *@p
        %look  *@t
        %flag  *flag:g
        %set   *(set value)
      ==
    ~|  "{<typ>} expected at {<key>}"
    ?-  typ
      %text  ?>(?=(%text -.val) p.val)
      %numb  ?>(?=(%numb -.val) p.val)
      %date  ?>(?=(%date -.val) p.val)
      %tint  ?>(?=(%tint -.val) p.val)
      %ship  ?>(?=(%ship -.val) p.val)
      %look  ?>(?=(%look -.val) p.val)
      %flag  ?>(?=(%flag -.val) p.val)
      %set   ?>(?=(%set -.val) p.val)
    ==
  --
::  +sane-contact: verify contact sanity
::
::  - restrict size of the jammed noun to 10kB
::  - prohibit 'data:' URLs in image data
::  - nickname and bio must be a %text
::  - avatar and cover must be a %look
::  - groups must be a %set of %flags
::
++  sane-contact
  |=  con=contact
  ^-  ?
  ?~  ((soft contact) con)
    |
  ::  10kB contact ought to be enough for anybody
  ::
  ?:  (gth (met 3 (jam con)) 10.000)
    |
  ::  field restrictions
  ::
  ::  1. %nickname field: max 64 characters
  ::  2. %bio field: max 2048 characters
  ::  3. data URLs in %avatar and %cover
  ::     are forbidden
  ::
  ?.  (~(typ cy con) %nickname %text)  |
  =+  nickname=(~(get cy con) %nickname %text)
  ?:  ?&  ?=(^ nickname)
          (gth (met 3 u.nickname) 64)
      ==
    |
  ?.  (~(typ cy con) %bio %text)  |
  =+  bio=(~(get cy con) %bio %text)
  ?:  ?&  ?=(^ bio)
          (gth (met 3 u.bio) 2.048)
      ==
    |
  ?.  (~(typ cy con) %avatar %look)  |
  =+  avatar=(~(get cy con) %avatar %look)
  ?:  ?&  ?=(^ avatar)
          =('data:' (end 3^5 u.avatar))
      ==
    |
  ?.  (~(typ cy con) %cover %look)  |
  =+  cover=(~(get cy con) %cover %look)
  ?:  ?&  ?=(^ cover)
          =('data:' (end 3^5 u.cover))
      ==
    |
  ?.  (~(typ cy con) %groups %set)  |
  =+  groups=(~(get cy con) %groups %set)
  ::  verifying the type of the first set element is enough,
  ::  set uniformity is verified by +soft above.
  ::
  ?:  ?&  ?=(^ groups)
          ?=(^ u.groups)
          !?=(%flag -.n.u.groups)
      ==
    |
  &
::  +do-edit: edit contact
::
::  edit .con with .mod contact map.
::  unifies the two maps, and deletes any resulting fields
::  that are null.
::
++  do-edit
  |=  [con=contact mod=(map @tas value)]
  ^+  con
  =/  don  (~(uni by con) mod)
  =/  del=(list @tas)
    %-  ~(rep by don)
    |=  [[key=@tas val=value] acc=(list @tas)]
    ?.  ?=(~ val)  acc
    [key acc]
  =?  don  !=(~ del)
    %+  roll  del
    |=  [key=@tas acc=_don]
    (~(del by don) key)
  don
::  +contact-uni: merge contacts
::
++  contact-uni
  |=  [c=contact mod=contact]
  ^-  contact
  (~(uni by c) mod)
::  +foreign-contact: get foreign contact
::
++  foreign-contact
  |=  far=foreign
  ^-  contact
  ?~(for.far ~ con.for.far)
::  +foreign-mod: modify foreign profile with user overlay
::
++  foreign-mod
  |=  [far=foreign mod=contact]
  ^-  foreign
  ?~  for.far
    far
  far(con.for (contact-uni con.for.far mod))
::  +mono: tick time
::
++  mono
  |=  [old=@da new=@da]
  ^-  @da
  ?:  (lth old new)  new
  (add old ^~((rsh 3^2 ~s1)))
--
