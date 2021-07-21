::  seek: scry namespace explorer
::
::NOTE  only really useful for clay right now, but will become more powerful
::      as the scry namespace becomes more broadly supported.
::
::TODO  would strongly benefit from arbitrary-line screen redraws
::TODO  should be prettier regardless
::
/+  shoe, pretty-file, *pal,
    default-agent, verb, dbug
::
|%
+$  state-0
  $:  %0
      sessions=(map sole-id session)
  ==
+$  sole-id  @ta
+$  card     card:agent:shoe
::
+$  session
  $:  =cursor
      ::TODO  tree view:
      ::  expanded=(set path)
      ::  known=(list path)
      ::TODO  search/filter?
  ==
::
+$  cursor  [=vane =desk =path]
+$  vane    ?(%a %b %c %d %e %f %g %i %j)
+$  care    ?(%x %y)  ::  internally supported cares
::
+$  command
  $%  [%dive into=@ta]
      [%rise ~]
      [%show ~]
      [%help ~]
      ::TODO  selecting vane/desk
  ==
::
+$  content
  $%  [%tree tree=(set @ta)]
      [%data data=(each tang tang)]
      [%both tree=(set @ta) data=(each tang tang)]
      [%fail =tang]
  ==
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
    |=  =vase
    ^-  (quip card _this)
    =/  loaded  !<(state-0 vase)
    ~&  [dap.bowl %load]
    [~ this(state loaded)]
  ::
  ++  command-parser  build-parser:do
  ++  tab-list        tab-list:do
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
  ++  on-poke   on-poke:def
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
++  default-session
  [%c %home /]
::
++  tab-list
  |=  sole-id=@ta
  ^-  (list [@t tank])
  =/  ,session  (~(gut by sessions) sole-id default-session)
  =/  bend=(each arch tang)
    %-  mule  |.
    (scry arch %y cursor)
  ?.  ?=(%& -.bend)  ~
  =+  dis=~(tap in ~(key by dir.p.bend))
  |-  ^-  (list [@t tank])
  ?~  dis  ~
  [[i.dis leaf+""] $(dis t.dis)]
::
++  build-parser
  |=  sole-id=@ta
  ^+  |~(nail *(like [? command]))
  %+  pick
    ;~  pose
      (cold [%rise ~] ket)
      (cold [%show ~] dot)
      (cold [%help ~] wut)
    ==
  (stag %dive mixed-case-symbol)
::
++  command-loop
  |=  [sole-id=@ta =command]
  ^-  (quip card _state)
  =/  =session  (~(gut by sessions) sole-id default-session)
  ::  navigate
  ::
  =.  session
    ?+  -.command  session
      %dive  session(path.cursor (snoc path.cursor.session into.command))
      %rise  session(path.cursor (snip path.cursor.session))
    ==
  ::  render
  ::
  :_  state(sessions (~(put by sessions) sole-id session))
  ^-  (list card)
  :_  ?.  ?=(?(%dive %rise) -.command)  ~
      [%shoe [sole-id]~ (prompt:render cursor.session)]~
  :+  %shoe  [sole-id]~
  ?:  ?=(%help -.command)
    help:render
  %+  content:render  cursor.session
  (get-content cursor.session)
::
++  get-content
  |=  =cursor
  ^-  content
  =/  bend=(each arch tang)
    %-  mule  |.
    (scry arch %y cursor)
  ?.  ?=(%& -.bend)
    [%fail p.bend]
  ?+  p.bend  ~|([dap.bowl %huh] !!)
    [^ ~]  [%data (get-data cursor)]
    [~ *]  [%tree ~(key by dir.p.bend)]
    [^ *]  [%both ~(key by dir.p.bend) (get-data cursor)]
  ==
::
++  get-data
  |=  =cursor
  ^-  (each tang tang)
  %-  mule  |.
  %-  flop  ::NOTE  %tan prints in reverse, because muh bottom-up tang
  ::TODO  if we had access to the result cage, we could mark-convert and/or
  ::      sell for much broader content rendering support...
  %-  pretty-file
  (scry * %x cursor)
::
++  find-tube
  |=  [from=mark to=mark]
  ^-  (unit tube:clay)
  ?:  =(from to)  `(bake same vase)
  =/  tub=(each tube:clay tang)
    %-  mule  |.
    (scry tube:clay 'c' 'c' %home /[from]/[to])
  ?.  ?=(%& -.tub)  ~
  `p.tub
::
++  render
  |%
  ++  welcome
    ^-  shoe-effect:shoe
    :+  %sole  %mor
    =-  (turn - (lead %klr))
    ^-  (list styx)
    :~  ~
        :~  'welcome to '
            [`%br ~ ~]^"seek"
            ', an explorer for urbit\'s '
            'typed, global, referentially-transparent namespace.'
        ==
        :~  'for help, '
            [`%un ~ ~]^"press ?"
            '.'
        ==
    ==
  ::
  ++  help
    ^-  shoe-effect:shoe
    :+  %sole  %mor
    =-  (turn - (lead %klr))
    ^-  (list styx)
    :~  ~
        :~(' ' [`%un ~ ~]^"seek")
        :~('scry namespace explorer.')
        ~
        :~(' ' [`%un ~ ~]^"navigation")
        :~('TODO help text')
        ~
    ==
  ::
  ++  prompt
    |=  cursor
    :+  %sole  %pro
    :+  &  dap.bowl
    :~  ':[%'  vane  ' %'  desk  ']/'
        [~ ~ ~]^(join '/' path)
        '> '
    ==
  ::
  ++  content
    |=  [cursor =^content]
    ^-  shoe-effect:shoe
    :+  %sole  %mor
    |^  ^-  (list sole-effect:shoe)
        ?-  -.content
          %tree  ~[(head |) (tree +.content)]
          %data  ~[(head &) (data +.content)]
          %fail  ~[(head &) (fail +.content)]
        ::
            %both
          :~  (head |)
              (tree tree.content)
              (head &)
              (data data.content)
          ==
        ==
    ::
    ++  head
      |=  leaf=?
      ^-  sole-effect:shoe
      :-  %mor
      :-  txt+""
      :_  ~
      :-  %klr
      ^-  styx
      ::  for directories, print base*/*,
      ::  for files, print base/*file*
      :~  :-  [`%un ~ ~]  :~
        (base leaf)
        ?:(leaf '/' '')
        [`%br ~ ~]^[?:(leaf (rear path) '/')]~
      ==  ==
    ::
    ++  base
      |=  leaf=?
      %-  crip
      :-  :((cury cat 3) '/' vane '/=' desk '=')
      =+  p=?:(leaf (snip path) path)
      ?~  p  ~
      ['/' (join '/' p)]
    ::
    ++  fail
      |=  =tang
      ^-  sole-effect:shoe
      :-  %mor
      :~  klr+:~([~ ~ `%r]^"failed to retrieve content.")
        ::
          :-  %txt
          |-  ^-  tape
          ?~  tang  "unknown error"
          ?:  ?=(%leaf -.i.tang)  p.i.tang
          $(tang t.tang)
      ==
    ::
    ++  tree
      |=  tree=(set @ta)
      ^-  sole-effect:shoe
      ?:  =(~ tree)  ::NOTE  tmi
        klr+:~([~ ~ `%r]^"[[empty]]")
      :-  %mor
      =/  tree=(list @ta)
        (sort ~(tap in tree) aor)
      =/  base=@t  (base |)
      |-  ^-  (list sole-effect:shoe)
      ?~  tree  ~
      =*  here  i.tree
      :_  $(tree t.tree)
      :-  %klr
      :~(base '/' [`%br ~ ~]^[i.tree]~)
    ::
    ++  data
      |=  data=(each tang tang)
      ^-  sole-effect:shoe
      ?:  ?=(%& -.data)  tan+p.data
      ~|  p.data
      klr+:~([~ ~ `%r]^"[[unrenderable]]")
    --
  --
::
++  scry
  |*  [=mold =care cursor]
  .^  mold
    (cat 3 vane care)
    (scot %p our.bowl)
    desk
    (scot %da now.bowl)
    path
  ==
--
