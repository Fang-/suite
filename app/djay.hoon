::  djay: social radio
::
::TODO  command queueing logic is garbage. general flow is iffy.
::      beware, here be monsters!
::
::TODO  for djay chat/stream page, include advice:
::      "for best results, share music similar to what's currently playing"?
::TODO  for djay, implement a chat-create-hook that creates new local channels
::      as /music/<user-input>. hooks should make this easy, right?
::      this way, ~paldev can be user-populated with genre-specific streams
::TODO  for random next song, "24/7 user-contributed beats to hang out to"
::
::  enqueueing flow:
::  - get chat msg. if youtube url, continue
::  - async get video details
::  - receive video details, add to station, append to queue
::  - if now-playing is empty, fill it and kick timer
::
::  dequeueing flow:
::  - get timer event
::  - pop from queue, update subs, send "now playing" msg into chat
::  - set new timer
::
/-  *chat-store
/+  pd=podium, default-agent, verb, dbug
::
::  structures
::
=>  |%
    +$  state-0
      $:  %0
          stations=(map path station)
          pending=(unit command)
          command-queue=(list command)
      ==
    ::
    +$  station
      $:  videos=(map video-id video-details)
          queue=(list video-id)
          now-playing=video-id
          ::NOTE  including next-at with now-playing details (@dr) allows us to
          ::      deduce the current seek position, allowing for true radio-like
          ::      playback on the interface side.
          next-at=@da
          source=path  ::  chat target
          =config
      ==
    ::
    +$  config  ~  ::TODO
    ::
    +$  video-id  cord
    +$  video-details
      $:  name=cord
          duration=@dr
          channel-id=cord
      ==
    ::
    +$  playlist
      (list [video-id video-details])
    ::
    ::
    +$  command
      $%  [%create-station =path]
          [%load-station =path]  ::  find videos in chat history
          [%delete-station =path]
          [%play-next =path =video-id]  ::TODO  why not lists here too?
          [%add-to-queue =path =video-id]
          [%add-to-library =path vids=(list video-id)]
          [%skip =path]
      ==
    ::
    +$  update
      $%  [%playlist =playlist]
          [%current =video-id =video-details next-at=@da]
      ==
    ::
    +$  card  card:agent:gall
    --
::
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
^-  agent:gall
::
::  interface logic
::
=<
  |_  =bowl:gall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init  on-init:def
  ++  on-save  !>(state)
  ++  on-load
    |=  old=vase
    ~&  [dap.bowl %on-load]
    =/  prev  !<(state-0 old)
    :: [~ this(state prev)]
    ~&  %clearing-cmd-queue
    [~ this(state prev(pending ~, command-queue ~))]
    :: ~&  %clearing-state
    :: [~ this(state *state-0)]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    :: ?>  ?=(%djay-command mark)
    =/  =command  !<(command vase)
    =^  cards  state
      (handle-command:do command)
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ~|  wire
    ?+  -.sign  (on-agent:def wire sign)
        %watch-ack
      ?~  p.sign  [~ this]
      ~|  [%watch-failed wire]
      !!  ::TODO  handle gracefully
    ::
        %kick
      ?+  wire  (on-agent:def wire sign)
          [%chat *]
        :_  this
        ~[(watch-chat:do t.wire)]
      ::
          [%thread *]
        ::TODO  likely because of success... but exclusively?
        ~&  [%kicked-by-thread wire]
        [~ this]
      ==
    ::
        %fact
      =*  mark  p.cage.sign
      =*  vase  q.cage.sign
      ?+  mark  (on-poke:def mark vase)
          %chat-update
        ?>  ?=([%chat *] wire)
        =/  upd  !<(chat-update vase)
        =^  cards  state
          ?+  -.upd  [~ state]
              %messages
            (handle-messages:do t.wire envelopes.upd)
          ::
              %message
            (handle-message:do t.wire envelope.upd)
          ==
        [cards this]
      ::
          ?(%thread-fail %thread-done)
        ?>  ?=([%thread @ *] wire)
        =*  reason  i.t.wire
        =*  path    t.t.wire
        ?-  mark
            %thread-done
          =^  cards  state
            %+  handle-video-details:do
              path
            !<((map video-id video-details) q.cage.sign)
          [cards this]
        ::
            %thread-fail
          ?:  =(~ pending)  ::NOTE  avoid tmi for =^ below
            ~&  [%weird-no-pending-command-for-thread-result wire]
            [~ this]
          =+  !<([=term =tang] q.cage.sign)
          =/  =tank  leaf+"{(trip dap.bowl)} failed; will retry"
          %-  (slog tank leaf+<term> tang)
          [~ this(pending ~)]
          :: =^  cards  state
          ::   retry:do
          :: [cards this]
        ==
      ==
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?.  ?=(%wake +<.sign-arvo)
      (on-arvo:def wire sign-arvo)
    =^  cards  state
      (play-next:do wire)
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ::NOTE  only support subscribing via /app/podium for now, it's all we use
    ?>  ?=([%podium *] path)
    [~ this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?.  ?=([%x %podium *] path)
      ~  ::  invalid
    =/  path  t.t.path
    ?.  (~(has by stations) path)
      [~ ~] ::  not available
    ``json+!>((podium-json:do path %all))
  ::
  ++  on-leave  on-leave:def
  ++  on-fail   on-fail:def
  --
::
::  app logic
::
|_  =bowl:gall
+*  podium  ~(. pd bowl)
::  config
::
++  max-dr  ~m5
::
::  efects
::
++  set-timer
  |=  [=wire until=@da]
  ^-  card
  [%pass wire %arvo %b %wait until]
::
++  cancel-timer
  |=  [=wire until=@da]
  ^-  card
  [%pass wire %arvo %b %rest until]
::
++  start-thread
  |=  [=wire name=term thread-args=vase]
  ~&  [%djay %starting-thread name]
  =/  tid=@ta
    :((cury cat 3) dap.bowl '--' name '--' (scot %uv (end 3 8 eny.bowl)))
  =/  args  [~ `tid name thread-args]
  =/  wire  [%thread tid wire]
  ^-  (list card)
  :~  [%pass wire %agent [our.bowl %spider] %watch /thread-result/[tid]]
      [%pass wire %agent [our.bowl %spider] %poke %spider-start !>(args)]
  ==
::
++  leave-thread  ::TODO  unused
  |=  [our=ship =wire]
  ^-  card
  [%pass [%thread wire] %agent [our %spider] %leave ~]
::
++  watch-chat
  |=  chat=path
  ^-  card
  [%pass [%chat chat] %agent [our.bowl %chat-store] %watch [%mailbox chat]]
::
++  leave-chat
  |=  chat=path
  ^-  card
  [%pass [%chat chat] %agent [our.bowl %chat-store] %leave ~]
::
++  notify-listeners
  |=  [=path what=?(%all %next %queue)]
  ^-  card
  ~&  [%djay %notifying-listeners path what]
  :: [%give %fact ~[path] %djay-update !>([%current current])]
  [%give %fact [%podium path]~ %json !>((podium-json path what))]
::
++  say-now-playing
  |=  [=path video-details]
  ^-  card
  =;  action=chat-action
    [%pass /notify %agent [our.bowl %chat-store] %poke %chat-action !>(action)]
  :+  %message  path
  :*  (shas %now-playing eny.bowl)
      *@ud
      our.bowl
      now.bowl
      [%text (cat 3 '::  Now playing: ' name)]
  ==
::
::  podium json
::
++  podium-json
  |=  [=path what=?(%all %next %queue)]
  ^-  json
  =+  (~(got by stations) path)
  =,  enjs:format
  |^  %-  pairs
      ^-  (list [@t json])
      ;:  welp
        ?.  ?=(?(%all %next) what)  ~
        ['nowPlaying' (video now-playing)]~
      ::
        ?.  ?=(%all what)  ~
        ['timeUntilNext' (numb (div (sub next-at now.bowl) ~s1))]~
      ::
        ['queue' a+(turn queue video)]~
      ==
  ::
  ++  video
    |=  =video-id
    ^-  json
    =+  (~(gut by videos) video-id *video-details)
    %-  pairs
    :~  'id'^s+video-id
        'name'^s+name
        'duration'^(numb (div duration ~s1))
    ==
  --
::
::  command queueing
::
++  handle-command
  |=  =command
  ^-  (quip card _state)
  ?.  =(~ pending)  ::NOTE  avoid tmi
    ~&  %still-working--command-added-to-queue
    ~&  pending=pending
    ~&  queque=command-queue
    =.  command-queue  (snoc command-queue command)
    [~ state]
  ::TODO  special-case non-async commands? ie ones that don't load details from
  ::      video-id. feels pretty ugly depending on "knowing" any given command
  ::      handler wants to do threads though...
  =.  pending  `command
  ?-  -.command
    %create-station       (create-station +.command)
    %load-station         (load-station +.command)
    %delete-station       (delete-station +.command)
  ::
    %play-next            (get-details [path ~[video-id]]:command)
    %add-to-queue         (get-details [path ~[video-id]]:command)
    %add-to-library       (get-details +.command)
    %skip                 (skip +.command)
  ==
::
++  retry
  ^-  (quip card _state)
  ?~  pending
    ~&  %nothing-pending--not-retrying
    [~ state]
  %.  u.pending
  handle-command(pending ~)
::
++  complete-command
  |=  cards=(list card)
  ^-  (quip card _state)
  =.  pending  ~
  ?:  =(~ command-queue)  [cards state]  ::NOTE  avoid tmi on the =^
  =^  more-cards  state
    ^-  (quip card _state)
    ?>  ?=(^ command-queue)
    %.  i.command-queue
    handle-command(command-queue t.command-queue)
  ^-  (quip card _state)
  [(weld cards more-cards) state]
::
::  actions
::
++  create-station
  |=  =path
  ^-  (quip card _state)
  ?:  (~(has by stations) path)
    ~&  [%already-exists path]
    (complete-command ~)
  =.  stations
    %+  ~(put by stations)  path
    [~ ~ *video-id *@da path *config]
  ::TODO  maybe only complete on watch-ack?
  %-  complete-command
  ~[(watch-chat path) (expose:podium path)]
::
++  load-station
  |=  =path
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [dap.bowl %cant-load-for-nonexistent path]
    [~ state]
  =;  mail=(unit mailbox)
    ?~  mail
      ~&  [dap.bowl %weird-no-mailbox path]
      [~ state]
    =^  cards  state
      (handle-messages path envelopes.u.mail)
    (complete-command cards)
  ::NOTE  screw trying to wrestle the envelopes scry interface into submission.
  ::      i will never get those 15 minutes back.
  .^  (unit mailbox)
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    %mailbox
    (snoc path %noun)
  ==
::
++  delete-station
  |=  =path
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [%doesnt-exist path]
    (complete-command ~)
  =/  =station  (~(got by stations) path)
  =.  stations  (~(del by stations) path)
  %-  complete-command
  ~[(leave-chat source.station) (censor:podium path)]
::
++  skip
  |=  =path
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [%doesnt-exist path]
    (complete-command ~)
  =/  =station  (~(got by stations) path)
  =/  cancel=card  (cancel-timer path next-at.station)
  =^  cards  state
    (play-next path)
  %-  complete-command
  [cancel cards]
::
++  add-next
  |=  [=path =video-id]
  ^-  (quip card _state)
  (get-details path ~[video-id])
::
++  add-to-library  get-details
::
++  get-details
  |=  [=path vids=(list video-id)]
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [%cant-add-to-nonexistent path]
    (complete-command ~)
  :_  state
  (start-thread path %youtube-get-videos !>(vids))
::
::  reactions
::
++  handle-messages
  |=  [=path envelopes=(list envelope)]
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [%msg-for-nonexistent path]
    :_  state
    ~[(leave-chat path)]
  %-  handle-command
  :+  %add-to-library  path
  (murn envelopes get-video-from-message)
::
++  handle-message
  |=  [=path =envelope]
  ^-  (quip card _state)
  ::TODO  we're doing this check *everywhere*...
  ::      maybe just init this entire core with station?
  ?.  (~(has by stations) path)
    ~&  [%msg-for-nonexistent path]
    :_  state
    ~[(leave-chat path)]
  ::  only care about url messages
  ::
  ?.  ?=(%url -.letter.envelope)  [~ state]
  =/  vid=(unit video-id)  (get-video-from-message envelope)
  ?~  vid  [~ state]
  (handle-command %add-to-queue path u.vid)
::
++  handle-video-details
  ::NOTE  the thread will likely return a bigger structure than this,
  ::      if i make it pass all api-provided details. but this is all djay
  ::      needs, so it's a good starting point.
  |=  [=path deets=(map video-id video-details)]
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~&  [%video-details-for-nonexistent path]
    (complete-command ~)
  =/  =station  (~(got by stations) path)
  ~&  [dap.bowl %got-vid-deets deets]
  ::  update station as desired by the command,
  ::  and figure out if we need to play the next video right now.
  ::
  =^  play-next-now  station
    ::  doesn't matter if we already have it in station or not, we just
    ::  overwrite with latest details
    ::
    =.  videos.station  (~(uni by videos.station) deets)
    ?~  pending
      ~&  %video-details-without-command
      [| station]
    ::
    =/  was-idle=?  =('' now-playing.station)
    ~&  [%was-idle was-idle]
    =*  cmd  u.pending
    ?+  -.cmd
      ~&  [%details-for-weird-command -.u.pending]
      [| station]
    ::
        %play-next
      :-  was-idle
      station(queue [video-id.cmd queue.station])
    ::
        %add-to-queue
      :-  was-idle
      station(queue (snoc queue.station video-id.cmd))
    ::
        %add-to-library
      [| station]
    ==
  =.  stations  (~(put by stations) path station)
  =^  cards  state
    ?:  play-next-now
      ::NOTE  above logic should guarantee we aren't playing next while
      ::      there's already a "play next eventually" timer running.
      (play-next path)
    :_  state
    ?.  ?=([~ ?(%play-next %add-to-queue) *] pending)
      ~
    [(notify-listeners path %queue)]~
  (complete-command cards)
::
++  play-next
  |=  =path
  ^-  (quip card _state)
  ?.  (~(has by stations) path)
    ~|  [%weird-play-next-for-unknown path]
    !!
  =/  =station  (~(got by stations) path)
  ~&  [dap.bowl %playing-next path]
  ::  update now-playing
  ::
  =/  from-queue=?  ?=(^ queue.station)
  =^  next-id=video-id  queue.station
    ::  if there is a queue, pop it.
    ::  else, get random video from library.
    ::
    ?^  queue.station
      queue.station
    :_  ~
    =/  video-list=(list video-id)
      ::  remove now-playing to avoid repetitive plays
      ::
      =-  (turn - head)
      ~(tap by (~(del by videos.station) now-playing.station))
    =+  count=(lent video-list)
    ?:  =(0 count)  now-playing.station
    %+  snag
      (~(rad og eny.bowl) count)
    video-list
  =/  =video-details       (~(got by videos.station) next-id)
  =.  now-playing.station  next-id
  =.  next-at.station      (add now.bowl (min duration.video-details max-dr))
  =.  stations             (~(put by stations) path station)
  :_  state
  ::  update subscribers, set new timer
  ::
  :*  (notify-listeners path %next)
      (set-timer path next-at.station)
    ::
      ?.  from-queue  ~
      [(say-now-playing path video-details)]~
  ==
::
::  utilities
::
++  get-video-from-message
  |=  envelope
  ^-  (unit video-id)
  ?.  ?=(%url -.letter)  ~
  =/  url=purl:eyre
    (need (de-purl:html url.letter))
  =*  host  r.p.url
  =*  path  q.q.url
  =*  quer    r.url
  ?:  ?=(%| -.host)  ~
  ?:  ?&  =(`0 (find ~['com' 'youtube'] p.host))
          ?=(^ (find ~['watch'] path))
      ==
    `(~(got by (~(gas by *(map @t @t)) quer)) 'v')
  ?:  =(`0 (find ~['be' 'youtu'] p.host))
    `(snag 0 path)
  ~
::
--



::  old code below this line
::  i don't think it was in a compiling state at the time (^:

::
::  async helpers
:: ::
:: =>  |%
::     ::TODO  send-effect-on-bone is small enough, just use as-is?
::     ++  send-diff-to
::       |=  [=bone out=out-peer-data]
::       =/  m  (async:stdio ,~)
::       ^-  form:m
::       (send-effect-on-bone:stdio bone %diff out)
::     ::
::     ++  broadcast-update
::       |=  out=out-peer-data
::       =/  m  (async:stdio ,~)
::       ^-  form:m
::       =-  (give-result:stdio - out)
::       ?-  +<.out
::         %current   /current
::         %playlist  /playlist
::       ==
::     ::
::     ++  youtube-api-request
::       |=  [=path data=(list [@t @t])]
::       =/  m  (async:stdio ,json)
::       ^-  form:m
::       =/  =request:http
::         =/  url=cord
::           ;:  (cury cat 3)
::             'https://www.googleapis.com/youtube/v3'
::             (spat path)
::           ::
::             %+  roll
::               `_data`[['key' 'API_KEY'] data]
::             |=  [[key=cord value=cord] all=cord]
::             ;:  (cury cat 3)
::               ?:(=(`@`0 all) '?' '&')
::               key
::               '='
::               value
::             ==
::           ==
::         :*  method=%'GET'
::             url=url
::             header-list=['Content-Type'^'application/json' ~]
::             body=~
::         ==
::       ;<  ~  bind:m  (send-request:stdio request)
::       ;<  rep=(unit client-response:iris)  bind:m
::         take-maybe-response:stdio
::       ?~  rep
::         (pure:m ~)
::       =*  client-response  u.rep
::       ?>  ?=(%finished -.client-response)
::       ?~  full-file.client-response
::         (pure:m `json`~)
::       =*  body=@t  q.data.u.full-file.client-response
::       (pure:m `json`(fall (de-json:html body) ~))
::     ::
::     ++  get-video-details
::       |=  =video-id
::       =/  m  (async:stdio video-details)
::       ;<  res=json  bind:m
::         %+  youtube-api-request  /videos
::         :~  ['part' 'snippet,contentDetails']
::             ['id' video-id]
::         ==
::       %-  pure:m
::       ~|  res
::       |^  =,  dejs:format
::           ^-  video-details
::           =-  ~!  -  -
::           %+  snag  0
::           ((ot 'items'^(ar item) ~) res)
::       ::
::       ++  item
::         =,  dejs:format
::         %-  ot
::         :~  'snippet'^(ot 'title'^so ~)
::             'contentDetails'^(ot 'duration'^(cu yule (su dure)) ~)
::             'snippet'^(ot 'channelId'^so ~)
::         ==
::       ::  +dure: parse ISO 8401 duration (excluding months, years)
::       ::TODO  stdlib?
::       ::
::       ++  dure
::         ;~  pfix  (jest 'PT')
::           ;~  plug
::             (easy 0)
::             ;~(pose ;~(sfix dum:ag (just 'H')) (easy 0))
::             ;~(pose ;~(sfix dum:ag (just 'M')) (easy 0))
::             ;~(pose ;~(sfix dum:ag (just 'S')) (easy 0))
::             (easy ~)
::           ==
::         ==
::       --
::     --
:: ::
:: ::  main loop
:: ::
:: =>  |%
::     ++  process-message
::       |=  [=state =station=path =chat=path =envelope]
::       =/  m  tapp-async
::       ^-  form:m
::       ?.  (~(has by stations.state) station-path)
::         ~&  [%weird-message-no-station station-path]
::         (pure:m state)
::       =/  =station  (~(got by stations.state) station-path)
::       ?.  =(chat-path path.source.station)
::         ~&  [%weird-message-wrong-source station=station-path chat=chat-path]
::         (pure:m state)
::       ...
::       ?~  vid  (pure:m state)
::       ;<  =video-details  bind:m
::         (get-video-details u.vid)
::       ;<  new=^station  bind:m
::         (add-video station u.vid video-details)
::       %-  pure:m
::       state(stations (~(put by stations.state) station-path new))
::     ::
::     ++  add-video
::       |=  [=station id=video-id deets=video-details]
::       =/  m  (async:stdio ,^station)
::       ^-  form:m
::       ::  see handle-video-details
::     ::
::
::     ::
::     ++  wake-next
::       |=  [wir=wire err=(unit tang)]
::       ^-  (quip move _this)
::       ?^  err
::         (mean u.err)
::       ?:  =(0 ~(wyt by videos))
::         ~&  %silently-drop-timer
::         [~ this]
::       :: ...
::       =^  moz  this  (play-next next-id from-queue)  ::  wtf
::       :_  this
::       (broadcast-update %djay-update %current next-id)  ::TODO  in play-next?
::     ::
::     ++  play-next
::       |=  =station
::       =/  m  (async:stdio ,^station)
::       ^-  form:m
::       ;<  now=@da  bind:m  get-time:stdio
::       =^  [=video-id say=?]  queue.station
::         ::  if anything in queue, pop it
::         ?^  queue.station  [[i &] t]:queue.station
::         ::  else, shuffle from library
::         =-  [[- &] queue]
::         =/  vis=(list video-id)  ~(tap in ~(key by videos))
::         =/  num=@ud  (lent vis)
::         ?:  =(1 num)  (snag 0 vis)
::         |-  ^-  video-id
::         =/  vid=video-id
::           (snag (~(rad og now) num) vis)
::         ?.  =(vid now-playing)  vid
::         $(now +(now))
::       =.  now-playing.station  video-id
::       ::  set timer for next
::       ;<  ~  bind:m
::         ::NOTE  we use +send-raw-card here to ensure we always set a new timer,
::         ::      regardless of what happens further on in the flow.
::         =;  next=@da
::           (send-raw-card:stdio %wait /effect/(scot %da next) next)
::         %+  add  now
::         %+  add  ~s2  ::NOTE  buffer for... buffering and other delays
::         duration:(~(got by videos) video-id)
::       ::  maybe announce new song
::       ;<  ~  bind:m
::         ?.  say  (pure:(async:stdio ,~) ~)
::         (announce (trip name:(~(got by videos) next-id)))
::       (pure:m station)
::     ::
::     ++  announce
::       |=  =tape
::       %+  poke-app:stdio
::         [our.bowl %chat-hook]
::       :-  %chat-action
::       :+  %message
::         [(scot %p ship.source) path.source]
::       :*  (shax dap.bowl now.bowl)
::           *@
::           our.bowl
::           now.bowl
::           [%text (crip "Now playing: {-}")]
::       ==
::     --
:: ::
:: ++  peer
::   |=  =path
::   %-  update-to
::   ?+  wire  ~|([%invalid-peer path] !!)
::       [%current ~]
::     `[bone %diff %djay-current now-playing]
::   ::
::       [%playlist ~]
::     %-  some
::     :^  bone  %diff  %djay-playlist
::     ^-  playlist
::     :-  [now-playing (~(got by videos) now-playing)]
::     %+  turn  queue
::     |=  id=video-id
::     [id (~(got by videos) id)]
::   ==
:: --
