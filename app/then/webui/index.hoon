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
  ~
::
++  final  (alert:rudder url.request build)
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
        ;h2:"(then this that)"
        ;*  (turn ~(tap by flows) show-flow)
      ==
    ==
  ::
  ++  show-flow
    |=  [key=@ta flow]
    ^-  manx
    ;div.flow
      ;b:"{(trip name)}"  ;br;
      ;*  ?^  live  ; active
          ; {(trip live)}ed
      ;b:"last run: "
      ;*  ?~  logs  ; never
          ;=  ; {(scow %da when.i.logs)}
              ; {?:(=(~ what.i.logs) "" "(!)")}
          ==
    ==
  --
--
