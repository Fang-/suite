::  assembly-2023: public schedule page
::
::TODO
::  - full schedule
::    - if no date specified, load today, bounded to earliest or latest date at which there are events
::    - render "today", "tomorow", "yesterday" headers, but always subtitle with date
::    - show mutual icon/count if any
::    - show star icon if attending
::
::TODO  priority:
::  - individual event page
::  - straight list for urbit week
::  - test personal calendar & pals listing
::  - pals page?? or maybe not, just through global schedule
::
/+  *assembly-2023, rudder
::
^-  (page:rudder state action)
|_  [bowl:gall order:rudder state]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  ?~  body  ~
  =/  args=(map @t @t)
    (frisk:rudder q.u.body)
  !!
::
++  final  (alert:rudder url.request build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ?>  ?=(~ msg)
  =/  args=(map @t @t)  (~(gas by *(map @t @t)) arg)
  ::  shift over "now" to be the time in portugal.
  ::
  =.  now  (ut-to-pt now)
  =/  day=@da
    =;  d=@da  (sub d (mod d ~d1))
    (fall (biff (~(get by args) 'day') (cury slaw %da)) now)
  =.  day  (min (max ~2023.10.28 day) ~2023.11.3)
  ::
  =/  kind=?(%main %week)  -:(~(gut by dates) day %week^'')
  =/  schedule=manx
    ?-  kind
        %main
      =;  strips=(list [=vid wen=@da lon=@dr])
        (build-schedule-main [database now] [day strips] [our calendar b.groupies])
      %+  sort
        %+  murn  ~(tap by database)
        |=  [=vid v=event]
        ?.  ?=(%main -.v)  ~
        =,  v
        ?:  |((lth (add when long) day) (gth when (add day ~d1)))  ~
        (some vid when long)
      |=  [[* a=@da aa=@dr] [* b=@da bb=@dr]]
      ?.  =(a b)  (lth a b)  ::  earlier events first
      (gth aa bb)  ::  longer events first
    ::
        %week
      =;  strips=(list [=vid wen=@da lon=(unit @dr)])
        (build-schedule-week [database now] [day strips] [our calendar b.groupies])
      %+  sort
        %+  murn  ~(tap by database)
        |=  [=vid v=event]
        ?.  ?=(%week -.v)  ~
        =,  v
        ?:  |((lth (add when (fall long 0)) day) (gte when (add day ~d1)))  ~
        (some vid when long)
      |=  [[* a=@da aa=(unit @dr)] [* b=@da bb=(unit @dr)]]
      ?.  =(a b)  (lth a b)  ::  earlier events first
      ?~  aa  &
      ?~  bb  |
      (gth u.aa u.bb)  ::  longer events first
    ==
  :: =/  [tot=@ud coz=(jar @ud [=vid fro=@da til=@da])]
  ::   (events-into-cols database strips)
  |^  [%page page]
  ::
  ++  page
    ^-  manx
    ;html
      ;+  (head 'Assembly 2023: schedule')
      ;body
        ;+  (cal-nav now day)
        ;+  schedule
      ==
    ==
  ::
  --
--