::  fafa: 2fa otp authenticator app
::
::NOTE  https://github.com/google/google-authenticator/wiki/Conflicting-Accounts
::
/-  *fafa
/+  *otp, rudder, verb, dbug, default-agent
::
/~  pages  (page:rudder (map label secret) action)  /app/fafa/pages
::
|%
+$  state-0
  $:  %0
      keys=(map label secret)
  ==
::
+$  card  card:agent:gall
--
::
^-  agent:gall
%+  verb  |
%-  agent:dbug
::
=|  state-0
=*  state  -
::
|_  =bowl:gall
+*  this   .
    def  ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this
  [%pass /eyre/connect %arvo %e %connect [~ /[dap.bowl]] dap.bowl]~
::
++  on-save  !>(state)
++  on-load
  |=  ole=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 ole))]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?.  =(%handle-http-request mark)
    (on-poke:def mark vase)
  ::
  =;  out=(quip card _keys)
    [-.out this(keys +.out)]
  %.  [bowl !<([@ta inbound-request:eyre] vase) keys]
  %+  (steer:rudder _keys action)  pages
  :+  (point:rudder /fafa & ~(key by pages))
    (fours:rudder keys)
  |=  act=action
  ^-  $@(@t [?(~ @t) (list card) _keys])
  ?-  -.act
      %add
    ?:  (~(has by keys) label.act)
      'cannot overwrite existing account'
    ?:  ?=(%hotp -.wat.secret.act)
      'counter-based otp not yet supported in the frontend. file an issue if you need this!'
    ``(~(put by keys) +.act)
  ::
      %del
    ``(~(del by keys) label.act)
  ::
      %mov
    ?:  =(old new):act  ``keys
    ?.  (~(has by keys) old.act)
      'unknown account'
    ?:  (~(has by keys) new.act)
      'cannot overwrite existing account'
    =.  keys  (~(put by keys) new.act (~(got by keys) old.act))
    =.  keys  (~(del by keys) old.act)
    ``keys
  ::
      %set
    ?.  (~(has by keys) label.act)
      'unknown account'
    =/  =secret  (~(got by keys) label.act)
    ?.  ?=(%hotp -.wat.secret)
      'account not counter-based'
    :+  ~  ~
    %+  ~(put by keys)  label.act
    secret(counter.wat counter.act)
  ::
      %sav
    :+  'saved to .urb/put/fafa/export.jam'
      =+  !>(`dill-blit:dill`[%sag /[dap.bowl]/export/jam keys])
      [%pass /save %agent [our.bowl %hood] %poke %dill-blit -]~
    keys
  ::
      %get
    =/  lap=(set label)
      ~(key by (~(int by keys) bak.act))
    ?:  =(~ lap)  ::NOTE  tmi
      ['restored succesfully' ~ (~(uni by keys) bak.act)]
    %+  rap  3
    :+  'the following accounts already exist. '
      'rename or delete them before importing. '
    %+  turn  ~(tap in lap)
    |=  label
    (rap 3 issuer ':' id ' ' ~)
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  =/  p=(pole @ta)  path
  =,  p
  ?+  p  [~ ~]
      [%x %dbug %state ~]
    ``noun+!>((~(run by keys) |=(secret +<(key 0))))
  ::
      [%x %codes %totp issuer=@ id=@ ~]
    =/  =label
      [(slav %t issuer) (slav %t id)]
    =/  =secret  (~(got by keys) label)
    ?>  ?=(%totp -.wat.secret)
    ``atom+!>((xotp secret now.bowl))
  ::
      [%x %codes %hotp issuer=@ id=@ counter=@ ~]
    ::TODO  or without counter in path for current one?
    =/  =label
      [(slav %t issuer) (slav %t id)]
    =/  =secret  (~(got by keys) label)
    ?>  ?=(%hotp -.wat.secret)
    =.  counter.wat.secret  (slav %ud counter)
    ``atom+!>((xotp secret now.bowl))
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    [~ this]
  (on-watch:def path)
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  =(/eyre/connect wire)
    (on-arvo:def wire sign-arvo)
  ?>  ?=([%eyre %bound *] sign-arvo)
  ~?  !accepted.sign-arvo
    [dap.bowl %strange-illegal-bind]
  [~ this]
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
