::  %then index
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
  ?:  (~(has by args) 'new')     [%draft *^draft]
  ?~  fid=(~(get by args) 'id')  ~
  ?.  (~(has by flows) u.fid)    ~
  ?:  (~(has by args) 'start')   [%start u.fid]
  ?:  (~(has by args) 'pause')   [%pause u.fid]
  ?:  (~(has by args) 'erase')   [%erase u.fid]
  ?:  (~(has by args) 'draft')   [%draft u.fid %last (~(got by flows) u.fid)]
  ~
::
++  final
  |=  [success=? =brief:rudder]
  =/  args=(map @t @t)
    ?~(body.request ~ (frisk:rudder q.u.body.request))
  ?:  &(success |((~(has by args) 'draft') (~(has by args) 'new')))
    [%next (rap 3 '/' dap.bowl '/build' ~) brief]
  (build ~ `[success `@t`brief])
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ::
  |^  [%page page]
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }
    .flow { padding: 1em; border: 1px solid black; }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%then"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h3:"auto prototype 2: %then"
        ;h2:"when, then"
        ;+  ?~  msg  ;/("")
            ;/("[[ {(trip t.u.msg)} ]]")
        ;form(method "post")
          ;input(type "submit", name "new", value "make new flow");
        ==
        ;br;
        ;*  ?:  =(~ flows)  ;=  ;i:"nothing happening yet..."  ==
            (turn ~(tap by flows) show-flow)
      ==
    ==
  ::
  ++  show-flow
    |=  [key=@ta flow]
    ^-  manx
    =/  stance=tape
      ?:(=(%live live) "pause" "start")
    ;div.flow
      ;b:"{(trip name)}"  ;br;
      ;*  ?:  ?=(%live live)  ; active
          ; {(trip live)}ed
      ;br;
      ;b:"last run: "
      ;*  ?~  logs  ; never
          ;=  ; {(scow %da when.i.logs)}
              ; {?:(=(~ what.i.logs) "" "(!)")}
          ==
      ;br;
      ;form(method "post")
        ;input(type "hidden", name "id", value "{(trip key)}");
        ;input(type "submit", name "draft", value "view & edit");
        ;input(type "submit", name stance, value stance);
        ;input(type "submit", name "erase", value "erase");
      ==
    ==
  --
--
