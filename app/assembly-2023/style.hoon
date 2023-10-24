/+  *assembly-2023, rudder
::
^-  (page:rudder state action)
|_  [bowl:gall order:rudder state]
++  argue  !!
++  final  !!
++  build
  |=  *
  ^~  ^-  reply:rudder
  :+  %full
    :-  200
    :~  ['content-type' 'image/svg+xml']
        ['cache-control' 'public, max-age=900, immutable']
    ==
  %-  some
  %-  as-octs:mimes:html
  |^  ^~((rap 3 fonts '\0a' style ~))
  ++  style
    '''
    * { margin: 0; padding: 0; }
    :root {
      --black: #38391f;
      --white: #f7f1d2;
      --green: #5dbf8d;
      --yellow: #fed107;
      --red: #f05826;
      --radius: .5rem;
    }

    a {
      text-decoration: none;
      color: inherit;
    }

    html, body {
      background-color: var(--white);
      color: var(--black);
      font-family: Urbit Sans, Arial;
      font-size: 14pt;
      max-width: 800px;
      margin: 0 auto;
    }

    header, nav {
      position: relative;
      z-index: 50;
      background-color: var(--red);
      color: var(--yellow);
      text-align: center;
      font-family: Urbit Sans;
      font-weight: 300;
    }
    header h1 {
      font-size: 25pt;
      font-family: Urbit Serif Italic;
      padding: 0.5em 0;
    }
    nav {
      display: grid;
      grid-template-rows: 1;
      grid-template-columns: [left] 1fr [center] 1fr [right] 1fr;
      padding: 0;
      margin-bottom: 1em;
    }
    nav a {
      text-decoration: none;
      text-align: center;
      font-family: Urbit Sans;
      color: var(--yellow);
      font-size: 18pt;
      grid-row: 1;
      margin: 10px;
    }
    nav .left   { grid-column: left; }
    nav .middle { grid-column: center; }
    nav .right  { grid-column: right; }

    .title {
      color: var(--green);
      font-family: Urbit Serif Italic, Times;
      text-align: center;
      margin-bottom: 1em;
    }

    /* no clue why mobile chrome is weird about this */
    .index a {
      display: block;
      margin: 20px;
      padding: 20px;
      background-color: var(--red);
      border-radius: var(--radius);
      color: var(--yellow);
      font-size: 20pt;
      text-decoration: none;
      vertical-align: middle;
    }
    .index a img {
      display: inline-block;
      vertical-align: middle;
      margin-right: 1rem;
    }

    .schedule.main {
      position: relative;
      margin-top: 2em;
      display: grid;
      /*NOTE  we don't do a row per minute, because of rachelandrew/gridbugs#28 */
    }
    .schedule.week {
      position: relative;
      padding: 0 1em 1em;
    }

    .schedule .time {
      grid-column: 1;
      font-size: 0.8em;
      transform-origin: 0 0;
      transform: rotate(-90deg) translate(-250%,0%);
      color: var(--red);
      font-family: Urbit Sans Mono;
    }
    .schedule .line {
      border-top: 1px solid var(--red);
      z-index: 1;
      grid-column: 1 / 99;
      height: 0;
    }
    .schedule .now {
      position: absolute;
      left: 0; right: 0;
      z-index: 4;
      border-top: 3px solid var(--green);
    }

    .event {
      position: relative;
      display: block;
      border-radius: var(--radius);
      background-color: var(--black);
      color: var(--white);
      text-decoration: none;
      margin: 3px 4px;
      padding: 7px;
      z-index: 2;
      font-size: 16pt;
    }
    .event.break {
      background-color: var(--white);
      color: var(--black);
      z-index: 3;
      opacity: 0.5;
      border-radius: 0;
    }
    .event .start {
      position: sticky;
      top: 5px;
      padding-bottom: 0.5em;
      margin-bottom: 1.5em;
      background-color: var(--black);
      z-index: 2;
    }
    .event h4 {
      font-size: 18pt;
    }
    .event.break .start {
      background-color: var(--white);
    }
    /* this one's so dumb, but webkit browsers need an explicit height
       for overflow:hidden to work
    */
    .schedule.main .event {
      height: calc(100% - 12px);
      box-sizing: border-box;
    }
    .schedule.main .event .start {
      top: 40px;
      max-height: 90%;
      overflow: hidden;
    }
    .schedule.week .event {
      margin: 0.5em 0;
      padding: 0.5em;
      padding-bottom: 2em;
    }
    .schedule.week .event h4 {
      margin-top: 0.3em;
    }
    .schedule.week .event p {
      margin: 0.3em 0;
    }
    .event .kind {
      display: inline-block;
      padding: 3px 5px;
      margin: 5px 0;
      border-radius: var(--radius);
      background-color: var(--white);
      color: var(--black);
    }
    .schedule.week .event .kind {
      position: absolute;
      top: 0.2em;
      right: 0.4em;
      font-size: 14pt;
    }
    .schedule.week .event h5 {
      color: var(--red);
      font-family: Urbit Sans Mono;
    }
    /* .main .kind {
      background-color: var(--green);
    }
    .second .kind {
      background-color: var(--yellow);
    } */
    .event .end {
      position: absolute;
      z-index: 25;
      bottom: 5px;
      right: 7px;
      text-align: right;
      opacity: 0.5;
      font-size: 12pt;
    }
    .event.break .icons {
      display: none;
    }
    .label {
      position: sticky;
      top: 5px;
      z-index: 10;
      display: block;
      height: 0;
      width: calc(50% - 1em + 1px);
    }
    .label div {
      padding: 4px;
      color: var(--black);
      border-radius: var(--radius);
    }
    .label.main {
      margin-left: calc(1em + 4px);
    }
    .label.second {
      margin-left: calc(50% + 1em - 5px);
    }
    .label.main div {
      background-color: var(--green);
    }
    .label.second div {
      background-color: var(--yellow);
    }

    .icons {
      position: absolute;
      z-index: 25;
      bottom: 7px;
      background-color: var(--black);
    }
    .icons img {
      display: inline-block;
      margin-right: 7px;
      height: 1.5em;
      width: 1.5em;
    }
    .icons span {
      position: absolute;
      right: 0; bottom: -0.2em;
      font-size: 10pt;
      color: var(--green);
      text-shadow: 0.5px 0.5px 1px var(--black), -0.5px -0.5px 1px var(--black), -0.5px 0.5px 1px var(--black), 0.5px -0.5px 1px var(--black);
      /* text-shadow: 0px 0px 2px var(--black), -0px -0px 2px var(--black), -0px 0px 2px var(--black), 0px -0px 2px var(--black); */
    }

    article.event {
      position: relative;
      padding: 1em;
      margin: 1em;
    }
    article h2 {
      color: var(--red);
    }
    article p {
      margin-top: 1em;
    }
    article p.short {
      font-style: italic;
    }
    article img {
      display: block;
      max-width: 90%;
      border: 1px solid var(--white);
      margin: 1em auto;
    }
    article table {
      color: inherit;
      margin: 1em 0;
      border-spacing: 5px;
      font-size: 13pt;
    }
    article td:first-child {
      padding-right: 1em;
      font-weight: bold;
      vertical-align: top;
    }
    tr.rsvp td {
      color: var(--yellow);
    }
    tr.rsvp a {
      text-decoration: underline;
    }
    button {
      display: block;
      background-color: var(--green);
      border: 0px;
      border-radius: var(--radius);
      padding: 5px;
      margin-top: 3px;
      font-family: Urbit Sans;
    }
    tr .no button {
      background-color: var(--red);
    }

    .messages h2 {
      margin-top: 0.3em;
    }
    .messages form {
      padding: 0 2em;
    }
    textarea {
      margin: 0 auto;
      width: 100%;
      border: 2px solid var(--black);
      border-radius: var(--radius);
      padding: 1em;
      font-family: Urbit Sans;
      font-size: 14pt;
      background-color: var(--white);
    }
    .messages button {
      margin: 0.5em auto 0;
      font-size: 14pt;
    }

    .message {
      margin: 1em 1em 0.5em;
      border-radius: var(--radius);
      background-color: var(--black);
      color: var(--white);
      padding: 0.5em;
    }
    .message .wen {
      font-family: Urbit Sans Mono;
      color: var(--red);
      font-size: 0.8em;
    }
    .message .who {
      font-family: Urbit Sans Mono;
      font-weight: bold;
      font-size: 1.2em;
    }
    .message .wat p {
      margin-top: 0.5em;
    }
    '''
  ::
  ++  fonts
    '''
    /*TODO  probably only need a few of these
    https://assembly.urbit.org/_next/static/media/UrbitSans-Medium.a5a9ec11.otf
    https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Medium.34d3ba07.otf
    https://assembly.urbit.org/_next/static/media/UrbitSans-SemiBold.bad49020.otf
    https://assembly.urbit.org/_next/static/media/UrbitSans-Regular.108abb2f.otf
    */

    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-UltraThin.0aea9905.otf);
      font-weight:100;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-Thin.833ff595.otf);
      font-weight:200;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-Light.07739c1a.otf);
      font-weight:300;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-Regular.108abb2f.otf);
      font-weight:400;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-Medium.a5a9ec11.otf);
      font-weight:500;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-SemiBold.bad49020.otf);
      font-weight:600;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSans-Bold.683a43ea.otf);
      font-weight:700;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-UltraThin.bc5a6d38.otf);
      font-weight:100;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-Thin.6a26d201.otf);
      font-weight:200;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-Light.677d7c8e.otf);
      font-weight:300;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-Regular.13315be0.otf);
      font-weight:400;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-Medium.9309e759.otf);
      font-weight:500;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-SemiBold.6803d5a2.otf);
      font-weight:600;
      font-style:normal
    }
    @font-face {
      font-family:Urbit Sans Mono;
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSansMono-Bold.b773b599.otf);
      font-weight:700;
      font-style:normal
    }
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-UltraThin.d14fddcb.otf);
      font-weight:100;
      font-style:normal
    }
    /*@font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Thin.862eb8c1.otf);
      font-weight:200;
      font-style:normal
    }*/
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Light.9056e25f.otf);
      font-weight:300;
      font-style:normal
    }/*
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Regular.579b769d.otf);
      font-weight:400;
      font-style:normal
    }
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Medium.34d3ba07.otf);
      font-weight:500;
      font-style:normal
    }
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-SemiBold.069c5055.otf);
      font-weight:600;
      font-style:normal
    }
    @font-face {
      font-family:"Urbit Serif Italic";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalic-Bold.59eec6bc.otf);
      font-weight:700;
      font-style:normal
    }
    @font-face {
      font-family:"Urbit Serif Italic VF";
      src:url(https://assembly.urbit.org/_next/static/media/UrbitSerifItalicVF.ae0e2f03.ttf)
    }*/
    '''
  --
--
