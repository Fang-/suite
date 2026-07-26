::  cliff: clay exposed
::
::    viewing, editing, down- and uploading of filesystem contents
::
::TODO  code quality
::
/+  multipart, server, dbug, verb, default-agent
::
|%
+$  state-0  [%0 pend=(map eyre-id [=mode =beam])]  ::  posts pending response
::
+$  mode
  ::TODO  %tree view?
  $?  %view  %edit  ::  w/ wrapper ui
      %down  %load  ::  raw down/upload
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
%-  agent:dbug
%+  verb  |
::
=<  ^-  agent:gall
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    :_  this
    [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
  ::
  ++  on-save  !>(state)
  ::
  ++  on-load
    |=  ole=vase
    ^-  (quip card _this)
    =/  old=state-0  !<(state-0 ole)
    =.  pend.old  ~
    [~ this(state old)]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
      ::  %handle-http-request: incoming from eyre
      ::
        %handle-http-request
      :_  this
      =,  mimes:html
      =+  !<([=eyre-id =inbound-request:eyre] vase)
      ?.  authenticated.inbound-request
        ::TODO  depend on publicness of requested file?
        ::TODO  probably put a function for this into /lib/server
        ::      we can't use +require-authorization because we also emit cards
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
      ::  out: page or edit
      ::
      =;  out=(each simple-payload:http [l=@t c=(list card)])
        ?-  -.out
          %&  (give-simple-payload:app:server eyre-id p.out)
          %|  %+  weld  c.p.out
              %+  give-simple-payload:app:server  eyre-id
              [[303 ['location' l.p.out]~] ~]
        ==
      ::  500 to all unexpected requests
      ::
      ?.  &(?=(^ site) =(dap.bowl i.site))
        [%& [500 ~] `(as-octs 'unexpected route')]
      ::  400 to all invalid requests
      ::
      =*  invalid  [%& [400 ~] `(as-octs 'invalid route')]
      ::TODO  support viewing foreign desks?
      ?.  ?=([mode %our @ @ *] t.site)
        invalid
      ?^  ext  invalid
      =/  cus=(unit case)
        =+  (de-case i.t.t.t.t.site)
        ?+  -  ~
          [~ ?(%ud %da) @]  -
          [~ %tas %now]     `da+now.bowl
        ==
      ?~  cus    invalid
      =/  =mode  i.t.site
      =/  =ship  our.bowl
      =/  =desk  i.t.t.t.site
      =/  =case  u.cus
      =/  =path  t.t.t.t.t.site
      ?:  &(!=(~ path) =(~ (rear path)))  invalid  ::  reject trailing /
      ::
      =*  beam  [[ship desk case] path]
      =+  go=~(. work bowl mode beam)
      ?-  mode
        %view  [%& (view:go request.inbound-request)]
        %edit  (edit:go request.inbound-request)
        %down  [%& (down:go request.inbound-request)]
        %load  (load:go request.inbound-request)
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ::NOTE  deliberately no =(our src) assertion here. eyre subscribes to
    ::      /http-response on our behalf using the _requester's_ identity,
    ::      which for a logged-out visitor is a synthesized comet. asserting
    ::      crashes the subscription, 500s every unauthenticated request, and
    ::      makes the login redirect in +on-poke unreachable.
    ?+  path  (on-watch:def path)
      [%http-response *]  [~ this]
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  wire  (on-arvo:def wire sign-arvo)
        [%eyre %connect ~]
      ?>  ?=([%eyre %bound *] sign-arvo)
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
::
|%
::  +ctype: content type for marks we know cast to %mime
::
::    membership doubles as the allowlist for building a mark->mime tube.
::    there is no way to ask clay whether a cast exists without building it,
::    and a failed build crashes uncatchably, so an explicit list is the only
::    crash-free option. marks absent here still download via +raw; they just
::    don't get a tube. covers %base and %yard as of 408K.
::
++  ctype
  |=  =mark
  ^-  (unit mite)
  ?+  mark  ~
    ::  text
    %txt         `/text/plain
    %hoon        `/text/x-hoon
    %css         `/text/css
    %js          `/text/javascript
    %json        `/application/json
    %html        `/text/html
    %hymn        `/text/html
    %xml         `/text/xml
    %csv         `/text/csv
    ::  '+' isn't a legal knot character, so this one can't be a path literal
    %svg         [~ `mite`~['image' 'svg+xml']]
    ::  images
    %png         `/image/png
    %jpg         `/image/jpeg
    %jpeg        `/image/jpeg
    %gif         `/image/gif
    %bmp         `/image/bmp
    %ico         `/image/x-icon
    %tiff        `/image/tiff
    %webp        `/image/webp
    ::  audio
    %mp3         `/audio/mpeg
    %wav         `/audio/wav
    %ogg         `/audio/ogg
    %oga         `/audio/ogg
    %flac        `/audio/flac
    %aac         `/audio/aac
    %weba        `/audio/webm
    %mid         `/audio/midi
    ::  video
    %mp4         `/video/mp4
    %webm        `/video/webm
    %ogv         `/video/ogg
    %mpeg        `/video/mpeg
    %avi         `/video/x-msvideo
    ::  fonts
    %ttf         `/font/ttf
    %otf         `/font/otf
    %woff2       `/font/woff2
    ::  documents
    %pdf         `/application/pdf
    %pem         `/application/x-pem-file
    %wasm        `/application/wasm
    ::  urbit-native, rendered as text
    ?(%atom %bill %kelvin %noun %ship %snip %story)  `/text/plain
    ?(%docket-0 %jam %map %udon %umd %urb)           `/text/plain
    %noun-autodiff                                   `/text/plain
  ==
::
++  work
  |_  [bowl:gall =mode =beam]
  ++  arch  ~+  .^(^arch %cy rend)
  ++  tree  ~+  .^((list path) %ct rend)
  ++  cass  ~+  .^(cass:clay %cw rend)
  ++  last  ~+  ud:.^(cass:clay %cw rend(r.beam da+now))
  ++  rend  ~+  (en-beam beam)
  ::
  ++  fils  ?=(^ [fil:arch])  ::TODO  why are the [] needed?
  ++  have  &(fils live)      ::  a file whose data we can still read
  ++  gone  &(fils !live)     ::  a file whose data has been tombstoned
  ++  peak  ?=(~ s.beam)
  ::
  ::  +live: whether this node's data is still in the store
  ::
  ::    a tombstoned file still shows up in the %cy arch with its lobe
  ::    intact, but %cx/%cq on it crashes -- and that crash bails the whole
  ::    event, escaping virtualization, so it cannot be caught with +mule.
  ::    we have to ask before reading.
  ::
  ++  live  ~+
    ^-  ?
    ?.  fils  |
    .^  ?  %cx
        %+  weld
          `path`[(scot %p our) %$ (scot %da now) %tomb ~]
        rend
    ==
  ::
  ++  free
    %+  turn  (sort ~(tap in ~(key by dir:arch)) aor)
    |=  k=@ta
    ^-  [dir=? path]
    =+  naf=(snoc s.beam k)
    =+  arf=arch(s.beam naf)
    ?^  fil.arf              [| /[k]]
    ?.  ?=([^ ~ ~] dir.arf)  [& /[k]]
    ::TODO  make tail recursive
    =+  dep=$(s.beam naf, k p.n.dir.arf)
    [-.dep k +.dep]
  ::
  :: ++  curb  ?+  -.r.beam  !!  ::TODO  as wrapper function
  ::             %ud  (gth p.r.beam ud:.^(cass:clay %cw rend(r.beam da+now)))
  ::             %da  (gth p.r.beam now)
  ::           ==
  ::
  ::
  ++  sput  ~+  (spud dap mode spot)
  ++  spot  ~+
    ^-  path
    =+  ?:(=(da+now r.beam) rend(r.beam tas+%now) rend)
    ?.  =(p.beam our)  -
    [%our (slag 1 -)]
  ::
  ++  show  ~+
    ^-  (unit mime)
    ?.  have  ~  ::  absent, or tombstoned
    =/  =mark  (rear s.beam)
    ::  %mime needs no mark build at all, clay special-cases it
    ::
    ?:  =(%mime mark)  `.^(mime %cx rend)
    ::  detect tube scry failures ahead of time, per the TODO that used to
    ::  live here. building a mark the desk doesn't carry, or one with no
    ::  mime cast, crashes uncatchably (see +live), so we never build one
    ::  we aren't confident in, and read typelessly instead.
    ::
    ?.  &(?=(^ (ctype mark)) .^(? %cu rend(r.beam da+now, s.beam /mar/[mark]/hoon)))
      (raw mark)
    =;  =tube:clay
      `!<(mime (tube .^(vase %cr rend)))
    ::NOTE  because %c scries crash on older revisions, we do a best-effort
    ::      here by using the current mark definition instead.
    ::      eventually, clay should be patched to support historic %c,
    ::      and this should be updated to not use da+now.
    .^(tube:clay %cc rend(r.beam da+now, s.beam /[mark]/mime))
  ::
  ::  +raw: typeless read, for files whose mark we can't safely build
  ::
  ::    %cq hands back the stored noun without touching marks, so it works
  ::    on any desk. atom-shaped marks (most binary formats) serve directly;
  ::    anything structured we decline to render rather than guess.
  ::
  ++  raw
    |=  =mark
    ^-  (unit mime)
    =/  dat  .^(* %cq rend)
    ?.  ?=(@ dat)  ~
    `[(fall (ctype mark) /application/octet-stream) [(met 3 dat) dat]]
  ::
  ::
  ++  view
    |=  request:http
    ^-  simple-payload:http
    ?.  ?=(%'GET' method)  deny
    (page ~)
  ::
  ++  edit
    |=  request:http
    ^-  (each simple-payload:http [loc=@t (list card)])
    ::  editing only makes sense against the head of the desk. now that
    ::  historical cases render, this is reachable by hand, so decline it
    ::  politely instead of crashing.
    ?.  =(da+now r.beam)  [%& wack]
    ?+  method  [%& deny]
      %'GET'   [%& (page ~)]
    ::
        %'POST'
      =/  are=(unit (map @t @t))
        ?~  body  ~
        %+  bind
          (rush q.u.body yquy:de-purl:html)
        ~(gas by *(map @t @t))
      ?~  are  [%& wack]
      =*  arm  u.are
      ?:  (~(has by arm) 'cancel')
        [%| (crip sput(mode %view)) ~]
      ?:  (~(has by arm) 'delete')
        :+  %|  (crip sput)
        [%pass /edit/delete %arvo %c %info (fray:space:userlib rend)]~
      ?.  (~(has by arm) 'save')  [%& wack]
      ?.  (~(has by arm) 'file')  [%& wack]
      :+  %|  (crip sput)
      :_  ~
      :+  %pass  /edit/save
      :+  %arvo  %c
      =;  =mime
        [%info (foal:space:userlib rend %mime !>(mime))]
      :-  /application/x-urb-unknown
      %-  as-octt:mimes:html
      %+  rash  (~(got by arm) 'file')
      (star ;~(pose (cold '\0a' (jest '\0d\0a')) next))
    ==
  ::
  ++  down
    |=  request:http
    ^-  simple-payload:http
    ?.  ?=(%'GET' method)  deny
    =+  m=show
    ?~  m  miss
    :_  `q.u.m
    [200 ['content-type'^(en-mite:mimes:html p.u.m)]~]
  ::
  ++  load
    |=  request:http
    ^-  (each simple-payload:http [loc=@t (list card)])
    ?.  ?=(%'POST' method)  [%& `simple-payload:http`deny]
    ~|  [%edit-must-be-now r.beam]
    ?>  =(da+now r.beam)
    =/  are=(unit (map @t part:multipart))
      %+  bind
        (de-request:multipart header-list body)
      ~(gas by *(map @t part:multipart))
    !!  ::TODO  implement
  ::
  ++  deny  [[405 ~] `(as-octs:mimes:html 'method not allowed')]
  ++  miss  [[404 ~] `(as-octs:mimes:html 'file not found')]
  ++  wack  [[400 ~] `(as-octs:mimes:html 'invalid request')]
  ::
  ::  page: renders file/directory content alongside metadata
  ::
  ::    page structure is roughly as follows:
  ::    interactive beam
  ::    directory navigator  ::TODO  should be desk-wide tree instead?
  ::    if file: contents
  ::    if file: metadata: last revision?, noun size, permissions
  ::
  ++  page
    |=  msg=(unit @t)
    =/  edit=?  =(%edit mode)
    ^-  simple-payload:http
    :-  [200 ['content-type'^'text/html']~]
    |^  `(as-octt:mimes:html (en-xml:html full))
    ::
    ++  style
      '''
      * { font-family: monospace; }
      pre { margin: 0; }
      a { text-decoration: none; color: #841; }

      header > div { display: inline-block; }
      .control { float: right; }

      body {
        margin: 0;
        padding: 0;
        width: 100vw;
        height: 100vh;
        display: flex;
        flex-direction: column;
      }

      header, footer {
        margin: 0.5em 1.2em;
        padding: 0;
      }

      header a {
        font-size: 1.5em;
        vertical-align: middle;
      }

      section {
        flex-basis: 0;
        flex-grow: 1;
        margin: 0 1em;
      }

      section, textarea {
        overflow: scroll;
        padding: 1em;
        border: 1px solid grey;
        border-radius: 3px;
      }

      section.body {
        flex-grow: 3;
      }

      section.edit {
        padding: 0em;
        border: none;
      }

      section.edit form {
        height: 100%;
        width: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
      }

      section.edit .container {
        flex-basis: 0;
        flex-grow: 1;
      }

      section.edit textarea {
        width: 100%;
        height: 100%;
      }

      section.edit button {
        margin: 0.5em;
      }

      section.directory > a {
        display: inline-block;
        border: 1px solid grey;
        border-radius: 2px;
        padding: 1em;
        margin: 0.5em;
      }

      footer {
        color: grey;
      }
      '''
    ::
    ++  full
      ^-  manx
      ;html
        ;head
          ;title:"%cliff: {spot}"
          ;meta(charset "utf-8");
          ;meta(name "viewport", content "width=device-width, initial-scale=1");
          ;style:"{(trip style)}"
        ==
        ;body
          ;+  site
          ;+  dile
          ;+  ::TODO  msg
              body
          ;+  meta
        ==
      ==
    ::
    ::TODO  intended behavior:
    ::  - "up" navigation always available
    ::  - dropdown selection for desk
    ::  - input field for case
    ::  - clickable parent path elements
    ::  - gap
    ::  - download, upload and edit buttons if mime-able
    ++  site
      ^-  manx
      ::
      ;header
        ;div.path
          ; / {(scow %p p.beam)} /
          ;select
            =onchange  """
                       window.location.href =
                       '/{(trip dap)}/{(trip mode)}/our/'
                       + this.value +
                       '{(spud (slag 2 spot))}';
                       """
            ::NOTE  pinned to now: clay's empty-desk fast path only applies at
            ::       [%da now], and off it this scry crashes the whole event.
            ::       the desk list is a property of the ship, not of the
            ::       revision being browsed, so now is also the correct case.
            ;*  %+  turn
                  =/  bem  rend(q.beam %$, r.beam da+now, s.beam ~)
                  (sort ~(tap in .^((set desk) %cd bem)) aor)
                |=  d=desk
                =+  p=(trip d)
                ?.  =(d q.beam)
                  ;option(value p):"\%{p}"
                ;option(selected "", value p):"\%{p}"
          ==
          ;
          ; /
          ; {?:(=(da+now r.beam) "now" (scow r.beam))}
          ::TODO  how to make this work?
          :: ;form
          ::   =style  "display: inline; margin: 0; padding: 0;"
          ::   =onsubmit  """
          ::              console.log('aaabb') &&
          ::              (e) => \{
          ::                console.log('aaa', e);
          ::                alert('hi');
          ::                e.preventDefault(); window.location.href =
          ::                {(spud (scag 2 spot))} +
          ::                '/' + e.target.value + {(spud (slag 3 spot))};
          ::              }
          ::              """
          ::   ;input(style "max-width: 80px;")
          ::     =value  "{?:(=(da+now r.beam) "now" (scow r.beam))}";
          :: ==
          ;
          ;*  %+  turn  (snip s.beam)
              |=  n=@ta
              ;span  ::TODO  ;a
                ; / {(trip n)}
              ==
          ;+  ?~  s.beam  :/""
              :/"/ {(trip (rear s.beam))}"
        ==
        ;
        ;+  ?:  =(~ s.beam)  :/""
            ;a/"{sput(s.beam (snip s.beam))}"(title "navigate up"):"↖️"
        ;
        ;div.control
          ;+  ?.  have  :/""
              ;a/"{sput(mode %down)}"
                =id  "download"
                =download  "{(join '.' (flop (scag 2 (flop s.beam))))}"
                =title  "download this file"
                ; ⬇️
              ==
          ;
          ;+  ?:  edit
                ;a/"{sput(mode %view)}"
                  =id  "view"
                  =title  "view this file"
                  ; 📄
                ==
              ::  only the head of the desk is editable
              ?.  =(da+now r.beam)  :/""
              ;a/"{sput(mode %edit)}"
                =id  "edit"
                =title  "edit this file"
                ; ✏️
              ==
          ::TODO  support
          :: ;form(style "display: inline;")
          ::   =method   "post"
          ::   =action   sput(mode %load)
          ::   =enctype  "multipart/form-data"
          ::   ;input(type "file", name "file");
          ::   ;button(type "submit"):"⬆️"
          :: ==
        ==
      ==
    ::
    ++  dile
      ^-  manx
      ?:  edit  :/""
      ?~  [dir:arch]  :/""
      ;section.directory
        ;+  ?:  peak  :/""
            ;a/"{sput(s.beam (snip s.beam))}"
              ; ..
            ==
        ;*  %+  turn
              free  ::  could sort here for dir>file sorting
            |=  [d=? p=path]
            =/  s=tape  (slag 1 (spud p))
            =?  s  d  (snoc s '/')
            ;a/"{sput(s.beam (weld s.beam p))}":"{s}"
      ==
    ::
    ::TODO  display appropriate message if case is in the future
    ++  body
      ^-  manx
      =/  bod=(unit mime)  show
      ?:  edit
        ;section.body.edit
          ;form(method "post")
            ;div.container
              ;textarea(name "file")
                ;+  :/(trip q.q:(fall bod *mime))
              ==
            ==
            ;div
              ;button(type "submit", name "save"):"save"
              ;button(type "submit", name "cancel"):"cancel"
              ;button(type "submit", name "delete"):"delete"
            ==
          ==
        ==
      ?:  gone
        ;section.fail
          ; this file's data has been tombstoned
        ==
      ?.  have
        ?^  [dir:arch]  :/""
        ;section.fail
          ; no data at this path
        ==
      ?~  bod
        ;section.fail
          ; this file could not be displayed
        ==
      ;section.body
        ;pre:"{(trip q.q.u.bod)}"
      ==
    ::
    ++  meta
      ^-  manx
      =/  bod=(unit mime)  show
      ::TODO  need to find a nice way to do conditional inline text
      ;footer
        ;span(title "case")
          ; rev {(scow %ud ud:cass)} @
          ; {(scow %da =+(da:cass (sub - (mod - ~s1))))},
        ==
        ;+  ?^  bod
              ;span(title "size")
                ; {(scow %ud p.q.u.bod)} bytes
              ==
            ?:  gone
              ;span(title "state")
                ; tombstoned
              ==
            ?:  fils
              ;span(title "state")
                ; unreadable
              ==
            ;span(title "tree")
              ; {(scow %ud ~(wyt by dir:arch))} items
            ==
      ==
    --
  --
--
