::  facepage
::
/+  rudder
::
^-  (page:rudder (map ship [@da (unit cord)]) [%set (unit cord)])
|_  [bowl:gall * faces=(map ship [@da (unit cord)])]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder [%set (unit cord)])
  ?~  body  ~
  =/  args=(map @t @t)  (frisk:rudder q.u.body)
  ?:  (~(has by args) 'remove')  [%set ~]
  ?~  face=(~(get by args) 'face')
    ~
  :-  %set
  ?:(=('' u.face) ~ `u.face)
::
++  final  (alert:rudder (cat 3 '/' dap) build)
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  |^  [%page page]
  ::
  ++  style
    '''
    * { margin: 0; padding: 0; }
    .status, .warn { margin: 0.5em 1em; clear: both; }
    .red { font-weight: bold; color: #dd2222; }
    .green { font-weight: bold; color: #229922; }

    body {
      font-family: "Lucida Grande", "Helvetica Neue", Arial, sans-serif;
    }

    h1 {
      margin: 0 0 0.5em;
      padding: 0.5em 0.8em 0.6em;
      color: white;
      background-color: #3b5998;
      font-weight: bold;
    }

    #ours > form {
      margin: 1em;
      display: inline-block;
    }
    input, button, label {
      margin: 0.5em;
      padding: 0.2em;
    }

    #theirs {
      clear: both;
    }

    .ship {
      float: left;
      margin: 0.5em 1em;
    }
    .face {
      position: relative;
      width: 40vw; max-width: 250px;
      height: 40vw; max-height: 250px;
      border: 1px solid #112;
      border-radius: 2%;
      overflow: hidden;
    }
    .our .face {
      width: 20vw; max-width: 100px;
      height: 20vw; max-height: 100px;
    }
    .face img {
      object-fit: cover;
      width: 100%;
      height: 100%;
      cursor: zoom-in;
    }
    .ship.blank .face img {
      opacity: 0.2;
    }
    .ship span {
      display: inline-block;
      margin-top: 0.4em;
      padding: 0 0.2em 0;
      font-family: Roboto, monospace;
    }
    .our span {
      font-size: 0.7em;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%face"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h1:"face"

        ;+  status

        ;div#ours
          ;form(method "post")
            ;label
              ; your face (image url):
              ;br;
              ;input
                =type  "text"
                =name  "face"
                =value  (trip (fall +:(~(got by faces) our) ''))
                =placeholder  "http://face.png";
            ==
            ;br;
            ;button(type "submit"):"update"
            ;button(type "submit", name "remove"):"remove"
          ==

          ;+  our-face
        ==

        ;+  ?:  pals-installed  :/""
            dependency-warning

        ;div#theirs
          ;*  their-faces
        ==
      ==
    ==
  ::
  ++  pals-installed  ~+
    .^(? %gu /(scot %p our)/pals/(scot %da now)/$)
  ::
  ++  mutuals  ~+
    .^((set ship) %gx /(scot %p our)/pals/(scot %da now)/mutuals/noun)
  ::
  ++  dependency-warning
    ^-  manx
    ;p.warn
      ; This app requires %pals for peer discovery.
      ;a(href "/apps/grid/perma/~paldev/pals/"):"Install it from ~paldev/pals."
    ==
  ::
  ++  status
    ^-  manx
    ?~  msg  :/""
    ?:  o.u.msg
      ;p.status.green:"{(trip t.u.msg)}"
    ;p.status.red:"{(trip t.u.msg)}"
  ::
  ++  our-face
    ^-  manx
    %+  render-face      our
    %+  fall
      +:(~(got by faces) our)
    '''
    data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' class='w-3 h-3 fill-current' viewBox='-10 -10 32 32'%3E%3Cpath d='M0.292893 10.2942C-0.0976311 10.6847 -0.0976311 11.3179 0.292893 11.7084C0.683417 12.0989 1.31658 12.0989 1.70711 11.7084L6.00063 7.41487L10.2948 11.7091C10.6853 12.0996 11.3185 12.0996 11.709 11.7091C12.0996 11.3185 12.0996 10.6854 11.709 10.2949L7.41484 6.00066L11.7084 1.70711C12.0989 1.31658 12.0989 0.683417 11.7084 0.292894C11.3179 -0.0976312 10.6847 -0.0976312 10.2942 0.292894L6.00063 4.58645L1.70775 0.293571C1.31723 -0.0969534 0.684061 -0.0969534 0.293536 0.293571C-0.0969879 0.684095 -0.0969879 1.31726 0.293536 1.70778L4.58641 6.00066L0.292893 10.2942Z'%3E%3C/path%3E%3C/svg%3E
    '''
  ::
  ++  their-faces
    ^-  (list manx)
    %+  murn  (sort ~(tap by faces) dor)
    |=  [=ship @da face=(unit cord)]
    ^-  (unit manx)
    ?:  =(ship our)  ~
    ?:  ?&  pals-installed
            !(~(has in mutuals) ship)
        ==
      ~
    (bind face (cury render-face ship))
  ::
  ++  render-face
    |=  [=ship face=cord]
    =/  class=tape
      """
      ship
       {?:(=(ship our) "our" "")}
       {?:((~(has by faces) ship) "" "blank")}
      """
    ;div(class class)
      ;div.face
        ;a(href (trip face), target "_blank")
          ;img(src (trip face));
        ==
      ==
      ;span(title (scow %p ship)):"{(cite:title ship)}"
    ==
  --
--
