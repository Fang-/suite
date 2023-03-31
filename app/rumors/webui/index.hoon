::  rumors frontend
::
/-  *rumors
/+  rudder
::
^-  (page:rudder [rumors @t (list @t)] [~ @t])
|_  [bowl:gall * =rumors @t (list @t)]
++  argue
  |=  [head=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder [~ @t])
  ?~  body  ~
  =/  args=(map @t @t)
    (frisk:rudder q.u.body)
  ?~  what=(~(get by args) 'rumor')
    ~
  ?:  =('' u.what)
    'like a fart in the wind'
  ?:  (gth (met 3 u.what) 1.024)
    'your tirade falls on deaf ears'
  [~ u.what]
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
    * { margin: 0; padding: 0; color: #fff0ff; font-family: sans-serif; }
    .status, .warn { margin: 1em; clear: both; }
    .red { color: #dd2266; }

    body {
      height: 100vh;
      width: 100vw;
      text-align: center;
      overflow-x: hidden;

      background: linear-gradient(345deg, #df7bdf, #847bde, #e5a0a0, #8199dc);
      background-size: 800% 800%;
      background-attachment: fixed;

      -webkit-animation: bg 160s ease infinite;
      -moz-animation: bg 160s ease infinite;
      animation: bg 160s ease infinite;
    }

    @-webkit-keyframes bg {
      0%{background-position:51% 0%}
      50%{background-position:50% 100%}
      100%{background-position:51% 0%}
    }
    @-moz-keyframes bg {
      0%{background-position:51% 0%}
      50%{background-position:50% 100%}
      100%{background-position:51% 0%}
    }
    @keyframes bg {
      0%{background-position:51% 0%}
      50%{background-position:50% 100%}
      100%{background-position:51% 0%}
    }

    h1 {
      font-weight: lighter;
      margin-top: 1em;
      font-style: italic;
    }

    form {
      margin: 2em auto 1em;
    }
    input, button {
      background-color: rgba(0,0,0,0.3);
      padding: 0.5em;
      width: 80vw;
      max-width: min(80vw, 500px);
      border-radius: 0.5em;
      border: 0.1em solid #fff0ff;
      font-size: 1.5em;
    }

    #listing {
      padding: 1em;
    }

    .rumor {
      margin-bottom: 2em;
      text-shadow: 1px 1px 3px rgb(0 0 0 / 15%);
      letter-spacing: 0.1px;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"rumors and gossip"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h1:"rumors and gossip"

        ;+  status

        ;+  ?:  pals-installed  :/""
            dependency-warning

        ;+  input
        ;+  listing
      ==
    ==
  ::
  ++  pals-installed  ~+
    .^(? %gu /(scot %p our)/pals/(scot %da now))
  ::
  ++  mutuals  ~+
    .^((set ship) %gx /(scot %p our)/pals/(scot %da now)/mutuals/noun)
  ::
  ++  dependency-warning
    ^-  manx
    ;p.warn
      ; this app requires %pals for peer discovery.
      ;a(href "/apps/grid/perma/~paldev/pals/"):"install it from ~paldev/pals."
    ==
  ::
  ++  status
    ^-  manx
    ?~  msg  :/""
    ?:  o.u.msg
      ;p.status.green:"{(trip t.u.msg)}"
    ;p.status.red:"{(trip t.u.msg)}"
  ::
  ++  input
    ^-  manx
    ;form(method "post")
      ;input(type "text", name "rumor", required "", placeholder prompt);
    ==
  ::
  ++  listing
    ^-  manx
    ;div#listing
      ;*  ?~  rumors  ;+  ;i:"it's been strangely quiet..."
          =/  n=@ud  0
          |-
          ?:  (gte n 50)  ~
          ?:  (lth when.i.rumors (sub now ~d14))  ~
          =*  w  when.i.rumors
          =.  w  (sub w (mod w ~s1))
          :-  ;div.rumor(title (scow %da w)):"{(trip what.i.rumors)}"
          ?~  t.rumors  ~
          $(rumors t.rumors, n +(n))
    ==
  ::
  ++  prompt
    =-  (snag (~(rad og eny) (lent -)) -)
    ^-  (list tape)
    :~  "word on the street is..."
        "rumor has it that..."
        "don't tell anyone, but..."
        "i'll let you in on a secret..."
        "you didn't hear this from me, but..."
        "i heard the strangest thing..."
    ==
  --
--
