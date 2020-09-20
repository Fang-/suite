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
::TODO  poke serval with known file names
::TODO  able to list total up/down stats for ship
::TODO  refactor this for local-first by the time app distribution becomes real
::
:: /+  serval  ::TODO
/+  torn,
    shoe, default-agent, verb, dbug
::
|%
+$  versioned-state
  $%  [%0 state-0]
  ==
::
+$  state-0
  $:  db=[=files =index]
      ui=(map ship navstate)  ::TODO  per sole-id instead?
  ==
::
+$  info-hash  info-hash:torn
+$  file-id    file-id:torn
+$  files      (map file-id finf)
+$  tag        path  ::NOTE  /music/dance -> music:dance
::
::
++  whem  ((ordered-map @da file-id) lte)
+$  index
  $:  when=(tree [key=@da val=file-id])
      whom=(jug ship file-id)  ::TODO  unused?
      tags=(jug tag file-id)   ::TODO  unused?
  ==
::
+$  finf
  $:  magnet:torn
      meta
  ==
::
+$  meta
  $:  from=ship
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
::  - render something
::  - update navstate and render list
::  - update state and render result
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
      [%submit =magnet:torn name=@t desc=@t tags=(set tag)]
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
      what=@t
      =tag
      who=(unit ship)
  ==
::
+$  card  card:agent:shoe
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
  ++  on-init   [~ this]
  ++  on-save   !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    ~&  [dap.bowl %load]
    [~ this(state !<(state-0 old))]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+  mark  ~&(state (on-poke:def mark vase))
        ?(%noun %duiker-action)  (on-action:do !<(action vase))
      ==
    [cards this]
  ::
  ++  command-parser  build-parser:do
  ++  tab-list        tab-list:des  ::NOTE  discoverability covered by help text
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
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
++  base-url  'https://urb.pal.dev/serval'
::
++  on-action
  |=  =action
  ^-  (quip card _state)
  |^  ?-  -.action
        %command  (command-loop +.action)
      ==
  ::
  ++  on-submit
    |=  [=magnet:torn name=@t desc=@t tags=(set tag)]
    ^+  db
    %+  ~(put fin db)
      (truncate-info-hash:torn info-hash.magnet)
    :_  [src.bowl now.bowl tags desc]
    %_  magnet
      name  `name
    ::
        trackers
      ::  remove local/personalized tracker urls
      ::
      =+  bum=(met 3 base-url)
      %+  skip  trackers.magnet
      |=(t=@t =(base-url (end 3 bum t)))
    ==
  --
::
++  default-navstate
  [*query ~(tap in ~(key by files.db))]
::
++  build-parser
  |=  sole-id=@ta
  ^+  |~(nail *(like [? command]))
  =/  =navstate  (~(gut by ui) src.bowl default-navstate)
  %+  pick
    ;~  pose
      (cold [%reprint ~] dot)
      (cold [%refresh ~] (just 'r'))
      (cold [%nav %left] lac)
      (cold [%nav %right] rac)
      (cold [%nav %first] gal)
      (cold [%nav %last] gar)
      (cold [%clear ~] zap)
      (cold [%help ~] wut)
    ::
      %+  sear
        |=  n=@ud
        ?:  (gte n (lent items.navstate))  ~
        (some [%select n])
      dit:ag
    ==
  ;~  pose
    (stag %search ;~(pfix fas ;~(pfix (opt ace) (cook crip (star next)))))
    (stag %narrow ;~(pfix col (most col parse-tag-term)))
    (stag %author ;~(pfix sig (punt fed:ag)))
  ::
    %+  stag  %submit
    %:  pfox
      ;~(pfix lus parse-magnet:torn)
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
    (stag %rename ;~((glue ace) select qut:ab))
    (stag %describe ;~((glue ace) select qut:ab))
    (stag %retag ;~((glue ace) select parse-tags))
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
  |^  =/  =navstate   (~(gut by ui) src.bowl default-navstate)
      =.   navstate   (navigate navstate)
      =^  caz  state  (undertake navstate)
      :_  state(ui (~(put by ui) src.bowl navstate))
      (turn (weld caz (render-result navstate)) out)
  ::
  ++  out
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
                    %right  (min +(page.query) (lent items))
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
      =-  (sort - |=([a=[* finf] b=[* finf]] (gth when.a when.b)))
      %+  skim  ~(tap by files.db)
      |=  [* finf]
      ^-  ?
      ?&  ?|  =('' what)
              ?=(^ (find (trip what) (trip (need name))))
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
    ^-  (quip shoe-effect:shoe _state)
    |^
    ?+  -.command  [~ state]
        %submit
      =,  command
      =/  =file-id
        (truncate-info-hash:torn info-hash.magnet)
      =/  ninja=@p
        ?~  fil=(~(get by files.db) file-id)
          our.bowl
        from.u.fil
      ?.  =(our.bowl ninja)
        =-  [[-]~ state]
        %-  failure:msg:render
        "this file was already submitted by {(scow %p ninja)}"
      =?  name.magnet.command  !=('' name)
        `name
      =.  db
        %+  ~(put fin db)  file-id
        :_  [src.bowl now.bowl tags desc]
        =-  magnet.command(trackers -)
        ::  remove local/personalized tracker urls
        ::TODO  dedupe with +on-action
        ::
        =+  bum=(met 3 base-url)
        %+  skip  trackers.magnet
        |=(t=@t =(base-url (end 3 bum t)))
      :_  state
      [(success:msg:render "file \"{(trip (need name.magnet))}\" added")]~
      ::TODO  also notify all connected clients? "~x submitted y"
    ::
      %rename    [[(failure:msg:render "unimplemented")]~ state]
      %describe  [[(failure:msg:render "unimplemented")]~ state]
      %retag     [[(failure:msg:render "unimplemented")]~ state]
    ==
    ::
    ++  get-file
      |=  =selector
      ^-  (unit finf)
      =;  fid=file-id
        (~(get by files.db) fid)
      ?-  -.selector
        %list  (snag num.selector items.navstate)
        %hash  fid.selector
      ==
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
        %select
      :_  ~
      %-  file-details:render
      (snag num.command items.navstate)
    ::
        ?(%submit %rename %describe %retag)
      ~  ::NOTE  rendered in +undertake...
    ==
  --
::
++  tracker-url
  |=  =ship
  %^  cat  3
    base-url
  %-  spat
  .^  path
    %gx
    (scot %p our.bowl)
    %serval
    (scot %da now.bowl)
    /announce/(scot %p ship)/path
  ==
::  +prep-magnet: add ourselves to the magnet's tracker list
::
++  prep-magnet
  |=  [=magnet:torn =ship]
  ^+  magnet
  magnet(trackers [(tracker-url ship) trackers.magnet])
::  +fin: file-index engine
::
++  fin
  |_  [=files =index]
  ::  +del: delete a file at file-id
  ::
  ++  del
    |=  i=file-id
    ^+  [files index]
    :-  (~(del by files) i)
    %_  index
      when  +:(del:whem when.index when:(~(gut by files) i *finf))
      whom  (~(run by whom.index) |*(s=(set) (~(del in s) i)))
      tags  (~(run by tags.index) |*(s=(set) (~(del in s) i)))
    ==
  ::  +put: add a file
  ::
  ++  put
    |=  [i=file-id f=finf]
    ^+  [files index]
    :-  (~(put by files) i f)
    %_  index
      when  (put:whem when.index when.f i)
      whom  (~(put ju whom.index) from.f i)
      tags  (~(gas ju tags.index) (turn ~(tap in tags.f) (late i)))
    ==
  ::  tig: add a tag to a file at file-id
  ::
  ++  tig
    |=  [i=file-id t=tag]
    ^+  [files index]
    :-  %+  ~(jab by files)  i
        |=  f=finf
        =-  f(tags -)
        :: ?@  t
          (~(put in tags.f) t)
        :: (~(uni in tags.f) t)
    =-  index(tags -)
    :: ?@  t
      (~(put ju tags.index) t i)
    :: %+  roll  ~(tap by tags.index)
    :: |=  [t=tag =_tags.index]
    :: (~(put in tags) t)
  ::  +tug: remove a tag from a file at file-id
  ::
  ++  tug
    |=  [i=file-id t=tag]
    ^+  [files index]
    :-  %+  ~(jab by files)  i
        |=  f=finf
        =-  f(tags -)
        :: ?@  t
          (~(put in tags.f) t)
        :: (~(dif in tags.f) t)
    =-  index(tags -)
    :: ?@  t
      (~(del ju tags.index) t i)
    :: %+  roll  ~(tap by tags.index)
    :: |=  [t=tag =_tags.index]
    :: (~(del in tags) t)
  --
::
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
            'for best results, do not share them with others.'
        ==
        :~  [~ `%r ~]^"this is a beta!"
            ' files and statistics may disappear. do not start dumping'
            ' your archives just yet.'
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
        :~('the magnet uri sharing terminal.')
        :~('a ~paldev initiative. developed, with love, by ~palfun-foslup.')
        :~('part of the arvo enhancement suite:')
        :~('https://github.com/fang-/suite')
        ~
        :~(' ' [`%un ~ ~]^"about tags:")
        :~  'tags might be nested. a file tagged with music:jazz is considered '
            'to be tagged with both music and music:jazz.'
        ==
        ~
        :~(' ' [`%un ~ ~]^"about magnet links and trackers:")
        :~  'duiker supports file sharing exclusively through magnet links. '
            'submitted magnet links may contain pre-configured tracker urls. '
            'duiker will automatically add a personalized tracker url to that '
            'list, letting serval associate up/download stats with urbit '
            'identities.'
        ==
        ~
        :~(' ' [`%un ~ ~]^"generating magnet links for submission:")
        :~('1) start the torrent creation process in your torrent client')
        :~  '2) for the tracker, input your '
            [`%br ~ ~]^"personal"
            ' tracker url:'
        ==
        :~((cat 3 '   ' (tracker-url src.bowl)))
        :~('3) copy the magnet link of the newly created torrent')
        :~('   (usually, right-click -> copy magnet, or similar)')
        :~('4) in duiker, type +, then paste the magnet link')
        :~  '5) optionally specify a custom \'name\' '
            '\'description\' some,tags:cool'
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
        :~('t       view personal tracker url')
        ~
        :~(' ' [`%un ~ ~]^"file search:")
        :~('/text   search for filenames containing text')
        :~('/       clear filename search')
        :~(':tag    search for files with specific tag')
        :~(':       clear tag search')
        :~('~ship   search for files submitted by ~ship')
        :~('~       clear ship search')
        :~('!       clear all search parameters')
        ~
        :~(' ' [`%un ~ ~]^"file management:")
        :~('+magnet:?xt=... \'name\' \'description\' example:tag,more')
        :~('        submit a file by typing + and pasting its magnet link.')
        :~('        name, description, and tags are all optional.')
        :~('        if name is the empty string, or not supplied at all, the')
        :~('        display name from the magnet link is used. if it has none,')
        :~('        providing a name manually is mandatory.')
        :~('editing and deletion are coming soon!')
        ~
    ==
  ::
  ++  msg
    |%
    ++  not-found
      |=  =selector
      ?-  -.selector
        %list  (failure "file was deleted")
        %hash  (failure "no such file {((x-co:co 0) fid.selector)}")
      ==
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
    =+  (~(got by files.db) file-id)
    =*  magnet  -<
    :+  %sole  %mor
    =-  (turn - (lead %klr))
    ^-  (list styx)
    :~  ~
        :~([`%un ~ ~]^[(need name)]~)
        :*('tags: ' (join ', ' (turn ~(tap in tags) tag:render)))
        :~  'submitted by '  (scot %p from)
            ' on '  (scot %da (sub now.bowl (mod now.bowl ~d1)))
        ==
        :~(desc)
        ~
        :~((render-magnet:torn (prep-magnet magnet src.bowl)))
        ~
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
            ~[t+'n' t+'name' t+'from' t+'s' t+'c' t+'l']
          ~[1 58 14 3 2 2]
        %+  fuse  (turn (gulf 0 9) (lead %ud))
        %+  turn
          (swag [(mul page.query 10) 10] items)
        |=  i=file-id
        ^-  (list dime)
        =+  (~(got by files.db) i)
        :~  t+(need name)
            p+from
            ud+(scry @ud %gx %serval /file/(scot %ux i)/seeders/atom)
            ud+(scry @ud %gx %serval /file/(scot %ux i)/completed/atom)
            ud+(scry @ud %gx %serval /file/(scot %ux i)/leechers/atom)
    ==  ==
  ::
  ++  tag
    |=  =^tag
    ^-  @t
    (roll (join ':' (flop tag)) (cury cat 3))
  ::
  ++  command-result
    |=  [=command =navstate]
    ^-  (list shoe-effect:shoe)
    ?+  -.command
      (filelist:render navstate)
    ::
        %help
      [%sole txt+"git gud"]~
    ::
        %select
      ::TODO  print selected item
      ~|  [%selected-outside-list -.navstate]
      =+  (snag num.command items.navstate)
      [%sole txt+"imagine a magnet link here"]~
    ==
  --
::
::TODO  /lib/scry ?
::
++  scry
  |*  [=mold care=term app=term =path]
  .^(mold care (scot %p our.bowl) app (scot %da now.bowl) path)
::
::TODO  stdlib?
::
++  lead  |*(h=* |*(* [+>+< +<]))                          ::  put head
++  late  |*(t=* |*(* [+< +>+<]))                          ::  put tail
::
::TODO  personal /lib/pal?
::
++  fuse                                                ::  cons contents
  |*  [a=(list) b=(list)]
  :: ^-  (list _?>(?=([^ ^] [a b]) [i.a i.b]))  ::TODO  why does this not work?
  ^-  (list [_?>(?=(^ a) i.a) _?>(?=(^ b) i.b)])
  ?~  a  ~
  ?~  b  ~
  :-  [i.a i.b]
  $(a t.a, b t.b)
::
++  opt
  |*  =rule
  ;~(pose rule (easy ~))
::
++  may
  |*  [=rule else=*]
  ;~(pose rule (easy else))
--
