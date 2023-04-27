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
  ?.  ?=([@ ~] t.site)
    [[404 ~] `'not found']
  ::
  =/  who=(unit @p)
    ?:  =('random' i.t.site)
      `(end 5 eny.bowl)
    (rush i.t.site ;~(pose fed:ag dum:ag))
  ?~  who
    [[404 ~] `(cat 3 i.t.site ' not found')]
  ::
  =*  fancy  ?=(^ (get-header:http 'fancy' args))
  =+  rend=render:emblemish
  ::
  ?+  ext  [[404 ~] `'not found']
      [~ %html]
    :-  [200 ['content-type'^'text/html;charset=utf-8']~]
    %-  some
    %+  rap  3
    :~  '<html><head>'
        '<title>emblemish: '  (scot %p u.who)  '</title>'
        '<meta charset="utf-8" />'
        '<meta name="viewport" content="width=device-width, initial-scale=1" />'
        '</head><body>'
        '<h3>'  (name:emblemish fancy u.who)  '</h3>'
        (rend(size 500) u.who)
        '</body></html>'
    ==
  ::
      [~ %json]
    :-  [200 ['content-type'^'application/json;charset=utf-8']~]
    %-  some  %-  en:json:html
    %-  pairs:enjs:format
    :~  'p'^s+(scot %p u.who)
        'title'^s+(name:emblemish | u.who)
        'emblem'^s+(rend u.who)
    ==
  ::
      [~ %svg]
    :-  [200 ['content-type'^'image/svg+xml;charset=utf-8']~]
    `(rend(size 1.024) u.who)
  ::
      [~ %txt]
    :-  [200 ['content-type'^'text/plain;charset=utf-8']~]
    `(name:emblemish fancy u.who)
  ==
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
