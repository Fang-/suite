::  verse: a random Bible verse, every day
::
::    displays a bible verse on the homescreen, refreshing every 24 hours.
::
/+  word, pal, server, default-agent
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
^-  agent:gall
::
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /verse] dap.bowl]~
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
    =;  payload=simple-payload:http
      :_  this(state state)
      %+  give-simple-payload:app:server
        eyre-id
      payload
    ::
    |^  ?+  site  [[404 ~] `(as-octs 'unexpected route')]
            [%verse %study ~]
          =-  [[302 ['location' -]~] ~]
          %^  cat  3
            'https://www.catholiccrossreference.online/fathers/index.php/'
          (crip (cass index))
        ::
            [%verse %verse ~]
          =;  svg
            ?~  picture
              [[200 ['content-type' 'image/svg+xml']~] `svg]
            :_  `q.u.picture
            :-  200
            :~  :-  'content-type'   (en-mite p.u.picture)
                :-  'cache-control'  'public, max-age=3600'
            ==
          %-  as-octt
          %-  en-xml:html
          ;svg
            =viewport  "0 0 100 100"
            =height    "100"
            =width     "100"
            =version   "1.1"
            =xmlns     "http://www.w3.org/2000/svg"
            ;rect
              =fill    "#eed"
              =width   "100"
              =height  "100";
            ;+  show-verse
            ;+  show-index
          ==
        ==
    ::
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
    ++  show-verse
      ^-  manx
      =+  siz=(sizes verse)
      =/  align=tape
        ?:((gth siz 6) "left" "justify")
      ;foreignObject
        =x  "10"
        =y  "10"
        =width  "80"
        =height  "80"
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
        =x  "10"
        =y  "85"
        =width  "80"
        =height  "80"
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
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--

