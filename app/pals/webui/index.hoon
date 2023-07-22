::  pals index
::
/-  *pals, contact=contacts
/+  rudder, sigil-svg=sigil
::
^-  (page:rudder records command)
::
=>  |%
    +$  role  ?(%all %mutual %target %leeche)
    --
::
|_  [=bowl:gall order:rudder records]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder command)
  =/  args=(map @t @t)
    ?~(body ~ (frisk:rudder q.u.body))
  ?~  what=(~(get by args) 'what')
    ~
  ?~  who=(slaw %p (~(gut by args) 'who' ''))
    'invalid ship name'
  ?:  =(u.who our.bowl)
    'befriend your inner self'
  |^  ?+  u.what  'say what now'
          ?(%meet %part)
        ?:  ?=(%part u.what)
          [%part u.who ~]
        =/  tags  get-lists
        ?~  tags  tag-error
        [%meet u.who u.tags]
      ::
          ?(%enlist %unlist)
        =/  tags  get-lists
        ?~  tags  tag-error
        ?:  =(~ u.tags)  'no-op'
        ?:  ?=(%enlist u.what)
          [%meet u.who u.tags]
        [%part u.who u.tags]
      ==
  ::
  ++  tag-error
    'tags must be in @ta (lowercase & url-safe) format and comma-separated'
  ::
  ++  get-lists
    ^-  (unit (set @ta))
    %+  rush  (~(gut by args) 'lists' '')
    %+  cook
      |=(s=(list @ta) (~(del in (~(gas in *(set @ta)) s)) ''))
    (more (ifix [. .]:(star ace) com) urs:ab)
  --
::
++  final  (alert:rudder url.request build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ::
  =/  rel=role
    =/  a  (~(gas by *(map @t @t)) arg)
    =/  r  (~(gut by a) 'rel' %all)
    ?:(?=(role r) r %all)
  =/  tag=(set @ta)
    %-  sy
    %+  murn  arg
    |=  [k=@t v=@t]
    ?:(=('tag' k) (some v) ~)
  ::
  |^  [%page page]
  ::
  ++  icon-color  "black"
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }

    p { max-width: 50em; }

    form { margin: 0; padding: 0; }

    .red { font-weight: bold; color: #dd2222; }
    .green { font-weight: bold; color: #229922; }

    a {
      display: inline-block;
      color: inherit;
      padding: 0;
      margin-top: 0;
    }

    .class-filter a {
      background-color: #ccc;
      border-radius: 3px;
      padding: 0.1em;
    }

    .class-filter.all .all,
    .class-filter.mutual .mutual,
    .class-filter.target .target,
    .class-filter.leeche .leeche {
      border: 1px solid red;
    }

    .label-filter a {
        background-color: #ddd;
        border-radius: 3px;
        padding: 0.1em;
    }

    .label-filter a.yes {
      border: 1px solid blue;
    }

    .class-filter .all::before,
    .class-filter .mutual::before,
    .class-filter .target::before,
    .class-filter .leeche::before,
    .label-filter a::before {
      content: '☐ '
    }

    .class-filter.all .all::before,
    .class-filter.mutual .mutual::before,
    .class-filter.target .target::before,
    .class-filter.leeche .leeche::before,
    .label-filter a.yes::before {
      content: '☒ '
    }

    table#pals tr td:nth-child(2) {
      padding: 0 0.5em;
    }

    .sigil {
      display: inline-block;
      vertical-align: middle;
      margin: 0 0.5em 0 0;
      padding: 0.2em;
      border-radius: 0.2em;
    }

    .sigil * {
      margin: 0;
      padding: 0;
    }

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
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h2:"%pals manager"

        Keep track of your friends! Other applications can use this list to
        find ships to talk to, pull content from, etc.

        Some applications that are better with pals:
        ;a/"/apps/grid/perma?ext=web+urbitgraph://~holnes/whom/"
          ; ~holnes/whom
        ==
        ; , contact book.
        ;br;
        ;a/"/apps/grid/perma?ext=web+urbitgraph://~paldev/face/"
          ; ~paldev/face
        ==
        ; , book of faces.
        ;br;
        ;a/"/apps/grid/perma?ext=web+urbitgraph://~paldev/rumors/"
          ; ~paldev/rumors
        ==
        ; , gossip mill.

        Tags are there mostly for your own book-keeping. Applications could
        make use of them for grouping content, but should not change their
        core behavior based on the presence or absence of specific tags.

        The status icons below indicate whether the ship is a mutual,
        a target (outgoing only), or a leeche (incoming only).

        ;+  ?~  msg  ;p:""
            ?:  o.u.msg  ::TODO  lightly refactor
              ;p.green:"{(trip t.u.msg)}"
            ;p.red:"{(trip t.u.msg)}"

        ;+  class-selectors
        ;+  label-selectors

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
          ;*  ?:(|(=(%all rel) =(%mutual rel)) (peers %mutual mutuals) ~)
          ;*  ?:(|(=(%all rel) =(%target rel)) (peers %target targets) ~)
          ;*  ?:(|(=(%all rel) =(%leeche rel)) (peers %leeche leeches) ~)
        ==
      ==
    ==
  ::
  ++  slur
    |=  [rel=role tag=(set @ta)]
    ^-  tape
    =-  ['/' 'p' 'a' 'l' 's' -]
    |^  ^-  tape
        ?-  [rel tag]
          [%all ~]  ""
          [* ~]     ['?' 'r' 'e' 'l' '=' (trip rel)]
          [%all *]  ['?' 't' 'a' 'g' '=' tags]
          [* *]     (weld $(tag ~) '&' 't' 'a' 'g' '=' tags)
        ==
    ++  tags  =>  [tag=tag ..zuse]  ~+
              (zing (join "&tag=" (turn ~(tap in tag) trip)))
    --
  ::
  ++  class-selectors
    ^-  manx
    =/  m  (lent mutuals)
    =/  t  (lent targets)
    =/  l  (lent leeches)
    ;div(class "class-filter {(trip rel)}")
      ; filter:
      ;a.all/"{(slur %all tag)}":"all ({(scow %ud :(add m t l))})"
      ;a.mutual/"{(slur %mutual tag)}":"pals ({(scow %ud m)})"
      ;a.target/"{(slur %target tag)}":"targets ({(scow %ud t)})"
      ;a.leeche/"{(slur %leeche tag)}":"leeches ({(scow %ud l)})"
    ==
  ::
  ++  label-selectors
    ^-  manx
    ;div.label-filter  ; labels:
      ;*
      %+  turn
        =-  (sort - aor)
        %~  tap   by
        %+  roll  ~(val by outgoing)
        |=  [l=(set @ta) a=(map @ta @ud)]
        =/  l=(list @ta)  ~(tap in l)
        |-
        ?~  l  a
        $(l t.l, a (~(put by a) i.l +((~(gut by a) i.l 0))))
      |=  [l=@ta n=@ud]
      =/  hav  (~(has in tag) l)
      =.  tag  (?:(hav ~(del in tag) ~(put in tag)) l)
      =/  l  (trip l)
      ?.  hav
        ;a/"{(slur rel tag)}":"{l} ({(scow %ud n)})"
      ;a.yes/"{(slur rel tag)}":"{l} ({(scow %ud n)})"
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
    ::TODO  maybe take acks in pez and do sorting internally?
    |=  [kind=?(%leeche %mutual %target) pez=(list [ship (set @ta)])]
    ^-  (list manx)
    %+  turn  pez
    |=  [=ship lists=(set @ta)]
    ^-  manx
    =/  ack=(unit ?)  (~(get by receipts) ship)
    ;tr
      ;td
        ;+  (status kind ack)
      ==
      ;+  ?:  ?=(%leeche kind)
            ;td
              ;+  (friend-adder ship)
            ==
          ;td
            ;+  (friend-remover ship)
          ==
      ;td
        ;+  (sigil ship)
        ; {(scow %p ship)}
      ==
      ;+  ?:  ?=(%leeche kind)  ;td;
          ;td
            ;+  (list-adder ship)
            ;*  (turn (sort ~(tap in lists) aor) (list-label ship))
          ==
    ==
  ::
  ++  por
    |=  [a=* b=*]
    ?:  ?=(@ a)
      ?>  ?=(@ b)
      (aor (scot %p a) (scot %p b))
    ?>  ?=(@ -.a)
    ?>  ?=([@ *] b)
    (aor (scot %p -.a) (scot %p -.b))
  ::
  ++  mutuals  ~+
    %+  skim  (sort ~(tap by outgoing) por)
    |=  [=ship les=(set @ta)]
    ?&  (~(has in incoming) ship)
    ?|  =(~ tag)
        (~(any in les) ~(has in tag))
    ==  ==
  ::
  ++  targets  ~+
    %+  sort
      %+  skim  ~(tap by outgoing)
      |=  [=ship les=(set @ta)]
      ?&  !(~(has in incoming) ship)
      ?|  =(~ tag)
          (~(any in les) ~(has in tag))
      ==  ==
    |=  [[sa=ship ma=*] [sb=ship mb=*]]
    =+  a=(~(get by receipts) sa)
    =+  b=(~(get by receipts) sb)
    ?:  =(a b)  (por sa sb)
    ?~(a ?=(~ b) ?~(b & |(u.a !u.b)))
  ::
  ++  leeches  ~+
    ?.  =(~ tag)  ~
    %+  murn  (sort ~(tap in incoming) por)
    |=  =ship
    ?:  (~(has by outgoing) ship)  ~
    (some ship ~)
  ::
  ++  contacts  ~+
    ::TODO  but only if permission has been granted
    =/  base=path
      /(scot %p our.bowl)/contacts/(scot %da now.bowl)
    ?.  .^(? %gu (snoc base %$))  *rolodex:contact
    .^(rolodex:contact %gx (weld base /all/noun))
  ::
  ++  sigil
    |=  =ship
    ^-  manx
    =/  bg=@ux
      ?~  p=(~(get by contacts) ship)  0xff.ffff
      ?@  for.u.p                      0xff.ffff
      ?@  con.for.u.p                  0xff.ffff
      color.con.for.u.p
    =/  fg=tape
      ::TODO  move into sigil.hoon or elsewhere?
      =+  avg=(div (roll (rip 3 bg) add) 3)
      ?:((gth avg 0xc1) "black" "white")
    =/  bg=tape
      ((x-co:co 6) bg)
    ;div.sigil(style "background-color: #{bg}; width: 20px; height: 20px;")
      ;img@"/pals/sigil.svg?p={(scow %p ship)}&fg={fg}&bg=%23{bg}&icon&size=20";
    ==
  ::
  ++  status
    |=  [kind=?(%leeche %mutual %target) ack=(unit ?)]
    ::NOTE  making ack more likely to be equal across calls by discarding any
    ::      resolution on it we don't currently use lets ~+ be more effective.
    =.  ack
      ?.  ?=(%target kind)  ~
      `(fall ack |)
    ^-  manx  ~+
    ?-  kind
        %leeche
      ;svg
        =width    "25"
        =height   "25"
        =viewbox  "0 0 100 100"
        =fill     "none"
        =xmlns    "http://www.w3.org/2000/svg"
        ;path
          =d  """
              M95 50
              C95 55.9095 93.836 61.7611 91.5746 67.2208
              C89.3131  72.6804 85.9984 77.6412 81.8198 81.8198
              C77.6412 85.9984 72.6804 89.3131 67.2208 91.5746
              C61.7611 93.836 55.9095 95 50 95
              """
          =stroke  icon-color
          =stroke-width  "10";
        ;path
          =d  """
              M67.2383 68.7383
              L59.7669 40.8545
              L39.3545 61.2669
              L67.2383 68.7383
              Z
              M31.5294 29.4939
              L29.7617 27.7262
              L26.2261 31.2617
              L27.9939 33.0295
              L31.5294 29.4939
              Z
              M53.0962 51.0607
              L31.5294 29.4939
              L27.9939 33.0295
              L49.5607 54.5962
              L53.0962 51.0607
              Z
              """
          =fill  icon-color;
      ==
    ::
        %mutual
      ;svg
        =width    "25"
        =height   "25"
        =viewbox  "13 0 113 100"
        =fill     "none"
        =xmlns    "http://www.w3.org/2000/svg"
        ;path
          =d  """
              M108 50
              C108 61.9348 103.259 73.3807 94.8198 81.8198
              C86.3807 90.2589 74.9347 95 63 95
              C51.0653 95 39.6193 90.2589 31.1802 81.8198
              C22.7411 73.3807 18 61.9347 18 50
              """
          =stroke  icon-color
          =stroke-width  "10";
        ;path
          =d  """
              M87.5114 31.5994
              C87.5114 28.4354 84.9226 25.8466 81.7585 25.8466
              C78.5945 25.8466 76.0057 28.4354 76.0057 31.5994
              C76.0057 34.7635 78.5945 37.3523 81.7585 37.3523
              C84.9226 37.3523 87.5114 34.7635 87.5114 31.5994
              Z
              M51.0767 31.5994
              C51.0767 28.4354 48.4879 25.8466 45.3239 25.8466
              C42.1598 25.8466 39.571 28.4354 39.571 31.5994
              C39.571 34.7635 42.1598 37.3523 45.3239 37.3523
              C48.4879 37.3523 51.0767 34.7635 51.0767 31.5994
              Z
              """
          =fill  icon-color;
      ==
    ::
        %target
      ;svg
        =width    "25"
        =height   "25"
        =viewbox  "0 0 100 100"
        =fill     "none"
        =xmlns    "http://www.w3.org/2000/svg"
        ;path
          =d  """
              M50 95
              C44.0905 95 38.2389 93.836 32.7792 91.5746
              C27.3196 89.3131 22.3588 85.9984 18.1802 81.8198
              C14.0016 77.6412 10.6869 72.6804 8.42542 67.2208
              C6.16396 61.7611 5 55.9095 5 50
              """
          =stroke  icon-color
          =stroke-width  "10";
        ;+  ?:  =([~ &] ack)
          ::  plain arrow
          ;path
            =d  """
                M30.5546 65.9099
                L28.7868 67.6777
                L32.3223 71.2132
                L34.0901 69.4454
                L30.5546 65.9099
                Z
                M67.6777 32.3223
                L39.7938 39.7938
                L60.2062 60.2062
                L67.6777 32.3223
                Z
                M34.0901 69.4454
                L53.5355 50
                L50 46.4645
                L30.5546 65.9099
                L34.0901 69.4454
                Z
                """
            =fill  icon-color;
        ::  dotted arrow
        ;path
          =d  """
              M31.4384 66.7938
              L30.5546 67.6777
              L32.3223 69.4454
              L33.2062 68.5616
              L31.4384 66.7938
              Z
              M67.6777 32.3223
              L53.7357 36.0581
              L63.9419 46.2643
              L67.6777 32.3223
              Z
              M33.2062 68.5616
              L34.974 66.7938
              L33.2062 65.026
              L31.4384 66.7938
              L33.2062 68.5616
              Z
              M38.5095 63.2583
              L42.045 59.7227
              L40.2773 57.955
              L36.7417 61.4905
              L38.5095 63.2583
              Z
              M45.5806 56.1872
              L49.1161 52.6517
              L47.3483 50.8839
              L43.8128 54.4194
              L45.5806 56.1872
              Z
              M52.6516 49.1161
              L56.1872 45.5806
              L54.4194 43.8128
              L50.8839 47.3484
              L52.6516 49.1161
              Z
              M59.7227 42.0451
              L63.2583 38.5095
              L61.4905 36.7418
              L57.9549 40.2773
              L59.7227 42.0451
              Z
              M30.5546 65.9099
              L28.7868 67.6777
              L32.3223 71.2132
              L34.0901 69.4454
              L30.5546 65.9099
              Z
              M67.6777 32.3223
              L39.7938 39.7938
              L60.2062 60.2062
              L67.6777 32.3223
              Z
              M34.0901 69.4454
              L35.8579 67.6777
              L32.3223 64.1421
              L30.5546 65.9099
              L34.0901 69.4454
              Z
              M39.3934 64.1421
              L42.9289 60.6066
              L39.3934 57.0711
              L35.8579 60.6066
              L39.3934 64.1421
              Z
              M46.4645 57.0711
              L50 53.5355
              L46.4645 50
              L42.9289 53.5355
              L46.4645 57.0711
              Z
              M53.5355 50
              L57.0711 46.4645
              L53.5355 42.9289
              L50 46.4645
              L53.5355 50
              Z
              M60.6066 42.9289
              L64.1421 39.3934
              L60.6066 35.8579
              L57.0711 39.3934
              L60.6066 42.9289
              Z
              """
          =fill  icon-color;
      ==
    ==
  --
--
