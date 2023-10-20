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
        ['cache-control' 'public, max-age=604800, immutable']
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
      display: grid;
      grid-template-rows: 1;
      grid-template-columns: [left] 20% [center] 60% [right] 20%;
      padding: 0;
      position: relative;
      z-index: 50;
      background-color: var(--red);
      color: var(--yellow);
      text-align: center;
      font-family: Urbit Serif Italic, Times;
      font-weight: 300;
    }
    nav {
      font-size: 13pt;
    }
    nav .title, header h1 {
      grid-row: 1;
      grid-column: center;
      padding: 1em;
    }
    header h1 {
      font-size: 18pt;
    }
    header .left, nav .left, nav .right {
      text-decoration: none;
      text-align: center;
      font-family: Urbit Sans Mono;
      color: var(--red);
      font-size: 25pt;
      font-weight: bold;
      grid-row: 1;
      background-color: var(--yellow);
      margin: 20px;
      border-radius: var(--radius);
    }
    nav .left, header .left { grid-column: left; }
    nav .right { grid-column: right; }
    nav a span {
      vertical-align: middle;
    }

    .index a {
      display: block;
      margin: 20px;
      padding: 20px;
      background-color: var(--red);
      border-radius: var(--radius);
      color: var(--yellow);
      font-size: 20pt;
      text-decoration: none;
    }
    .index a:hover {
      color: var(--yellow);
    }
    .index a div {
      display: inline-block;
      width: 2rem;
      height: 2rem;
      vertical-align: middle;
      margin-right: 1rem;
      background-color: var(--yellow);
    }

    .schedule.main {
      position: relative;
      display: grid;
      margin-top: -50vh;
      /* margin-top: -180%;  /*NOTE  hack, borks on pages with just 1 short event */
      grid-template-rows: repeat(288, 5.5vh); /* 1 row is ~m5 */ /*TODO  1fr -> 5.5vh? */
      /*NOTE  we don't do a row per minute, because of rachelandrew/gridbugs#28 */
    }
    .schedule.week {
      position: relative;
      padding: 1em;
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
      z-index: 3;
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
      top: 0;
      z-index: 10;
      display: block;
      height: 0; /* important, somehow */
    }
    .label div {
      margin: 4px;
      padding: 4px;
      color: var(--black);
      border-radius: var(--radius);
    }
    .label.main div {
      background-color: var(--green);
    }
    .label.second div {
      background-color: var(--yellow);
    }

    .grid, .pals, .mine {
      mask-size: cover;
    }
    .grid {
      mask: url('/assembly-2023/db.svg');
      background-color: var(--black);
    }
    .pals {
      mask: url('/assembly-2023/p2p.svg');
      background-color: var(--green);
    }
    .mine {
      mask: url('/assembly-2023/star.svg');
      background-color: var(--yellow);
    }
    .icons {
      position: absolute;
      z-index: 25;
      bottom: 7px;
    }
    .icons div {
      display: inline-block;
      margin-right: 7px;
      height: 1.5em;
      width: 1.5em;
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
    tr button {
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
