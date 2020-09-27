::  serval: simple http/s bittorrent tracker for urbit
::
::    serval is a torrent tracker, n the sense of implementing the bittorrent
::    tracker protocol.
::
::    serval expects requests to come in on announce urls that contain a unique
::    secret, allowing it to identify the connecting client as belonging to a
::    specific @p. it uses this to track up/download stats for @ps.
::
::    q: "bittorrent client when?"
::    a: after these happen:
::       - there is an on-urbit torrent *file* sharing mechanism
::       - clay supports tombstoning
::       - urbit can store more than 2gb of state
::       - event logs can be truncated
::       - there is a raw tcp (or udp, or utp?) vane
::       - we can do event (de)prioritization
::       - i get around to actually doing it
::
::TODO  move some data structures/functions into /lib/torn?
::
::  scry endpoints:
::  /x/file/[file-id]/seeders    %atom  seeder count
::  /x/file/[file-id]/leechers   %atom  leecher count
::  /x/file/[file-id]/completed  %atom  download count
::  /x/announce/[ship]           %path  unique announce url for ship
::  /x/stat/[ship]               %noun  total stats for ship
::  /x/stat/[ship]/[file-id]     %noun  stats for ship on file
::
/+  benc, torn, *pal,
    server, default-agent, verb, dbug
::
|%
+$  state-1
  $:  %1
      files=(map file-id file)
      stats=(mip ship file-id stat)
      ::  secrets for generating unique announce urls
      ::
      base-secret=@
      ship-secret=(map ship @)
  ==
::
+$  file-id  file-id:torn
+$  peer-id  @uxtpeerid  ::NOTE  actually @t, but rendering might cause trouble
::
+$  file
  ::TODO  maybe we want to ditch peer-id and operate off @p all the time?
  ::      still need to track it for announce responses though
  $:  peers=(map peer-id peer)
      keys=(map @ peer-id)
      completed=(set ship)  ::NOTE  we could do peer-id, but "less real"
      name=(unit @t)  ::NOTE  for scrape response ::TODO  make duiker send poke
  ==
::
+$  peer
  $:  ip=address:eyre
      port=@ud
      uploaded=@ud
      downloaded=@ud
      left=@ud
      key=(unit @)
      last-seen=@da
  ==
::
+$  stat
  $:  uploaded=@ud
      downloaded=@ud
      completed=_|
      seedtime=@dr
  ==
::
+$  announce
  $:  file-id=file-id
      =peer-id
      ip=address:eyre  ::TODO  maybe integrate +peer type explicitly
      port=@ud
      uploaded=@ud
      downloaded=@ud
      left=@ud
      compact=?
      no-peer-id=?
      event=?(~ %started %stopped %completed)
      numwant=(unit @ud)
      key=(unit @)
      tracker-id=(unit @)
  ==
::
+$  response
  $@  fail=@t
  $:  $:  compact=?
          no-peer-id=?
      ==
    ::
      warn=(unit @t)
      tracker-id=(unit @t)
      interval=@ud
      min-interval=(unit @ud)
      complete=@ud
      incomplete=@ud
      peers=(list peer-result)
  ==
::
+$  peer-result
  $:  =peer-id
      ip=address:eyre
      port=@ud
  ==
::
+$  scrape-response
  (map file-id scrape-stat)
::
+$  scrape-stat
  $:  complete=@ud
      incomplete=@ud
      downloaded=@ud
      name=(unit @t)
  ==
::
+$  action
  $%  [%base-secret new=@]
      [%ship-secret =ship new=@]
      [%filename =file-id name=@t]
  ==
::
+$  card     card:agent:gall
+$  eyre-id  @ta
--
::
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  sek=@ux  (shas dap.bowl eny.bowl)
    ~&  [dap.bowl %please-backup-base-secret sek]
    :_  this(base-secret sek)
    :~  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
        kick-peer-timer:do
    ==
  ++  on-save  !>(state)
  ++  on-load
    |=  =vase
    |^  ^-  (quip card _this)
        =/  loaded  !<(state-v vase)
        ~&  [dap.bowl %load -.loaded -.state]
        =?  loaded  ?=(%0 -.loaded)
          (state-0-to-1 loaded)
        ?>  ?=(%1 -.loaded)
        [~ this(state loaded)]
    ::
    +$  state-v
      $%  state-0
          state-1
      ==
    ::
    +$  state-0
      $:  %0
          files=(map file-id file)
          stats=(mip ship file-id stat-0)
          base-secret=@
          ship-secret=(map ship @)
      ==
    ::
    +$  stat-0
      $:  uploaded=@ud
          downloaded=@ud
          completed=_|
      ==
    ::
    ++  state-0-to-1
      |=  state-0
      ^-  state-1
      =-  [%1 files - base-secret ship-secret]
      %-  ~(run by stats)
      |=  f=(map file-id stat-0)
      %-  ~(run by f)
      |=  stat-0
      [uploaded downloaded completed ~s0]
    --
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+  mark  (on-poke:def mark vase)
        %handle-http-request
      =^  cards  state
        %-  handle-http-request:do
        !<([=eyre-id =inbound-request:eyre] vase)
      [cards this]
    ::
        %serval-action
      ?>  (team:title [our src]:bowl)
      =/  =action  !<(action vase)
      :-  ~
      ?-  -.action
        %base-secret  ~&  [dap.bowl 'expiring all announce urls!']
                      this(base-secret new.action)
        %ship-secret  ~&  [dap.bowl 'expiring announce url!' ship.action]
                      this(ship-secret (~(put by ship-secret) +.action))
        %filename     =-  this(files (~(put by files) file-id.action -))
                      =-  -(name `name.action)
                      (~(gut by files) file-id.action *file)
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ?:  ?=([%http-response @ ~] path)
      [~ this]
    (on-watch:def path)
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%e %bound *]
      ~?  !accepted.sign-arvo
        [dap.bowl 'bind rejected!' binding.sign-arvo]
      [~ this]
    ::
        [%b %wake *]
      ?>  ?=([%stale-peers ~] wire)
      =.  state  clear-stale-peers:do
      [[kick-peer-timer:do]~ this]
    ==
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?.  ?=([%x *] path)
      [~ ~]
    ?+  t.path  [~ ~]
        [%file @ ?(%seeders %leechers %completed) ~]
      ?~  fid=(slaw %ux i.t.t.path)  [~ ~]
      :^  ~  ~  %atom
      !>  ^-  @ud
      ?~  fil=(~(get by files) u.fid)  0
      =,  `file`u.fil
      ?-  i.t.t.t.path
        %seeders      complete:(count-in-complete peers)
        %leechers   incomplete:(count-in-complete peers)
        %completed  ~(wyt in completed)
      ==
    ::
        [%announce @ ~]
      ?.  =(src.bowl our.bowl)  ~
      ?~  who=(slaw %p i.t.t.path)  [~ ~]
      ``path+!>((generate-announce-path:do u.who))
    ::
        [%stats @ ?(~ [@ ~])]
      ?~  who=(slaw %p i.t.t.path)  [~ ~]
      ?^  t.t.t.path
        ?~  fid=(slaw %ux i.t.t.t.path)  [~ ~]
        ``noun+!>((~(gut bi stats) u.who u.fid *stat))
      =/  all=(list stat)
        ~(val by (~(gut by stats) u.who *(map file-id stat)))
      :^  ~  ~  %noun
      !>  ^-  [files=@ud uploaded=@ud downloaded=@ud completed=@ud seedtime=@dr]
      :-  (lent all)
      %+  roll  all
      |=  [stat [up=@ud down=@ud comp=@ud time=@dr]]
      :^    (add up uploaded)
          (add down downloaded)
        ?:(completed +(comp) comp)
      (add time seedtime)
    ==
  ::
  ++  on-leave  on-leave:def
  ++  on-agent  on-agent:def
  ++  on-fail   on-fail:def
  --
::
|_  =bowl:gall
::
::TODO  figure out what load we can bear
++  config
  |%
  ++  interval-dr   ~m60
  ++  expire-dr     (add interval-dr ~m15)
  ++  interval      (div interval-dr ~s1)
  ++  min-interval  (div ~m5 ~s1)
  ++  defwant       30
  --
::
++  kick-peer-timer
  =+  (add ~m5 (sub now.bowl (mod now.bowl ~m5)))
  [%pass /stale-peers %arvo %b %wait -]
::.
++  clear-stale-peers
  ^+  state
  =-  state(files -)
  %-  ~(run by files)
  |=  =file
  ^+  file
  =/  stale=(list [=peer-id peer])
    %+  skim  ~(tap by peers.file)
    |=  [* peer]
    (lth (add last-seen expire-dr:config) now.bowl)
  |-
  ?~  stale  file
  =,  i.stale
  ~&  [%clearing-stale-peer peer-id last-seen]
  =.  peers.file  (~(del by peers.file) peer-id)
  =?  keys.file  ?=(^ key.i.stale)  ::NOTE  =, shenanigans
    (~(del by keys.file) u.key)
  $(stale t.stale)
::
++  our-tracker-id
  :((cury cat 3) 'urbit-' dap.bowl '-' (scot %p our.bowl))
::
++  generate-announce-path
  |=  =ship
  ^-  path
  /(scot %p ship)/(announce-secret ship)/announce
::
++  validate-announce-path
  |=  =path
  ^-  (unit ship)
  ?.  ?=([@ @ *] path)
    ~
  ?~  who=(slaw %p i.path)  ~
  ?.  =(i.t.path (announce-secret u.who))  ~
  who
::
++  announce-secret
  |=  =ship
  %-  crip
  %+  scag  32  ::TODO  do we care about announce url length?
  %-  en-base58:mimes:html
  %+  shas  ship
  ::TODO  should we always include the base secret?
  (~(gut by ship-secret) ship base-secret)
::
++  handle-http-request
  |=  [=eyre-id =inbound-request:eyre]
  ^-  (quip card _state)
  =/  ,request-line:server
    (parse-request-line:server url.request.inbound-request)
  =;  [[status=@ud res=value:benc] =_state]
    :_  state
    %-  give-bencoded-response
    [status eyre-id res]
  ?.  ?&  ?=(%'GET' method.request.inbound-request)
          ?=(^ site)
          =(dap.bowl i.site)
      ==
    [[405 (bencode-response 'invalid request')] state]
  ?+  t.site  [[400 (bencode-response 'unsupported endpoint')] state]
      [@ @ %announce *]
    =/  who=(unit ship)
      (validate-announce-path t.site)
    ?~  who  [[400 (bencode-response 'invalid announce key')] state]
    =/  announce=(unit announce)
      %-  announce-from-args
      [args address.inbound-request]
    ?^  announce
      =+  (process-announce u.who u.announce)
      [[-<- (bencode-response -<+)] ->]
    ~&  [%invalid-announce url.request.inbound-request]
    :_  state
    [400 (bencode-response 'invalid announce')]
  ::
      [@ @ %scrape *]
    ::TODO  wish we could handle these as http scry...
    :_  state
    =/  who=(unit ship)
      (validate-announce-path t.site)
    ?~  who  [400 (bencode-response 'invalid announce key')]
    :-  200
    %-  bencode-scrape-response
    %-  process-scrape
    %+  murn  args
    |=  [key=@t value=@t]
    ^-  (unit file-id)
    ?.  =('info_hash' key)  ~
    ``@`(rev 3 20 value)
  ==
::
++  announce-from-args
  |=  [args=(list [key=@t value=@t]) =address:eyre]
  ^-  (unit announce)
  |^  %-  drop-pole:unity
  :~  (bind (get 'info_hash') (cury (cury rev 3) 20))  ::NOTE  rev because @t
    ::
      `(unit @)`(get 'peer_id')
    ::
      :-  ~
      %+  fall
        (rush (fall (get 'ip') '') ipa:eyre)
      address
    ::
      (bum 'port')
      (bum 'uploaded')
      (bum 'downloaded')
      (bum 'left')
      `=('1' (fall (get 'compact') '0'))
      `?=(^ (get 'no_peer_id'))
    ::
      :-  ~
      ?+  (get 'event')  ~
        [~ %started]    %started
        [~ %stopped]    %stopped
        [~ %completed]  %completed
      ==
    ::
      `(bum 'numwant')
      `(get 'key')
      `(get 'tracker_id')
  ==
  ::
  ++  get  (curr get-header:http args)
  ++  num  (curr rush dim:ag)
  ++  bum  |=(k=@t (biff (get k) num))
  --
::
++  process-announce
  |=  [=ship announce]
  ~&  [%announce ship=ship peer=`@ux`peer-id file=file-id what=event]
  ^-  [[status=@ud =response] _state]
  ::  if they report a tracker-id, and it doesn't match ours, reject them
  ::
  ?.  =(our-tracker-id (fall tracker-id our-tracker-id))
    :_  state
    [400 :((cury cat 3) 'this is ' our-tracker-id ', not ' (need tracker-id))]
  ::
  =/  =file
    (~(gut by files) file-id *file)
  =/  knew=?
    (~(has by peers.file) peer-id)
  =/  =peer
    (~(gut by peers.file) peer-id *peer)
  =/  =stat
    (~(gut bi stats) ship file-id *stat)
  ::  update stats based off of previously reported values (for this peer-id)
  ::
  =?  stat  &(!?=(%started event) (~(has by peers.file) peer-id))
    :*  ?:  (gte uploaded uploaded.peer)
          %+  add  uploaded.stat
          (sub uploaded uploaded.peer)
        ~&  [%strange-stat-report ship]
        %+  sub  uploaded.stat
        %+  min  uploaded.stat  ::  prevent underflow
        (sub uploaded.peer uploaded)
      ::
        ?:  (gte downloaded downloaded.peer)
          %+  add  downloaded.stat
          (sub downloaded downloaded.peer)
        ~&  [%sketchy-stat-report ship]
        %+  sub  downloaded.stat
        %+  min  downloaded.stat  ::  prevent underflow
        (sub downloaded.peer downloaded)
      ::
        |(completed.stat ?=(%completed event))
      ::
        %+  add  seedtime.stat
        ?.  &(knew =(0 left.peer) =(0 left))
          ~s0
        (sub now.bowl last-seen.peer)
    ==
  ::  update peer based off announce arguments
  ::
  =.  peer
    %_  peer
      ip          ip
      port        port
      uploaded    uploaded
      downloaded  downloaded
      left        left
      key         key
      last-seen   now.bowl
    ==
  ::  if they're using a key, delete their older peer-id,
  ::  and store a backpointer to the new one.
  ::
  =?  peers.file  &(?=(^ key.peer) (~(has by keys.file) u.key.peer))
    (~(del by peers.file) (~(got by keys.file) u.key.peer))
  =?  keys.file  ?=(^ key.peer)
    (~(put by keys.file) u.key.peer peer-id)
  ::  handle special events
  ::
  =.  file
    ?-  event
      ~           file
      %started    file
      %completed  file(completed (~(put in completed.file) ship))
    ::
        %stopped
      %_  file
        peers  (~(del by peers.file) peer-id)
        keys   ?~(key.peer keys.file (~(del by keys.file) u.key.peer))
      ==
    ==
  ::  update the peer, but only if not gone
  ::
  =?  peers.file  !?=(%stopped event)
    (~(put by peers.file) peer-id peer)
  ::
  =.  files
    (~(put by files) file-id file)
  =.  stats
    (~(put bi stats) ship file-id stat)
  ::
  :_  state
  :-  200
  ^-  response
  =+  (count-in-complete peers.file)
  :*  [compact no-peer-id]
      ~  ::TODO  when do we want to warn? in weird stats case?
      `our-tracker-id
      interval:config
      `min-interval:config
      complete
      incomplete
    ::
      %^  find-peers  peer-id
        peers.file
      [=(0 left) (fall numwant defwant:config) compact]
  ==
::
++  find-peers
  |=  [self=peer-id peers=(map peer-id peer) seed=? numwant=@ud compact=?]
  ^-  (list peer-result)
  =-  peers
  %+  roll
    =+  ~(tap by peers)
    ::  dumb pseudorandom shuffle
    ::
    (turn (sort (turn - (late now.bowl)) gor) head)
  |=  [[=peer-id =peer] have=@ud peers=(list [peer-id address:eyre @ud])]
  ^+  [have peers]
  =;  relevant=?
    ?.  relevant  [have peers]
    [+(have) [peer-id [ip port]:peer] peers]
  ::  don't gather more than required
  ::  don't include the requester
  ::  for compact responses, avoid ivp6
  ::  for seeders, find only leechers
  ::
  ?&  (lth have numwant)
      !=(peer-id self)
      !&(compact ?=(%ipv6 -.ip.peer))
      |(!seed (gth left.peer 0))
  ==
::
++  process-scrape
  |=  what=(list file-id)
  %-  ~(gas by *scrape-response)
  %+  turn
    ^-  (list [file-id file])
    ?:  =(~ what)  ~(tap by files)  ::NOTE  tmi
    %+  murn  what
    |=  h=file-id
    ^-  (unit [file-id file])
    ?.  (~(has by files) h)  ~
    `[h (~(got by files) h)]
  |=  [hash=file-id file]
  :-  hash
  =+  (count-in-complete peers)
  [complete incomplete ~(wyt in completed) name]
::
++  count-in-complete
  |=  peers=(map peer-id peer)
  ^-  [complete=@ud incomplete=@ud]
  =/  complete=@ud
    (lent (skim ~(tap by peers) |=([* peer] =(left 0))))
  :-  complete
  (sub ~(wyt by peers) complete)
::
++  give-bencoded-response
  |=  [status=@ud =eyre-id response=value:benc]
  ^-  (list card)
  %+  give-simple-payload:app:server
    eyre-id
  :-  [status ~]
  ?:  =(~ response)  ~
  %-  some
  %-  as-octt:mimes:html
  %-  render:benc
  response
::
::
++  render-ip
  |=  =address:eyre
  ^-  tape
  ?-  -.address
    %ipv4  (slag 1 (scow %if +.address))
    %ipv6  !!
  ==
::
++  bencode-response
  |=  =response
  ^-  value:benc
  :-  %map
  %-  ~(gas by *(map tape value:benc))
  ?@  response
    ~&  [%bencoding-failure response]
    ^-  (list (pair tape value:benc))
    ["failure reason" %byt (trip fail.response)]~
  ~&  [%bencoding-response com=complete.response inc=incomplete.response per=(turn peers.response tail)]
  =,  response
  %+  weld
    ^-  (list (pair tape value:benc))
    ?~  tracker-id.response  ~  ::NOTE  =, bork
    ["tracker id" %byt (trip u.tracker-id)]~
  %+  weld
    ^-  (list (pair tape value:benc))
    ?~  min-interval.response  ~  ::NOTE  =, bork
    ["min interval" %int (new:si & u.min-interval)]~
  ^-  (list (pair tape value:benc))
  :~  "interval"^[%int (new:si & interval)]
      "complete"^[%int (new:si & complete)]
      "incomplete"^[%int (new:si & incomplete)]
    ::
      :-  "peers"
      ^-  value:benc
      ::TODO  only transmission seems to consider this valid?
      :: ?:  compact
      ::   ~&  %note-compact-peers-untested-maybe
      ::   (bencode-compact-peers peers)
      (bencode-dictionary-peers no-peer-id peers)
  ==
::
++  bencode-dictionary-peers
  |=  [no-peer-id=? peers=(list peer-result)]
  ^-  value:benc
  :-  %mor
  %+  turn  peers
  |=  [=peer-id ip=address:eyre port=@ud]
  :-  %map
  %-  ~(gas by *(map tape value:benc))
  :*  "ip"^[%byt (render-ip ip)]
      "port"^[%int (new:si & port)]
    ::
      ?:  no-peer-id  ~
      ["peer id" [%byt (trip peer-id)]]~
  ==
::
++  bencode-compact-peers
  |=  peers=(list peer-result)
  ^-  value:benc
  :-  %byt
  %-  zing
  %+  turn  peers
  |=  peer-result
  ~|  [%unexpected-peer-result ip]
  ?>  ?=(%ipv4 -.ip)  ::NOTE  caught in +find-peers
  ::  we con so that we get (at least) the required amount of bytes,
  ::  even if the values have leading zeroes.
  ::
  ::NOTE  if someone submitted ip or port number greater than expected sizes
  ::      somehow, this will render incorrect data. but, that shouldn't happen!
  ::
  %+  weld
    (flop (scag 4 (rip 3 (con +.ip 0x1.0000.0000))))
  (flop (scag 2 (rip 3 (con port 0x1.0000))))
::
++  bencode-scrape-response
  |=  res=scrape-response
  ^-  value:benc
  ~&  [%bencoding-scrape res]
  =;  files=value:benc
    [%map ["files"^files ~ ~]]
  :-  %map
  %-  ~(gas by *(map tape value:benc))
  %+  turn  ~(tap by res)
  |=  [hash=file-id scrape-stat]
  :-  (flop (rip 3 hash)) :: (trip hash)  ::NOTE  care, maybe ordering...
  :-  %map
  %-  ~(gas by *(map tape value:benc))
  :*  "complete"^[%int (new:si & complete)]
      "incomplete"^[%int (new:si & incomplete)]
      "downloaded"^[%int (new:si & downloaded)]
    ::
      ?~  name  ~
      ["name" [%byt (trip u.name)]]~
  ==
--

