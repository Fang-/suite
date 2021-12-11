::  fafa/index.hoon: landing page etc
::
/-  *fafa
/+  *otp, multipart
::
|_  [bowl:gall keys=(map label secret)]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  (unit action)
  =/  args=(map @t part:multipart)
    ?~  req=(de-request:multipart headers body)  ~
    (~(gas by *(map @t part:multipart)) u.req)
  ?:  (~(has by args) 'save')  `[%sav ~]
  ?.  (~(has by args) 'load')  ~
  ?.  (~(has by args) 'file')  ~
  %+  bind
    %-  (soft (map label secret))
    (cue body:(~(got by args) 'file'))
  (lead %get)
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  |^  page
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
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"fafa authenticator"
        ;style:"{(trip style)}"
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
          ;form#factors(method "post", enctype "multipart/form-data")
            ;div.factor
              ;input(type "submit", name "save", value "backup");
              ;
              ; will export to .urb/put/fafa/export.jam
            ==
            ;div.factor
              ;input(type "submit", name "load", value "restore");
              ;
              ; from an export.jam
              ;input(type "file", name "file", accept "*");
            ==
            ;a(href "/fafa/mod", title "manage"):"<"
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
    ;form.factor(method "post", enctype "multipart/form-data")
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
