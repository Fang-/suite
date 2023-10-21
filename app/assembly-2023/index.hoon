::  assembly-2023: homepage
::
::TODO  crib style from https://assembly.urbit.org/schedule/urbit-week
::TODO  pages
::  - full schedule
::    - if no date specified, load today, bounded to earliest or latest date at which there are events
::    - render "today", "tomorow", "yesterday" headers, but always subtitle with date
::    - show mutual icon/count if any
::    - show star icon if attending
::  - my schedule
::  - event page w/ deets & buttons
::  - todo event search?
::
/+  *assembly-2023, rudder, pals
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
  |^  [%page page]
  ::
  ++  page
    ^-  manx
    ;html
      ;+  (head 'Assembly 2023')
      ;body.index
        ;header
          ;h1:"Assembly Lisboa"
        ==
        ;a/"/assembly-2023/schedule"
          ;div.grid;
          ; All Events
        ==
        ;a/"/assembly-2023/calendar"
          ;div.mine;
          ; My Schedule
        ==
        ;a/"/assembly-2023/messages"
          ;div.bulb;
          ; Community Kiosk
        ==
        :: ::TODO  re-enable..
        :: :: ;*  ?.  .^(? %gu /(scot %p our)/pals/(scot %da now)/$)  ~
        :: ::   :_  ~
        :: ;a/"/assembly-2023/groupies"
        ::   ;div.pals@"/assembly-2023/p2p.svg";
        ::   ; Pals
        :: ==
      ==
    ::
      ;svg
          =viewBox  "0 0 397 198"
          =fill  "none"
          =xmlns  "http://www.w3.org/2000/svg"
          =style  "position: absolute; height: 1em; bottom: 0.2em; right: 0.2em; opacity: 0.1;"
        ;path
          =d  "M137.58 57.6511C101.874 22.489 53.1361 0.5 0 0.5C0 53.9595 21.9704 102.564 57 138.119L137.58 57.6511Z"
          =fill  "var(--black)";
        ;path
          =d  "M130 70L140 60C148.5 68 161 84.5 165.5 92C160.5 90.5 142.5 82.5 130 70Z"
          =fill  "var(--black)";
        ;path
          =d  "M95 105L128 72C142 84 153 92 168 96C175.5 107.5 185.5 129 190 147C151.5 144.5 120.5 129 95 105Z"
          =fill  "var(--black)";
        ;path
          =d  "M59.5 140.5C59.5 140.5 81.5 118.333 92.5 107.5C117 131 148.5 148 191 150.5C191 150.5 197 178 197 197.5C129.5 195.5 89 168 59.5 140.5Z"
          =fill  "var(--black)";
        ;path
          =d  "M247.5 0.5H200V197.5H247.5V0.5Z"
          =fill  "var(--black)";
        ;path
          =fill-rule  "evenodd"
          =clip-rule  "evenodd"
          =d  "M298 0.5H251V197.5H298C315 197.5 333 193 347.5 184.5V13.5C334 5.5 316.5 0.5 298 0.5ZM298.5 114.5C307.06 114.5 314 107.56 314 99C314 90.4396 307.06 83.5 298.5 83.5C289.94 83.5 283 90.4396 283 99C283 107.56 289.94 114.5 298.5 114.5Z"
          =fill  "var(--black)";
        ;path
          =d  "M351 15.5C410.5 54 414 141 351 182.5V15.5Z"
          =fill  "var(--black)";
      ==
    ==
  ::
  --
--