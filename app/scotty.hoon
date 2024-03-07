::  scotty: @p-based http redirecter
::
::    redirects /scotty/~sampel/etc to sampel.com or w/e, based on eauth keen
::
::TODO  maybe support eauthed ships providing a persistent override url
::
/+  dbug, verb
::
|%
+$  state-0
  $:  %0
      pending=(map ship (map @ta [til=@da url=@t]))
  ==
::
+$  card  card:agent:gall
::
++  response-timeout  ~s30
::
++  send-keen
  |=  [kind=?(%keen %yawn) =ship =time]
  ^-  card
  =/  =wire       /keen/(scot %p ship)
  =.  time        (sub time (mod time ~h1))
  =/  =spar:ames  [ship /e/x/(scot %da time)//eauth/url]
  [%pass wire %arvo %a ?-(kind %keen keen+[~ spar], %yawn yawn+spar)]
::
++  respond
  |=  [rid=@ta simple-payload:http]
  ^-  (list card)
  =/  =path  /http-response/[rid]
  :~  [%give %fact ~[path] %http-response-header !>(response-header)]
      [%give %fact ~[path] %http-response-data !>(data)]
      [%give %kick ~[path] ~]
  ==
::
++  timeout-response
  |=  who=@p
  ^-  simple-payload:http
  :-  [200 ['content-type' 'text/html']~]
  %-  some
  %-  as-octs:mimes:html
  %+  rap  3
  :~  'Sorry, '
      (scot %p who)
      ' seems to be unavailable right now. Please try again later.'
  ==
::
++  redirect-response
  |=  [who=@p url=@t]
  ^-  simple-payload:http
  :-  [302 ~['content-type'^'text/html' 'location'^url]]
  %-  some
  %-  as-octs:mimes:html
  %+  rap  3
  :~  'Redirecting to '
      (scot %p who)
      '...'
  ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
::
^-  agent:gall
|_  =bowl:gall
+*  this  .
::
++  on-init
  :_  this
  [%pass /eyre/bind %arvo %e %connect [~ /scotty] dap.bowl]~
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
  ?+  mark  ~|([%unexpected-mark mark] !!)
      %handle-http-request
    =+  !<([rid=@ta [* * * =request:http]] vase)
    ?>  ?=(%'GET' method.request)
    =/  [who=@p url=@t]
      %+  rash  url.request
      ;~  pfix  (jest '/scotty/')
        ;~(plug ;~(pfix sig fed:ag) (cook crip (star next)))
      ==
    =/  new=?    !(~(has by pending) who)
    =/  til=@da  (add now.bowl response-timeout)
    =.  pending
      %+  ~(put by pending)  who
      (~(put by (~(gut by pending) who ~)) rid [til url])
    :_  this
    :~  (send-keen %keen who now.bowl)
        [%pass /timeout/(scot %p who)/[rid] %arvo %b %wait til]
    ==
  ==
::
++  on-arvo
  |=  [=wire sign=sign-arvo]
  ^-  (quip card _this)
  ~|  wire
  ?+  wire  !!
      [%timeout @ @ ~]
    ?>  ?=(%wake +<.sign)
    ?^  error.sign
      %.  [~ this]
      (slog (cat 3 dap.bowl ' failed to process %wake') u.error.sign)
    =/  who=@p   (slav %p i.t.wire)
    =/  rid=@ta  i.t.t.wire
    =.  pending
      =/  new  (~(del by (~(gut by pending) who ~)) rid)
      ?:  =(~ new)  (~(del by pending) who)
      (~(put by pending) who new)
    :_  this
    (respond rid (timeout-response who))
  ::
      [%keen @ ~]
    ?>  ?=(%tune +<.sign)
    =/  who=@p  (slav %p i.t.wire)
    =/  bas=(unit @t)
      ?~  roar.sign  ~
      ?~  q.dat.u.roar.sign  ~
      ;;((unit @t) q.u.q.dat.u.roar.sign)
    =?  bas  ?=(^ bas)
      =+  i=(find "/~/eauth" (trip u.bas))
      ?~  i  bas
      `(end 3^u.i u.bas)
    =/  all=(list [rid=@ta til=@da url=@t])
      ~(tap by (~(gut by pending) who ~))
    =.  pending  (~(del by pending) who)
    :_  this
    %-  zing
    %+  turn  all
    |=  [rid=@ta til=@da url=@t]
    ^-  (list card)
    :-  [%pass /timeout/(scot %p who)/[rid] %arvo %b %rest til]
    %+  respond  rid
    ?~  bas  (timeout-response who)
    (redirect-response who (cat 3 u.bas url))
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  ?=([%http-response @ ~] path)
  [~ this]
::
++  on-agent  |=(* `this)
++  on-leave  |=(* `this)
++  on-fail   |=(* `this)
++  on-peek   |=(* ~)
--
