::  assembly 2023
::
|%
+$  state  state-0
+$  state-0
  $:  %0
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
      kind=?(~ %talk %presentation %panel)
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
      [%enlist =vid yes=?]
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
    (sub ut ~h1)
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
          :~  ?.  (~(has in calendar) vid)  ~
              (some ;div.mine;)
            ::
              ?:  =(~ (~(del in (~(get ju groupies) vid)) our))  ~
              (some ;div.pals;)
          ==
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
      ==
  ^-  manx
  ?>  =(%main -:(~(gut by dates) day %week^''))
  ?:  =(~ vez)
    ;div.schedule(style "text-align: center; margin-top: 2em;"):"Calm Day..."
  =+  (events-into-cols dab vez)
  =/  ran=[fro=@ud til=@ud]
    :-  (div (sub (max day (sub wen:(snag 0 vez) ~h1)) day) ~h1)
    (div (sub (min (add day ~d1) (add =+((rear vez) (add wen lon)) ~h1)) day) ~h1)
  =+  dif=(sub til.ran fro.ran)
  =+  ros=(mul dif 12)  ::  row for every ~m5
  =+  off=(mul fro.ran 12)  :: missing rows
  ;div.schedule.main
      =style
    """
    grid-template-rows: repeat({(a-co:co ros)}, 5.5vh);
    grid-template-columns: 1em repeat({(a-co:co tot)}, 1fr);
    """
    ;*  (main-labels day)
    ;*  (grid-times fro.ran til.ran)
    ;*  (grid-lines dif)
    ;*  ::  if today, add time indicator
        ::
        ::TODO  update me with javascript too!
        =+  fro=(add day (mul ~h1 fro.ran))
        =+  til=(add day (mul ~h1 til.ran))
        ?.  &((gth now fro) (lth now til))  ~
        =+  dif=(sub til fro)
        =+  pec=(div (mul 100 (sub now fro)) dif)
        :_  ~
        ;div.now(style "top: {(a-co:co pec)}%;");
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
          ?+  col  !!
            %0  "event break"
            %2  "event main"
            %3  "event second"
          ==
        ;a(class class)
            =href  ?:(=(0 col) "#" "event?id={(scow %uv vid)}")
            =style
          """
          grid-column: {?:(=(0 col) "2 / 4" (a-co:co col))};
          grid-row: {(a-co:co s)} / {(a-co:co e)};
          """
          ;div.start
            ;b.time:"{(render-range (sub fro day) `(sub til day))}"
            ;h4:"{(trip name)}"
            ;*  ?-  kind
                  ~  ~
                  %talk          ~[;div.kind.talk:"talk"]
                  %panel         ~[;div.kind.panel:"panel"]
                  %presentation  ~[;div.kind.presentation:"presentation"]
                ==
            ;+  ?:  (lth (met 3 desc) 64)
                  ;p:"{(trip desc)}"
                ;p:"{(trip (end 3^64 desc))}..."
          ==
          ;div.icons
            ;*  =;  l=(list (unit manx))  (murn l same)
                :~  ?.  (~(has in calendar) vid)  ~
                    (some ;div.mine;)
                  ::
                    ?:  =(~ (~(del in (~(get ju groupies) vid)) our))  ~
                    (some ;div.pals;)
                ==
          ==
          ;div.end:"ends at {(render-time (sub til day))}"
        ==
  ==
::
++  cal-nav
  |=  [now=@da day=@da]
  ^-  manx
  ?.  (~(has by dates) day)  ;nav:"it's so over..."
  ::TODO  just date instead if no entry
  ;nav
    ;*  ?.  (~(has by dates) (sub day ~d1))  ~
        :_  ~
        ;a.left/"?day={(scow %da (sub day ~d1))}"
          ;span:"<"
        ==
    ::TODO  maybe icon
    ;a.title/"/assembly-2023"
      ;h2:"{(trip +:(~(got by dates) day))}"
      ;h3:"{(scow %da day)}"
    ==
    ;*  ?.  (~(has by dates) (add day ~d1))  ~
        :_  ~
        ;a.right/"?day={(scow %da (add day ~d1))}"
          ;span:">"
        ==
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
    ;link(rel "stylesheet", type "text/css", href "/assembly-2023/style.css");
  ==
::
++  main-labels
  |=  day=@da
  ^-  marl
  ?.  =(%main -:(~(gut by dates) day %week^''))  ~
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