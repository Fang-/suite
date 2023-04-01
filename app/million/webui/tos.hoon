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
  =.  grid  ::TODO  tmp
    %-  ~(gas by grid)
    =+  rng=~(. og eny.bowl)
    |-  ^-  (list [spot tile])
    =^  x  rng  (rads:rng 100)
    =^  y  rng  (rads:rng 100)
    ?:  &((gth x 95) (gth y 95))  ~
    :_  $
    :-  `spot`[x y]
    =^  a  rng  (rads:rng 256)
    =^  b  rng  (rads:rng 256)
    =^  c  rng  (rads:rng 256)
    ^-  tile
    :+  %managed  ~zod
    [[a b c] [%nothing ~] [%display (scot %ub a)] [%weblink 'https://urbit.org/']]
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

    #tos {
      box-sizing: border-box;
      margin: 0 auto 1em;
      padding: 1em 3em 1em;
      text-align: justify;
      max-width: 1000px;
      font-family: serif;
      background-color: white;
      border: 1px solid black;
    }

    h2 { margin-bottom: 0.5em; }
    p  { margin-bottom: 0.5em; }
    ul { margin: 0.5em 0; }
    li { margin-left: 2em; }
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
        ;+  text
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
      %+  skim  ~(val by grid)
      |=  t=tile
      ?=(?([%managed *] [%mystery *] [%unacked * [%managed *]]) t)
    =/  a=@ud  (sub 1.000.000 s)
    ;div#stat
      ; Sold: {(scow %ud s)}
      ;br;
      ; Available: {(scow %ud a)}
      ;br;
      ;+  ?.  authenticated.order
            ;span:"Want in? Install ~paldev/million!"
          ;a.buy/"/million/manage":"Buy now!"
    ==
  ::
  ++  text
    ^-  manx
    ;div#tos
      ;h2:"So what are you actually buying?"

      Unlike the MillionDollarHomepage.com, we are not selling merely pixels,
      but instead fully generic coordinates in a 1.000 by 1.000 grid.

      Of course, in this app, the representation of that grid is still such
      that every coordinate renders as a 10 by 10 pixel tile, which the owner
      of the tile can fill in as they desire. But the "coordinate" primitive
      can be made useful for other kinds of applications also.

      Other use cases have... not yet manifested themselves. Whether they ever
      will, nobody can tell for certain. However, when you purchase a
      coordinate, you do get the following Paldev Guarantee™:

      - %million (this app) will be maintained and kept usable in some form or
        other for at least the next five years. (That is, until April 1st 2028.)
      - You, the buyer of one or more coordinates, will have canonical
        ownership and control over those coordinates for at least the next five
        years, or until you transfer it to a new owner, who will then have this
        same guarantee. This ownership status will remain legible to other
        Urbit applications for as long as it lasts.
      - All funds acquired through the sale of coordinates will be used towards
        the development of ~paldev software, and the organization of ~paldev
        events.

      The Paldev Guarantee™ means ~paldev is, as the provider of a centralized
      service and keeper of a centralized ledger, staking its reputation on
      these promises. If ~paldev does not deliver on them, it can and should be
      dragged through the mud for it.
    ==
  --
--
