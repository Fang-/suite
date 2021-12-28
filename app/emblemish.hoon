::  emblemish: http endpoint for the /lib/emblemish
::
/+  dbug, verb, default-agent,
    emblemish, server
::
|%
+$  eyre-id  @ta
+$  card  card:agent:gall
--
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
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(~)
::
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  [~ this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?.  =(%handle-http-request mark)  (on-poke:def mark vase)
  ::
  ~>  %bout
  =+  !<([=eyre-id =inbound-request:eyre] vase)
  ::  parse request url into path and query args
  ::
  =/  ,request-line:server
    (parse-request-line:server url.request.inbound-request)
  ::
  =;  [head=response-header:http body=(unit @t)]
    :_  this
    %+  give-simple-payload:app:server  eyre-id
    [head (bind body as-octs:mimes:html)]
  ::  405 to all unexpected requests
  ::
  ?.  &(?=(^ site) =(dap.bowl i.site))
    [[500 ~] `'unexpected route']
  ::
  ?.  =('GET' method.request.inbound-request)
    [[405 ~] `'illegal method']
  ::
  |^  ?+  [t.site ext]  [[404 ~] `'not found']
          [[%full @ ~] [~ %json]]
        ?~  who=(who (snag 1 t.site))
          [[404 ~] `(cat 3 (snag 2 t.site) ' not found')]
        :-  [200 ['content-type'^'application/json']~]
        %-  some  %-  crip  %-  en-json:html
        %-  pairs:enjs:format
        :~  'p'^s+(scot %p u.who)
            'title'^s+(name:emblemish | u.who)
          ::
            :+  'emblem'  %s
            =+  rend=render:emblemish
            ?~  syz=(get-header:http 'size' args)
              (rend u.who)
            ?~  siz=(rush u.syz dum:ag)
              (rend u.who)
            ~&  u.siz
            (rend(size u.siz) u.who)
        ==
      ==
  ::
  ++  who
    |=  k=knot
    ^-  (unit @p)
    ?:  =('random' k)
      `(end 5 eny.bowl)
    (rush k ;~(pose fed:ag dum:ag))
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?:  ?=([%http-response *] path)  [~ this]
  (on-watch:def path)
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
++  on-agent  on-agent:def
++  on-peek   on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
