::  pals: manual peer discovery
::
::    acts as a "friendlist" of sorts, letting one add arbitrary ships to
::    arbitrary lists. upon doing so, the other party is informed of this.
::    this lets the app expose "friend requests" and mutuals, in addition
::    to user-defined sets of friends.
::
::    intended use case is as simple, bare-bones peer discovery and
::    permissioning for truly peer-to-peer applications, in place of
::    (or as supplement to) group-based peer discovery.
::    for example, a game wanting to stay abreast of high scores,
::    or filesharing service giving selective access.
::
::    "leeches" are ships who added us.
::    "targets" are ships we have added.
::    "mutuals" is the intersection of "leeches" and "targets".
::
::      reading
::    external applications likely want to read from this via scries or
::    watches, both of which are outlined below.
::    finding interaction targets or mutuals to poke or subscribe to, using
::    mutual status as permission check, etc.
::    to scry data out of this app, please use /lib/pals.
::    one might be tempted to use list names for namespacing (ie %yourapp
::    would only retrieve targets from the ~.yourapp list), but beware that
::    this overlaps with user-facing organizational purposes. if lists feel
::    opaque or inaccessible, it's to discourage this. but the right balance
::    might not have been found yet...
::
::      writing
::    poke this app with a $command.
::    %meet adds a ship. it is also added to any list names specified.
::    %part removes a ship from either all or the specified lists.
::    the ~. list name is reserved and cannot be added to.
::    managing pals without an interface that lets users control that behavior
::    is bad manners. managing pals without informing the user is evil.
::
::      scry endpoints (all %noun marks)
::NOTE  %y at / doesn't actually work because gall eats it ):
::    y  /                       arch        [%leeches %targets %mutuals ~]
::    y  /[status]               arch        non-empty lists listing
::
::    x  /                       records     full pals state
::    x  /leeches                (set ship)  foreign one-sided friendships
::    x  /targets(/[list])       (set ship)  local one-sided friendships
::    x  /mutuals(/[list])       (set ship)  mutual friendships
::
::    x  /leeches/[ship]         ?  is ship a leeche?
::    x  /targets/[list]/[ship]  ?  is ship a target? list may be ~. for all
::    x  /mutuals/[list]/[ship]  ?  is ship a mutual? list may be ~. for all
::
::      subscription endpoints (local ship only, all %pals-effect marks)
::    /targets   target-effect   effect for every addition/removal
::    /leeches   leeche-effect   effect for every addition/removal
::
/-  *pals
/+  rudder, dbug, verb, default-agent
::
/~  pages  (page:rudder records command)  /app/pals/webui
::
|%
+$  state-1  [%1 records]
::
+$  card  card:agent:gall
--
::
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
::
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =^  cards  this
    (on-poke %pals-command !>(`command`[%meet ~paldev ~]))
  :_  this
  :+  [%pass /jael/pubs %arvo %j %public-keys ~]
    [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]
  cards
::
++  on-save  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
      =/  old=state-n  !<(state-n ole)
      =^  caz=(list card)  old
        ?.  ?=(%0 -.old)  [~ old]
        =.  state  [%1 +.old]
        =^  caz    this
          ::TODO  run this again some time in the future, to solve for
          ::      the "breached & never re-added you" case, where they
          ::      might not know you need to hear a %bye.
          (on-poke %noun !>(%resend))
        [[[%pass /jael/pubs %arvo %j %public-keys ~] caz] state]
      ?>  ?=(%1 -.old)
      :_  this(state old)
      (weld caz (update-widget bowl +.old))
  ::
  +$  state-n  $%(state-1 state-0)
  +$  state-0  [%0 records]
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %noun
    ?+  q.vase  $(mark %pals-command)
        %resend
      =/  out=(set ship)  ~(key by outgoing)
      =.  receipts
        =/  out=(list ship)  ~(tap in out)
        |-
        ?~  out  receipts
        =.  receipts  (~(del by receipts) i.out)
        $(out t.out)
      :_  this
      %+  weld
        %+  turn  ~(tap in out)
        |=  o=ship
        [%pass /hey %agent [o dap.bowl] %poke %pals-gesture !>([%hey ~])]
      %+  turn  ~(tap in (~(dif in incoming) out))
      |=  i=ship
      [%pass /bye %agent [i dap.bowl] %poke %pals-gesture !>([%bye ~])]
    ==
  ::
    ::  %pals-command: local app control
    ::
      %pals-command
    ?>  =(our src):bowl
    =+  !<(cmd=command vase)
    ?:  (~(has in in.cmd) ~.)
      ~|  [%illegal-empty-list-name in=-.cmd]
      !!
    ?:  =(our.bowl ship.cmd)
      [~ this]
    ::
    =/  known=?  (~(has by outgoing) ship.cmd)
    =;  [yow=? =_outgoing]
      ^-  (quip card _this)
      =?  receipts  yow
        ::  if we're sending a new %hey, clear any existing receipt.
        ::  if we're sending a %bye, no need to track the old receipt.
        ::
        (~(del by receipts) ship.cmd)
      =.  outgoing.state  outgoing
      :_  this
      ?.  yow  ~
      %+  weld  (update-widget bowl +.state)
      ^-  (list card)
      :~  =/  =gesture  ?-(-.cmd %meet [%hey ~], %part [%bye ~])
          =/  =cage     [%pals-gesture !>(gesture)]
          [%pass /[-.gesture] %agent [ship.cmd dap.bowl] %poke cage]
        ::
          =/  =effect   ?-(-.cmd %meet [- ship]:cmd, %part [- ship]:cmd)
          =/  =cage     [%pals-effect !>(effect)]
          [%give %fact [/targets]~ cage]
      ==
    ::
    ?-  -.cmd
        %meet
      :-  !known
      %+  ~(put by outgoing)  ship.cmd
      %-  ~(uni in in.cmd)
      (~(gut by outgoing) ship.cmd ~)
    ::
        %part
      ?:  =(~ in.cmd)
        ::  remove target entirely
        ::
        [known (~(del by outgoing) ship.cmd)]
      ::  remove from specified lists
      ::
      :-  |
      =.  outgoing
        =/  liz=(list @ta)  ~(tap in in.cmd)
        |-  ^+  outgoing
        ?~  liz  outgoing
        $(liz t.liz, outgoing (~(del ju outgoing) ship.cmd i.liz))
      ::NOTE  we could account for this above, but +del:ju is just easier there
      =?  outgoing  !(~(has by outgoing) ship.cmd)
        (~(put by outgoing) ship.cmd ~)
      outgoing
    ==
  ::
    ::  %pals-gesture: foreign %pals signals
    ::
      %pals-gesture
    ?<  =(our src):bowl
    =*  ship  src.bowl
    =+  !<(=gesture vase)
    =/  [yow=? =_incoming]
      =*  has  (~(has in incoming) ship)
      ?-  -.gesture
        %hey  :-  !has  (~(put in incoming) ship)
        %bye  :-   has  (~(del in incoming) ship)
      ==
    =.  incoming.state  incoming
    :_  this
    ^-  (list card)
    ?.  yow  ~
    %+  weld  (update-widget bowl +.state)
    ^-  (list card)
    :*  =/  =effect  ?-(-.gesture %hey [%near ship], %bye [%away ship])
        =/  =cage    [%pals-effect !>(effect)]
        [%give %fact [/leeches]~ cage]
      ::
        ?.  .^(? %gu /(scot %p our.bowl)/hark/(scot %da now.bowl)/$)  ~
        =/  body
          =-  [ship+ship - ~]
          ?-  -.gesture
            %hey  ' added you as a pal.'
            %bye  ' no longer considers you a pal.'
          ==
        =/  id      (end 7 (shas %pals-notification eny.bowl))
        =/  rope    [~ ~ q.byk.bowl /(scot %p ship)/[-.gesture]]
        =/  action  [%add-yarn & & id rope now.bowl body /pals ~]
        =/  =cage   [%hark-action !>(action)]
        [%pass /hark %agent [our.bowl %hark] %poke cage]~
    ==
  ::
    ::  %handle-http-request: incoming from eyre
    ::
      %handle-http-request
    =;  out=(quip card _+.state)
      [-.out this(+.state +.out)]
    %.  [bowl !<(order:rudder vase) +.state]
    %-  (steer:rudder _+.state command)
    :^    pages
        (point:rudder /[dap.bowl] & ~(key by pages))
      (fours:rudder +.state)
    |=  cmd=command
    ^-  $@  brief:rudder
        [brief:rudder (list card) _+.state]
    =^  caz  this
      (on-poke %pals-command !>(cmd))
    ['Processed succesfully.' caz +.state]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  =(our.bowl src.bowl)
  ?+  path  (on-watch:def path)
    [%http-response *]  [~ this]
  ::
      [%targets ~]
    :_  this
    %+  turn  ~(tap in ~(key by outgoing))
    |=(=@p [%give %fact ~ %pals-effect !>(`effect`[%meet p])])
  ::
      [%leeches ~]
    :_  this
    %+  turn  ~(tap in incoming)
    |=(=@p [%give %fact ~ %pals-effect !>(`effect`[%near p])])
  ::
    ::TODO  consider adding a subscription endpoint that includes tags?
    ::      shouldn't become too legible to applications though...
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  wire  ~&([dap.bowl %strange-wire wire] [~ this])
      [%profile %widget @ ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  p.sign  [~ this]
    %.  [~ this]
    (slog (cat 3 'pals: failed to update widget %' i.t.t.wire) u.p.sign)
  ::
      [%hark ~]
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  p.sign  [~ this]
    ((slog 'pals: failed to notify' u.p.sign) [~ this])
  ::
      [%bye ~]  [~ this]  ::TODO  also retry if nack?
      [%hey ~]
    ::  for %pals-gesture pokes, record the result
    ::TODO  should we slowly retry for nacks?
    ::
    =-  [~ this(receipts -)]
    ?+  -.sign  ~|([%unexpected-agent-sign wire -.sign] !!)
      %poke-ack  (~(put by receipts) src.bowl ?=(~ p.sign))
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+  wire  ~|([dap.bowl %strange-wire wire] !!)
      [%eyre %connect ~]
    ?.  ?=([%eyre %bound *] sign-arvo)
      (on-arvo:def wire sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl 'eyre bind rejected!' binding.sign-arvo]
    [~ this]
  ::
      [%jael %pubs ~]
    ?.  ?=([%jael %public-keys *] sign-arvo)
      (on-arvo:def wire sign-arvo)
    =/  who=(unit ship)
      =*  pkr  public-keys-result.sign-arvo
      ?+  -.public-keys-result.sign-arvo  ~
        %breach  `who.pkr
      ==
    ?~  who  [~ this]
    :_  %_  this
          incoming  (~(del in incoming) u.who)
          receipts  (~(del by receipts) u.who)
        ==
    =;  caz=(list (unit card))
      (murn caz same)
    :~  ::  if they liked us, for now that's no longer true
        ::
        ?.  (~(has in incoming) u.who)  ~
        =/  =cage  [%pals-effect !>(`effect`[%away u.who])]
        `[%give %fact [/leeches]~ cage]
      ::
        ::  if we liked them, assume they come back and remind them
        ::
        ?.  (~(has by outgoing) u.who)  ~
        =/  =cage  [%pals-gesture !>(`gesture`[%hey ~])]
        `[%pass /hey %agent [u.who dap.bowl] %poke cage]
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?>  =(our src):bowl
  |^  ?+  path  [~ ~]
        [%x ~]                 ``noun+!>(`records`+.state)
        [%y ~]                 (arc %leeches %targets %mutuals ~)
        [%y %leeches ~]        (arc ~)
        [%y %targets ~]        (arc (las targets))
        [%y %mutuals ~]        (arc (las mutuals))
        [%x %leeches ~]        (alp leeches)
        [%x %leeches @ ~]      (ask (bind (slaw %p i.t.t.path) (sin leeches)))
        [%x %targets ~]        (alp targets)
        [%x %targets ~ ~]      [~ ~]
        [%x %targets @ta ~]    (alp (lap targets i.t.t.path))
        [%x %targets @ta @ ~]  (ask (bind (wat t.t.path) (hal targets)))
        [%x %mutuals ~]        (alp mutuals)
        [%x %mutuals ~ ~]      [~ ~]
        [%x %mutuals @ta ~]    (alp (lap mutuals i.t.t.path))
        [%x %mutuals @ta @ ~]  (ask (bind (wat t.t.path) (hal mutuals)))
      ::
          [%x %json ~]  ::NOTE  dumb hack, subject to change
        =;  =json  ``json+!>(json)
        =,  enjs:format
        %-  pairs
        :~  :-  'outgoing'
            %-  pairs
            %+  turn  ~(tap by outgoing)
            |=  [=^ship lists=(set @ta)]
            :-  (rsh 3 (scot %p ship))
            %-  pairs
            :~  'lists'^a+(turn ~(tap in lists) (lead %s))
                'ack'^(fall (bind (~(get by receipts) ship) (lead %b)) ~)
            ==
          ::
            :-  'incoming'
            %-  pairs
            %+  turn  ~(tap in incoming)
            |=(=^^ship [(rsh 3 (scot %p ship)) b+&])
        ==
      ==
  ::  scry results
  ++  arc  |=  l=(list @ta)  ``noun+!>(`arch`~^(malt (turn l (late ~))))
  ++  alp  |=  s=(set @p)    ``noun+!>(s)
  ++  alf  |=  f=?           ``noun+!>(f)
  ++  ask  |=  u=(unit ?)  ?^(u (alf u.u) [~ ~])
  ::  data wrestling
  ++  wat  |=([l=@ta p=@ta ~] ?~(p=(slaw %p p) ~ (some [l u.p])))
  ++  nab  ~(got by outgoing)
  ++  las  |=(s=(set @p) (zing (turn (sit s) |=(=@p (sit (nab p))))))
  ++  lap  |=([s=(set @p) l=@ta] (ski s |=(=@p ((sin (nab p)) l))))
  ++  hal  |=(s=(set @p) |=([l=@ta =@p] ((sin ?~(l s (lap s l))) p)))
  ::  set shorthands
  ++  sin  |*(s=(set) ~(has in s))
  ++  sit  |*(s=(set) ~(tap in s))
  ++  ski  |*([s=(set) f=$-(* ?)] (sy (skim (sit s) f)))
  ::  pals
  ++  leeches  incoming
  ++  targets  ~(key by outgoing)
  ++  mutuals  (~(int in targets) leeches)
  --
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::
|%
++  update-widget
  |=  [=bowl:gall records]
  ^-  (list card)
  ?.  .^(? %gu /(scot %p our.bowl)/profile/(scot %da now.bowl)/$)
    ~
  =;  widget=[%0 desc=@t %marl marl]
    =/  =cage  noun+!>([%command %update-widget %pals %mutuals widget])
    [%pass /profile/widget/mutuals %agent [our.bowl %profile] %poke cage]~
  :^  %0  'Amount of mutual pals'  %marl
  =/  count=@ud  ~(wyt in (~(int in ~(key by outgoing)) incoming))
  =;  number=tape
    =/  s=tape  ?:(=(1 count) "" "s")
    :_  ~
    ;div
      =style  """
              padding: 10px;
              padding-right: 20px;
              border-radius: 40px;
              background-color: rgb(234, 246, 236);
              color: rgb(26, 24, 24);
              """
      ;div
        =style  """
                background-color: rgb(155, 217, 166);
                border-radius: 50%;
                padding: 2;
                margin-right: 1em;
                display: inline-block;
                vertical-align: middle;
                """
        ;svg
          =width  "32"
          =height  "32"
          =viewBox  "0 0 16 16"
          =fill  "none"
          =xmlns  "http://www.w3.org/2000/svg"
          ;g
            ;path
              =fill-rule  "evenodd"
              =clip-rule  "evenodd"
              =d  "M6.5 5.5C6.5 5.08579 6.16421 4.75 5.75 4.75C5.33579 4.75 5 5.08579 5 5.5V6.87923C5 7.29345 5.33579 7.62923 5.75 7.62923C6.16421 7.62923 6.5 7.29345 6.5 6.87923V5.5ZM10.2484 4.75C10.6626 4.75 10.9984 5.08579 10.9984 5.5V6.87923C10.9984 7.29345 10.6626 7.62923 10.2484 7.62923C9.83419 7.62923 9.4984 7.29345 9.4984 6.87923V5.5C9.4984 5.08579 9.83419 4.75 10.2484 4.75ZM10.6718 9.70353C10.9766 9.98395 10.9766 10.4386 10.6718 10.719C9.19575 12.0767 6.80265 12.0767 5.32664 10.719C5.02177 10.4386 5.02177 9.98395 5.32664 9.70353C5.6315 9.42312 6.12577 9.42312 6.43063 9.70353C7.29693 10.5004 8.70147 10.5004 9.56777 9.70353C9.87263 9.42312 10.3669 9.42312 10.6718 9.70353Z"
              =fill  "currentColor";
          ==
        ==
      ==
      ;span:"{number} friend{s} on Urbit"
    ==
  ?:  (gte count 100)  (a-co:co count)
  |-  ^-  tape
  ?:  (gte count 20)
    =;  head=tape
      =/  rest=@ud  (mod count 10)
      ?:  =(0 rest)  head
      (weld head '-' $(count rest))
    =/  tens=@ud  (div count 10)
    ?+  tens  !!
      %2  "twenty"  %3  "thirty"   %4  "forty"   %5  "fifty"
      %6  "sixty"   %7  "seventy"  %8  "eighty"  %9  "ninety"
    ==
  ?+  count  !!
    %0  "zero"   %5  "five"   %10  "ten"       %15  "fifteen"
    %1  "one"    %6  "six"    %11  "eleven"    %16  "sixteen"
    %2  "two"    %7  "seven"  %12  "twelve"    %17  "seventeen"
    %3  "three"  %8  "eight"  %13  "thirteen"  %18  "eighteen"
    %4  "four"   %9  "nine"   %14  "fourteen"  %19  "nineteen"
  ==
--
