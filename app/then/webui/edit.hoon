::  %then new flow creation
::
/-  *then
/+  rudder
::
^-  (page:rudder xxxx task)
::
|_  [=bowl:gall order:rudder xxxx]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder task)
  =/  args=(map @t @t)
    ?~(body ~ (frisk:rudder q.u.body))
  ::TODO
  'todo implement me'
::
::TODO  even if failed, update state as far as possible so that build fields
::      reflect user input
++  final  (alert:rudder url.request build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  =/  args  (~(gas by *(map @t @t)) arg)
  =/  fowl  (~(gut by args) 'flow' 'new-flow')
  =+  (~(gut by flows) fowl 'new flow' %stop ~ *when *then)
  =*  flow  -
  ::
  =/  name  "xx" ::(trip name)
  ::
  |^  [%page page]
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%then: {name}"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h2:"editing flow"
        ;form
          ; name-input
          ; live-toggle
          ;+  when-input
          ; then-input
        ==
      ==
    ==
  ::
  ++  when-input
    ^-  manx
    ;div
      ;+  (when-group "kick" "manually" ~)
      ::
      ;+  %^  when-group  "time"  "on a timer"
          ^-  marl
          ;=  ; at:
              ;input(type "datetime-local", name "from"); ::TODO  value now
              ;input(type "checkbox", name "reap-enabled"):"repeating?"
              ; every
              ;input(type "number", name "reap");
              ; seconds.
          ==
    ==
    :: either:
    :: - manual
    :: - timer
    :: - subscription
    :: - dynamic trigger
    :: with optional dynamic conditional test (later)
  ::
  ++  when-group
    |=  [type=tape desc=tape body=marl]
    ^-  manx
    ;div
      ;input(type "radio", name "when-type", value type)
        ; {desc}
        ;*  body
      ==
    ==
  ::
  ++  then-input
    !!
    :: either:
    :: - poke agent w/ cage
    :: - dill output
    :: - no-op
    :: - disable self
    :: - dynamic
    :: with optional %both follow-up (later)
  --
--
