::  corsac-store: cors access control settings
::
::    for storing per-origin cors requests & approvals.
::    if a timeout is specified, automatically deletes the approval then.
::
::  usage: /lib/cors should provide all you need. if it doesn't, complain!
::
::TODO  subscription endpoints? would let us make a ui/notification thing
::
/-  *corsac
/+  default-agent, verb, dbug
::
|%
+$  state-0
  $:  %0
      requests=(set origin)
      approved=(map origin (unit @da))
      rejected=(map origin (unit @da))
  ==
::
+$  card  card:agent:gall
--
::
=|  state-0
=*  state  -
::
%+  verb  |
%-  agent:dbug
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init   on-init:def
  ++  on-save   !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    [~ this(state !<(state-0 old))]
  ::
  ++  on-poke
    |=  [=mark =vase]
    ?>  (team:title [our src]:bowl)
    =?  mark  ?=(%noun mark)  %corsac-action
    ?.  ?=(%corsac-action mark)  [~ this]
    =/  =action  !<(action vase)
    =^  cards  state
      ?-  -.action
        %request  (request:do +.action)
        %approve  (approve:do +.action)
        %disavow  (disavow:do +.action)
      ==
    [cards this]
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?>  (team:title [our src]:bowl)
    ?+  path  (on-peek:def path)
      [%x %approved @ ~]   ``noun+!>((~(has by approved) (slav %t i.t.t.path)))
      [%x %approvals ~]    ``noun+!>(approved)
      [%x %rejections ~]   ``noun+!>(rejected)
      [%x %requests ~]     ``noun+!>(requests)
    ::
        [%x %known @ ~]
      =/  =origin  (slav %t i.t.t.path)
      :^  ~  ~  %noun
      !>  ^-  ?
      ?|  (~(has in requests) origin)
          (~(has by rejected) origin)
          (~(has by approved) origin)
      ==
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%b %wake *]
      ?>  ?=([%expire ?(%approved %rejected) @ ~] wire)
      =/  =origin  (slav %t i.t.t.wire)
      =^  cards  state
        ?-  i.t.wire
          %approved  (expire-approved:do origin)
          %rejected  (expire-rejected:do origin)
        ==
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
++  request
  |=  =origin
  ^-  (quip card _state)
  :-  ~
  ~&  [dap.bowl %request origin]
  state(requests (~(put in requests) origin))
::
++  approve
  |=  [=origin until=(unit @da)]
  ^-  (quip card _state)
  :_  %_  state
        approved  (~(put by approved) origin until)
        requests  (~(del in requests) origin)
        rejected  (~(del by rejected) origin)
      ==
  %+  weld
    ^-  (list card)
    =/  old=(unit @da)  (~(gut by approved) origin ~)
    ?~  old  ~
    [%pass /expire/cancel/(scot %t origin) %arvo %b %rest u.old]~
  ^-  (list card)
  ?~  until  ~
  [%pass /expire/approved/(scot %t origin) %arvo %b %wait u.until]~
::
++  disavow
  |=  [=origin until=(unit @da)]
  ^-  (quip card _state)
  :_  %_  state
        rejected  (~(put by rejected) origin until)
        requests  (~(del in requests) origin)
        approved  (~(del by approved) origin)
      ==
  %+  weld
    ^-  (list card)
    =/  old=(unit @da)  (~(gut by rejected) origin ~)
    ?~  old  ~
    [%pass /expire/cancel/(scot %t origin) %arvo %b %rest u.old]~
  ^-  (list card)
  ?~  until  ~
  [%pass /expire/rejected/(scot %t origin) %arvo %b %wait u.until]~
::
++  expire-approved
  |=  =origin
  ^-  (quip card _state)
  :-  ~
  state(approved (~(del by approved) origin))
::
++  expire-rejected
  |=  =origin
  ^-  (quip card _state)
  :-  ~
  state(rejected (~(del by rejected) origin))
--
