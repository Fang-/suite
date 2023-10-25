::  assembly-2023: demo day schedule
::
/+  *assembly-2023, rudder, events=assembly-2023-events
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
  =/  day=@da  ~2023.10.30
  ::
  =/  demo-db  (~(gas by *(map @ event)) demo-day:events)
  =/  schedule=marl
    =;  strips=(list [=vid wen=@da lon=@dr])
      (build-schedule-main [demo-db now] [day strips] [our ~ ~] [& &])
    %+  sort
      %+  murn  ~(tap by demo-db)
      |=  [=vid v=event]
      ?.  ?=(%main -.v)  ~
      =,  v
      ?:  |((lth (add when long) day) (gth when (add day ~d1)))  ~
      (some vid when long)
    |=  [[* a=@da aa=@dr] [* b=@da bb=@dr]]
    ?.  =(a b)  (lth a b)  ::  earlier events first
    (gth aa bb)  ::  longer events first
  |^  [%page page]
  ::
  ++  page
    ^-  manx
    ;html
      ;+  (head 'Assembly 2023: Demo Day')
      ;body.demo
        ;nav
          ;a.left/"#"(onclick "window.history.back();"):"← Back"
          ;a.middle/"/assembly":"↑ Home"
        ==
        ;div.title
          ;h2:"Demo Day"
          ;h3:"~2023.10.30"
        ==
        ;*  schedule
      ==
    ==
  ::
  --
--