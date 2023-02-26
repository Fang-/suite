::  /pkg/pals/app/then/yard.hoon: %then prefab components for pals
::
/-  *pals, then
/+  *pals
::
^-  yard:then
:-  %0
%-  ~(gas by *(map @ta part:then))
:~
::
::  triggers
::
  :-  'targets-changes'
  ^-  part:then
  :+  'Watch for outgoing pals.'
    'Triggers whenever you add or remove a pal.'
  :+  %when
    %easy
  ^-  when:then
  [%peer %pals /targets]
::
  :-  'leeches-change'
  ^-  part:then
  :+  'Watch for incoming pals.'
    'Triggers whenever you get added or removed by someone.'
  :+  %when
    %easy
  ^-  when:then
  [%peer %pals /leeches]
::
  :-  'timer'
  ^-  part:then
  :+  'Periodically'
    'Run this flow every so often, on a timer'
  :+  %when
    %vary
  :+  ~
    :~  [%dr %delay 'At what interval should we run?']
        [%f %now 'Do the first run immediately?']
    ==
  |=  [self:then =args:then]
  %-  some
  ^-  when:then
  =/  delay=@dr  (snag 0 args)
  =/  donow=?    ;;(? (snag 1 args))
  [%time ?:(donow now (add now delay)) `delay]
::
::  transformers
::
  :-  'ship-from-pals-change'
  ^-  part:then
  :+  'Extract ship from pals change.'
    'Inspects a pals change, producing the ship if it\'s relevant.'
  :+  %fold
    %vary
  :+  [%peer]~
    [%tas %kind '"added" or "removed" or "all" (default)']~
  |=  [* =args:then]
  ^-  (unit fold:then)
  =/  kind=term  (snag 0 args)
  ?.  ?=(?(%added %removed %all %$) kind)  ~
  =-  `[~ `bill:then`[%peer]~ - `bill:then`[%cash [%p]~]~]
  ^-  (gait:then fact:then fact:then)
  |=  [self:then =fact:then]
  ^-  (unit fact:then)
  ?>  ?=(%peer -.fact)
  ?.  ?=(%pals-effect -.cage.fact)  ~
  =+  !<(fec=effect +.cage.fact)
  =*  out  `[%p ship.fec]~
  ?+  kind    out
    %added    ?:(?=(?(%meet %near) -.fec) out ~)
    %removed  ?:(?=(?(%part %away) -.fec) out ~)
  ==
::
  :-  'mutuals-only'
  ^-  part:then
  :+  'Proceed only if the ship is a mutual.'
    'Inspects a ship fact, produces the same ship if it\'s a mutual.'
  :+  %fold
    %easy
  ^-  fold:then
  =-  [~ [%cash [%p]~]~ - [%cash [%p]~]~]
  |=  [self:then =fact:then]
  ^-  (unit fact:then)
  ?>  ?=([%cash [%p who=@] ~] fact)
  ?:((mutual %$ who.fact) `fact ~)
::
::  actions
::
  :-  'add-pal'
  ^-  part:then
  :+  'Add pal'
    'Adds the given ship as a pal.'
  :+  %then
    %easy
  ^-  then:then
  :+  %take
    :~  [%cash %p ~]
        [%cash %p %ta ~]
    ==
  |=  [self:then =fact:then]
  ^-  (unit thin:then)
  ?>  ?=([%cash [%p who=@] t=*] fact)
  =*  who  who.fact
  ~!  fact
  =/  tag=(unit @ta)
    ?.  ?=([[%ta tag=@] *] t.fact)  ~
    `tag.t.fact
  %-  some
  :+  %poke  %pals
  [%pals-command !>(`command`[%meet who (sy (drop tag))])]
::
  :-  'remove-pal'
  ^-  part:then
  :+  'Remove pal'
    'Remove a given ship as a pal.'
  :+  %then
    %easy
  ^-  then:then
  :+  %take
    :~  [%cash %p ~]
        [%cash %p %ta ~]
    ==
  |=  [self:then =fact:then]
  ^-  (unit thin:then)
  ?>  ?=([%cash [%p who=@] t=*] fact)
  =*  who  who.fact
  =/  tag=(unit @ta)
    ?.  ?=([[%ta tag=@] *] t.fact)  ~
    `tag.t.fact
  %-  some
  :+  %poke  %pals
  [%pals-command !>(`command`[%part who (sy (drop tag))])]
::
  :-  'print'
  ^-  part:then
  :+  'Print output to terminal'
    'Print the output from the trigger into the terminal as system output.'
  :+  %then
    %vary
  :+  ~
    [%t %prefix 'prefix all output with this string']~
  |=  [* =args:then]
  ^-  (unit then:then)
  =/  pre=@t  (snag 0 args)
  %-  some
  :+  %take  ~
  ^-  (gait:then fact:then thin:then)
  |=  [* =fact:then]
  ^-  (unit thin:then)
  :+  ~  %talk
  ^-  (list tank)
  ?-  -.fact
    %kick  ?:  =('' pre)  [(sell vase.fact)]~
           ~[pre (sell vase.fact)]
    %time  [(cat 3 pre 'timer fired')]~
    %peer  ~[(cat 3 pre p.cage.fact) (sell q.cage.fact)]
    %quit  [pre (flop tang.fact)]
    %cash  :_  ~
           %^  cat  3  pre
           %+  roll  +.fact
           |=  [[=aura =atom] =cord]
           =?  cord  !=('' cord)  (cat 3 cord ', ')
           (cat 3 cord (scot aura atom))
  ==
==
