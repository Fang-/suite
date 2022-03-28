::  inet/index: browse the library
::
::    (for the shocked bystander: yes, there's some ugly code here.
::     we are very much in "event running mode", not in "architecture mode".
::     if it works, it works!)
::
/-  *inet
/+  rudder, bbcode, *pal
::
^-  (page:rudder state action)
|_  [bowl:gall =order:rudder state]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  ?~  body  ~
  =/  args=(map @t @t)
    (frisk:rudder q.u.body)
  ?:  (~(has by args) 'save')
    ?~  id=(biff (~(get by args) 'i') (curr rush dum:ag))  ~
    ?~  content=(~(get by args) 'content')  ~
    ?:  =('' u.content)  'Clippy has no time for your games.'
    =/  sprout=(unit @ud)
      %+  sink  (biff (~(get by args) 'p') (curr rush dum:ag))
      (bind (~(get by library) [our u.id]) |=(story sprout))
    ?~  sprout  'Clippy doesn\'t know where to save this to...'
    [%add u.id u.sprout now u.content]
  ?:  (~(has by args) 'show')
    [%pre ~]
  ?:  (~(has by args) 'nuke')
    ?~  id=(biff (~(get by args) 'i') (curr rush dum:ag))  ~
    [%del u.id]
  ?:  (~(has by args) 'like')
    ?~  at=(biff (~(get by args) 'a') (curr rush ;~(pfix sig fed:ag)))  ~
    ?~  id=(biff (~(get by args) 'i') (curr rush dum:ag))  ~
    [%luv [u.at u.id]]
  ~
::
::  +final: if we asked to preview content, do so
++  final
  |=  [done=? =brief:rudder]
  ^-  reply:rudder
  =/  args=(map @t @t)
    ?~  body.request.order  ~
    (frisk:rudder q.u.body.request.order)
  =/  show=(unit @t)
    ?~  body.request.order  ~
    ?.  (~(has by args) 'show')  ~
    (~(get by args) 'content')
  ::TODO  would honestly be really nice if the action was passed...
  ?:  &(done |((~(has by args) 'save') (~(has by args) 'like')))
    =;  url  [%next (crip url) brief]
    =;  who  "/invisible-networks?a={who}&i={(trip (~(got by args) 'i'))}"
    ?:((~(has by args) 'save') (scow %p our) (trip (~(got by args) 'a')))
  ?:  &(done (~(has by args) 'nuke'))
    [%next '/invisible-networks' brief]
  %+  build
    =-  ?~(show - ['content'^u.show -])
    args:(purse:rudder url.request.order)
  ?~(brief ~ `[| brief])
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  ^-  reply:rudder
  =/  day=@ud  ?:((gth start now) 0 (div (sub now start) ~d1))
  =/  sprouts  (scag +(day) sprouts)
  ::
  =/  args=(map @t @t)    (my `(list (pair @t @t))`args)
  =/  author=(unit @p)    (biff (~(get by args) 'a') (cury slaw %p))
  =/  id=(unit @)         (biff (~(get by args) 'i') (cury slaw %ud))
  =/  index=(unit index)  (both author id)
  =/  sprout=(unit @ud)   (biff (~(get by args) 'p') (cury slaw %ud))
  =/  alter=?             ?&  |(?=(^ sprout) ?=(^ index))
                              =(our (fall author our))
                              (~(has by args) 'e')
                          ==
  ::
  ~|  [index=index id=id author=author sprout=sprout alter=alter]
  =?  sprout  &(?=(^ sprout) !=(0 u.sprout))  `(dec u.sprout)
  =?  sprout  &(?=(^ sprout) (gte u.sprout (lent sprouts)))  ~
  ::  default to showing the "daily" prompt, rolling over after event ends
  ::
  =?  sprout  &(=(~ author) =(~ sprout))
    ?:  =(~ sprouts)  ~
    ?:  (gth start now)  ~
    `(mod day (lent sprouts))
  ::
  =/  format
    ?:  alter   %pencil
    ?^  index   %single
    ?^  sprout  %sprout
    ?^  author  %author
    %biding
  ~|  format=format
  |^  [%page page]
  ::
  ++  style
    '''
    * {
      font-family: Pixelated MS Sans Serif, MS Sans Serif, Microsoft Sans Serif, Arial, Helvetica, sans-serif;
      -webkit-font-smoothing: antialiased;
    }
    ::selection {
      background: #fa2;
    }
    a {
      color: inherit;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    html {
      height: 100%;
      background-image: url('https://pal.dev/props/inet2022/blissed.jpg');
      background-size: cover;
      background-attachment: fixed;
    }
    body {
      padding: 0 1em;
    }
    ul, ol {
      margin: 0;
    }
    blockquote {
      margin: 0;
      padding: 0.5em 1em;
      border-left: 2px dotted black;
    }
    blockquote > .author {
      display: block;
      position: relative;
      top: -0.5em; left: -0.5em;
    }
    blockquote > .author::after {
      content: ' said:'
    }
    code {
      display: inline-block;
      vertical-align: middle;
      white-space: pre;
      font-family: Courier, monospace;
      padding: 0.5em;
      background-color: rgba(0,0,0,0.1);
    }

    #wrapper {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      margin: 1em auto;
      padding: 3px;
      max-width: 1500px;
      /* box-shadow: inset -1px -1px #00138c,inset 1px 1px #0831d9,inset -2px -2px #001ea0,inset 2px 2px #166aee,inset -3px -3px #003bda,inset 3px 3px #0855dd; */
      /* box-shadow: inset -1px -1px #00aacc,inset 1px 1px #02aaee,inset -2px -2px #0099dd,inset 2px 2px #02dcdf,inset -3px -3px #0099ee,inset 3px 3px #02bbff; */
      /* box-shadow: inset -1px -1px #0053af,inset 1px 1px #0871eb,inset -2px -2px #0065b5,inset 2px 2px #16bafe,inset -3px -3px #0082ed,inset 3px 3px #08a5ef; */
      box-shadow: inset -1px -1px #c29562,inset 1px 1px #e8af6a,inset -2px -2px #e8af6a,inset 2px 2px #e8af6a,inset -3px -3px #e8af6a,inset 3px 3px #e8af6a;
      border-radius: 0.5em 0.5em 0 0;
    }

    #wrapper > h1 {
      margin: 0;
      margin-top: -2px;
      padding: 0.5em;
      width: 100%;
      font-size: 1.2em;
      /* background: linear-gradient(180deg,#00aacc,#02aaee 8%,#0099dd 40%,#02dcdf 88%,#02dcdf 93%,#0099ee 95%,#02bbff 96%,#02bbff); */
      /* background: linear-gradient(180deg,#09d7ff,#0083ee 8%,#0090ee 40%,#0af 88%,#0af 93%,#009bff 95%,#006dd7 96%,#006dd7); */
      background: linear-gradient(180deg,#e89f6a,#db9368 8%,#eaa16c 40%,#f59f6f 88%,#f59f6f 93%,#f4a76e 95%,#eaa86b 96%,#eaa86b);
      border-radius: 0.5em 0.2em 0 0;
      color: white;
      text-shadow: 1px 1px #0f1089;
    }
    /*
    <div style="height: 10px; width: 10px; background-color: #0053af;"></div>
    <div style="height: 10px; width: 10px; background-color: #0871eb;"></div>
    <div style="height: 10px; width: 10px; background-color: #0065b5;"></div>
    <div style="height: 10px; width: 10px; background-color: #16bafe;"></div>
    <div style="height: 10px; width: 10px; background-color: #0082ed;"></div>
    <div style="height: 10px; width: 10px; background-color: #08a5ef;"></div>
    --
    <div style="height: 10px; width: 10px; background-color: #09d7ff;"></div>
    <div style="height: 10px; width: 10px; background-color: #0083ee;"></div>
    <div style="height: 10px; width: 10px; background-color: #0090ee;"></div>
    <div style="height: 10px; width: 10px; background-color: #0af;"></div>
    <div style="height: 10px; width: 10px; background-color: #0af;"></div>
    <div style="height: 10px; width: 10px; background-color: #009bff;"></div>
    <div style="height: 10px; width: 10px; background-color: #006dd7;"></div>
    <div style="height: 10px; width: 10px; background-color: #006dd7;"></div>
    */

    .header {
      display: flex;
      flex-direction: row;
      width: 100%;
      background-color: rgb(235,235,220);
      border-top: 2px solid rgba(255,255,255,0.5);
      border-bottom: 2px solid rgba(0,0,0,0.3);
      overflow: scroll;
    }

    .header > div, .header > a {
      padding: 0.5em 0.5em;
      margin: 0 0.2em;
      text-shadow: 1px 1px rgba(255,255,255,0.3);
      white-space: nowrap;
      text-decoration: none !important;
    }

    .header > a:hover {
      background-color: rgba(255,255,255,0.3);
    }

    .header > div {
      filter: grayscale(80%);
      opacity: .6;
    }

    .header summary, .header details {
      display: inline-block;
    }

    .header summary > .icon:hover {
      transform: rotate(80deg);
    }

    .header .icon {
      display: inline-block;
      font-size: 2em;
      margin-right: 0.2em;
      vertical-align: middle;
      transition: transform 0.5s cubic-bezier(0.64, -0.50, 0.67, 1.55);
    }

    .header > hr {
      display: inline;
      margin: 0 0.5em;
      border: none;
      height: 100%;
      width: 1px;
      background-color: rgba(0,0,0,0.3);
      vertical-align: middle;
    }

    .sidebar {
      flex-grow: 1;
      max-width: 25em;
      padding: 1.5em;
      overflow: scroll;
      background: linear-gradient(-40deg, #ffcba1 -5%, #02ccdf 60%, #02fcff);
      background-color: #02ccdf; /* rgb(85,100,205); */
      color: rgb(55,75,95);
    }

    .sidebar > h3 {
      box-sizing: border-box;
      margin: 0;
      padding: 0.5em 1em;
      width: 100%;
      /* background: linear-gradient(to right, rgb(250,255,255) 50%, rgb(205,210,250)); */
      background: linear-gradient(to right, #ffdbb1 50%, #02fcff);
      border-radius: 0.3em 0.3em 0 0;
      font-size: 1em;
      font-weight: bold;
    }

    .sidebar > div {
      margin-bottom: 1.5em;
      padding: 1em;
      background-color: #02fcff; /* rgb(205,210,250); */
      border: 1px solid rgb(250,255,255);
      border-top: none;
    }

    .sidebar > div > a {
      display: block;
      margin-bottom: 0.1em;
    }

    .sidebar > div > form {
      margin: 0; padding: 0;
    }
    .sidebar > div > form > button {
      display: block;
      padding: 0;
      margin-bottom: 0.1em;
      border: none;
      box-shadow: none;
      background: none;
      font-size: inherit;
      color: inherit;
    }
    .sidebar > div > form > button:hover {
      text-decoration: underline;
      cursor: pointer;
    }

    main {
      position: relative;
      flex-basis: 10em;
      flex-grow: 3;
      min-height: 100%;
      padding-bottom: 5em;
      overflow: scroll;
      background-color: white;
      z-index: 0;
    }

    main > h1 {
      margin: 0.5em 1em;
      padding: 0;
      text-align: center;
      font-size: 2em;
      font-weight: bold;
    }

    main hr {
      border: none;
      height: 3px;
      width: 100%;
      margin-top: 0;
      margin-bottom: 1em;
      background: linear-gradient(to right, #ffcba1, white 70%);
    }

    main section a, main .tips a {
      text-decoration: underline;
      color: blue;
    }

    main > img {
      position: absolute;
      right: 0.2em; bottom: 0.2em;
      /* filter: grayscale(100%);
      opacity: .3; */
      z-index: -1;
    }
    main > img.fg {
      filter: none;
      opacity: 1;
    }
    main > .empty {
      color: grey;
      text-align: center;
      margin-top: 2em;
      margin-bottom: 6em;
    }
    main > .tips {
      position: absolute;
      bottom: 1em; right: min(30%, 12em);
      padding: 1em;
      margin-left: 1em;
      max-width: 60%;
      background-color: rgb(245,245,105);
      border-radius: 3px;
      border: 1px solid black;
    }

    article h1, article h2, article h3 {
      display: inline;
      margin: 0.5em 0 0 1em;
      font-size: 1em;
      font-weight: bold;
      text-decoration: none;
    }
    article h1 {
      display: block;
      margin-bottom: 0.2em;
    }

    article > section {
      margin: 0 1em 2em;
    }

    form {
      padding: 2em;
      padding-top: 0;
    }

    .pencil section {
      background-color: rgba(0,0,0,0.05);
      border: 2px dashed #00effe;
      padding: 1em;
    }

    form textarea {
      display: block;
      padding: 0.5em;
      width: 100%;
      height: 15em;
      margin-bottom: 1em;
      font-family: Courier, monospace;
    }

    form button {
      display: inline-block;
      margin: 0 1em 1em 0;
    }

    button {
      border: 1px solid #003c74;
      background: linear-gradient(180deg,#fff,#ecebe5 86%,#d8d0c4);
      border-radius: 3px;
      padding: 0.2em;
      min-width: 8em;
      text-align: center;
    }

    button[name='save'] {
      box-shadow: inset -1px 1px #fff0cf,inset 1px 2px #fdd889,inset -2px 2px #fbc761,inset 2px -2px #e5a01a;
    }

    button:focus {
      box-shadow: inset -1px 1px #cee7ff,inset 1px 2px #98b8ea,inset -2px 2px #bcd4f6,inset 1px -1px #89ade4,inset 2px -2px #89ade4;
    }

    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"Invisible Networks 2022"
        ;style:"{(trip style)}"
        ;meta(charset "utf-8");
        ;meta
          =name     "viewport"
          =content  "width=device-width, initial-scale=1";
      ==
      ;body
        ;div#wrapper
          ;h1:"Invisible Networks 2022"
          ;+  render-toolbar
          ;+  render-sidebar
          ;+  render-content
        ==
      ==
    ==
  ::
  ++  fake-title
    |=  =^index
    ^-  tape
    =/  m=@  (mug index)
    ?+  (mod m 7)  !!
      %0  "📄 0x{((x-co:co 8) m)}.txt"
      %1  "📃 0x{((x-co:co 8) m)}.pdf"
      %3  "🖼 {((d-co:co 10) m)}.ppt"
      %4  "📊 {((d-co:co 10) m)}.xls"
      %2  "📑 {((d-co:co 10) m)}.doc"
      %5  "💾 {(scow %uw m)}.jam"
      %6  "🎵 0x{((x-co:co 8) m)}.mp3.exe"
    ==
  ::
  ++  prompt-title
    |=  sprout=(unit @ud)
    =?  sprout  &(?=(~ sprout) ?=(^ index))
      `sprout:(~(got by library) u.index)
    =;  =tape
      "{tape}.{(trip (snag (need sprout) ^sprouts))}"
    =+  s=(need sprout)
    ?:  (gth s 13)  ((x-co:co 2) (sub s 4))
    (y-co:co +(s))
  ::
  ++  date-format
    ::NOTE  this reimplements +dust:chrono:userlib to be better
    =,  chrono:userlib
    |=  d=@da
    ^-  tape
    =/  yed  (yore d)
    =/  wey  (daws yed)
    =/  num  (d-co:co 1)
    =/  dub  y-co:co
    =/  pik  |=([n=@u t=wall] `tape`(scag 3 (snag n t)))
    ::
    "{(pik wey wik:yu)}, ".
    "{(num d.t.yed)} {(pik (dec m.yed) mon:yu)} {(num y.yed)} ".
    "{(dub h.t.yed)}:{(dub m.t.yed)}:{(dub s.t.yed)}"
  ::
  ::
  ++  link-to-pencil
    |=  where=$@(sprout=@ud ^index)
    ?@  where  (weld (link-to-sprout sprout.where) "&e")
    (weld (link-to-single where) "&e")
  ::
  ++  link-to-single
    |=  ^index
    "/invisible-networks?a={(scow %p author)}&i={(a-co:co id)}"
  ::
  ++  link-to-sprout
    |=  sprout=@ud
    "/invisible-networks?p={(a-co:co +(sprout))}"
  ::
  ++  link-to-author
    |=  author=@p
    "/invisible-networks?a={(scow %p author)}"
  ::
  ++  find-prev-and-next
    |=  [for=^index lis=(list ^index)]  ~+
    ^-  [prev=(unit ^index) next=(unit ^index)]
    ::NOTE  this does way more list traversals than necessary,
    ::      but the lists aren't likely to get very big,
    ::      and this is more legible implementation.
    =/  hit=(unit @)
      (find [for]~ lis)
    ?~  hit  ~&([dap %strange-miss index] [~ ~])
    :_  (snug +(u.hit) lis)
    ?:  =(0 u.hit)  ~
    ^-  (unit ^index)
    (snug (dec u.hit) lis)
  ::
  ::
  ++  render-toolbar  ^-  manx
    =/  [prev=(unit tape) next=(unit tape)]
      ?+  format  [~ ~]
          %sprout
        =/  sprout=@ud  (need sprout)
        :-  ?:(=(0 sprout) ~ `(link-to-sprout (dec sprout)))
        ?:((gte +(sprout) (lent sprouts)) ~ `(link-to-sprout +(sprout)))
      ::
          %single
        =/  =^index  (need index)
        ?.  (~(has by library) index)  [~ ~]
        =-  [(bind prev link-to-single) (bind next link-to-single)]
        %+  find-prev-and-next  index
        (flop (~(get ja volumes) sprout:(~(got by library) index)))
      ==
    =/  up=tape
      ?+  format  "/invisible-networks"
          %single
        ?~  story=(~(get by library) (need index))
          "/invisible-networks"
        (link-to-sprout sprout.u.story)
      ::
          %pencil
        ?~  index  (link-to-sprout (need sprout))
        (link-to-single u.index)
      ==
    ::
    ;nav.header
      ;+  :-  ?~  prev  [%div ~]
              [%a [%href u.prev] ~]
          :~  ;span.icon:"⬅️"
              :/"previous"
          ==
      ;+  :-  ?~  next  [%div ~]
              [%a [%href u.next] ~]
          :~  ;span.icon:"➡️"
              :/"next"
          ==
      ;+  :-  ?~  args  [%div ~]
              [%a [%href "{up}"] ~]
          :~  ;span.icon:"⬆️"
          ==
      ;hr;
      ;div
        ;span.icon:"🔎"
        ; search
      ==
      ;div
        ;span.icon:"📁"
        ; folders
      ==
      ;hr;
      ;div
        ;details
          ;summary  ;span.icon:"🏄‍♀️"  ==
          ; by tocrex-holpen & paldev
        ==
      ==
    ==
  ::
  ++  render-sidebar  ^-  manx
    |^  ;nav.sidebar
          ;*  ?~  msg  ~
              :~  ;h3:"{?:(-.u.msg "Message" "Warning")}"
                  ;div  ;+  :/"‼️ {(trip +.u.msg)}"  ==
              ==
        ::
          ;h3:"System Tasks"
          ;div  ;*  tasks  ==
        ::
          ;h3:"Other Places"
          ;div  ;*  spots  ==
        ::
          ;h3:"Details"
          ;div  ;*  deets  ==
        ==
    ::
    ++  tasks  ^-  marl
      ::  always show at least one "task"
      ::
      =-  ?.  =(~ -)  -
          ;+  ;a/"#":"⏳ Witness the Passage of Time"
      ::  show a button for "like"ing the story if it's not ours
      ::
      =;  tax
        ?.  ?=(%single format)  tax
        =/  =^index  (need index)
        ?:  =(our author.index)  tax
        =/  likes  likes:(~(gut by library) index *story)
        %+  snoc  tax
        =/  count=tape
          =/  c  ~(wyt in likes)
          ?:(=(0 c) "" " ({(a-co:co c)})")
        ?:  (~(has in likes) our)
          :/"💖 Thanked the Author for their Work{count}"
        ;form(method "post")
          ;input(type "hidden", name "i", value "{(a-co:co id.index)}");
          ;input(type "hidden", name "a", value "{(scow %p author.index)}");
          ;button(type "submit", name "like")
            ; 💗 Thank the Author for their Work
            ;+  :/"{count}"
          ==
        ==
      ::  declare sidebar links conveniently
      ::
      =-  ^-  marl
          %+  murn  -
          |=  u=(unit [tape tape])
          (bind u |=([u=tape t=tape] ;a/"{u}":"{t}"))
      :~  =?  sprout  &(?=(~ sprout) ?=(^ index))
            ?~  story=(~(get by library) u.index)  ~
            `sprout.u.story
          ?~  sprout  ~
          %+  some
            (link-to-pencil u.sprout)
          "📄 New Document about this Topic"
        ::
          ?:  ?=(%pencil format)
            %+  some
              ?:  ?&  ?=(^ index)
                      (~(has by library) u.index)
                  ==
                (link-to-single u.index)
              (link-to-sprout (need sprout))
            "❌ Discard Changes"
          ?.  ?&  ?=(^ index)
                  =(our author.u.index)
                  (~(has by library) u.index)
              ==
            ~
          %+  some
            (link-to-pencil u.index)
          "📝 Edit this Document"
      ==
    ::
    ++  spots  ^-  marl
      =-  %+  murn  -
          |=  u=(unit [tape tape])
          (bind u |=([u=tape t=tape] ;a/"{u}":"{t}"))
      =/  story  (biff index ~(get by library))
      :~  ?.  ?=(%single format)  ~
          ?~  story  ~
          %+  some
            (link-to-author author:(need story))
          "👤 More by this Author"
        ::
          ?.  ?=(%single format)  ~
          ?~  story  ~
          %+  some
            (link-to-sprout sprout:(need story))
          "📚 More about this Topic"
        ::
          (some "/invisible-networks" "📅 Topic of the Day")
          (some (link-to-author our) "📁 Your Documents")
      ==
    ::
    ++  deets  ^-  marl
      |-
      ?-  format
          %pencil
        ?:  &(?=(^ index) (~(has by library) u.index))
          $(format %single)
        :~  ;b:"New Document"
            ;br;
            :/"{(prompt-title sprout)}"
        ==
      ::
          %single
        ?:  !(~(has by library) (need index))  [:/"???"]~
        =/  =story  (~(got by library) (need index))
        :*  ;b:"{(fake-title (need index))}"
            ?:(echoed.story :/"" ;span(title "Saving..."):" (⏳)")
            ;br;
            :/"{(prompt-title sprout)}"
            ;br;
            ;br;
            :/"Date Modified: {(date-format date.story)}"
            ;br;
            ?.  &(=(our author.story) !=(~ likes.story))
              :_  ~
              :/"By: {+:(scow %p author.story)}"
            :~  :/"By: You!"
                ;br;
                ;br;
              ::
                =;  t
                  ;span(title t)
                    ;+  :/"Thanked {(a-co:co ~(wyt in likes.story))} time(s)."
                  ==
                %+  roll  ~(tap in likes.story)
                |=  [=@p t=tape]
                ?~  t  "by {(scow %p p)}"
                "{t}, {(scow %p p)}"
            ==
        ==
      ::
          %sprout
        :~  ;b:"{(prompt-title sprout)}"
            ;br;
            ?^  args  :/"Category"
            :/"Category of the day"
            ;br;
            ;br;
            =/  time  (add start (mul ~d1 (need sprout)))
            =/  when  (flop (slag 9 (flop (date-format time))))
            :/"Date Modified: {when}"
        ==
      ::
          %author
        :~  ;b:"{+:(scow %p (need author))}"
            ;br;
            :/"Author"
        ==
      ::
          %biding
        :~  ;b:"Silence"
            ;br;
            :/"Date Modified: {(date-format start)}"
        ==
      ==
    ::
    ++  rend
      |=  all=(list (unit [tape tape]))
      %+  murn  all
      |=  u=(unit [tape tape])
      (bind u |=([u=tape t=tape] ;a/"{u}":"{t}"))
    --
  ::
  ::
  ++  render-content  ^-  manx
    |^  ;main(class "{(trip format)}")
          ;*  ?-  format
                %pencil  render-pencil
                %single  render-single
                %sprout  render-sprout
                %author  render-author
                %biding  render-biding
        ==    ==
    ::
    ++  render-pencil  ^-  marl
      =/  content  (~(get by args) 'content')
      =/  id=@
        %+  fall  id
        =/  nex  (mod eny 900)
        |-
        =/  rid  (add 100 nex)
        ?.  (~(has by library) [our rid])  rid
        $(nex (mod +(nex) 900))
      ^-  marl
      :~
        %+  article  [our id]
        =;  =story
          story(body (fall content ''))
        ?~  sprout  (~(got by library) [our id])
        (~(gut by library) [our id] [our & ~ u.sprout now ''])
      ::
        ^-  manx
        ;form(method "post", id "pencil")
          ;textarea(name "content")
            ;+  =-  :/"{(trip -)}"
            %+  fall  (~(get by args) 'content')
            ?~  index  ''
            body:(~(got by library) u.index)
          ==
          ;*  ?~  sprout  ~
              ;+  ;input(type "hidden", name "p", value "{(a-co:co u.sprout)}");
          ;input(type "hidden", name "i", value "{(a-co:co id)}");
          ;button(type "submit", name "save"):"💾 Save"
          ;button(type "submit", name "show"):"👁 Preview"
          ;button
            =type  "submit"
            =name  "nuke"
            =onclick  "return confirm('Are you sure you want to delete this file?');"
            ; 🗑 Delete...
          ==
        ==
      ::
        ;div.tips
          ;+  :/"You can use BBCode! For example, [b]"
          ;b:"bold"
          ;+  :/"[/b] or [color=red]"
          ;span(style "color: red"):"color"
          ; [/color] or
          ;a/"/invisible-networks/bbcode.txt"(target "_blank"):"others"
          ; .
        ==
        ;img@"https://pal.dev/props/inet2022/clippy-gun.gif";
      ==
    ::
    ++  render-single  ^-  marl
      =/  =^index  (need index)
      ?~  story=(~(get by library) index)
        ;*  :~
          ;div.tips:"You dun goofed."
          ;img@"https://pal.dev/props/inet2022/clippy-gun.gif";
        ==
      ;+  (article index u.story)
    ::
    ++  render-sprout  ^-  marl
      =/  sprout=@ud  (need sprout)
      :-  ;h1:"{(prompt-title `sprout)}"
      =/  stories  (~(get ja volumes) sprout)
      ?:  =(~ stories)
        ;*  :~
          ;div.empty:"This folder is empty."
          ;div.tips
            ;+  :/"You can help by "
            ;a/"{(link-to-pencil sprout)}":"expanding this section"
            ; .
          ==
          ;img.fg@"https://pal.dev/props/inet2022/clippy-gun.gif";
        ==
      %+  turn  stories
      |=  =^index
      (article index (~(got by library) index))
    ::
    ++  render-author  ^-  marl
      =/  author=@p  (need author)
      :-  ;h1:"{+:(cite:title author)}'s Documents"
      =/  stories  (~(get ja authors) author)
      ?:  =(~ stories)
        ;+  ;div.empty:"This folder is empty."
      %+  turn  stories
      |=  =^index
      (article index (~(got by library) index))
    ::
    ++  render-biding  ^-  marl
      =/  rem=@ud
        ?:  (gth now start)  0
        (div (sub start now) ~h1)
      ;=  ;div.empty:"{(a-co:co rem)} hour(s) remain."
          ;div.tips:"Your time will come. Soon..."
          ;img.fg@"https://pal.dev/props/inet2022/clippy-gun.gif";
      ==
    ::
    ::
    ++  article
      |=  [=^index =story]  ^-  manx
      ;article
        ;*  ?.  ?=(?(%author %single %pencil) format)  ~
            ;+  ;a/"{(link-to-sprout sprout.story)}"
                  ;h1:"{(prompt-title `sprout.story)}"
                ==
        ;a/"{(link-to-single index)}"
          ;h2:"{(fake-title index)}"
        ==
        ;+  ?:(echoed.story :/"" ;span(title "Saving..."):" (⏳)")
        ;*  ?:  ?=(%author format)  ~
            ;+  ;h3
                  ;+  :/" by "
                  ;a/"{(link-to-author author.story)}"
                    ;  {+:(scow %p author.story)}
            ==    ==
        ;hr;
        ;*  ?:  =('' body.story)  ~
            ;+  ;section
              ;*  (render:bbcode (obtain:bbcode body.story))
            ==
      ==
    --
  --
--
