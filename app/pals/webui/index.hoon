::  pals index
::
/-  *pals
::
^-  webpage
|_  records
++  argue
  |=  arg=(list [k=@t v=@t])
  ^-  (unit command)  ::TODO  maybe (each command @t) for error messages?
  =+  args=(~(gas by *(map @t @t)) arg)
  ::TODO  alternatively we should just crash on invalid args,
  ::      since ui shouldn't allow it without user meddling?
  ::      poorly constructed commands here might crash anyway.
  ?~  what=(~(get by args) 'what')
    ~
  ?~  who=(slaw %p (~(gut by args) 'who' ''))
    ~
  |^  ?+  u.what  ~
          ?(%meet %part)
        %-  some
        ?:  ?=(%part u.what)
          [%part u.who ~]
        [%meet u.who get-lists]
      ::
          ?(%enlist %unlist)
        =/  tags=(set @ta)  get-lists
        ?:  =(~ tags)  ~
        %-  some
        ?:  ?=(%enlist u.what)
          [%meet u.who tags]
        [%part u.who tags]
      ==
  ::
  ++  get-lists
    ^-  (set @ta)
    =-  (fall - ~)
    %+  rush  (~(gut by args) 'lists' '')
    %+  cook
      |=(s=(list @ta) (~(del in (~(gas in *(set @ta)) s)) ''))
    (more (ifix [. .]:(star ace) com) urs:ab)
  --
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  manx
  |^  page
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }

    form { margin: 0; padding: 0; }

    .red { font-weight: bold; color: #dd2222; }
    .green { font-weight: bold; color: #229922; }

    table#pals tr td:nth-child(2) {
      padding: 0 0.5em;
    }

    .status {
      height: 10px;
      width: 10px;
      border-radius: 50%;
      border: 2px dashed black;
    }

    .status.ack    { border: 2px solid black; }
    .status.nack   { border: 2px dashed red; }

    .status.leeche {
      background-color: black;
      border: 2px solid white !important;
    }
    .status.mutual { background-color: green; }
    .status.target { background-color: #ccc; }

    .label {
      display: inline-block;
      background-color: #ccc;
      border-radius: 3px;
      margin-right: 0.5em;
      padding: 0.1em;
    }
    .label input[type="text"] {
      max-width: 100px;
    }
    .label span {
      margin: 0 0 0 0.2em;
    }

    button {
      padding: 0.2em 0.5em;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%pals"
        ;meta(charset "utf-8");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h2:"%pals manager"
        ;+  ?~  msg  ;p:""
            ?:  o.u.msg  ::TODO  lightly refactor
              ;p.green:"{(trip t.u.msg)}"
            ;p.red:"{(trip t.u.msg)}"
        ;table#pals
          ;form(method "post")
            ;tr(style "font-weight: bold")
              ;td:""
              ;td:""
              ;td:"@p"
              ;td:"tags"
            ==
            ;tr
              ;td:""
              ;td
                ;button(type "submit", name "what", value "meet"):"+"
              ==
              ;td
                ;input(type "text", name "who", placeholder "~sampel");
              ==
              ;td.label
                ;input(type "text", name "lists", placeholder "some, tags");
              ==
            ==
          ==
          ;*  mutuals
          ;*  targets
          ;*  leeches
        ==
      ==
    ==
  ::
  ++  list-label
    |=  =ship
    |=  name=@ta
    ^-  manx
    ;form.label(method "post")
      ;span:"{(trip name)}"
      ;input(type "hidden", name "who", value "{(scow %p ship)}");
      ;input(type "hidden", name "lists", value "{(trip name)}");
      ;button(type "submit", name "what", value "unlist"):"x"
    ==
  ::
  ++  list-adder
    |=  =ship
    ^-  manx
    ;form.label(method "post")
      ;input(type "text", name "lists", placeholder "some, tags");
      ;input(type "hidden", name "who", value "{(scow %p ship)}");
      ;input(type "hidden", name "what", value "enlist");
    ==
  ::
  ++  friend-adder
    |=  =ship
    ^-  manx
    ;form(method "post")
      ;input(type "hidden", name "who", value "{(scow %p ship)}");
      ;button(type "submit", name "what", value "meet"):"+"
    ==
  ::
  ++  friend-remover
    |=  =ship
    ^-  manx
    ;form(method "post")
      ;input(type "hidden", name "who", value "{(scow %p ship)}");
      ;button(type "submit", name "what", value "part"):"-"
    ==
  ::
  ++  peers
    |=  [kind=?(%leeche %mutual %target) pez=(list [ship (set @ta)])]
    ^-  (list manx)
    %+  turn  (sort pez dor)
    |=  [=ship lists=(set @ta)]
    ^-  manx
    =/  ack=(unit ?)  (~(get by receipts) ship)
    ;tr
      ;td
        ;div(class "status {(trip kind)} {?+(ack "" [~ %&] "ack", [~ %|] "nack")}");
      ==
      ;+  ?:  ?=(%leeche kind)
            ;td
              ;+  (friend-adder ship)
            ==
          ;td
            ;+  (friend-remover ship)
          ==
      ;td:"{(scow %p ship)}"
      ;+  ?:  ?=(%leeche kind)  ;td;
          ;td
            ;+  (list-adder ship)
            ;*  (turn (sort ~(tap in lists) aor) (list-label ship))
          ==
    ==
  ::
  ++  mutuals
    ^-  (list manx)
    %+  peers  %mutual
    %+  skim  ~(tap by outgoing)
    |=  [=ship *]
    (~(has in incoming) ship)
  ::
  ++  targets
    ^-  (list manx)
    %+  peers  %target
    %+  skip  ~(tap by outgoing)
    |=  [=ship *]
    (~(has in incoming) ship)
  ::
  ++  leeches
    ^-  (list manx)
    %+  peers  %leeche
    %+  murn  ~(tap in incoming)
    |=  =ship
    ?:  (~(has by outgoing) ship)  ~
    (some ship ~)
  --
--
