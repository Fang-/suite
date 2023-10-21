::  assembly-2023: pals events page
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
  =/  kind=?(%main %week)  -:(~(gut by dates) day %week^'')
  ::
  ::TODO  partially shared with /schedule, dedupe
  =/  schedule=marl
    ?-  kind
        %main
      =;  strips=(list [=vid wen=@da lon=@dr])
        (build-schedule-main [database now] [day strips] [our calendar b.groupies] |)
      %+  sort
        %+  murn  ~(tap by b.groupies)
        |=  [=vid pals=(set @p)]
        =.  pals  (~(del in pals) our)
        ?:  =(~ pals)  ~
        ?~  vet=(~(get by database) vid)  ~
        =+  v=u.vet
        ?.  ?=(%main -.v)  ~
        =,  v
        ?:  |((lth (add when long) day) (gth when (add day ~d1)))  ~
        ^-  (unit [^vid @da @dr])
        (some vid when long)
      |=  [[* a=@da aa=@dr] [* b=@da bb=@dr]]
      ?.  =(a b)  (lth a b)  ::  earlier events first
      (gth aa bb)  ::  longer events first
    ::
        %week
      =;  strips=(list [=vid wen=@da lon=(unit @dr)])
        :_  ~
        (build-schedule-week [database now] [day strips] [our calendar b.groupies])
      %+  sort
        %+  murn  ~(tap by b.groupies)
        |=  [=vid pals=(set @p)]
        =.  pals  (~(del in pals) our)
        ?:  =(~ pals)  ~
        ?~  vet=(~(get by database) vid)  ~
        =+  v=u.vet
        ?.  ?=(%week -.v)  ~
        =,  v
        ?:  |((lth (add when (fall long 0)) day) (gth when (add day ~d1)))  ~
        (some vid when long)
      |=  [[* a=@da aa=(unit @dr)] [* b=@da bb=(unit @dr)]]
      ?.  =(a b)  (lth a b)  ::  earlier events first
      ?~  aa  &
      ?~  bb  |
      (gth u.aa u.bb)  ::  longer events first
    ==
  ::
  |^  [%page page]
  ::
  ::
  ++  page
    ^-  manx
    ;html
      ;+  (head 'Assembly 2023: pals calendar')
      ;body
        ;+  (cal-nav now day)
        ;*  schedule
      ==
    ==
  --
--
