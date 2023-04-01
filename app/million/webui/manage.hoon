::  million dollar urbit page
::
::TODO  implement %giv
::
/-  *million
/+  rudder, make-grid=million-webui-grid, css=million-webui-style
::
^-  (page:rudder grid action)
|_  [=bowl:gall * =grid]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  ?~  body  ~
  =/  args=(map @t @t)
    (frisk:rudder q.u.body)
  ?:  (~(has by args) 'edit')
    ?~  spot=(~(get by args) 'spot')  ~
    ?~  tint=(~(get by args) 'tint')  ~
    ?~  show=(~(get by args) 'show')  ~
    ?~  echo=(~(get by args) 'echo')  ~
    ?~  link=(~(get by args) 'link')  ~
    ?~  spot=(rush u.spot ;~((glue com) dum:ag dum:ag))  ~
    ?~  tint=(rush u.tint ;~(pfix hax ;~(plug mes mes mes)))  ~
    =/  =^show  ?~(u.show [%nothing ~] [%sourced u.show])
    =/  =^echo  ?~(u.echo [%nothing ~] [%display u.echo])
    =/  =^link  ?~(u.link [%nothing ~] [%weblink u.link])
    [%set u.spot u.tint show echo link]
  ?:  (~(has by args) 'buy')
    ?~  spots=(~(get by args) 'spots')  ~
    ?~  spots=(rush u.spots (most com ;~((glue com) dum:ag dum:ag)))  ~
    [%buy our.bowl (~(gas in *(set spot)) u.spots)]
  ~
::
++  final  (alert:rudder '/million/manage' build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  =/  which=tape  "blank"
  |^  [%page page]
  ::
  ::
  ++  style
    =-  (cat 3 - (crip "#{which} \{ display: block; }"))
    %^  cat  3  css
    '''
    #head {
      box-sizing: border-box;
      padding-left: 100px;
      height: auto;
      min-height: 80px;
    }
    a {
      color: blue;
      text-decoration: none;
    }
    #back, #ours {
      position: absolute;
      top: 0; bottom: 50%; left: 0;
      width: 100px;
      display: block;
      box-sizing: border-box;
      padding: 7px 10px 0;
    }
    #back:hover, #ours:hover {
      background-color: rgba(0,0,0,0.1);
    }
    #ours {
      top: 50%; bottom: 0;
    }

    #overlay {
      position: absolute;
      top: 0; bottom: 0;
      left: 0; right: 0;
      z-index: 5;
    }

    #cursor, #select, .basket {
      position: absolute;
      box-sizing: content-box;
      top: -1000px; left: -1000px;
      z-index: 4;
    }
    #cursor {
      width: 12px; height: 12px;
      border: 3px solid grey;
    }
    #select {
      width: 10px; height: 10px;
      border: 4px solid black;
    }
    .basket {
      width: 12px; height: 12px;
      background-color: gold;
      z-index: 3;
      animation: basket-bg 3s ease infinite;
    }
    @keyframes basket-bg {
      0% { background-color: gold; }
      2% { background-color: #fe9; }
      4% { background-color: gold; }
      12% { background-color: gold; }
      14% { background-color: #fe9; }
      16% { background-color: gold; }
    }

    #selected {
      margin-right: 50px;
    }
    #addbutton {
      margin-top: 45px;
    }
    #basket form {
      max-height: 100px;
      overflow: auto;
    }

    #blank, #error, #load, #view, #edit, #basket {
      display: none;
    }

    label {
      display: inline-block;
      min-width: 60px;
    }

    .scoords {
      float: left;
      height: 100%; /* real tall bc "auto" on #head */
      max-height: 150px;
      padding: 40px 10px 0;
      margin-right: 10px;
      border-left: 1px solid black;
      border-right: 1px dotted black;
    }
    .hint, #receipts div {
      display: inline-block;
      border: 1px solid black;
      margin: 5px;
      padding: 2px;
      cursor: pointer;
    }
    .hint:hover {
      background-color: rgba(0,0,0,0.1);
    }
    #receipts div {
      border: 1px solid gold;
      background-color: rgba(250,200,100,0.5);
    }
    #receipts div:hover {
      background-color: rgba(230,180,100,0.5);
    }

    #msg {
      width: 1000px;
      box-sizing: border-box;
      color: black;
      padding: 5px;
      margin: 0 auto;
    }
    #msg.gud { background-color: rgb(150, 250, 160); }
    #msg.bad { background-color: rgb(250, 150, 160); }
    '''
  ::
  ++  script
    '''
    let our;
    let g, c, s, p,
        blank, error, load, view, edit, receipts,
        scoords, status,
        spots, spot, tint, show, echo, link, addbutton, buybutton;
    let cx = 0;
    let cy = 0;
    let sx = -1;
    let sy = -1;
    let cart = [];  //  { x, y, e }
    function cut(x) {
      return Math.min(Math.floor(x / 10), 99);
    }
    function mov(x, y, e, o) {
      e.style['top'] = ((y * 10) - o) + 'px';
      e.style['left'] = ((x * 10) - o) + 'px';
    }
    function hov(x, y) {
      cx = x
      cy = y
      mov(cx, cy, c, 4);
    }
    function tap(x, y) {
      sx = x;
      sy = y;
      Array.prototype.forEach.call(scoords, c => {
        c.innerHTML = render(sx, sy);
      });
      mov(sx, sy, s, 4);
      display(load);
      let xhr = new XMLHttpRequest();
      xhr.open('GET', '/~/scry/million/tile/'+sx+'/'+sy+'.json', true);
      xhr.responseType = 'json';
      let rx = sx;
      let ry = sy;
      xhr.onload = function() {
        if (rx != sx || ry != sy) return;
        if (xhr.status != 200)
          return oww(ry, ry, xhr.status);
        return got(rx, ry, xhr.response);
      };
      xhr.send();
    }
    function oww(x, y, err) {
      //TODO  render error msg
      console.error(x, y, err);
    }
    function got(x, y, til) {
      console.log(x, y, til);
      if (til.unacked) til = til.unacked.new;
      if ( til.managed ) {
        status.innerHTML = 'owned by ' + til.managed.who;
      }
      if ( til.pending ) {
        status.innerHTML = 'pending sale to ' + til.pending;
      }
      if ( til.managed && til.managed.who === our ) {
        spot.value = x + ',' + y;
        tint.value = til.managed.tint;
        show.value = til.managed.show;
        echo.value = til.managed.echo;
        link.value = til.managed.link;
        display(edit);
      } else if ( til.forsale ) {
        if (cart.some(s => (s.x === x) && (s.y === y))) {
          addbutton.innerHTML = 'Remove from cart';
        } else {
          addbutton.innerHTML = 'Add to cart';
        }
        display(basket);
      } else {
        display(view);
      }
    }
    function buy() {
      if ( cart.findIndex(s => ((s.x === sx) && (s.y === sy))) >= 0 ) {
        drop();
        return;
      }
      let e = document.createElement('div');
      e.classList = 'basket';
      mov(sx, sy, e, 1);
      g.appendChild(e);
      let r = document.createElement('div');
      r.innerHTML = render(sx, sy);
      let x = sx; let y = sy;
      r.addEventListener('click', () => { tap(x, y); });
      receipts.appendChild(r);
      cart.push({x: sx, y: sy, e: e, r: r});
      addbutton.innerHTML = 'Remove from cart';
      updateCart();
    }
    function drop() {
      let i = cart.findIndex(s => ((s.x === sx) && (s.y === sy)));
      g.removeChild(cart[i].e);
      receipts.removeChild(cart[i].r);
      cart.splice(i, 1)
      updateCart();
    }
    function updateCart() {
      buybutton.innerHTML = 'Buy for $U ' + (cart.length * 100);
      spots.value = cart.map(s => (s.x + ',' + s.y)).join(',');
      buybutton.disabled = !(cart.length > 0);
    }
    function display(e) {
      if (p) p.style['display'] = 'none';
      e.style['display'] = 'block';
      p = e;
    }
    function render(x, y) {
      return '[x=' + x + ' y=' + y + ']';
    }
    function setup() {
      g = document.getElementById('grid');
      c = document.getElementById('cursor');
      s = document.getElementById('select');

      blank = document.getElementById('blank');
      p = blank;
      error = document.getElementById('error');
      load = document.getElementById('load');
      view = document.getElementById('view');
      basket = document.getElementById('basket');
      edit = document.getElementById('edit');
      receipts = document.getElementById('receipts');
      scoords = document.getElementsByClassName('scoords');

      status = document.getElementById('status');

      spots = document.getElementById('spots');
      spot = document.getElementById('spot');
      tint = document.getElementById('tint');
      show = document.getElementById('show');
      echo = document.getElementById('echo');
      link = document.getElementById('link');
      addbutton = document.getElementById('addbutton');
      buybutton = document.getElementById('buybutton');
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"Million $U Urbit Page"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
        ;script:"{(trip script)} our = '{(scow %p our.bowl)}'"
      ==
      ;body(onload "setup()")
        ;*  %-  drop
            ?~  msg  ~
            %-  some
            ;div#msg(class "{?:(o.u.msg "gud" "bad")}"):"{(trip t.u.msg)}"
        ;+  head
        ;+  grid
      ==
    ==
  ::
  ++  head
    ^-  manx
    ;div#head(onload "display({which})")
      ;a#back/"/million":"<- back"
      ;a#ours/"#"(onclick "display(blank)"):"your tiles"
      ;+  ours
      ;div#load:"Loading details..."
      ;div#error:"Something went wrong!"
      ;div#view
        ;h3.scoords:"[x=? y=?]"
        ;div#status:"???"
      ==
      ;div#basket
        ;div#selected(style "float: left;")
          ;h3.scoords:"[x=? y=?]"
          ;button(onclick "buy()", id "addbutton"):"add to cart"
        ==
        ;div#receipts;
        ;form(method "post")
          ;input(type "hidden", name "spots", id "spots");
          ;button
            =type      "submit"
            =name      "buy"
            =id        "buybutton"
            =disabled  ""
            =onclick   "return confirm('Are you sure? You will be on the hook for $U ' + (cart.length*100) + '.')"
            ; purchase for $U 0
          ==
          ;
          ;a/"/million/tos"(target "_blank"):"(?)"
        ==
      ==
      ;div#edit
        ;h3.scoords:"[x=? y=?]"
        ;form(method "post")
          ;input(type "hidden", name "spot", id "spot");
          ;label(for "tint"):"color: "
          ;input(type "color", name "tint", id "tint");
          ;br;
          ;label(for "show"):"image: "
          ;input(type "text", name "show", id "show", placeholder "https://...png");
          ;br;
          ;label(for "echo"):"text: "
          ;input(type "text", name "echo", id "echo", placeholder "Hello Urbit!");
          ;br;
          ;label(for "link"):"link: "
          ;input(type "text", name "link", id "link", placeholder "https://...");
          ;br;
          ;input(type "submit", name "edit", value "Save");
        ==
      ==
    ==
  ::
  ++  ours
    ^-  manx
    =/  spol=(list spot)
      =-  (sort - aor)
      %+  murn  ~(tap by ^grid)
      |=  [s=spot t=tile]
      ^-  (unit spot)
      ?+  -.t  ~
        %pending  ?:(=(our.bowl who.t) `s ~)
        %managed  ?:(=(our.bowl who.t) `s ~)
        %unacked  $(t old.t)
      ==
    ?:  =(~ spol)  ;div#blank:"You control no tiles. Select one to begin..."
    ;div#blank
      ;h3:"Your tiles"
      ;div(style "overflow: auto;")
        ;*  %+  turn  spol
            |=  s=spot
            ;span.hint(onclick "tap({(scow %ud x.s)}, {(scow %ud y.s)})"):"{<s>}"
      ==
    ==
  ::
  ++  grid
    ^-  manx
    ;div#grid
      ;*  (make-grid ^grid &)
      ;div#overlay
        =onmousemove  "hov(cut(event.layerX), cut(event.layerY))"
        =onclick      "tap(cut(event.layerX), cut(event.layerY))";
      ;div#select;
      ;div#cursor;
    ==
  --
--
