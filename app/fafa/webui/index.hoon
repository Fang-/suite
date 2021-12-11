::  fafa/index.hoon: landing page etc
::
/-  *fafa
/+  *otp
::
|_  [bowl:gall keys=(map label secret)]
++  argue  !!
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
    #head a {
      color: inherit;
      text-decoration: none;
      font-size: 2em;
    }

    #wrapper {
      max-width: 50em;
      margin: 0 auto;
    }

    h1 {
      margin: 0;
      font-size: 2em;
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
    let status;

    function prep() {
      status = document.getElementById('status');
    }

    function loadCode(e, l, issuer, id) {
      let nod = e.getElementsByClassName('code')[0];
      nod.innerHTML = 'loading...';
      let bas = ('0').repeat(l);
      let req = new XMLHttpRequest();

      req.onload = function() {
        if (req.status == 200) {
          let num = (bas + atomToInt(req.response)).slice(-l);
          nod.innerHTML = num.slice(0, l/2) + ' ' + num.slice(l/2);
          navigator.clipboard.writeText(num);
        } else {
          nod.innerHTML = 'oops!';
          console.log('strange response status', req.status, req.response);
        }
      }

      req.onerror = function() {
        nod.innerHTML = 'oops!';
        console.log('request error', req.status, req.response);
      }

      req.responseType = 'arraybuffer';
      req.open('GET', `/~/scry/fafa/codes/totp/${issuer}/${id}.atom`);
      req.send();
    }

    function atomToInt(a) {
      let val = 0;
      a = new Uint8Array(a);
      for (let i = a.length; i >= 0; i--) {
        console.log('char', i, a[i]);
        val = (val << 8) | (a[i] & 0xff);
      }
      return val;
    }

    window.onload = prep;
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
            ;h1:"fafa authenticator"
          ==
          ;+  ?^  msg  ;div#status:"{(trip +.u.msg)}"
          ;div#status
            ; remember that neither urbit nor this app have had a full
            ; security audit yet. avoid adding factors over unencrypted
            ; http. make sure to save the recovery codes, and/or add
            ; a copy of these factors into an authenticator on earth.
          ==
          ;div#factors
            ;*  (turn (sort ~(tap by keys) aor) render-factor)
            ;a(href "/fafa/add"):"+"
            ;a(href "/fafa/mod"):"•••"
          ==
        ==
      ==
    ==
  ::
  ++  render-factor
    |=  [label secret]
    ^-  manx
    ;div.factor
      =onclick
        """
        loadCode(this,
          {((d-co:co 1) len)},
          '{(scow %t issuer)}',
          '{(scow %t id)}')
        """
      ;div.label
        ;span.issuer:"{(trip issuer)}"
        ;br;
        ;span.id:"{(trip id)}"
      ==
      ;div.code.totp
        ; [click to load & copy new code]
      ==
    ==
  --
--
