::  fafa: 2fa otp authenticator app
::
::NOTE  https://github.com/google/google-authenticator/wiki/Conflicting-Accounts
::
/-  *fafa, webpage
/+  *otp, server, verb, dbug, default-agent
::
/~  webui  (webpage (map label secret) action)  /app/fafa/webui
::
|%
+$  state-0
  $:  %0
      keys=(map label secret)
  ==
::
+$  card  card:agent:gall
--
::
^-  agent:gall
%+  verb  |
%-  agent:dbug
::
=|  state-0
=*  state  -
::
|_  =bowl:gall
+*  this   .
    def  ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(state)
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 ole))]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?.  =(%handle-http-request mark)
    (on-poke:def mark vase)
  =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
  =*  as-octs  as-octs:mimes:html
  ::  require login for the web interface
  ::
  ?.  authenticated.inbound-request
    :_  this
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
  =;  [res=simple-payload:http =_state]
    :_  this(state state)
    (give-simple-payload:app:server eyre-id res)
  ::
  ?.  &(?=(^ site) =(dap.bowl i.site))
    [[[500 ['Location' '/fafa']~] `(as-octs 'unexpected route')] state]
  ::
  =/  page=@ta
    ?~  t.site  %index
    ?~  i.t.site  %index
    i.t.site
  ::
  ::TODO  these want specific headers, so we can't use the webpage pattern ):
  ?:  =(%tile page)
    :_  state
    ?.  =(%'GET' method.request.inbound-request)
      [[405 ~] ~]
    ^~  ^-  simple-payload:http
    :-  :-  200
        :~  ['content-type' 'image/svg+xml']
            ['cache-control' 'public, max-age=604800, immutable']
        ==
    %-  some
    %-  as-octt:mimes:html
    %-  en-xml:html
    |^  svg
    ++  svg
      ;svg
        =xmlns     "http://www.w3.org/2000/svg"
        =version   "1.1"
        =width     "100"
        =height    "100"
        =viewport  "0 0 100 100"
        ;rect(width "100%", height "100%", fill "#1a1a2a");
        ;g(style "stroke-width: 6;", transform "rotate(40 50 50)")
          :: ;g(style "stroke: goldenrod;", transform "rotate(25 50 60)")
          ::   ;*  (key |)
          :: ==
          ;g(style "stroke: gold;")
            ;*  (key &)
          ==
        ==
      ==
    ++  key
      |=  ring=?
      ^-  (list manx)
      :*  ;line(x1 "50", y1 "25", x2 "50", y2 "55");
          ;line(style "stroke-width: 4;", x1 "50", y1 "27", x2 "60", y2 "27");
          ;line(style "stroke-width: 4;", x1 "50", y1 "35", x2 "60", y2 "35");
        ::
          ?.  ring  ~
          [;circle(style "fill: none;", cx "50", cy "60", r "8");]~
      ==
    --
  ::
  ?.  (~(has by webui) page)
    [[[400 ~] `(as-octs 'no such page')] state]
  =*  view  ~(. (~(got by webui) page) bowl keys)
  ::
  =*  request  request.inbound-request
  ?+  method.request  !!
      %'GET'
    :_  state
    :-  [200 ~]
    %-  some
    %-  as-octt:mimes:html
    (en-xml:html (build:view args ~))
  ::
      %'POST'
    =/  act=(unit action)
      (argue:view header-list.request body.request)
    ?~  act  [[[405 ~] `(as-octs 'bad request')] state]
    =^  err=(unit @t)  state
      ?-  -.u.act
          %add
        ?:  (~(has by keys) label.u.act)
          [`'cannot overwrite existing account' state]
        ?:  ?=(%hotp -.wat.secret.u.act)
          [`'counter-based otp not yet supported in the frontend. file an issue if you need this!' state]
        `state(keys (~(put by keys) +.u.act))
      ::
          %del
        `state(keys (~(del by keys) label.u.act))
      ::
          %mov
        ?:  =(old new):u.act  `state
        ?.  (~(has by keys) old.u.act)
          [`'unknown account' state]
        ?:  (~(has by keys) new.u.act)
          [`'cannot overwrite existing account' state]
        =.  keys  (~(put by keys) new.u.act (~(got by keys) old.u.act))
        =.  keys  (~(del by keys) old.u.act)
        `state
      ::
          %set
        ?.  (~(has by keys) label.u.act)
          [`'unknown account' state]
        =/  =secret  (~(got by keys) label.u.act)
        ?.  ?=(%hotp -.wat.secret)
          [`'account not counter-based' state]
        =.  keys
          %+  ~(put by keys)  label.u.act
          secret(counter.wat counter.u.act)
        `state
      ==
    :_  state
    ?~  err
      ?:  =(%add page)
        [[303 ['Location' '/fafa']~] ~]
      [[303 ['Location' (cat 3 '/fafa/' page)]~] ~]
    :-  [400 ~]
    %-  some
    %-  as-octt:mimes:html
    (en-xml:html (build:view args `|^u.err))
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  =/  p=(pole @ta)  path
  =,  p
  ?+  p  [~ ~]
      [%x %codes %totp issuer=@ id=@ ~]
    =/  =label
      [(slav %t issuer) (slav %t id)]
    =/  =secret  (~(got by keys) label)
    ?>  ?=(%totp -.wat.secret)
    ``atom+!>((xotp secret now.bowl))
  ::
      [%x %codes %hotp issuer=@ id=@ counter=@ ~]
    ::TODO  or without counter in path for current one?
    =/  =label
      [(slav %t issuer) (slav %t id)]
    =/  =secret  (~(got by keys) label)
    ?>  ?=(%hotp -.wat.secret)
    =.  counter.wat.secret  (slav %ud counter)
    ``atom+!>((xotp secret now.bowl))
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    [~ this]
  (on-watch:def path)
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  =(/eyre/connect wire)
    (on-arvo:def wire sign-arvo)
  ?>  ?=([%eyre %bound *] sign-arvo)
  ~?  !accepted.sign-arvo
    [dap.bowl %strange-illegal-bind]
  [~ this]
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
