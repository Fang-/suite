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
      %perm         ::  w/ wrapper ui, permissions
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
        %perm  [%& (perm:go request.inbound-request)]
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
::  +limit: largest upload we'll accept, to keep a stray POST from
::          committing something enormous into a desk
::
++  limit  (bex 23)  ::  8MiB
::
::  +walk: how many paths we'll check for explicit rules in one page
::
::    a %cp costs around 2ms, and a desk root can easily have several hundred
::    candidate paths, so this is bounded and the page says when it truncated.
::
++  walk  512
::
::  +ships: "~zod, ~nec", for rule membership
::
++  ships
  |=  who=(set ship)
  ^-  tape
  ::  sorted on the rendered name, not the raw @p, so the order reads the way
  ::  it looks
  =/  nam=(list tape)
    %+  sort  `(list tape)`(turn ~(tap in who) |=(p=ship (scow %p p)))
    aor
  |-  ^-  tape
  ?~  nam    ""
  ?~  t.nam  i.nam
  :(weld i.nam ", " $(nam t.nam))
::
::  +dull: the rule clay falls back to when nothing is set anywhere
::
++  dull  `real:clay`[%white ~ ~]
::
::  +owns: whether a rule is really set at pax, as opposed to inherited
::
::    a dict's src is the path its rule was found at, so src == pax normally
::    means "set here".  the exception is the desk root: clay hands back
::    src=/ with a hardcoded empty whitelist when no rule exists anywhere,
::    which is indistinguishable from someone having set that same rule at /.
::    we call the ambiguous case unset -- it's the weaker claim, and the two
::    are identical in effect regardless.
::
++  owns
  |=  [pax=path =dict:clay]
  ^-  ?
  ?.  =(pax src.dict)  |
  !&(?=(~ pax) =(rul.dict dull))
::
::  +gist: what a resolved rule actually means, in one phrase
::
::    an empty whitelist admits no one and an empty blacklist admits everyone,
::    which is easy to read backwards off the raw noun -- hence spelling it out.
::
++  gist
  |=  rul=real:clay
  ^-  tape
  =/  shp=@ud  ~(wyt in p.who.rul)
  =/  cru=@ud  ~(wyt by q.who.rul)
  ?:  &(=(0 shp) =(0 cru))
    ?:(=(%black mod.rul) "public" "private")
  =/  who=tape
    ;:  weld
      ?:(=(0 shp) "" "{(scow %ud shp)} ship{?:(=(1 shp) "" "s")}")
      ?:(|(=(0 shp) =(0 cru)) "" " and ")
      ?:(=(0 cru) "" "{(scow %ud cru)} crew{?:(=(1 cru) "" "s")}")
    ==
  ?:(=(%black mod.rul) "everyone except {who}" "only {who}")
::
::  +kin: the marks a given mark needs in order to build, dependencies first
::
::    a mark written as `++grad %foo` delegates its diff to mark %foo, and
::    clay builds %foo to build it -- so installing one means installing the
::    other. a mark whose ++grad is an inline core is terminal, even when its
::    ++form names another mark: %txt says `++form %txt-diff` but builds fine
::    without mar/txt-diff, because the name is never resolved as a mark.
::    that makes every chain here exactly one deep.
::
::    derived from the marks cliff vendors, so this arm and
::    pkg/cliff/dep.txt have to move together.
::
++  kin
  |=  =mark
  ^-  (list ^mark)
  ?+  mark  ~[%mime mark]  ::  the large majority grad to %mime
    ::  inline ++grad cores: nothing further to build
    ?(%mime %noun %txt)                                ~[mark]
    ::  ++grad %noun
    ?(%bill %docket-0 %hymn %kelvin %ship %snip %urb)  ~[%noun mark]
    %txt-diff                                          ~[%noun mark]
    ::  ++grad %txt
    ?(%hoon %udon %umd)                                ~[%txt mark]
  ==
::
::  +safe: coerce arbitrary text into something usable as a path element
::
++  safe
  |=  t=@t
  ^-  @ta
  %-  crip
  %+  turn  (trip t)
  |=  c=@tD
  ^-  @tD
  ?:  &((gte c 'A') (lte c 'Z'))  (add c 32)
  ?:  ?|  &((gte c 'a') (lte c 'z'))
          &((gte c '0') (lte c '9'))
          =('-' c)
      ==
    c
  '-'
::
::  +splt: filename -> [name mark], as clay path elements
::
::    clay has no notion of an extension: foo.png is the file /foo/png, whose
::    mark is png. so the extension is load-bearing, and a file without one
::    leaves us no mark to write it under.
::
++  splt
  |=  fil=@t
  ^-  (unit [nam=@ta =mark])
  =/  t=tape  (trip fil)
  ::  split on the last dot
  ?~  dex=(find "." (flop t))  ~  ::  no extension, so no mark
  =/  cut=@ud  (sub (lent t) +(u.dex))
  =/  nam=@ta  (safe (crip (scag cut t)))
  =/  ext=@ta  (safe (crip (slag +(cut) t)))
  ?:  |(=('' ext) =('' nam))  ~
  `[nam ext]
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
  ++  perm
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
  ::  +pear: read and write permissions in force at this node
  ::
  ::    pinned to now on purpose. clay's %cp ignores the case entirely --
  ::    +read-p takes only a path -- so permissions are always current state,
  ::    never historical. asking at the browsed case would imply a history
  ::    clay doesn't keep, so we ask at now and label it as such in the ui.
  ::
  ++  pear  ~+
    ^-  [red=dict:clay wit=dict:clay]
    .^([dict:clay dict:clay] %cp rend(r.beam da+now))
  ::
  ::  +sown: explicit rules at or under this node
  ::
  ::    clay exposes no way to enumerate its regs, so we reconstruct them: a
  ::    dict's src is the path its rule was found at, so src == path is
  ::    exactly "there's an explicit rule here". candidates are every prefix
  ::    of every file at or below us, which misses rules set on paths with no
  ::    files under them -- the only blind spot, and not one clay lets us fix.
  ::
  ++  sown  ~+
    ^-  [more=? out=(list [=path red=(unit real:clay) wit=(unit real:clay)])]
    =/  wid=@ud  (lent s.beam)
    =/  can=(list path)
      %~  tap  in
      %-  ~(gas in *(set path))
      %-  zing
      %+  turn  tree
      |=  p=path
      ^-  (list path)
      ?.  (gte (lent p) wid)  ~
      (turn (gulf wid (lent p)) |=(n=@ud (scag n p)))
    :-  (gth (lent can) walk)
    %+  murn  (scag walk (sort can aor))
    |=  p=path
    ^-  (unit [path (unit real:clay) (unit real:clay)])
    =/  d  .^([red=dict:clay wit=dict:clay] %cp rend(r.beam da+now, s.beam p))
    =/  red=(unit real:clay)  ?:((owns p red.d) `rul.red.d ~)
    =/  wit=(unit real:clay)  ?:((owns p wit.d) `rul.wit.d ~)
    ?:  &(?=(~ red) ?=(~ wit))  ~
    `[p red wit]
  ::
  ::  +want: which of a mark's dependencies the target desk is missing
  ::
  ++  want
    |=  =mark
    ^-  (list ^mark)
    %+  skip  (kin mark)
    |=  m=^mark
    .^(? %cu rend(r.beam da+now, s.beam /mar/[m]/hoon))
  ::
  ::  +vend: source for a mark cliff carries, to install on another desk
  ::
  ++  vend
    |=  =mark
    ^-  (unit @t)
    =/  pax=path  /(scot %p our)/[q.byk]/(scot %da now)/mar/[mark]/hoon
    ?.  .^(? %cu pax)  ~
    `.^(@t %cx pax)
  ::
  ++  load
    |=  request:http
    ^-  (each simple-payload:http [loc=@t (list card)])
    ?.  ?=(%'POST' method)  [%& `simple-payload:http`deny]
    ::  uploads only make sense against the head of the desk
    ?.  =(da+now r.beam)  [%& `simple-payload:http`wack]
    ?~  par=(de-request:multipart header-list body)
      [%& (oops "expected a multipart/form-data upload")]
    (take (~(gas by *(map @t part:multipart)) u.par))
  ::
  ::  +take: commit an uploaded file, with the marks it needs
  ::
  ::    clay validates every changed file at commit time, building its mark to
  ::    do so, so a file can't land on a desk that doesn't carry its mark. we
  ::    put the marks and the file in a single %info, which commits atomically:
  ::    either the desk gains a working file or it gains nothing.
  ::
  ++  take
    |=  arm=(map @t part:multipart)
    ^-  (each simple-payload:http [loc=@t (list card)])
    ?~  fil=(~(get by arm) 'file')
      [%& (oops "no file was submitted")]
    ?~  file.u.fil
      [%& (oops "the upload had no filename")]
    =*  nom  (trip u.file.u.fil)
    ?:  =(0 size.u.fil)
      [%& (oops "{nom} is empty")]
    ?:  (gth size.u.fil limit)
      [%& (oops "{nom} is larger than the {(scow %ud (rsh 3^10 limit))}KiB limit")]
    ?~  spl=(splt u.file.u.fil)
      [%& (oops "can't derive a mark from {nom} - it needs an extension")]
    =*  nam  nam.u.spl
    =*  mak  mark.u.spl
    ::  a mark over a bare atom cannot hold trailing NUL bytes -- an atom has
    ::  no high-order zeros, so they're gone the moment we hand them over, and
    ::  the mark's ++grow recomputes the length with +met on the way back out.
    ::  %mime is the exception: it stores octs, which carry the length. refuse
    ::  rather than quietly hand back a shorter file than we were given.
    ::
    =/  nul=@ud  (sub size.u.fil (met 3 body.u.fil))
    ?:  &(!=(%mime mak) !=(0 nul))
      :-  %&
      %-  oops
      ;:  weld
        "{nom} ends in {(scow %ud nul)} NUL byte"  ?:(=(1 nul) "" "s")
        ", which the %{(trip mak)} mark can't store - marks over a bare atom "
        "have no high-order zeros.  rename it to end in .mime to store it "
        "byte-for-byte instead."
      ==
    ::  marks the target desk is missing, and whether we may add them
    ::
    =/  gap=(list mark)  (want mak)
    =/  yea=?            (~(has by arm) 'marks')
    ?:  &(?=(^ gap) !yea)
      :-  %&
      %-  oops
      ;:  weld
        "%{(trip q.beam)} doesn't carry "
        (mark-list gap)
        ", which {nom} needs.  "
        "tick \"install missing marks\" to add "
        ?:(?=([* ~] gap) "it" "them")  " to the desk."
      ==
    =/  new=(list [=mark src=@t])
      %+  murn  gap
      |=(m=mark ^-((unit [mark @t]) ?~(s=(vend m) ~ `[m u.s])))
    ?.  =((lent new) (lent gap))
      :-  %&
      %-  oops
      "cliff has no source for {(mark-list gap)}, so it can't install {?:(?=([* ~] gap) "it" "them")}."
    ::
    =/  tar=path  (weld s.beam /[nam]/[mak])
    =/  =mime
      :_  [size body]:u.fil
      (fall type.u.fil (fall (ctype mak) /application/octet-stream))
    :-  %|
    :-  (crip sput(mode %view, s.beam tar))
    :_  ~
    :+  %pass  /load/save
    :+  %arvo  %c
    :+  %info  q.beam
    :-  %&
    %+  weld
      ^-  soba:clay
      %+  turn  new
      |=([m=mark src=@t] ^-([path miso:clay] [/mar/[m]/hoon %ins %hoon !>(src)]))
    ^-  soba:clay
    [tar (feel:space:userlib rend(s.beam tar) %mime !>(mime))]~
  ::
  ::  +mark-list: "%png and %mime", for error text
  ::
  ++  mark-list
    |=  mus=(list mark)
    ^-  tape
    =/  nam=(list tape)  (turn mus |=(m=mark "%{(trip m)}"))
    |-  ^-  tape
    ?~  nam        ""
    ?~  t.nam      i.nam
    ?~  t.t.nam    "{i.nam} and {i.t.nam}"
    "{i.nam}, {$(nam t.nam)}"
  ::
  ++  deny  [[405 ~] `(as-octs:mimes:html 'method not allowed')]
  ++  miss  [[404 ~] `(as-octs:mimes:html 'file not found')]
  ++  wack  [[400 ~] `(as-octs:mimes:html 'invalid request')]
  ::
  ::  +oops: re-render this node with an error banner
  ::
  ::    rendered as %view: we're answering a POST, and the page's own links
  ::    would otherwise all point back at the POST-only route we came in on.
  ::
  ++  oops
    |=  msg=tape
    ^-  simple-payload:http
    =/  pay=simple-payload:http  (page(mode %view) `(crip msg))
    pay(status-code.response-header 400)
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

      form.upload {
        display: inline;
        margin-left: 1em;
      }

      form.upload label {
        font-size: 0.8em;
      }

      section.perm h3 {
        margin: 0 0 0.2em 0;
        font-size: 1em;
      }

      section.perm .rule, section.perm .sown {
        margin-bottom: 1.5em;
      }

      section.perm .gist {
        font-size: 1.2em;
      }

      section.perm .from, footer .from {
        color: grey;
      }

      section.perm .warn {
        color: #841;
      }

      section.perm ul.who {
        margin: 0.3em 0;
        padding-left: 1.5em;
      }

      section.perm table {
        border-collapse: collapse;
      }

      section.perm th, section.perm td {
        text-align: left;
        padding: 0.1em 1.5em 0.1em 0;
      }

      section.perm th {
        color: grey;
        font-weight: normal;
      }

      section.note {
        flex-grow: 0;
        flex-basis: auto;
        color: #841;
        border-color: #841;
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
          ;+  ?~  msg  :/""
              ;section.note
                ; {(trip u.msg)}
              ==
          ;+  body
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
          ::  upload, into directories at the head of the desk only
          ;+  ?.  &(!fils =(da+now r.beam))  :/""
              ;form.upload(method "post", enctype "multipart/form-data")
                =action  sput(mode %load)
                ;input(type "file", name "file", required "");
                ;label(title "cliff carries the mark sources, and can commit the ones this desk lacks")
                  ;input(type "checkbox", name "marks", value "1");
                  ; install missing marks
                ==
                ;button(type "submit", title "upload into this directory"):"⬆️"
              ==
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
    ::  +folk: who a rule names, ships then crews with their membership
    ::
    ++  folk
      |=  rul=real:clay
      ^-  manx
      ?:  &(=(~ p.who.rul) =(~ q.who.rul))  :/""
      =/  cru=(list [nom=@ta mem=(set ship)])
        %+  sort  ~(tap by q.who.rul)
        |=  [a=[nom=@ta mem=(set ship)] b=[nom=@ta mem=(set ship)]]
        (aor nom.a nom.b)
      ;ul.who
        ;+  ?:  =(~ p.who.rul)  :/""
            ;li:"{(ships p.who.rul)}"
        ;*  %+  turn  cru
            |=  [nom=@ta mem=(set ship)]
            ^-  manx
            ;li
              ; \%{(trip nom)}
              ;+  ?:  =(~ mem)  :/" - empty, so it admits no one"
                  ;span.crew:" - {(ships mem)}"
            ==
      ==
    ::
    ::  +rite: one rule, with where it came from
    ::
    ++  rite
      |=  [wat=tape =dict:clay]
      ^-  manx
      ;div.rule
        ;h3:"{wat}"
        ;p.gist:"{(gist rul.dict)}"
        ;p.from
          ;+  ?:  (owns s.beam dict)
                :/"set on this node"
              ?:  &(?=(~ src.dict) =(rul.dict dull))
                :/"clay's default - no rule is set anywhere on this desk"
              :/"inherited from {?:(=(~ src.dict) "/" (spud src.dict))}"
        ==
        ;+  (folk rul.dict)
      ==
    ::
    ::  +hold: the permissions view
    ::
    ++  hold
      ^-  manx
      =/  d  pear
      =/  s  sown
      ;section.perm
        ;+  (rite "read" red.d)
        ;+  (rite "write" wit.d)
        ;p.warn
          ; clay stores write rules and inherits them, but never consults
          ; them: +may-write has no callers at all as of 408K.  the write
          ; rule is a record, not a control.  call your local core dev
          ; before relying on it for anything.
        ==
        ;div.sown
          ;h3:"explicit rules here and below"
          ;+  ?~  out.s
                ;p.from:"none - everything here inherits"
              ;table
                ;tr
                  ;th:"path"
                  ;th:"read"
                  ;th:"write"
                ==
                ;*  %+  turn  out.s
                    |=  [p=path red=(unit real:clay) wit=(unit real:clay)]
                    ;tr
                      ;td
                        ;a/"{sput(s.beam p)}"
                          ; {?:(=(~ p) "/" (spud p))}
                        ==
                      ==
                      ;td:"{?~(red "-" (gist u.red))}"
                      ;td:"{?~(wit "-" (gist u.wit))}"
                    ==
              ==
          ;+  ?.  more.s  :/""
              ;p.warn
                ; more than {(scow %ud walk)} paths sit under this node; only
                ; the first {(scow %ud walk)} were checked, so there may be
                ; rules below that aren't listed.  navigate downwards to see
                ; them.
              ==
        ==
        ;p.from
          ; permissions are not versioned - clay keeps only the current rules,
          ; so these are as of now even when browsing an older revision.
        ==
      ==
    ::
    ++  body
      ^-  manx
      =/  bod=(unit mime)  show
      ?:  =(%perm mode)  hold
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
        ;
        ;a/"{sput(mode %perm)}"
          =title  "read permissions in force here, as of now"
          ; read: {(gist rul.red:pear)}
        ==
      ==
    --
  --
--
