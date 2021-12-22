::  picture: simple picture frame for the homescreen
::
::    lets you upload an arbitrary image, then serves that as the icon
::    for the app's tile on the homescreen.
::
::    to disable seasonal framing, :picture |
::
/-  webpage
/+  server, dbug, verb, default-agent
::
/~  webui  (webpage ~ (unit mime))  /app/picture/webui
::
|%
+$  state-1
  $:  %1
      picture=(unit mime)
      [framing=? caching=(unit octs)]  ::  for seasonal surprises
  ==
::
+$  card  card:agent:gall
::
+$  eyre-id  @ta
--
::
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /picture] dap.bowl]~
::
++  on-save  !>(state)
::
++  on-load
  |^  |=  ole=vase
      ^-  (quip card _this)
      =/  old=state-any  !<(state-any ole)
      =?  old  ?=(%0 -.old)
        (state-0-to-1 old)
      ?>  ?=(%1 -.old)
      =.  caching.old  ~
      [~ this(state old)]
  ::
  +$  state-any  $%(state-1 state-0)
  ::
  ++  state-0-to-1
    |=  state-0
    ^-  state-1
    [%1 picture [& ~]]
  ::
  +$  state-0
    $:  %0
        picture=(unit mime)
    ==
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %noun
    =+  f=(? q.vase)
    =?  caching  !f  ~
    [~ this(framing f)]
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =,  mimes:html
    =+  !<([=eyre-id =inbound-request:eyre] vase)
    ?.  authenticated.inbound-request
      :_  this
      ::TODO  probably put a function for this into /lib/server
      ::      we can't use +require-authorization because we also update state
      %+  give-simple-payload:app:server
        eyre-id
      =-  [[307 ['location' -]~] ~]
      %^  cat  3
        '/~/login?redirect='
      url.request.inbound-request
    ::  parse request url into path and query args
    ::
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    ::
    =;  [payload=simple-payload:http caz=(list card) =_state]
      :_  this(state state)
      %+  weld  caz
      %+  give-simple-payload:app:server
        eyre-id
      payload
    ::  405 to all unexpected requests
    ::
    ?.  &(?=(^ site) =('picture' i.site))
      [[[500 ~] `(as-octs 'unexpected route')] ~ state]
    ::
    =/  page=@ta
      ?~  t.site  %index
      i.t.site
    ?:  =(%image page)
      =?  caching  &(framing ?=(^ picture) ?=(~ caching))
        %-  some
        =/  dat
          %+  rap  3
          ~['data:' (en-mite p.u.picture) ';base64,' (en:base64 q.u.picture)]
        %-  as-octt
        %-  en-xml:html
        ^-  manx
        ;svg
          =viewport  "0 0 100 100"
          =height    "100"
          =width     "100"
          =version   "1.1"
          =xmlns     "http://www.w3.org/2000/svg"
          ;image
            =x  "0"
            =y  "0"
            =width  "100"
            =height  "100"
            =preserveAspectRatio  "xMidYMid slice"
            =href  (trip dat);
          ;image
            =x  "-4"
            =y  "-4"
            =width  "108"
            =height  "108"
            =href
              "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAeAAAAHgCAMAAABKCk6nAAADAFBMVEUAAAD///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////+/Gh3////dh4n89vbitLXf2NjntbbYqqu8REe+GRy6V1nk0NC7GRzTsrO9PD7BPD+5Oz68YGL79va/GRy/Ghy8GRy9GRz+/v6+GR2+HB+8Gx65GRy8ICPy4+T8+fm+IST59fW5HSD++/u5ISTv4+O+JijXmpv35OS/Ki3ivb3GXV/9+/u1REXHWFrCTlHv3t+8KSzqz8/z6ursvr/o4uK/QELv2dq9Mzb27u7FRUjARUj7+PjCSUvPdHblyMnQhYfoy8vs4+PPfH3JYmTfs7Tdra7PeXrp1NXKRkjSiovUmJm/LjDXkJH58vKxICPs1dXXu7zANznkvr705OXcnp/GYWK8ODrBIiXit7jz7e3gmpv28vK6LzLOcXPDWFrZmJrCNDfapabTj5Dovb7VbW/McnTDUVPUhofJZmj27Oy5Ki3t1te6JSjUk5Xy6Oj38PDox8iqHyLNamzcqqvboaPSgYLlxMT69/ft3d7w4OHaqKnCQkS2ISS8TU/JeHrGaWrs2Ni6REbak5TevL3OmJncmZq8PkHLbnDesbHlu7zp0tLKW13NgYPGVVbt0NG3JSjXn6Dhw8Pv3NzWdHbJc3Tq2tvz4ODFTU/gubq/UFL05+favLzQm5ytICO1KSzZm53VpqfEc3Xs6enJTlHnz8+2NTe/Oz7QZWjZv8Dft7jXsrO4R0rUra7Lnp/MFf+hAAAAUnRSTlMAuM4zhildU9gLrpqYxFaku8oDBUAW+EjhtKkYOi6eHtS+JrEk6yHBpqF+dnFaDmDlTWVvnFASRdCsHJUxS/MqDGs0BpF78Ixz6IM2zN6l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";
        ==
      :_  [~ state]
      =;  placeholder
        ?~  picture
          [[200 ['content-type'^'image/svg+xml']~] `placeholder]
        :_  `(fall caching q.u.picture)
        :-  200
        :~
          :-  'content-type'   ?^(caching 'image/svg+xml' (en-mite p.u.picture))
          :-  'cache-control'  'public, max-age=604800, immutable'
        ==
      ^~
      %-  as-octt
      %-  en-xml:html
      ^-  manx
      ;svg
        =viewport  "0 0 100 100"
        =height    "100"
        =width     "100"
        =version   "1.1"
        =xmlns     "http://www.w3.org/2000/svg"
        ;rect
          =fill    "#ddd"
          =width   "100"
          =height  "100";
        ;text
          =fill  "#777"
          =font-family  "sans-serif"
          =font-weight  "bold"
          =text-anchor  "middle"
          =x            "50%"
          =y            "50%"
          =dy           "0.2em"
          ; 1:1
        ==
      ==
    ::
    =;  [[status=@ud out=(unit manx)] caz=(list card) =_state]
      :_  [caz state]
      ^-  simple-payload:http
      :-  :-  status
          ?~  out  ~
          ['content-type'^'text/html']~
      ?~  out  ~
      `(as-octt (en-xml:html u.out))
    ::TODO  mostly copied from pals, dedupe!
    ::
    ?.  (~(has by webui) page)
      [[404 `:/"no such page: {(trip page)}"] ~ state]
    =*  view  ~(. (~(got by webui) page) bowl ~)
    ::
    ::TODO  switch higher up: get never changes state!
    ?+  method.request.inbound-request  [[405 ~] ~ state]
        %'GET'
      :_  [~ state]
      [200 `(build:view args ~)]
    ::
        %'POST'
      ?~  body.request.inbound-request  [[400 `:/"no body!"] ~ state]
      =/  new=(unit (unit mime))
        (argue:view [header-list body]:request.inbound-request)
      ?~  new
        :_  [~ state]
        :-  400
        %-  some
        %+  build:view  args
        `|^'Something went wrong! Did you provide sane inputs?'
      :_  [~ state(picture u.new, caching ~)]
      :-  200
      %-  some
      (build:view args `&^'Processed succesfully.')  ::NOTE  silent?
    ==
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  sign-arvo  (on-arvo:def wire sign-arvo)
      [%eyre %bound *]
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(/x/dbug/state path)  ~
  :^  ~  ~  %noun
  !>  %=  state
    picture  (bind picture |=(mime [p p.q 1.337]))
    caching  (bind caching |=(octs [p 1.337]))
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--

