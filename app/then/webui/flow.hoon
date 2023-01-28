::  %then flow details
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
  =/  args  (~(gas by *(map @t @t)) arg)
  ?.  (~(has by args) 'flow')
    [%code 400 'no flow specified']
  =/  fowl  (~(got by args) 'flow')
  ?.  (~(has by flows) fowl)
    [%code 404 'no such flow']
  =+  (~(got by flows) fowl)
  =*  flow  -
  ::
  =/  name  (trip name)
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
        ;h2:"{name}"
        ;*  ?^  live  ; active
            ; {(trip live)}ed
        ;br;
        ;b:"runs:"
        ;br;
        ;*  %+  join  `manx`;br;
            ^-  marl
            %+  turn  logs
            |=  [when=@da what=tang]
            ^-  manx
            ;div.log
              ;b:"{(scow %da (sub when (mod when ~s1)))}"
              ;pre
                ;*  %+  turn  what
                    |=  t=tank
                    ^-  manx
                    ::TODO  why is it not easy to make a text node?
                    ;x
                      ;*  (turn (wash [0 80] t) |=(l=tape ;x:"{l}"))
                    ==
              ==
            ==
      ==
    ==
  ::
  --
--
