::  markov: single-level word-block markov chains
::
::    for usage, first (roll your-texts tokenize), and optionally
::    cache the output. be careful, this might be a big noun.
::    then, call +generate with some entropy and the output from +tokenize
::    to generate some inane cord.
::
::    in the frequency mapping generated in +tokenize, the empty cord
::    represents both the start and end of texts.
::
::    this was made quick-and-dirty for purposes of rumors shitposting,
::    it's probably sub-optimal in a good number of ways.
::
::    (each) is used to attempt to deal with spacing around tokens, but it
::    feels not great, and sometimes gives undesired results.
::
/+  pal
::
|%
+$  node  $@(@t (each @t @t))
+$  nums  (map node (map node @ud))
::
++  generate
  =|  p=node
  |=  [eny=@ mac=nums]
  ^-  @t
  =|  o=@t
  =?  o  ?=(@ p)  p
  |-
  =/  m=(map node @ud)  (~(gut by mac) p ~)
  =/  n=node
    =/  c  ~(tap by m)
    ?:  =(~ c)  ''
    -:(snag (wild:pal eny (turn c tail)) c)
  ?:  =('' n)
    ?:  (gth (met 3 o) 20)  o
    ?:  ?=([[%$ @] ~ ~] m)  o  ::  eol only known option
    $(eny +(eny))
  =.  m
    ::  guarantee eventual termination by making eol increasingly likely
    ::
    %+  ~(put by m)  ''
    +((~(gut by m) '' 0))
  :: =?  o  &(!=('' o) ?=(@ n))  (cat 3 o ' ')
  =/  t=@t
    ?-  n
      @       ?:  ?=([%& *] p)  n
              ?:(=('' o) n (cat 3 ' ' n))
      [%& @]  ?:(=('' o) +.n (cat 3 ' ' +.n))
      [%| @]  +.n
    ==
  $(p n, o (cat 3 o t), mac (~(put by mac) p m), eny +(eny))
::
++  tokenize
  |=  [rum=@t hav=nums]
  ^+  hav
  =;  [p=node o=_hav]
    =+  i=(~(gut by o) p *(map node @ud))
    =+  n=(~(gut by i) '' 0)
    (~(put by o) p (~(put by i) '' +(n)))
  %+  roll
    ^-  (list node)
    %+  rash  rum
    %-  star
    ;~  pose
      (cook crip (plus alp))
      (stag %& (cook crip ;~(pfix ace (plus ;~(less alp ace next)))))
      (stag %| (cook crip ;~(sfix (plus ;~(less alp ace next)) ace)))
      ::TODO  doesn't support the common ' case
      (stag %| (full next))
      (stag %& next)
    ==
  |=  [t=node p=node o=_hav]
  ?:  |(?=(%' ' t) ?=([* %' '] t))  [p o]
  :-  t
  =+  i=(~(gut by o) p *(map node @ud))
  =+  n=(~(gut by i) t 0)
  (~(put by o) p (~(put by i) t +(n)))
--
