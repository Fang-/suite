::  duiker: bittorrent magnet link sharing
::
::    duiker is a torrent tracker, in the sense of sharing torrent links.
::
::    duiker as it currently exist is a server-side client, intended to be
::    |link-ed to from a user's ship. it renders a simple text-based interface
::    for browsing submitted files and adding your own.
::
::    for simplicity's sake, duiker only supports files in the form of magnet
::    links. this may change in the future, but seems sufficient for now.
::
::TODO  able to list total up/down stats for ship
::TODO  refactor this for local-first by the time app distribution becomes real
::TODO  download torrent files using %sav !!!
::.
/+  srvl=serval, torn, benc, multipart, *pal,
    shoe, server, default-agent, verb, dbug
::
|%
+$  state-0
  $:  %0
      files=(map file-id file)
      ui=(map ship navstate)  ::TODO  per sole-id instead?
  ==
::
+$  info-hash  info-hash:torn
+$  file-id    file-id:torn
+$  tag        path  ::NOTE  /music/dance -> music:dance
::
+$  file
  $:  finf
      meta
  ==
::
+$  finf
  $%  [%magnet =magnet:torn]
      [%torrent =metainfo:torn]
  ==
::
+$  meta
  $:  name=@t
      from=ship
      when=@da
      tags=(set tag)
      desc=@t
  ==
::
+$  action
  $%  [%command sole-id=@ta cmd=command]
  ==
::
+$  navstate
  [=query items=(list file-id)]
::
::NOTE  regarding code flows, we have commands that:
::      - render something
::      - update navstate and render list
::      - update state and render result
::
+$  command
  $%  [%reprint ~]
      [%help ~]
      [%select num=@ud]
    ::
      [%refresh ~]
      [%nav ?(%first %left %right %last)]
      [%search what=@t]
      [%narrow =tag]
      [%author who=(unit ship)]
      [%clear ~]
    ::
      [%tags ~]
      ::TODO
      ::  %stats print stats for ship
    ::
      [%submit =finf name=@t desc=@t tags=(set tag)]
      [%delete id=selector ~]
      [%rename id=selector name=@t]
      [%describe id=selector desc=@t]
      [%retag id=selector tags=(set tag)]
  ==
::
+$  selector
  $%  [%list num=@ud]
      [%hash fid=file-id]
  ==
::
+$  query
  $:  page=@ud  ::NOTE  only for navigation, items always all  TODO move out?
      ::TODO  support things like "files i downloaded", "files i'm seeding",
      ::      tag browser maybe
      what=@t
      =tag
      who=(unit ship)
  ==
::
+$  card     card:agent:shoe
+$  eyre-id  @ta
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
%-  (agent:shoe command)
::
=<
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      des   ~(. (default:shoe this command) bowl)
      do    ~(. +> bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    :_  this
    [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
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
    (on-watch:def path)
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+  mark  ~&(state (on-poke:def mark vase))
        ?(%noun %duiker-action)  (on-action:do !<(action vase))
      ::
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
  ++  command-parser  build-parser:do
  ++  tab-list        tab-list:des
  ++  on-command
    |=  [sole-id=@ta =command]
    ^-  (quip card _this)
    =^  cards  state
      (command-loop:do sole-id command)
    [cards this]
  ++  can-connect     |=(* &)
  ::
  ++  on-connect
    |=  sole-id=@ta
    ^-  (quip card _this)
    :_  this
    [%shoe [sole-id]~ welcome:render:do]~
  ::
  ++  on-disconnect  on-disconnect:des
  ::
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
+*  serval  ~(. srvl bowl)
::
++  base-url  'https://urb.pal.dev/serval'
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
    %+  give-simple-payload:app:server
      eyre-id
    :-  [status ~]
    ?~  out  ~
    `[(met 3 u.out) u.out]
  ::  405 to all unexpected requests
  ::
  ?.  &(?=(^ site) =(dap.bowl i.site))
    [[500 `'unexpected route'] state]
  ::  set src.bowl through secret-path-based authentication
  ::
  ?~  who=(validate-secret-path:serval t.site)
    [[404 ~] state]
  =.  src.bowl  u.who
  ::
  =/  =path  (slag 3 `path`site)
  ::  handle announce and scrape requests on /serval/[ship]/[key]/...
  ::
  ?+  path  [[404 `'four oh four'] state]
      [%upload ~]
    ?+  method.request.inbound-request  [[405 ~] state]
        %'GET'
      :_  state
      [200 `(crip (en-xml:html (upload-page u.who)))]
    ::
        %'POST'
      ::  try to get metainfo from the request
      ::
      =,  multipart
      =/  submitted=(unit (list [@t part]))
        (de-request [header-list body]:request.inbound-request)
      ?~  submitted
        [[400 `'not multipart?'] state]
      =/  args
        (~(gas in *(map @t part)) u.submitted)
      ?.  (~(has by args) 'file')
        [[400 `'no file!'] state]
      =/  body=@t
        body:(~(got by args) 'file')
      =/  info=(unit metainfo:torn)
        %+  biff  (rush body parse:benc)
        reap-metainfo:torn
      ?~  info
        [[400 `'file not metainfo'] state]
      ?.  =(body (crip (render:benc (benc-metainfo:torn u.info))))
        ~&  :+  dap.bowl  %lossy-conversion
            [body=body copy=(render:benc (benc-metainfo:torn u.info))]
        [[500 `'lossy'] state]
      ::  make sure we can actually submit this
      ::
      ?^  why=(may-submit (finf-id %torrent u.info))
        [[403 `(crip u.why)] state]
      ::  get other arguments
      ::
      =/  parg  (curr ~(gut by args) *part:multipart)
      =/  name=@t
        =/  nom=@t  body:(parg 'name')
        ?:(=('' nom) name.mode.u.info nom)
      =/  desc=@t   body:(parg 'desc')
      =/  tags=(set tag)
        (fall (rush body:(parg 'tags') parse-tags) ~)
      ::  store file in state
      ::
      =.  files
        (on-submit:on-action [%torrent u.info] name desc tags)
      [[200 `'i think we got it chief'] state]
    ==
  ==
::
++  on-action
  |^  |=  =action
      ^-  (quip card _state)
      ?-  -.action
        %command  (command-loop +.action)
      ==
  ::
  ++  on-submit
    |=  [=finf name=@t desc=@t tags=(set tag)]
    ^+  files  ::TODO  also notify?
    %+  ~(put by files)
      (finf-id finf)
    :_  [name src.bowl now.bowl tags desc]
    %-  privatize-trackers
    ?:  ?=(%torrent -.finf)  finf
    ::  the name stored in magnets we can safely update
    finf(name.magnet `name)
  --
::
++  default-navstate
  [*query ~(tap in ~(key by files))]
::
++  build-parser
  |=  sole-id=@ta
  ^+  |~(nail *(like [? command]))
  =/  =navstate  (~(gut by ui) src.bowl default-navstate)
  %+  pick
    ;~  pose
      (cold [%reprint ~] dot)
      (cold [%refresh ~] (just 'r'))
      (cold [%nav %left] sel)
      (cold [%nav %right] ser)
      (cold [%nav %first] gal)
      (cold [%nav %last] gar)
      (cold [%clear ~] zap)
      (cold [%help ~] wut)
      (cold [%tags ~] (just 't'))
    ::
      %+  sear
        |=  n=@ud
        ?:  (gte n (lent items.navstate))  ~
        (some [%select n])
      dit:ag
    ==
  ;~  pose
    (stag %search ;~(pfix fas ;~(pfix (opt ace) (cook crip (star next)))))
    (stag %narrow ;~(pfix col (more col parse-tag-term)))
    (stag %author ;~(pfix sig (punt fed:ag)))
  ::
    %+  stag  %submit
    %:  pfox
      ::TODO  enforce name is provided: either in magnet, or in command
      ;~(pfix (jest ';add ') (stag %magnet parse-magnet:torn))
      ace
      ['' '' ~]
      %:  pfox
        qut:ab
        ace
        ['' ~]
        (pfox qut:ab ace ~ parse-tags)
      ==
    ==
  ::
    %+  qfix  mic
    ;~  pose
      ;~((glue ace) (perk %delete ~) ;~(plug select (easy ~)))
      ;~((glue ace) (perk %rename ~) select qut:ab)
      ;~((glue ace) (perk %describe ~) select qut:ab)
      ;~((glue ace) (perk %retag ~) select parse-tags)
    ==
  ==
::
::TODO  alternatively: [separator=rule rules=(list rule) defaults=(list)]
++  pfox
  |*  [z=rule a=rule b=* c=rule]
  ;~  plug
    z
    ;~  pose
      ;~(pfix a c)
      (easy b)
    ==
  ==
::
++  parse-tags
  %+  cook  ~(gas in *(set tag))
  (more (ifix [. .]:(star ace) com) (most col parse-tag-term))
::
++  parse-tag-term
  %+  cook
    |=(a=tape (rap 3 ^-((list @) a)))
  (plus ;~(pose nud low hep dot sig))
::
++  select
  ;~(pose (stag %list dit:ag) (stag %hash hex))
::
++  command-loop
  |=  [sole-id=@ta =command]
  ^-  (quip card _state)
  |^  =/   =navstate  (~(gut by ui) src.bowl default-navstate)
      =.    navstate  (navigate navstate)
      =^  caz  state  (undertake navstate)
      :_  state(ui (~(put by ui) src.bowl navstate))
      %+  weld  caz
      (turn (render-result navstate) display)
  ::
  ++  display
    |=  fec=shoe-effect:shoe
    ^-  card
    [%shoe ~[sole-id] fec]
  ::
  ++  navigate
    |=  =navstate
    ^+  navstate
    ?.  ?=(?(%refresh %nav %search %narrow %author %clear) -.command)
      navstate
    |^  =.  query.navstate  update-query
        navstate(items run-query)
    ::
    ++  update-query
      =,  navstate
      ^+  query
      ?-  -.command
        %refresh  query
        %nav      %_  query.navstate  page
                  ?-  +.command
                    %first  0
                    %left   (dec (max 1 page.query))
                    %right  (min +(page.query) (div (lent items) 10))
                    %last   (div (lent items) 10)
                  ==  ==
        %search   query.navstate(page 0, what what.command)
        %narrow   query.navstate(page 0, tag tag.command)
        %author   query.navstate(page 0, who who.command)
        %clear    *^query
      ==
    ::
    ++  run-query  ::NOTE  ignores page, returns all matching files
      =,  query.navstate
      ^-  (list file-id)
      =-  (turn - head)
      =-  (sort - |=([a=[* file] b=[* file]] (gth when.a when.b)))
      %+  skim  ~(tap by files)
      |=  [* file]
      ^-  ?
      ?&  ?|  =('' what)
              ?=(^ (find (trip what) (trip name)))
          ==
          =(from (fall who from))
          ?|  =(~ tag)
            ::
              =+  l=(lent tag)
              %+  lien  ~(tap in tags)
              |=(t=^tag =((scag l t) tag))
              ::TODO  what if...
              ::(lien ~(tap in tags) (cork (cury scag l) (cury test tag)))
      ==  ==
    --
  ::
  ++  undertake
    |=  =navstate
    |^  ^-  (quip card _state)
    ?+  -.command  [~ state]
        %submit
      =,  command
      =/  =file-id
        (finf-id finf)
      ::  if we can't submit his, say why
      ::
      ?^  why=(may-submit file-id)
        =-  [[(display -)]~ state]
        (failure:msg:render u.why)
      ::  add the file to state
      ::
      =.  files
        (on-submit:on-action finf name.command desc tags)
      :_  state
      :~  (set-filename:serval file-id name)
        ::
          %-  display
          %-  success:msg:render
          "file \"{(trip name)}\" added"
      ==
      ::TODO  also notify all connected clients? "~x submitted y"
    ::
        ?(%delete %rename %describe %retag)
      =/  fil=(unit [=file-id =finf =meta])  (get-file id.command)
      ?~  fil  [[(display (not-found:msg:render id.command))]~ state]
      =+  u.fil  ::NOTE  we want to do typechecking later, =, would trip up
      ?.  ?|  (team:title from.meta src.bowl)
              (team:title [our src]:bowl)
          ==
        [[(display (failure:msg:render "not your file!"))]~ state]
      ::
      =.  files
        ?:  ?=(%delete -.command)
          (~(del by files) file-id)
        %+  ~(put by files)  file-id
        ^-  file
        :-  ?.  &(?=(%rename -.command) ?=(%magnet -.finf))  finf
            finf(name.magnet `name.command)
        ?-  -.command
          %rename    meta(name name.command)
          %describe  meta(desc desc.command)
          %retag     meta(tags tags.command)
        ==
      ::
      :_  state
      :_  ?.  ?=(%rename -.command)  ~
          [(set-filename:serval file-id name.command)]~
      %-  display
      ?:  ?=(%delete -.command)
        (success:msg:render "\"{(trip name.meta)}\" was deleted")
      %+  change:msg:render
        ?-  -.command
          %rename    "renamed"
          %describe  "redescribed"
          %retag     "retagged"
        ==
      =,  meta
      ?-  -.command
        %rename    [(trip name) (trip name.command)]
        %describe  [(scag 25 (trip desc)) (scag 25 (trip desc.command))]
        %retag     [(tags:render tags) (tags:render tags.command)]
      ==
    ==
    ::
    ++  get-file
      |=  =selector
      ^-  (unit [=file-id file])
      ?~  fid=(get-file-id navstate selector)   ~
      ?~  fil=(~(get by files) u.fid)           ~
      `[u.fid u.fil]
    --
  ::
  ++  render-result
    |=  =navstate
    ^-  (list shoe-effect:shoe)
    ?-  -.command
        ?(%reprint %refresh %nav %search %narrow %author %clear)
      (filelist:render navstate)
    ::
        %help
      [help:render]~
    ::
        %tags
      [tag-list:render]~
    ::
        %select
      :_  ~
      ?~  fid=(get-file-id navstate %list num.command)
        (not-found:msg:render %list num.command)
      (file-details:render u.fid)
    ::
        ?(%submit %delete %rename %describe %retag)
      ~  ::NOTE  rendered in +undertake...
    ==
  ::
  ++  get-file-id
    |=  [=navstate =selector]
    ^-  (unit file-id)
    ?:  ?=(%hash -.selector)  `fid.selector
    =/  num=@ud
      %+  add  num.selector
      (mul page.query.navstate 10)
    ?:  (gte num (lent items.navstate))
      ~
    `(snag num items.navstate)
  --
::
++  tracker-url
  |=  =ship
  %^  cat  3
    base-url
  (spat (announce-path:serval ship))
::  +prep-magnet: add ourselves to the magnet's tracker list
::
++  prep-magnet
  |=  [=magnet:torn =ship]
  ^+  magnet
  magnet(trackers [(tracker-url ship) trackers.magnet])
::
++  prep-metainfo
  |=  [=metainfo:torn =ship]
  ^+  metainfo
  =-  metainfo(announces -)
  ^-  announces:torn
  :-  [`@t`(tracker-url ship)]~
  ?~  announces.metainfo  ~
  ?^  announces.metainfo  announces.metainfo
  [[announces.metainfo]~]~
::
++  finf-id
  |=  =finf
  ?-  -.finf
    %magnet   (truncate-info-hash:torn info-hash.magnet.finf)
    %torrent  (hash-info:torn -.metainfo.finf)
  ==
::
++  privatize-trackers
  |=  =finf
  ^+  finf
  =>  |%
      ++  is-secret
        =+  bum=(met 3 base-url)
        |=  t=@t
        =(base-url (end [3 bum] t))
      --
  ?-  -.finf
      %magnet
    =-  finf(trackers.magnet -)
    (skip trackers.magnet.finf is-secret)
  ::
      %torrent
    =-  finf(announces.metainfo -)
    =*  announces  announces.metainfo.finf
    ?@             announces.metainfo.finf
      ?:((is-secret `@`announces) '' announces)
    %+  turn  announces
    |=  l=(list @t)
    (skip l is-secret)
  ==
::
++  find-name
  |=  =finf
  ^-  (unit @t)
  ?-  -.finf
    %magnet   name.magnet.finf
    %torrent  `name.mode.metainfo.finf
  ==
::
++  may-submit
  |=  =file-id
  ^-  (unit tape)
  =/  ninja=@p
    ?~  fil=(~(get by files) file-id)
      src.bowl
    from.u.fil
  ?:  =(src.bowl ninja)  ~
  `"this file was already submitted by {(scow %p ninja)}"
::  +render: rendering engine
::
++  render
  |%
  ++  welcome
    :+  %sole  %mor
    =-  (turn - (lead %klr))
    ^-  (list styx)
    :~  ~
        :~  'welcome to '
            [`%br ~ ~]^"duiker"
            ', the first on-urbit torrent sharing tool.'
        ==
        :~  'duiker is backed by '
            [`%br ~ ~]^"serval"
            ', a torrent tracker that associates traffic with urbit identities.'
        ==
        :~  'the magnet links shown are unique to you! '
            'for best results, '
            [~ `%r ~]^"do not share them with others"
            '.'
        ==
        :~  'for detailed help, '
            [`%un ~ ~]^"press ?"
            '.'
        ==
        ~
    ==
  ::
  ++  help
    :+  %sole  %mor
    =-  (turn - (lead %klr))
    ^-  (list styx)
    :~  ~
        :~(' ' [`%un ~ ~]^"duiker:")
        :~('the magnet link sharing terminal.')
        :~('a ~paldev initiative. developed, with love, by ~palfun-foslup.')
        :~('part of the arvo enhancement suite:')
        :~('https://github.com/fang-/suite')
        ~
        :~(' ' [`%un ~ ~]^"about magnet links and trackers:")
        :~  'duiker supports file sharing exclusively through magnet links. '
            'submitted magnet links may contain pre-configured tracker urls. '
            'duiker will automatically add a personalized tracker url to that '
            'list, letting serval associate up/download stats with urbit '
            'identities.'
        ==
        ~
        :~(' ' [`%un ~ ~]^"about tags:")
        :~  'tags might be nested. a file tagged as music:jazz is considered '
            'to be tagged with both music and music:jazz.'
        ==
        ~
        :~(' ' [`%un ~ ~]^"generating magnet links for submission:")
        :~('1) start the torrent creation process in your torrent client')
        :~  '2) for the tracker, input your '
            [`%br `%r ~]^"personal"
            ' tracker url:'
        ==
        :~((cat 3 '   ' (tracker-url src.bowl)))
        :~('3) start seeding the newly created torrent')
        :~('3) copy the magnet link of the torrent')
        :~('   (usually, right-click -> copy magnet, or similar)')
        :~('4) in duiker, type ;add, then paste the magnet link')
        :~  '5) optionally specify a custom \'name\' '
            '\'description\' some, tags:etc'
        ==
        :~('6) hit return')
        ~
        :~(' ' [`%un ~ ~]^"instant navigation:")
        :~('.       reprint the file list')
        :~('r       refresh the file list')
        :~('[       previous page')
        :~(']       next page')
        :~('<       first page')
        :~('>       last page')
        :~('0-9     view file details')
        ~
        :~(' ' [`%un ~ ~]^"file search:")
        :~('/text   search for filenames containing text')
        :~('/       clear filename search')
        :~(':tag    search for files with specific tag')
        :~(':       clear tag search')
        :~('~ship   search for files submitted by ~ship')
        :~('~       clear ship search')
        :~('!       clear all search parameters')
        :~('t       view the list of used tags')
        ~
        :~(' ' [`%un ~ ~]^"file management:")
        :~(';add magnet:?xt=... \'name\' \'description\' tag:example, etc:etc')
        :~('        submit a file by typing ;add and pasting its magnet link.')
        :~('        name, description, and tags are all optional.')
        :~('        if no name is supplied, the display name from the magnet')
        :~('        link is used. if it has none, providing a name manually')
        :~('        becomes mandatory.')
        :~(';delete 0')
        :~('        delete the 0th file in the 0-9 numbered list')
        :~(';rename 0 \'new name\'')
        :~('        rename the 0th file')
        :~(';describe 0 \'some description\'')
        :~('        change the description of the 0th file')
        :~(';retag 0 some, example:tags')
        :~('        change the tags on the 0th file')
        ~
    ==
  ::
  ++  msg
    |%
    ++  not-found
      |=  =selector
      ?-  -.selector
        %list  (failure "no such file #{(scow %ud num.selector)}")
        %hash  (failure "no such file {((x-co:co 40) fid.selector)}")
      ==
    ::
    ++  deleted
      (failure "file was deleted")
    ::
    ++  change
      |=  [wut=tape old=tape new=tape]
      %-  success
      "{wut} \"{old}\" -> \"{new}\""
    ::
    ++  success
      |=  txt=tape
      [%sole %klr ~[[```%g "success: "] (crip txt)]]
    ::
    ++  failure
      |=  txt=tape
      [%sole %klr ~[[```%r "failure: "] (crip txt)]]
    --
  ::
  ++  file-details
    |=  =file-id
    ^-  shoe-effect:shoe
    ?.  (~(has by files) file-id)  deleted:msg
    =+  (~(got by files) file-id)
    =*  file  -<
    :+  %sole  %mor
    %+  weld
      ^-  (list sole-effect:shoe)
      =;  meta=(list styx)
        (turn meta (lead %klr))
      :~  ~
        :~([`%un ~ ~]^[name]~)
        :~  'submitted by '  (scot %p from)
            ' on '  (scot %da (sub now.bowl (mod now.bowl ~d1)))
        ==
        :*('tags: ' ?~(tags ['(untagged)']~ (tags:render tags)))
        :~(?:(=('' desc) '(no description provided)' desc))
        ~
      ==
    ^-  (list sole-effect:shoe)
    ?-  -.file
        %magnet
      [%url (render-magnet:torn (prep-magnet magnet src.bowl))]~
    ::
        %torrent
      =.  metainfo  (prep-metainfo metainfo src.bowl)
      =/  file=@t  (crip (render:benc (benc-metainfo:torn metainfo)))
      =/  uniq=@t  (crip ((x-co:co 6) (end 5 file-id)))
      =/  name=@t  :((cury cat 3) name '_' uniq)
      :~  [%sav /[dap.bowl]/[name]/torrent file]
          [%txt "downloaded to .urb/put/{(trip dap.bowl)}/"]
      ==
    ==
  ::
  ++  filelist
    |=  =navstate
    ^-  (list shoe-effect:shoe)
    =,  navstate
    =+  total=(lent items)
    :-  =-  [%sole %klr [[`%br ~ ~] `styx`[(crip -)]~]~]
        =,  query
        =/  all=tape
          ?:(&(?=(~ what) ?=(~ tag) ?=(~ who)) "all " "")
        ;:  weld
          "showing {all}{(scow %ud total)} files"
        ::
          ?~  what.query  ""
          ", matching \"{(trip what.query)}\""
        ::
          ?:  ?=(?(~ [~ ~]) tag.query)  ""
          ", tagged as {(trip (tag:render tag.query))}"
        ::
          ?~  who.query.navstate  ""
          ", submitted by {(scow %p u.who.query)}"
        ==
    ?~  items
      [%sole %txt "no results"]~
    =+  pages=(div total 10)
    :~  :+  %sole  %txt
        %+  weld  "page {(scow %ud page.query)} of {(scow %ud pages)}"
        " ({(scow %ud total)} files)"
      ::
        ^-  shoe-effect:shoe
        :^    %table
            ~[t+'n' t+'name' t+'from' t+'s' t+'l' t+'c']
          ~[1 59 14 2 2 2]
        %+  fuse  (turn (gulf 0 9) (lead %ud))
        %+  turn
          (swag [(mul page.query 10) 10] items)
        |=  i=file-id
        ^-  (list dime)
        ?.  (~(has by files) i)
          ~[t+'(deleted file)' t+~ t+~ t+~ t+~]
        =+  (~(got by files) i)
        :~  t+name
            p+from
            ud+(seeder-count:serval i)
            ud+(leecher-count:serval i)
            ud+(completed-count:serval i)
    ==  ==
  ::
  ++  tag
    |=  =^tag
    ^-  @t
    (roll (join ':' (flop tag)) (cury cat 3))
  ::
  ++  tags
    |=  tags=(set ^tag)
    (join ', ' (turn ~(tap in tags) tag:render))
  ::
  ++  tag-list
    ^-  shoe-effect:shoe
    :+  %sole  %mor
    =;  tagset=(set ^tag)
      ?:  =(~ tagset)
        [%txt "no tags"]~
      %+  turn
        (sort ~(tap in tagset) aor)
      |=(t=^tag txt+(trip (tag t)))
    %+  roll  ~(val by files)
    |=  [file tagset=(set ^tag)]
    =+  tags=~(tap in tags)
    |-  =*  next-tag  $
    ?~  tags  tagset
    |-  =*  unpack-tag  $
    ?:  ?|  =(~ i.tags)
            (~(has in tagset) i.tags)
        ==
      next-tag(tags t.tags)
    %_  unpack-tag
      tagset  (~(put in tagset) i.tags)
      i.tags  (snip i.tags)
    ==
  --
::
++  upload-page
  |=  who=ship
  =/  style=@t
    '''
    * { margin: 1em; padding: 0.5em; }
    input, textarea { width: 50%; }
    '''
  ;html
    ;head
      ;title:"~paldev/duiker - upload"
      ;style:"{(trip style)}"
    ==
    ;body
      ;h2:"duiker - uploading as {(scow %p who)}"
      ;form(method "post", enctype "multipart/form-data")
              ;input(type "text", name "name", placeholder "name");
        ;br;  ;textarea(name "desc", placeholder "description");
        ;br;  ;input(type "text", name "tags", placeholder "tags");
        ;br;  ;input(type "file", name "file", accept ".torrent");
        ;br;  ;button(type "submit"):"Submit"
      ==
    ==
  ==
--
