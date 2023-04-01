::  million dollar urbit page
::
/-  *million
/+  rudder, make-grid=million-webui-grid, css=million-webui-style
::
^-  (page:rudder grid action)
|_  [=bowl:gall =order:rudder =grid]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  ~
::
++  final  (alert:rudder (cat 3 '/' dap.bowl) build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  |^  [%page page]
  ::
  ++  style
    %^  cat  3  css
    '''
    #stat {
      float: right;
      border: 1px solid goldenrod;
      border-radius: 3px;
      padding: 5px;
      font-size: 12px;
    }

    .tile .tip {
      display: none;
      position: absolute;
      top: 12px; left: 12px;
      z-index: 2;
      background-color: rgba(255, 255, 255, 0.85);
      color: black;
      padding: 3px;
      border: 1px solid grey;
      width: max-content;
      font-family: monospace;
    }
    .tile .tip.y {
      top: unset; bottom: 12px;
    }
    .tile .tip.x {
      left: unset; right: 12px;
    }
    .tile:hover .tip {
      display: block;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"Million Dollar Urbit Page"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;+  head
        ;+  grid
      ==
    ==
  ::
  ++  head
    ^-  manx
    ;div#head
      ;div(style "float: left;")
        ;h1:"The Million Dollar Urbit App™"
        ;span:"1,000,000 pixels • $1 per pixel • Own a piece of Urbit history!"
      ==
      ;+  stat
    ==
  ::
  ++  stat
    ^-  manx
    =/  s=@ud
      %+  mul  100
      %-  lent
      %+  skip  ~(val by ^grid)
      |=  t=tile  ?=(%forsale -.t)
      :: ?=(?([%managed *] [%pending *] [%mystery *] [%unacked * [%managed *]]) t)
    =/  a=@ud  (sub 1.000.000 s)
    ;div#stat
      ; Sold: {(scow %ud s)}
      ;br;
      ; Available: {(scow %ud a)}
      ;br;
      ;+  ?.  authenticated.order
            ;span:"Want in? |install ~paldev %million"
          ;a.buy/"/million/manage":"Buy now!"
    ==
  ::
  ++  grid
    ^-  manx
    ;div#grid
      ;*  (make-grid ^grid |)
    ==
  --
--
