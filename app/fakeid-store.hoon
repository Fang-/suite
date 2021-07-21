::  fakeid-store: temporary local identities
::
::    for storing fake comet identities and their access keys.
::    these sessions automatically expire after the configured time.
::
::    usage: /lib/fakeid should provide all you need. if it doesn't, complain!
::
/-  *fakeid
/+  default-agent, verb, dbug
::
|%
+$  state-0
  $:  %0
      sessions=(map session-key session)
      names=(map ship session-key)  ::TODO  also address:eyre
      ::TODO  banned=(set address:eyre)
  ==
::
+$  card  card:agent:gall
--
::
=|  state-0
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
    [~ this]
  ++  on-save  !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    [~ this(state !<(state-0 old))]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title [our src]:bowl)
    ?.  ?=(%fakeid-action mark)  [~ this]
    =/  =action  !<(action vase)
    =^  cards  state
      ?-  -.action
        %new     (new-session:do +.action)
        %expire  (expire-session:do +.action)
      ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?>  (team:title [our src]:bowl)
    ?+  path  (on-peek:def path)
      [%x %session @ ~]  ``noun+!>((get-session:do (slav %uv i.t.t.path)))
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%behn %wake *]
      =^  cards  state
        (expire-session:do |+(slav %uv (snag 0 wire)))
      [cards this]
    ==
  ::
  ++  on-watch   on-watch:def
  ++  on-leave   on-leave:def
  ++  on-agent   on-agent:def
  ++  on-fail    on-fail:def
  --
::
|_  =bowl:gall
++  new-session
  |=  [=session-key =session]
  ^-  (quip card _state)
  :-  [%pass /(scot %uv session-key) %arvo %b %wait until.session]~
  %_  state
    sessions  (~(put by sessions) session-key session)
    names     (~(put by names) name.session session-key)
  ==
::
++  expire-session
  |=  who=(each ship session-key)
  ^-  (quip card _state)
  :-  ~
  =/  =session-key
    ?:  ?=(%| -.who)  p.who
    (~(gut by names) p.who *session-key)
  =/  name=ship
    name:(~(gut by sessions) session-key *session)
  %_  state
    sessions  (~(del by sessions) session-key)
    names     (~(del by names) name)
  ==
::
++  get-session
  |=  =session-key
  ^-  (unit session)
  =/  session  (~(get by sessions) session-key)
  ?~  session  ~
  ?:  (gth now.bowl until.u.session)  ~
  session
--
