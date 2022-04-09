::  fafa/mod.hoon: rename & delete factors
::
/-  *fafa
/+  *otp, rudder
::
^-  (page:rudder (map label secret) action)
|_  [bowl:gall * keys=(map label secret)]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder action)
  ?~  body  ~
  =/  args=(map @t @t)
    (frisk:rudder q.u.body)
  ?.  (~(has by args) 'cur-issuer')  ~
  ?.  (~(has by args) 'cur-id')      ~
  =/  old=label
    [(~(got by args) 'cur-issuer') (~(got by args) 'cur-id')]
  ?:  (~(has by args) 'del')
    [%del old]
  ?.  (~(has by args) 'save')    ~
  ?.  (~(has by args) 'issuer')  ~
  ?.  (~(has by args) 'id')      ~
  =/  new=label
    [(~(got by args) 'issuer') (~(got by args) 'id')]
  [%mov old new]
::
++  final  (alert:rudder 'mod' build)
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  ^-  reply:rudder
  |^  [%page page]
  ::
  ++  style
    '''
    * {
      font-family: monospace;
      font-size: 11pt;
    }
    body {
      margin: 0;
      background-color: #fafafa;
    }

    .disabled {
      display: none !important;
    }

    #head {
      padding: 1em;
      background-color: black;
      color: gold;
    }

    #wrapper {
      max-width: 50em;
      margin: 0 auto;
    }

    a {
      color: inherit;
      text-decoration: none;
    }
    h1 {
      margin: 0;
      font-size: 2em;
    }

    form {
      margin: 0;
    }

    #factors {
      padding: 0 1em;
    }

    .factor {
      cursor: pointer;
    }
    .factor, #status, #factors a {
      display: block;
      border: 1px solid black;
      border-radius: 2px;
      margin-top: 1em;
      padding: 1em;
      background-color: white;
      color: black;
      text-decoration: none;
    }
    #factors a {
      float: left;
      font-weight: bold;
      padding: 1em 2em;
      margin-right: 1em;
      width: 2em;
      text-align: center;
    }

    #status {
      margin: 1em;
      border-width: 1px 3px;
    }

    .label, .code {
      width: 50%;
      display: inline-block;
    }
    .id {
      font-weight: bold;
    }
    .code {
      text-align: right;
    }
    '''
  ::
  ++  script
    '''
    function cconfirm(this) {
      console.log('huh', this);
      this.onclick = () => {};
      return false;
    }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"fafa authenticator"
        ;style:"{(trip style)}"
        ;script:"{(trip script)}"
        ;meta(charset "utf-8");
        ;meta
          =name     "viewport"
          =content  "width=device-width, initial-scale=1";
      ==
      ;body
        ;div#wrapper
          ;div#head
            ;a(href "/fafa")
              ;h1:"fafa authenticator"
            ==
          ==
          ;+  ?~  msg  ;div#status.disabled;
              ;div#status:"{(trip +.u.msg)}"
          ;div#factors
            ;*  (turn (sort ~(tap by keys) aor) render-factor)
            ;a(href "/fafa", title "factors"):"<"
            ;a(href "/fafa/sav", title "backup & restore"):"⭘"
          ==
        ==
      ==
    ==
  ::
  ++  render-factor
    |=  [label secret]
    ^-  manx
    =/  tis  (trip issuer)
    =/  tid  (trip id)
    ;form.factor(method "post")
      ;input(type "hidden", name "cur-issuer", value tis);
      ;input(type "hidden", name "cur-id", value tid);
      ;div.label
        ;input.issuer(type "text", name "issuer", value "{tis}");
        ;br;
        ;input.id(type "text", name "id", value "{tid}");
      ==
      ;div.code
        ;input
          =type     "submit"
          =name     "del"
          =value    "del"
          =onclick  "return confirm('delete: are you sure?');";
        ;
        ;input(type "submit", name "save", value "save");
      ==
    ==
  --
--
