::  fafa/add.hoon: factor addition
::
/-  *fafa
/+  *otp
::
|_  [bowl:gall keys=(map label secret)]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  (unit action)
  ~&  [%body body]
  ?~  body  ~
  =/  args=(map @t @t)
    %-  ~(gas by *(map @t @t))
    (fall (rush q.u.body yquy:de-purl:html) ~)
  ::
  ?:  (~(has by args) 'uri')
    =-  ~&  [%uri (~(got by args) 'uri') -]  -
    %+  rush  (~(got by args) 'uri')
    (stag %add puri)
  ::
  ?.  (~(has by args) 'secret')  ~
  ?.  (~(has by args) 'issuer')  ~
  ?.  (~(has by args) 'id')      ~
  ?~  key=(rush (~(got by args) 'secret') bask)
    ~
  %-  some
  :+  %add
    [(~(got by args) 'issuer') (~(got by args) 'id')]
  %*(. *secret key u.key)
::
++  build
  |=  [args=(list [k=@t v=@t]) msg=(unit [? @t])]
  =.  keys  (~(put by keys) ['issuer' 'my acount'] *secret)
  =.  keys  (~(put by keys) ['issuer2' 'etc acount'] *secret)
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

    #status {
      display: block;
      border: 1px solid black;
      border-radius: 2px;
      margin: 1em;
      padding: 1em;
      background-color: white;
      color: black;
      text-decoration: none;
      border-width: 1px 3px;
    }

    #scanner>button, #manual>button {
      display: block;
      margin: 1em auto;
    }

    #scanner {
      padding: 0 1em;
    }
    #cam {
      display: block;
      margin: 1em auto;
      border: 2px solid black;
      border-radius: 3px;
    }
    #cam.success {
      border: 2px solid lightgreen;
    }

    form table {
      margin: 0 auto;
    }

    form table tr:first-child {
      text-align: right;
    }

    input {
      margin: 0.2em 0.5em;
    }
    '''
  ::
  ++  script
    '''
    let status, bat, cam;

    function prep() {
      status = document.getElementById('status');
      manual = document.getElementById('manual');
      scanner = document.getElementById('scanner');
      cam = document.getElementById('cam');

      if (!('BarcodeDetector' in window)) {
        showMsg('barcode detector not supported. ' +
                'for best ux, use a chrome-based mobile browser ' +
                'and a secure connection.');
        document.getElementById('scantoggle').setAttribute('class', 'disabled');
        toggleInput();
        return;
      }

      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        showMsg('no camera available for scanning qr code.');
        document.getElementById('scantoggle').setAttribute('class', 'disabled');
        toggleInput();
        return;
      }

      bat = new BarcodeDetector({formats: ['qr_code']});

      navigator.mediaDevices.getUserMedia({
          video: { facingMode: 'environment' },
          audio: false
      }).then(stream => {
        cam.srcObject = stream;
      });

      setTimeout(() => setInterval(detect, 1000), 2000);
    }

    function toggleInput() {
      let a = scanner.getAttribute('class');
      scanner.setAttribute('class', manual.getAttribute('class'));
      manual.setAttribute('class', a);
      //TODO  should maybe unload the camera feed?
    }

    function detect() {
      bat.detect(cam).then(codes => {
        if (codes.length === 0) return;
        cam.setAttribute('class', 'success');
        document.getElementById('uri').value = codes[0].rawValue;
        document.getElementById('scannerform').submit();
      }).catch(e => showMsg('Detection error: ' + e));
    }

    function showMsg(text) {
      status.innerHTML = text;
      status.setAttribute('class', '');
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
            ;a(href "/fafa")
              ;h1:"fafa authenticator"
            ==
          ==
          ;+  ?~  msg  ;div#status.disabled;
              ;div#status:"{(trip +.u.msg)}"
          ;div#entry
            ;div#scanner
              ;video#cam(width "100%", height "auto", autoplay "");
              ;button(onclick "toggleInput()"):"input manually"
              ;form#scannerform.disabled(method "post")
                ;input#uri(name "uri", type "text", readonly "");
              ==
            ==
            ;div#manual.disabled
              ;button#scantoggle(onclick "toggleInput()"):"scan qr code"
              ;form(method "post")  ;table
                ;tr
                  ;td  ;label(for "secret"):"secret"  ==
                  ;td  ;input(name "secret", type "text", placeholder "SOMEBASE32");  ==
                ==
                ;tr
                  ;td  ;label(for "issuer"):"service"  ==
                  ;td  ;input(name "issuer", type "text", placeholder "pal.dev");  ==
                ==
                ;tr
                  ;td  ;label(for "id"):"account"  ==
                  ;td  ;input(name "id", type "text", placeholder "SOMEBASE32");  ==
                ==
                ;tr
                  ;td;
                  ;td  ;input(type "submit", value "add");  ==
                ==
              ==  ==
            ==
          ==
        ==
      ==
    ==
  --
--
