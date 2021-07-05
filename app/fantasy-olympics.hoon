::  olympics fantasy: entry form
::
::TODO  write export to .put after every change
::
/-  sole
/+  static=enetpulse-static, server,
    dbug, verb, default-agent
::
|%
+$  state-0
  $:  %0
      entries=(map ship entry)
      base-secret=@
      cli=path
  ==
::
+$  entry
  (map @t @t)  ::  discipline string to country code
::
+$  card     card:agent:gall
+$  eyre-id  @ta
::
++  close-date  ~2021.7.20..23.00.00
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
::
=<
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      do    ~(. +> bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  sek=@ux  (shas dap.bowl eny.bowl)
    ~&  [dap.bowl %please-backup-base-secret `@ux`sek]
    :_  this(base-secret sek)
    [%pass /eyre/connect %arvo %e %connect [~ /fantasy] dap.bowl]~
  ::
  ++  on-save   !>(state)
  ++  on-load
    |=  =vase
    ^-  (quip card _this)
    =/  loaded  !<(state-0 vase)
    ~&  [dap.bowl %load -.loaded]
    [~ this(state loaded)]
  ::
  ++  on-watch
    |=  =path
    ?:  ?=([%http-response @ ~] path)
      [~ this]
    ?.  ?=([%sole *] path)
      (on-watch:def path)
    ?:  =(src our):bowl
      :_  this(cli path)
      [%give %fact ~ %sole-effect !>([%txt "local!"])]~
    :_  this
    =/  url=@t
      %+  rap  3
      :~  'https://olympics.pal.dev/fantasy/'
          (scot %p src.bowl)
          '/'
          (ship-secret:do src.bowl)
      ==
    :_  ~
    :^  %give  %fact  ~
    :-  %sole-effect
    !>  ^-  sole-effect:sole
    :~  %mor
        [%txt ""]
        [%txt "your private page, do not share this:"]
        [%url url]
        [%txt ""]
        [%bye ~]
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+  mark  (on-poke:def mark vase)
          %handle-http-request
        =^  cards  state
          %-  handle-http-request:do
          !<([=eyre-id =inbound-request:eyre] vase)
        [cards state]
      ==
    [cards this]
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%eyre %bound *]
      ~?  !accepted.sign-arvo
        [dap.bowl 'bind rejected!' binding.sign-arvo]
      [~ this]
    ==
  ::
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ?+  path  (on-peek:def path)
      [%x %entries ~]  ``noun+!>(entries)
    ==
  ++  on-agent  on-agent:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
++  ship-secret
  |=  =ship
  %-  crip
  %+  scag  32
  %-  en-base58:mimes:html
  (shas ship base-secret)
::
++  validate-secret-path
  |=  =path
  ^-  (unit ship)
  ?.  ?=([@ @ *] path)                 ~
  ?~  who=(slaw %p i.path)             ~
  ?.  =(i.t.path (ship-secret u.who))  ~
  who
::
++  handle-http-request
  |=  [=eyre-id =inbound-request:eyre]
  ^-  (quip card _state)
  ::  parse request url into path and query args
  ::
  =/  ,request-line:server
    (parse-request-line:server url.request.inbound-request)
  ::
  =;  [[status=@ud out=(unit @t)] =_state]
    :_  state
    %+  weld
      ^-  (list card)
      ?.  ?&  ?=(%'POST' method.request.inbound-request)
              (lth now.bowl close-date)
          ==
        ~
      =/  nom=@ta  (scot %da (mul (div now.bowl ~h6) ~h6))
      [%give %fact [cli]~ %sole-effect !>([%sag /fantasy/[nom]/jam state])]~
    %+  give-simple-payload:app:server
      eyre-id
    :-  [status ~]
    ?~  out  ~
    `[(met 3 u.out) u.out]
  ::  405 to all unexpected requests
  ::
  ?.  &(?=(^ site) =('fantasy' i.site))
    [[500 `'unexpected route'] state]
  ::  set src.bowl through secret-path-based authentication
  ::
  ?~  who=(validate-secret-path t.site)
    [[404 ~] state]
  =.  src.bowl  u.who
  ::
  ?+  method.request.inbound-request  [[405 ~] state]
      %'GET'
    :_  state
    [200 `(crip (en-xml:html (entry-page src.bowl ~)))]
  ::
      %'POST'
    ?~  body.request.inbound-request  [[400 `'no body!'] state]
    ?:  (gte now.bowl close-date)
      :_  state
      :-  200
      %-  some
      %-  crip
      %-  en-xml:html
      (entry-page src.bowl `|+'The games have begun, selection has closed!')
    =.  entries
      %+  ~(put by entries)  src.bowl
      %-  ~(gas by (~(gut by entries) src.bowl *entry))
      (rash q.u.body.request.inbound-request yquy:de-purl:html)
    :_  state
    :-  200
    %-  some
    %-  crip
    %-  en-xml:html
    (entry-page src.bowl `&+'Entry updated successfully.')
  ==
::
++  entry-page
  |=  [who=ship msg=(unit (each @t @t))]
  ^-  manx
  =/  =entry  (~(gut by entries) who *entry)
  =/  closed=?  (gte now.bowl close-date)
  =/  submit=manx
    ?.  closed
      ;div
        ;b:"{(flop (slag 6 (flop (scow %dr (sub close-date now.bowl)))))} until submissions close."
        ;br;
        ;button(type "submit"):"Submit"
      ==
    ;p.red:"The Games have begun! Your entry, shown here, is frozen."
  |^  ;html
        ;head
          ;title:"~paldev/olympics - Fantasy"
          ;meta(charset "utf-8");
          ;style:"{(trip style)}"
        ==
        ;body
          ;h2:"Fantasy Olympics selection for {(scow %p who)}"
          Up-to-date information on rules and scoring can be found in the
          ~paldev/olympics group.
          ;+  ?~  msg  ;p:""
              ?:  ?=(%& -.u.msg)
                ;p.green:"{(trip p.u.msg)}"
              ;p.red:"{(trip p.u.msg)}"
          ;form(method "post")
            ;+  submit
            ;p
              Default country (used in place of empty selections below,
              may be used for tie-breakers)
              ;select(name "default")
                ;*  (country-options (~(gut by entry) 'default' ''))
              ==
            ==
            ;table
              ;tr(style "font-weight: bold")
                ;td:""
                ;td:"🥇"
                ;td:"Discipline"
                ;td:"Country"
              ==
              ;*  discipline-rows
            ==
            ;+  submit
          ==
        ==
      ==
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: sans-serif; }
    input, textarea { width: 50%; }
    .red { font-weight: bold; color: #dd2222; }
    .green { font-weight: bold; color: #229922 }
    '''
  ::
  ++  discipline-rows
    ^-  (list manx)
    %+  turn
      discipline-list:static
    |=  [name=@t medals=@ud icon=?(@t [m=@t w=@t])]
    =/  icon=@t  ?@(icon icon -.icon)
    =/  selector
      ?:  closed
        ;select(name (trip name), disabled "true")
          ;*  (country-options (~(gut by entry) name ''))
        ==
      ;select(name (trip name))
        ;*  (country-options (~(gut by entry) name ''))
      ==
    ;tr
      ;td:"{(trip icon)}"
      ;td:"{(scow %ud medals)}"
      ;td:"{(trip name)}"
      ;td
        ;+  selector
      ==
    ==
  ::
  ++  country-options
    |=  selected=@t
    ^-  (list manx)
    ?:  closed
      =>  [selected=selected members=members:static ..zuse]  ~+
      =/  name=@t
        name:(~(gut by members) selected [name='' ath=@ud])
      ;+  ;option:"{(trip name)}"
    =>  [selected=selected countries=sorted-countries ..zuse]  ~+
    :-  ;option(value "");
    %+  turn  countries
    |=  [name=@t code=@t]
    ?.  =(code selected)
      ;option(value (trip code)):"{(trip name)}"
    ;option(value (trip code), selected "true"):"{(trip name)}"
  ::
  ++  sorted-countries
    =>  [members=members:static ..zuse]  ~+
    %+  sort
      %+  turn  ~(tap by members)
      |=  [code=@t name=@t *]
      [name code]
    aor
  --
--