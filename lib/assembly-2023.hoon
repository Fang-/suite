::  assembly 2023
::
|%
+$  state  state-1
+$  state-1
  $:  %1
      database=(map vid event)
      crowding=(map vid (each (set @p) @ud))  :: %&: host-only
    ::
      calendar=(set vid)
      groupies=[a=(jug @p vid) b=(jug vid @p)]  ::  pals & us
    ::
      messages=(list [who=@p wen=@da wat=@t])
      ruffians=(set @p)
  ==
::
+$  vid  @
+$  event  ::  static event data
  $%  [%main main-event]
      [%week week-event]
  ==
::
+$  main-event
  $:  name=@t
      desc=@t
      full=@t
      when=@da
      long=@dr
      area=?(~ %main %second)
      host=(list @t)
      kind=?(~ %talk %presentation %panel @t)
  ==
::
+$  week-event
  $:  name=@t
      desc=@t
      full=@t
      when=@da
      long=(unit @dr)
      area=look
      show=(unit @t)   ::  img url
      kind=@t
      rsvp=(unit [aid=@t act=@t url=@t])   ::  registration text, call & url
  ==
::
+$  look
  $:  desc=@t
  $=  spot
  %-  unit
  $%  [%url @t]
      [%lot lon=@t lat=@t]
  ==  ==
::
+$  action   from-user
+$  command  to-host
+$  update   from-host
::
+$  from-user
  $%  [%coming =vid yes=?]
      [%advice wat=@t]
  ==
::
+$  from-host
  $%  [%events dab=(each (map vid event) [=vid ven=(unit event)])]
      [%crowds nus=(map vid @ud)]
      [%coming =vid num=@ud]  ::TODO  collate?
    ::
      [%advice vas=(list [who=@p wen=@da wat=@t])]
      [%reject who=@p]
  ==
::
+$  to-host
  $%  [%coming =vid yes=?]
      [%advice wat=@t]
  ==
::
::  datetime wrangling
::
++  dates  ^~
  %-  ~(gas by *(map @da [?(%main %week) @t]))
  :~  ~2023.10.28^[%main 'Assembly day 1']
      ~2023.10.29^[%main 'Assembly day 2']
      ~2023.10.30^[%week 'Urbit Week day 1']
      ~2023.10.31^[%week 'Urbit Week day 2']
      ~2023.11.1^[%week 'Urbit Week day 3']
      ~2023.11.2^[%week 'Urbit Week day 4']
      ~2023.11.3^[%week 'Urbit Week day 5']
  ==
::
++  ut-to-pt
  |=  ut=@da
  ^-  @da
  ?:  (lth ut ~2023.10.29..02.00.00)  ::  dst
    (add ut ~h1)
  ut
::
::  rendering
::
++  events-into-cols
  |=  [dab=(map vid event) vez=(list [=vid wen=@da lon=@dr])]  ::NOTE  vez already sorted
  ^-  [tot=@ud coz=(jar @ud [=vid fro=@da til=@da])]
  =|  tot=@ud
  =|  til=(map @ud @da)
  =|  coz=(jar @ud [=vid fro=@da tol=@da])
  |-
  ?~  vez  [tot (~(run by coz) flop)]
  =*  ven  [vid.i.vez wen.i.vez til=(add wen.i.vez lon.i.vez)]
  ::  main-week events have fixed columns for the three areas
  ::
  =/  vet=main-event
    =+((~(got by dab) vid.i.vez) ?>(?=(%main -<) ->))
  :: ?@  area.vet
  =.  tot  2
  =/  col=@ud
    ?-  area.vet
      ~           0
      %main       1
      %second     2
    ==
  =.  coz  (~(add ja coz) col ven)
  =.  til  (~(put by til) col til.ven)
  $(vez t.vez)
  :: =/  col=@ud  1
  :: ::  for each event, try columns left-to-right
  :: ::
  :: |-
  :: =.  tot  (max tot col)
  :: ::  if there is nothing in this column, put the event in
  :: ::
  :: ?~  las=(~(get by til) col)
  ::   =.  coz  (~(add ja coz) col ven)
  ::   =.  til  (~(put by til) col til.ven)
  ::   ^$(vez t.vez)
  :: ::  if there is something in this column, but it ended, put this event in
  :: ::
  :: ?:  (lte u.las wen.i.vez)
  ::   =.  coz  (~(add ja coz) col ven)
  ::   =.  til  (~(put by til) col til.ven)
  ::   ^$(vez t.vez)
  :: ::  no space, try the next column
  :: ::
  :: $(col +(col))
::
++  build-schedule-week
  |=  $:  [dab=(map vid event) now=@da]
          [day=@da vez=(list [=vid wen=@da lon=(unit @dr)])]
          [our=@p calendar=(set vid) groupies=(jug vid @p)]
      ==
  ^-  manx
  ?:  =(~ vez)
    ;div.schedule(style "text-align: center; margin-top: 2em;"):"nothing happening..."
  ?>  =(%week -:(~(gut by dates) day %week^''))
  ;div.schedule.week
    ;*  %+  turn  vez
    |=  [=vid wen=@da lon=(unit @dr)]
    ^-  manx
    =+  ^-  week-event
      =+((~(got by dab) vid) ?>(?=(%week -<) ->))
    =/  time=tape
      ?:  =(day wen)  "All Day"
      %+  render-range  (sub wen day)
      ?~  lon  ~
      `(sub (add wen u.lon) day)
    ;a.event/"event?id={(scow %uv vid)}"
      ;h5:"{time}"
      ;h4:"{(trip name)}"
      ;p:"{(trip desc)}"
    ::
      ;div.icons
      ;*  =;  l=(list (unit manx))  (murn l same)
          :-  ?.  (~(has in calendar) vid)  ~
              (some ;img.mine@"/assembly/star.svg";)
          =/  pals=@ud
            ~(wyt in (~(del in (~(get ju groupies) vid)) our))
          ?.  (gth pals 0)  ~
          :-  (some ;img.pals@"/assembly/p2p.svg";)
          ?.  (gth pals 1)  ~
          [(some ;span.count:"{(a-co:co pals)}")]~
        ==
    ::
      ;div.kind:"{(trip kind)}"
    ==
  ==
::
::NOTE  list assumed to be already sorted by .wen
++  build-schedule-main
  |=  $:  [dab=(map vid event) now=@da]
          [day=@da vez=(list [=vid wen=@da lon=@dr])]
          [our=@p calendar=(set vid) groupies=(jug vid @p)]
          [skip-first=? demo-day=? prior=?(%schedule %calendar)]
      ==
  ^-  marl
  :: ?>  =(%main -:(~(gut by dates) day %week^''))
  ?:  =(~ vez)
    :_  ~
    ;div.schedule(style "text-align: center; margin-top: 2em;"):"Calm Day..."
  =+  (events-into-cols dab vez)
  =/  ran=[fro=@ud til=@ud]
    :-  (div (sub (max day (sub wen:(snag 0 vez) ~h0)) day) ~h1)
    (div (sub (min (add day ~d1) (add =+((rear vez) (add wen lon)) ~h1)) day) ~h1)
  =+  dif=(sub til.ran fro.ran)
  =+  ros=(mul dif 12)  ::  row for every ~m5
  =+  off=(mul fro.ran 12)  :: missing rows
  %+  snoc  (main-labels day)
  =/  style=tape
    ?.  skip-first
      """
      grid-template-rows: repeat({(a-co:co ros)}, 5.5vh);
      grid-template-columns: 1em repeat({(a-co:co tot)}, 1fr);
      """
    """
    grid-template-rows: repeat({(a-co:co 12)}, 0.4em) repeat({(a-co:co (sub ros 12))}, 5.5vh);
    grid-template-columns: 1em repeat({(a-co:co tot)}, 1fr);
    """
  ;div.schedule.main(style style)
    ;*  (grid-times fro.ran til.ran)
    ;*  (grid-lines dif)
    ;*  ::  if today, add time indicator
        ::
        =+  fro=(add day (mul ~h1 fro.ran))
        =+  til=(add day (mul ~h1 til.ran))
        ?.  &((gth now fro) (lth now til))  ~
        :: ?:  &(skip-first (lth now (add fro ~h1)))
        ::   ::  registration
        ::   :: =+
        ::   :: ;div.now(style "top: calc(4.8em + {(scow %ud pec)}%);");
        ::   ~
        =+  row=+((div (sub now fro) ~m5))
        =+  pec=(div (mul 100 (mod now ~m5)) ~m5)
        :_  ~
        ;div#now.now(style "grid-row: {(a-co:co row)};");
        :: =+  dif=(sub til fro)
        :: =+  pec=(div (mul 100.000 (sub now (add fro ~h1))) dif)
        :: :_  ~
        :: ;div.now(style "top: calc(4.8em + {(scow %ud pec)}%);");
    ;+  =-  ;script:"{^~((trip -))}"
        '''
        const line = document.getElementById('now');
        if (line) {
          const start = Date.now() - (Date.now() % 300000);
          const first = parseInt(line.style['grid-row']);
          let upd = () => {
            const now = Date.now();
            const dif = Math.floor((now - start) / 300000);
            line.style['grid-row'] = first + dif;
            setTimeout(upd, 60000);
          }
          setTimeout(upd, 60000);
        }
        '''
    ;*  ^-  marl
        %-  zing
        %+  turn  (sort ~(tap by coz) aor)
        |=  [col=@ud vez=(list [=vid fro=@da til=@da])]
        =?  col  !=(0 col)  +(col)
        %+  turn  vez
        |=  [=vid fro=@da til=@da]
        =+  =+((~(got by dab) vid) ?>(?=(%main -<) ->))
        =.  til  (min til (add day ~d1))
        =/  s  (sub +((div (sub fro day) ~m5)) off)
        =/  e  (sub +((div (sub til day) ~m5)) off)
        =/  class=tape
          ?:  |(=('d001' vid) =('d002' vid))
            "event break"
          ?+  col  !!
            %0  "event break"
            %2  "event main"
            %3  "event second"
          ==
        =/  special=?  |(demo-day =(0 col))
        ;a(class class)
            =href  ?:(special "#" "event?id={(scow %uv vid)}&prior={(trip prior)}")
            =onclick  ?:(special "return false;" "")
            =style
          """
          {?:(special "cursor: default;" "")}
          grid-column: {?:(=(0 col) "2 / 4" (a-co:co col))};
          grid-row: {(a-co:co s)} / {(a-co:co e)};
          """
          ;div.start
            ;b.time:"{(render-range (sub fro day) `(sub til day))}"
            ;h4:"{(trip name)}"
            ;*  ?+  kind  ~[;div.kind:"{(trip kind)}"]
                  ~  ~
                  %talk          ~[;div.kind.talk:"talk"]
                  %panel         ~[;div.kind.panel:"panel"]
                  %presentation  ~[;div.kind.presentation:"presentation"]
                ==
            ;+  =+  max=(mul 12 (sub e (min (add s 1) (dec e))))
                =?  max  demo-day  (mul 2 max)
                ?:  (lth (met 3 desc) max)
                  ;p:"{(trip desc)}"
                ;p:"{(trip (end 3^max desc))}..."
          ==
          ;div.icons
            ;*  =;  l=(list (unit manx))  (murn l same)
                :-  ?.  (~(has in calendar) vid)  ~
                    (some ;img.mine@"/assembly/star.svg";)
                =/  pals=@ud
                  ~(wyt in (~(del in (~(get ju groupies) vid)) our))
                ?.  (gth pals 0)  ~
                :-  (some ;img.pals@"/assembly/p2p.svg";)
                ?.  (gth pals 1)  ~
                [(some ;span.count:"{(a-co:co pals)}")]~
          ==
          ;div.end:"ends at {(render-time (sub til day))}"
        ==
  ==
::
++  top-nav
  |=  [let=(unit [t=@t u=@t]) mid=(unit [t=@t u=@t]) ryt=(unit [t=@t u=@t])]
  ^-  manx
  ;nav
    ;*  ?~  let  ~
        :_  ~
        ;a.left/"{(trip u.u.let)}":"{(trip t.u.let)}"
    ;*  ?~  mid  ~
        :_  ~
        ;a.middle/"{(trip u.u.mid)}":"{(trip t.u.mid)}"
    ;*  ?~  ryt  ~
        :_  ~
        ;a.right/"{(trip u.u.ryt)}":"{(trip t.u.ryt)}"
  ==
::
++  cal-nav
  |=  day=@da
  ^-  manx
  =/  let=(unit [@t @t])
    ?.  (~(has by dates) (sub day ~d1))  ~
    `['← Previous' (cat 3 '?day=' (scot %da (sub day ~d1)))]
  =/  ryt=(unit [@t @t])
    ?.  (~(has by dates) (add day ~d1))  ~
    `['Next →' (cat 3 '?day=' (scot %da (add day ~d1)))]
  (top-nav let `['↑ Home' '/assembly'] ryt)
::
++  cal-head
  |=  day=@da
  ;div.title
    ;h2:"{(trip +:(~(got by dates) day))}"
    ;h3:"{(scow %da day)}"
  ==
::
++  render-time
  |=  t=@dr
  "{((d-co:co 2) (div t ~h1))}:{((d-co:co 2) (div (mod t ~h1) ~m1))}"
::
++  render-range
  |=  [fro=@dr til=(unit @dr)]
  ^-  tape
  ?:  =([~h0 ~] [fro til])  "all day"
  ?~  til  "{(render-time fro)} ->"
  "{(render-time fro)} - {(render-time u.til)}"
::
++  head
  |=  title=@t
  ^-  manx
  ;head
    ;title:"{(trip title)}"
    ;meta(charset "utf-8");
    ;meta(name "viewport", content "width=device-width, initial-scale=1");
    ;link(rel "manifest", href "/assembly/manifest.json", crossorigin "use-credentials");
    ;link(rel "icon", type "image/png", sizes "any", href "https://pal.dev/props/assembly/tile.png");
    ;link(rel "stylesheet", type "text/css", href "/assembly/style.css");
  ==
::
++  main-labels
  |=  day=@da
  ^-  marl
  %+  turn
    :~  [1 "Galaxy Stage" "label main"]
        [2 "Star Stage" "label second"]
    ==
  |=  [col=@ud nom=tape cas=tape]
  ;div(class cas, style "grid-column: {(a-co:co +(col))}")
    ;div:"{nom}"
  ==
::
++  grid-times
  |=  [fro=@ud til=@ud]
  ^~  ^-  marl
  %+  turn  (gulf fro (dec til))
  |=  h=@ud
  ^-  manx
  ;div.time(style "grid-row: {(a-co:co +((mul (sub h fro) 12)))};"):"{((d-co:co 2) h)}:00"
::
++  grid-lines
  |=  dif=@ud
  ^~  ^-  marl
  %+  turn  (gulf 0 dif)
  |=  a=@ud
  ^-  manx
  ;div.line(style "grid-row: {(a-co:co +((mul a 12)))};");
::
--
