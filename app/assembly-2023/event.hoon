::  assembly-2023: event page
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
  =/  vid=@  (slav %uv (~(got by args) 'vid'))
  ?:  (~(has by args) 'save')     [%coming vid &]
  ?:  (~(has by args) 'unsave')   [%coming vid |]
  !!
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
  :: ?>  ?=(~ msg)
  =/  args=(map @t @t)  (~(gas by *(map @t @t)) arg)
  =/  vid=@  (fall (slaw %uv (~(gut by args) 'id' '')) 0v0)
  ?~  vet=(~(get by database) vid)
    [%move '.']
  =,  u.vet
  :-  %page
  ^-  manx
  ;html
    ;+  (head (cat 3 'Assembly 2023: ' name))
    ;body
      ;nav
        ;a.left/"#"(onclick "window.history.back();"):"← Back"
        ;a.middle/"/assembly":"↑ Home"
      ==
      ;article.event
        ;h2:"{(trip name)}"
        ;table
          ;tr
            ;td:"When?"
            ;+  =/  tim=tape
                  %+  render-range  (mod when ~d1)
                  ?-  -.u.vet
                    %main  `(add (mod when ~d1) long)
                    %week  ?~  long.u.vet  ~
                           `(add (mod when ~d1) u.long)
                  ==
                ;td:"{(scow %da (sub when (mod when ~d1)))} {tim}"
          ==
          ;*  ?.  &(?=(%main -.u.vet) !=(~ host.u.vet))  ~
              :_  ~
              =/  who=tape
                %+  roll  host.u.vet
                |=  [w=cord t=tape]
                ?:  =("" t)  (trip w)
                "{t}, {(trip w)}"
              ;tr
                ;td:"Who?"
                ;td:"{who}"
              ==
          ;tr
            ;td:"Where?"
            ;+  ?-  -.u.vet
                    %main
                  ?-  area.u.vet
                    ~           ;td:"~"
                    %main       ;td:"Galaxy Stage"
                    %second     ;td:"Star Stage"
                  ==
                ::
                    %week
                  ;td:"{(trip desc.area)}"  ::TODO  mb url/lot
                ==
          ==
          ;*  ?.  &(?=(%week -.u.vet) ?=(^ rsvp.u.vet))  ~
              =;  l=(list (unit manx))  (murn l same)
              :~  ?:  =('' aid.u.rsvp)  ~
                  %-  some
                  ;tr.rsvp.aid
                    ;td;
                    ;td:"{(trip aid.u.rsvp)}"
                  ==
                ::
                  ?:  =('' url.u.rsvp)  ~
                  %-  some
                  ;tr.rsvp.act
                    ;td:"RSVP"
                    ;td
                      ;a/"{(trip url.u.rsvp)}":"{(trip act.u.rsvp)}"
                    ==
                  ==
              ==
          ;*  =/  pals=(list @p)
                %~  tap  in
                (~(del in (~(get ju b.groupies) vid)) our)
              =/  others=(unit tape)
                =/  num=@ud
                  =+  (~(gut by crowding) vid |+0)
                  ?-(-< %& ~(wyt in `(set)`->), %| ->)
                =?  num  &(!=(0 num) (~(has ju b.groupies) vid our))
                  (dec num)
                ?:  =(~ pals)
                  ?:  =(0 num)  ~
                  `"{(a-co:co num)} others"
                =-  `(weld - " and {(a-co:co (sub num (min num (lent pals))))} others")
                %+  roll  pals
                |=  [p=@p t=tape]
                ?:  =("" t)  (cite:title p)
                "{t}, {(cite:title p)}"
              ?~  others  ~
              :_  ~
              ;tr(style "{?:(=(~ pals) "" "color: var(--green);")}")
                ;td:"With?"
                ;td:"{u.others} are going"
              ==
          ::TODO  add icons as status indicators?
          ;tr
            ;td:"Save"
            ;td
              ;+  ?:  (~(has in calendar) vid)
                    ;form.no(method "post")
                      ; This is on your personal schedule.
                      ;input(type "hidden", name "vid", value "{(scow %uv vid)}");
                      ;button(type "submit", name "unsave"):"Remove"
                    ==
                  ;form.yes(method "post")
                    ; Add this to your personal schedule:
                    ;input(type "hidden", name "vid", value "{(scow %uv vid)}");
                    ;button(type "submit", name "save"):"Save"
                  ==
            ==
          ==
        ==
        ;*  ?.  &(?=(%week -.u.vet) ?=(^ show.u.vet))  ~
            :_  ~
            ;img@"{(trip u.show)}";
        ;p:"{(trip desc)}"
        ;*  %+  murn  (to-wain:format full)
            |=  p=@t
            ?:  =('' p)  ~
            (some ;p:"{(trip p)}")
      ==
    ==
  ==
--