::  sc'o're scoreboard page
::
/-  channels
/+  *pal, rudder
::
^-  (page:rudder (mip ship react:channels @ud) ~)
|_  [=bowl:gall * bits=(mip ship react:channels @ud)]
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  =?  bits  !(~(has by bits) our.bowl)
    (~(put by bits) our.bowl ~)
  |^  ^-  reply:rudder
      =/  board=(list line)
        %+  sort
          (turn ~(tap by bits) entry-to-line)
        |=  [[* a=@ud pa=(list)] [* b=@ud pb=(list)]]
        ?.  =(a b)  (gth a b)
        ::  in case of tie, most unique reacts wins
        ::
        (gth (lent pa) (lent pb))
      =/  ours=@ud
        =/  num=@ud  1
        |-
        ?~  board  !!
        ?:  =(our.bowl who.i.board)  num
        $(num +(num), board t.board)
      ::
      :-  %page
      %^  page
          %+  turn  (scag 10 board)
          |=  =line
          line(per (sort per.line |=([[* a=@ud] [* b=@ud]] (gth a b))))
        (gth (lent board) 10)  ::TODO  what if ours is 11
      :-  ours
      ?:  (lte ours 10)  *line
      (entry-to-line our.bowl (~(got by bits) our.bowl))
  ::
  +$  line
    [who=ship sum=@ud per=(list [f=react:channels c=@ud])]
  ::
  ++  entry-to-line
    |=  [who=ship all=(map react:channels @ud)]
    ^-  line
    :+  who
      (~(rep by all) |=([[* a=@ud] s=@ud] (add s a)))
    ~(tap by all)
  ::
  ++  style
    '''
    * {
      margin: 0;
      padding: 0;
    }
    *::selection {
      background-color: yellow;
      color: black;
    }
    body {
      cursor: cell;
      width: 100vw;
      min-height: 100vh;
      overflow-x: hidden;
      background: yellow linear-gradient(130deg, rgba(255,255,200,0.5) 10%, yellow 70%, rgba(0,0,0,0.2));
      color: black;
      font-family: Impact, Arial Black, sans-serif;
      font-weight: bolder;
      font-style: italic;
      text-transform: uppercase;
    }
    @keyframes shake {
      0%  { transform: translate(0, 0) }
      10% { transform: translate(-8px, 3px) }
      30% { transform: translate(3px, -8px) }
      50% { transform: translate(-3px, -3px) }
      80% { transform: translate(5px, 8px) }
    }
    body::before {
      content: '';
      position: fixed;
      top: -100%; bottom: -100%;
      left: -100%; right: -100%;
      transform: rotate(-20deg);
      background-image: url('/scooore/back.svg');
      background-repeat: repeat;
      opacity: 0.2;
      animation: bg-slide 80s linear infinite;
      z-index: -10;
    }
    @keyframes bg-slide {
      0% {
        background-position: 0 0;
      }
      100% {
        background-position: 800px 600px;
      }
    }
    h1 {
      font-style: normal;
      background: linear-gradient(90deg, rgba(255,255,255,0.8), rgba(255,255,255,0.4));
      padding: 0.5em 2em;
      margin-bottom: 0.5em;
      border: 0.2em solid black;
      border-left: none;
      border-right: none;
      color: black;
    }
    .one {
      position: relative;
      display: block;
      clear: both;
      max-width: calc(100vw - 3em);
      white-space: nowrap;
      overflow-x: scroll;
      scrollbar-width: none;
      margin: 0 -1em 0.5em;
      padding: 1em 3em;
      transition: background-color 0.2s ease-out;
    }
    .one::-webkit-scrollbar {
      display: none;
    }
    .one:hover, .one:focus {
      background-color: rgba(0, 0, 0, 0.1);
    }
    .one:focus {
      animation: shake 0.1s linear 3;
    }
    .one:active {
      animation: none;
    }
    .num, .who, .sum, .bit {
      position: relative;
      height: 3em;
      box-sizing: border-box;
      display: inline-block;
      text-align: center;
      vertical-align: middle;
      overflow: hidden;
      max-width: 10em;
      padding: 0.7em 2em;
      background: black linear-gradient(170deg, rgba(255,255,255,0.4), black);
      color: white;
      border: 0.15em solid white;
      transform: skew(20deg) scale(1);
      transition: transform 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .num:hover, .who:hover, .one > .sum:hover, .bit:hover {
      transform: skew(20deg) scale(1.3);
      z-index: 10;
    }
    .num > *, .who > *, .sum > *, .bit > * {
      display: inline-block;
      transform: skew(-20deg);
      vertical-align: middle;
    }
    .num, .who, .one > .sum {
      margin: 0 0.2em;
      font-size: 1.3em;
    }
    .num {
      width: 3em;
      margin-left: 0.4em;
      margin-right: 0;
      padding: 0.82em 0 0;
      z-index: 4;
    }
    .who {
      margin-right: 0.2em;
      margin-left: 0;
      width: 20em;
      padding-left: 0;
      padding-right: 0;
      z-index: 5;
    }
    .one:nth-child(1) .num, .one:nth-child(1) .who {
      border-image: linear-gradient(180deg, gold 15%, white 25%, gold 40%, gold 80%, goldenrod);
      border-image-slice: 1;
      border-width: 0.2em;
      font-size: 1.8em;
    }
    .one:nth-child(2) .num, .one:nth-child(2) .who {
      border-image: linear-gradient(180deg, silver 15%, white 25%, silver 40%, silver 80%, grey);
      border-image-slice: 1;
      border-width: 0.17em;
      font-size: 1.6em;
    }
    .one:nth-child(3) .num, .one:nth-child(3) .who {
      border-image: linear-gradient(180deg, goldenrod 15%, white 25%, goldenrod 40%, goldenrod 80%, brown);
      border-image-slice: 1;
      font-size: 1.4em;
    }
    .sum {
      z-index: 3;
    }
    .bit {
      margin-left: 0.1em;
    }
    .bit em-emoji {
      position: absolute;
      top: 0; bottom: 1em;
      left: -1em; right: -1em;
      padding-top: 0.2em;
      text-align: center;
      background-color: black;
      border-bottom: 1px solid white;
      font-style: normal;
      overflow: hidden;
    }
    .bit .emoji-mart-emoji {
      padding: 0.3em 0.2em 0.1em;
      font-size: 2em;
      position: relative; top: -0.3em;
    }
    .bit .sum {
      position: absolute;
      top: 1.35em; bottom: 0;
      left: -1em; right: -1em;
      z-index: -1;
      font-size: 0.8em;
      text-align: center;
      background-color: black;
      color: white;
    }
    .one.etc, .one.etc:hover {
      background: none;
      float: left;
    }
    .one.etc:focus {
      animation: deny 0.15s linear 2;
    }
    .one.etc:active {
      animation: none;
    }
    @keyframes deny {
      0%   { transform: translate(0, 0) }
      25%  { transform: translate(-8px, 0) }
      50%  { transform: translate(0, 0) }
      75%  { transform: translate(8px, 0) }
      100% { transform: translate(0, 0) }
    }
    '''
  ::
  ++  page
    |=  [tops=(list line) mis=? our=[num=@ud =line]]
    ;html
      ;head
        ;title:"['o']{(reap (sub 4 (min 4 num.our)) '+')}"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
        ;script(type "module")
          ; import * as em from 'https://unpkg.com/emoji-mart@5.4.0/dist/module.js';
          ; em.init({});
        ==
      ==
      ;body
        ;br;
        ;h1:"reaction highscores (local)"
        ;div#top
          ;*  `(list manx)`(flop `(list manx)`-:(roll tops entries))
          ;*  (other mis our)
        ==
      ==
    ==
  ::
  ++  other
    |=  [mis=? our=[num=@ud =line]]
    =*  self  (snag 0 -:(entries line.our ~ [num.our 0 0] num.our))
    ;=  ;+  ?:(=(11 num.our) self ;div;)
        ;+  ?.  mis  ;div;
            ;div.one.etc(tabindex "0")
              ;div.num.etc:"•••"
            ==
        ;+  ?:((gth num.our 11) self ;div;)
    ==
  ::
  ++  entries
    |=  [line out=(list manx) las=[num=@ud sum=@ud niq=@ud] num=_1]
    ^+  [out las num]
    =^  pos  las
      =+  l=(lent per)
      ?.  =(+.las [sum l])  [num [num sum l]]
      [num .]:las
    =;  =manx
      [[manx out] las +(num)]
    ;div.one(tabindex "0")  ::NOTE  tabindex enables focus/active animation
      ;div.num
        ;span:"#{(scow %ud pos)} "
      ==
      ;div.who(title "{(scow %p who)}")
        ;span:"{(cite:title who)}"
      ==
      ;div.sum
        ;span:" {(scow %ud sum)}"
      ==
      ;*  (turn per react)
    ==
  ::
  ++  react
    |=  [f=react:channels c=@ud]
    ^-  manx
    ;div.bit
      ;em-emoji(shortcodes (trip f), fallback "?");
      ;div.sum:"{(scow %ud c)}"
    ==
  --
::
++  argue  !!
++  final  !!
--
