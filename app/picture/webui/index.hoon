::  picture upload page
::
/+  multipart
::
|_  [=bowl:gall ~]
++  argue
  |=  arg=[header-list:http (unit octs)]
  ^-  (unit (unit mime))
  =/  args=(unit (list [@t part:multipart]))
    (de-request:multipart arg)
  ?~  args  ~
  ?.  ?=([~ [%image *] ~] args)  ~
  =*  image=part:multipart  +.i.u.args
  ?:  =('' body.image)  [~ ~]
  ?~  type.image  ~
  ``[(need type.image) (as-octs:mimes:html body.image)]
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  manx
  ::NOTE  we would auto-close the window on-success...
  ::      except browsers don't let us, because we weren't opened by a script.
  |^  page
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }
    p { max-width: 50em; }
    form { margin: 0; padding: 0; }
    button { padding: 0.2em 0.5em; }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%picture"
        ;meta(charset "utf-8");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h2:"%picture selection"

        Upload a new picture, or simply remove the existing one.

        Your browser may cache the picture. If the old one sticks
        around after uploading a new one, perform a hard refresh.

        Be careful not to upload crazy big files, this could put
        your ship under memory pressure.

        ;+  ?~  msg  ;p:""
            ?:  o.u.msg
              ;p.green:"{(trip t.u.msg)}"
            ;p.red:"{(trip t.u.msg)}"

        ;form(method "post", enctype "multipart/form-data")
          ;label
            ;+  :/"image: "
            ;input(type "file", name "image", accept "image/*");
          ==
          ;br;
          ;button(type "submit"):"upload"
        ==

        ;br;

        ;form(method "post", enctype "multipart/form-data")
          ;input(type "hidden", name "image");
          ;button(type "submit"):"remove"
        ==
      ==
    ==
  --
--
