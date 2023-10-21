::  assembly-2023: messages page
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
  =/  msg=@t  (~(got by args) 'msg')
  [%advice msg]
::
++  final
  |=  [done=? =brief:rudder]
  [%next url.request ~]
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ::
  =.  messages  (scag 50 messages)
  ::
  |^  [%page page]
  ::
  ::
  ++  page
    ^-  manx
    ;html
      ;+  (head 'Assembly 2023: Community Kiosk')
      ;body.messages
        ;header
          ;a.left/"/assembly":"<"
          ;a/"/assembly"
            ;h2:"Community Kiosk"
            ;h3:"Cartas de Lisboa"
          ==
        ==
        ;*  ?:  =(%pawn (clan:title our))  ~
            :_  ~
            ;form(method "post")
              ;textarea
                =name         "msg"
                =maxlength    "1000"
                =placeholder  "Share local finds, ask for recommendations, coordinate...";
              ;button(type "submit", name "send"):"Share"
            ==
        ;*  ?:  =(~ messages)
              :_  ~
              ;div(style "text-align:center;margin-top:2em;"):"It's quiet..."
            %+  turn  messages
            |=  [who=@p wen=@da wat=@t]
            ;div.message
              ;div.wen:"{(scow %da (sub wen (mod wen ~d1)))} {(render-time (mod wen ~d1))}"
              ;div.who:"{(scow %p who)}"
              ;div.wat
                ;*  %+  turn  (to-wain:format wat)
                    |=  l=@t
                    ;p:"{(trip l)}"
              ==
            ==
      ==
    ==
  --
--
