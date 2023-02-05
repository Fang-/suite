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
  :-  'targets-change'
  ^-  part:then
  :^  'Watch for outgoing pals.'
      'Triggers whenever you add or remove a pal.'
    ~
  :-  %when
  |=  [* *]
  ^-  (unit when:then)
  `[%peer %pals /targets]
::
  :-  'leeches-change'
  ^-  part:then
  :^  'Watch for incoming pals.'
      'Triggers whenever you get added or removed by someone.'
    ~
  :-  %when
  |=  [* *]
  ^-  (unit when:then)
  `[%peer %pals /leeches]
::
::  transformers
::
  :-  'ship-from-pals-change'
  ^-  part:then
  :^  'Extract ship from pals change.'
      'Inspects a pals change, producing the ship if it\'s relevant.'
    [%tas %kind '"added" or "removed" or "all" (default)']~
  :-  %fold
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
  :^  'Proceed only if the ship is a mutual.'
      'Inspects a ship fact, produces the same ship if it\'s a mutual.'
    ~
  :-  %fold
  |=  [* *]
  ^-  (unit fold:then)
  =-  `[~ [%cash [%p]~]~ - [%cash [%p]~]~]
  |=  [self:then =fact:then]
  ^-  (unit fact:then)
  ?>  ?=([%cash [%p who=@] ~] fact)
  ?:((mutual %$ who.fact) `fact ~)
::
::  actions
::
  :-  'add-pal'
  ^-  part:then
  :^  'Add pal'
      'Adds the given ship as a pal.'
    ~
  :-  %then
  |=  [* *]
  ^-  (unit then:then)
  %-  some
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
  :^  'Remove pal'
      'Remove a given ship as a pal.'
    ~
  :-  %then
  |=  [* *]
  ^-  (unit then:then)
  %-  some
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
==
