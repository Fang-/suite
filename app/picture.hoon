::  picture: simple picture frame for the homescreen
::
::    lets you upload an arbitrary image, then serves that as the icon
::    for the app's tile on the homescreen.
::
/-  webpage
/+  server, dbug, verb, default-agent
::
/~  webui  (webpage ~ (unit mime))  /app/picture/webui
::
|%
+$  state-0
  $:  %0
      picture=(unit mime)
  ==
::
+$  card  card:agent:gall
::
+$  eyre-id  @ta
--
::
=|  state-0
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
  |=  ole=vase
  ^-  (quip card _this)
  =/  old=state-0  !<(state-0 ole)
  [~ this(state old)]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
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
      :_  [~ state]
      =;  placeholder
        ?~  picture
          [[200 ['content-type'^'image/svg+xml']~] `placeholder]
        :_  `q.u.picture
        :-  200
        :~  :-  'content-type'   (en-mite p.u.picture)
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
      :_  [~ state(picture u.new)]
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
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--

