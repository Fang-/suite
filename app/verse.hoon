::  verse: a random Bible verse, every day
::
::    displays a bible verse on the homescreen, refreshing every 24 hours.
::
/+  word, pal, server, default-agent
::
|%
+$  state-1  [%1 ~]
::
+$  card  card:agent:gall
::
+$  eyre-id  @ta
--
::
=|  state-1
=*  state  -
::
^-  agent:gall
::
=<
|_  =bowl:gall
+*  this  .
    do    ~(. +> bowl)
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  :~  [%pass /eyre/connect %arvo %e %connect [~ /verse] dap.bowl]
      [%pass /profile/refresh %arvo %b %wait now.bowl]
  ==
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
      =+  !<(old=state-any ole)
      =^  caz  old
        ?.  ?=(%0 -.old)  [~ old]
        [[%pass /profile/refresh %arvo %b %wait now.bowl]~ [%1 ~]]
      ?>  ?=(%1 -.old)
      [caz this(state old)]
  ::
  +$  state-any  $%(state-0 state-1)
  +$  state-0    [%0 (unit mime)]
  --
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
    ?>  authenticated.inbound-request
    ::  parse request url into path and query args
    ::
    =/  ,request-line:server
      (parse-request-line:server url.request.inbound-request)
    ::
    =;  payload=simple-payload:http
      :_  this(state state)
      %+  give-simple-payload:app:server
        eyre-id
      payload
    ::
    ?+  site  [[404 ~] `(as-octs 'unexpected route')]
        [%verse %study ~]
      =-  [[302 ['location' -]~] ~]
      %^  cat  3
        'https://www.catholiccrossreference.online/fathers/index.php/'
      (crip (cass index:do))
    ::
        [%verse %verse ~]
      =/  svg  (as-octt (en-xml:html make-svg:do))
      [[200 ['content-type' 'image/svg+xml']~] `svg]
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
  ~|  wire=wire
  ?+  wire  (on-arvo:def wire sign-arvo)
      [%eyre %connect ~]
    ?>  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ::
      [%profile %refresh ~]
    ?>  ?=([%behn %wake *] sign-arvo)
    :_  this
    :-  [%pass /profile/refresh %arvo %b %wait next:do]
    ?^  error.sign-arvo
      ((slog 'verse: profile refresh crashed' u.error.sign-arvo) ~)
    ?.  .^(? %gu /(scot %p our.bowl)/profile/(scot %da now.bowl)/$)
      ~
    =;  widget=[%0 desc=@t %marl marl]
      =/  =cage  noun+!>([%command %update-widget %verse %verse widget])
      [%pass /profile/widget/verse %agent [our.bowl %profile] %poke cage]~
    :^  %0  'Daily Bible verse'  %marl
    ::NOTE  we use a data url in an <img> because something about the <svg>
    ::      makes it unable to scale properly otherwise...
    [make-img:do]~
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ~|  wire=wire
  ?>  ?=([%profile %widget @ ~] wire)
  ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
  ?~  p.sign  [~ this]
  %.  [~ this]
  (slog (cat 3 'verse: failed to update widget %' i.t.t.wire) u.p.sign)
::
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--
::
|_  =bowl:gall
++  ci  ~+
  (wild:pal (div now.bowl ~d1) weight)
::
++  vi  ~+
  =+  c=verses:(chapter ci)
  ~?  !=((snag ci weight) (lent c))
    [dap.bowl %why]  ::TODO  why not equal? you'd expect it...
  (~(rad og (div now.bowl ~d1)) (lent c))
::
++  verse
  ^-  tape  ~+
  %-  trip
  (snag vi verses:(chapter ci))
::
++  chapter
  |=  c=@ud  ~+
  =+  a=linear:word
  |-  ^-  [book=term local=@ud verses=(list @t)]
  ?~  a  !!
  =+  s=(lent q.i.a)
  ?:  (gth s c)  [p.i.a c (snag c q.i.a)]
  $(c (sub c s), a t.a)
::
++  index  ~+
  =+  (chapter ci)
  =.  book  (~(got by titles:word) book)
  "{(trip book)} {(scow %ud +(local))}:{(scow %ud +(vi))}"
::
++  weight  ^~  ::  verses per chapter
  =+  a=linear:word
  |-  ^-  (list @ud)
  ?~  a  ~
  =+  b=i.a
  =+  c=1
  |-
  ?~  q.b  ^$(a t.a)
  [(lent i.q.b) $(q.b t.q.b)]
::
::NOTE  verse length ranges from 11 to 528 characters
++  sizes
  |=  t=tape
  ^-  @ud
  =+  l=(lent t)
  ?:  (lth l 120)  7
  ?:  (lth l 180)  6
  ?:  (lth l 300)  5
  ?:  (lth l 480)  4
  3
::
++  next
  `@da`(add now.bowl (sub ~d1 (mod now.bowl ~d1)))
::
++  make-img
  =/  dat=@t
    =,  mimes:html
    (en:base64 (as-octt (en-xml:html make-svg)))
  ;img
    =src  "data:image/svg+xml;base64,{(trip dat)}"
    =style  """
            width: 346px; max-width: 85.1vw;
            aspect-ratio: 1;
            border-radius: 40px;
            """;
::
++  make-svg
  ;svg
    =viewport  "0 0 100 100"
    =height    "100" ::%"
    =width     "100" ::%"
    =version   "1.1"
    =xmlns     "http://www.w3.org/2000/svg"
    ;rect
      =fill    "#eed"
      =width   "100" ::%"
      =height  "100"; ::%";
    ;+  show-verse
    ;+  show-index
  ==
::
++  show-verse
  ^-  manx
  =+  siz=(sizes verse)
  =/  align=tape
    ?:((gth siz 6) "left" "justify")
  ;foreignObject
    =x  "10" ::%"
    =y  "10" ::%"
    =width  "80" ::%"
    =height  "80" ::%"
    ;div
      =xmlns  "http://www.w3.org/1999/xhtml"
      =style  """
              color: #445; font-family: serif;
              font-size: {((d-co:co 1) siz)}pt;
              line-height: 1.1em;
              text-align: justify;
              """
      ; {verse}
    ==
  ==
::
++  show-index
  ;foreignObject
    =x  "10" ::%"
    =y  "85" ::%"
    =width  "80" ::%"
    =height  "80" ::%"
    ;div
      =xmlns  "http://www.w3.org/1999/xhtml"
      =style  """
              color: #88a; font-family: serif;
              font-size: 6pt;
              text-align: right;
              """
      ; {index}
    ==
  ==
--
