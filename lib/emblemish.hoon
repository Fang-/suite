::  emblemish (BETA): sigils but emoji, @p but real words
::
::    rendering logic adapted from /lib/sigil.
::    we add additional logic for defining components in a <defs> block, to
::    reduce output size, especially when rendering components with borders.
::    another difference is that components here are 36x36, so scaling and
::    translation needs to behave accordingly.
::
/+  twemoji
::
|%
++  render
  =/  bg=cord  'white'
  =/  size=@ud  128
  =/  margin=?  &
  =/  stroke=(unit cord)  `'black'
  ::
  ~%  %emblemish  ..part  ~
  =/  who=ship  ~zod
  =/  syc=@ud  1
  |^  |=  =ship
      ^-  @t
      ::
      =.  who  ship
      =/  nis  (nibs who)
      =.  syc  (lent nis)
      ::  shift the sigil to account for the margin
      ::  scale the sigil to account for the amount of symbols
      ::
      =/  sire=@rd  (sun:rd size)
      =/  tr=cord
        ::TODO  render transform inside +sigil:svg?
        %+  transform:svg
          ?.  margin  ~
          =+  grid:pos
          `[(gird:pos x) (gird:pos y)]
        `span:pos
      ::
      =/  sw=@rd  ::TODO
        (add:rd .~0.33 (div:rd sire .~128))
      ::
      %-  outer:svg
      %+  sigil:svg
        [tr sw]
      (symbols:svg nis)
  ::
  ++  pos
    |%
    ++  span  ::  symbol scale (relative to full canvas)
      ^-  @rd
      ::TODO  accounting for margin here feels a bit ugly?
      ?+  (max grid)  !!
        %1  ?:(margin .~1.2 .~3)
        %2  ?:(margin .~1.2 .~1.5)
        %4  ?:(margin .~0.6 .~0.75)
      ==
    ::
    ++  grid  ::  size in symbols
      ^-  [x=@ud y=@ud]
      ?+  syc  !!
        %16  [4 4]
        %8   [4 4]
        %4   [2 2]
        %2   [2 1]
        %1   [1 1]
      ==
    ::
    ++  gird  ::  calculate margin
      |=  n=@ud
      ^-  @rd
      =-  (div:rd - .~2)     ::  / both sides
      %+  sub:rd  .~128      ::  canvas size -
      %+  mul:rd  (sun:rd n) ::  symbols *
      %+  mul:rd  span:pos   ::  symbol scale *
      .~36                   ::  symbol size
    ::
    ++  plan  ::  as position on symbol grid
      |=  i=@ud
      ^-  [x=@ud y=@ud]
      ?+  [syc i]  !!
        [%16 *]  [(mod i 4) (div i 4)]
      ::
        [%8 %0]  [0 0]
        [%8 %1]  [3 0]
        [%8 %2]  [0 3]
        [%8 %3]  [3 3]
        [%8 %4]  [1 1]
        [%8 %5]  [2 1]
        [%8 %6]  [1 2]
        [%8 %7]  [2 2]
      ::
        [%4 *]   [(mod i 2) (div i 2)]
        [%2 *]   [i 0]
        [%1 *]   [0 0]
      ==
    --
  ::
  ++  rd  ~(. ^rd %n)
  ++  say-rd
    |=  n=@rd
    ^-  tape
    =/  =dn          (drg:rd n)
    ?>  ?=(%d -.dn)
    =/  [s=? m=@ud]  (old:si e.dn)
    =/  x=@ud        (pow 10 m)
    %+  weld
      %-  (d-co:co 1)
      ?:(s (mul a.dn x) (div a.dn x))
    ?:  s  ~
    ['.' ((d-co:co m) (mod a.dn x))]
  ::
  ++  svg
    |%
    ++  outer
      |=  inner=@t
      ^-  @t
      =/  s=@t  (crip ((d-co:co 1) size))
      %+  rap  3
      :~  '<svg style="display: block; width: '  s  'px; height: '  s
          'px;" viewBox="0 0 128 128" version="1.1" '
          'xmlns="http://www.w3.org/2000/svg">'
          defs
          '<rect fill="'  bg  '" width="128" height="128" />'
          inner
          '</svg>'
      ==
    ::
    ++  defs
      =-  (rap 3 '<defs>' - '</defs>' ~)
      %+  rap  3
      %+  turn  ~(tap in (sy (turn (nibs who) chew)))
      |=  moj=@t
      %+  rap  3
      ::  we downscale them slightly to ensure margin between components
      ::
      :~  '<g id="'  moj
          '" transform-origin="18 18" transform="scale(0.95)">'
          (~(got by twemoji) moj)
          '</g>'
      ==
    ::
    ++  sigil
      |=  [[tr=cord sw=@rd] symbols=(list @t)]
      ^-  @t
      %+  rap  3
      :*  '<g transform="'  tr  '">'
          (snoc symbols '</g>')
      ==
    ::
    ++  symbols
      |=  nis=(list [pre=? nib=@])
      ^-  (list @t)
      =|  i=@ud
      =/  l=@ud  (lent nis)
      |-
      ?~  nis  ~
      :_  $(nis t.nis, i +(i))
      ::TODO  exclude transform if both 0
      =+  (plan:pos i)
      %+  rap  3
      :~  '<g transform="'
          (transform `[(sun:rd (mul x 36)) (sun:rd (mul y 36))] ~)
          '">'
        ::
          ?~  stroke  ''
          %+  rap  3
          :~  '<use href="#'  (chew i.nis)
              '" stroke="'  u.stroke
              '" stroke-width="1" />'
          ==
        ::
          '<use href="#'  (chew i.nis)  '" />'
          '</g>'
      ==
    ::
    ++  transform  ::TODO  take manx instead so we can omit attr entirely?
      |=  [translate=(unit [x=@rd y=@rd]) scale=(unit @rd)]
      ^-  cord
      %+  rap  3
      ^-  (list cord)
      ::TODO  make cleaner
      =-  ?:  ?=(?(~ [* ~]) -)  -
          (join ' ' `(list cord)`-)
      ^-  (list cord)
      :~  ?~  translate  ''
          ?:  =([0 0] u.translate)  ''
          %-  crip
          "translate({(say-rd x.u.translate)} {(say-rd y.u.translate)})"
        ::
          ?~  scale  ''
          %-  crip
          "scale({(say-rd u.scale)})"
      ==
    --
  --
::
++  nibs
  |=  who=@p
  ^-  (list [pre=? nib=@])
  %-  flop
  =+  nom=(fein:ob who)
  =/  wor=@ud
    ?-  (clan:title who)
      %czar  1
      %king  2
      %duke  4
      %earl  8
      %pawn  16
    ==
  =+  pre=|
  |-
  ?:  =(0 wor)  ~
  :-  pre^(end 3 nom)
  $(nom (rsh 3 nom), wor (dec wor), pre !pre)
::
++  bite
  |=  [pre=? nib=@]
  (snag nib ?:(pre pre:dat suf:dat))
::
++  chew
  (cork bite head)
::
++  spit
  |=  [pre=? nib=@]
  ^-  @t
  (?:(pre tos:po tod:po) nib)
::
++  name
  |=  [sym=? who=@p]
  ^-  @t
  %+  roll  (nibs who)
  |=  [[pre=? nib=@] out=@t]
  =+  (bite pre nib)
  %^  rap  3  out
  :~  ?~(out '' ?:(pre ', ' ' '))
      n
      ?.(sym '' s)
  ==
::
++  dat
  |%
  ++  pre  ::  prefixes
    ^-  (list [s=@t n=@t])
    :~
      :-  '⚫'  'the'                                    ::  doz
      :-  '1️⃣'  'prime'                                  ::  mar
      :-  '🗑'  'discarded'                              ::  bin
      :-  '💕'  'coveted'                                ::  wan
      :-  '👥'  'identical'                              ::  sam
      :-  '🔥'  'impassioned'                            ::  lit
      :-  '🖋'  'contracted'                             ::  sig
      :-  '😶‍🌫️'  'obscure'                             ::  hid
      :-  '🔺'  'greater'                                ::  fid
      :-  '🔻'  'lesser'                                 ::  lis
      :-  '💦'  'drenched'                               ::  sog
      :-  '📁'  'collector of'                           ::  dir
      :-  '🤪'  'broken'                                 ::  wac
      :-  '✅'  'honest'                                 ::  sab
      :-  '🧙'  'sage of'                                ::  wis
      :-  '🥷'  'covert'                                 ::  sib
      :-  '⛵'  'hoisted'                                ::  rig
      :-  '☀'  'shining'                                ::  sol
      :-  '☕'  'reduced'                                ::  dop
      :-  '💂'  'guardian of'                            ::  mod
      :-  '🌫'  'mysterious'                             ::  fog
      :-  '🧢'  'limited'                                ::  lid
      :-  '🦘'  'kinetic'                                ::  hop
      :-  '🐳'  'distant'                                ::  dar
      :-  '🚪'  'portal to'                              ::  dor
      :-  '📜'  'historied'                              ::  lor
      :-  '🏘'  'collective'                             ::  hod
      :-  '📂'  'amasser of'                             ::  fol
      :-  '💍'  'vowed'                                  ::  rin
      :-  '🔮'  'foreseen'                               ::  tog
      :-  '🙃'  'fool\'s'                                ::  sil
      :-  '🪞'  'parallel'                               ::  mir
      :-  '⛳'  'final'                                  ::  hol
      :-  '🛂'  'identifying'                            ::  pas
      :-  '🥛'  'neutral'                                ::  lac
      :-  '🦅'  'roving'                                 ::  rov
      :-  '🫒'  'nourishing'                             ::  liv
      :-  '🪙'  'golden'                                 ::  dal
      :-  '🛰'  'visionary'                              ::  sat
      :-  '📚'  'documented'                             ::  lib
      :-  '🔖'  'significant'                            ::  tab
      :-  '✋'  'dexterous'                              ::  han
      :-  '🎟'  'admitted'                               ::  tic
      :-  '🦑'  'leviathan'                              ::  pid
      :-  '🧅'  'layered'                                ::  tor
      :-  '🥣'  'vessel for'                             ::  bol
      :-  '🤼'  'antagonist'                             ::  fos
      :-  '🔘'  'instance of'                            ::  dot
      :-  '⚰'  'loss of'                                ::  los
      :-  '🌿'  'savory'                                 ::  dil
      :-  '🐸'  'fugitive'                               ::  for
      :-  '💊'  'supposed'                               ::  pil
      :-  '🐏'  'combative'                              ::  ram
      :-  '🐅'  'hidden'                                 ::  tir
      :-  '🏆'  'triumphant'                             ::  win
      :-  '🤏'  'miniscule'                              ::  tad
      :-  '🏍'  'roaming'                                ::  bic
      :-  '🆚'  'battling'                               ::  dif
      :-  '🪨'  'rugged'                                 ::  roc
      :-  '🌠'  'wishful'                                ::  wid
      :-  '🦬'  'cultivated'                             ::  bis
      :-  '🌀'  'turbulent'                              ::  das
      :-  '💧'  'laminar'                                ::  mid
      :-  '🦞'  'behavioral'                             ::  lop
      :-  '🌄'  'rising'                                 ::  ril
      :-  '🧿'  'blinding'                               ::  nar
      :-  '💖'  'handsome'                               ::  dap
      :-  '🌷'  'manic'                                  ::  mol
      :-  '🎅'  'jolly'                                  ::  san
      :-  '🔒'  'restricted'                             ::  loc
      :-  '🈵'  'occupied'                               ::  nov
      :-  '💩'  'residual'                               ::  sit
      :-  '🧩'  'fragmented'                             ::  nid
      :-  '💵'  'gratuitous'                             ::  tip
      :-  '🤒'  'weakened'                               ::  sic
      :-  '🪳'  'resilient'                              ::  rop
      :-  '🥀'  'expired'                                ::  wit
      :-  '🎁'  'gift of'                                ::  nat
      :-  '🐼'  'endangered'                             ::  pan
      :-  '➖'  'absence of'                             ::  min
      :-  '💥'  'destroyer of'                           ::  rit
      :-  '🐛'  'enslaved'                               ::  pod
      :-  '🦋'  'holometabolic'                          ::  mot
      :-  '™'  'mark of'                                ::  tam
      :-  '🔔'  'herald of'                              ::  tol
      :-  '💾'  'archived'                               ::  sav
      :-  '📯'  'bringer of'                             ::  pos
      :-  '💤'  'slumbering'                             ::  nap
      :-  '🙅'  'declined'                               ::  nop
      :-  '🖌'  'painted'                                ::  som
      :-  '🐬'  'transcendental'                         ::  fin
      :-  '☎'  'networked'                              ::  fon
      :-  '🚫'  'forbidden'                              ::  ban
      :-  '🔁'  'perpetual'                              ::  mor
      :-  '🌍'  'ephemeral'                              ::  wor
      :-  '🥃'  'nursed'                                 ::  sip
      :-  '🥚'  'early'                                  ::  ron
      :-  '⬆'  'ascendant'                              ::  nor
      :-  '🤖'  'mechanical'                             ::  bot
      :-  '🕯'  'illuminating'                           ::  wic
      :-  '🧦'  'theoretical'                            ::  soc
      :-  '❓'  'perplexed'                              ::  wat
      :-  '🎎'  'imitation'                              ::  dol
      :-  '🚅'  'expedient'                              ::  mag
      :-  '🖼'  'framed'                                 ::  pic
      :-  '🤴'  'king\'s'                                ::  dav
      :-  '👨‍⚖️'  'offered'                                ::  bid
      :-  '🖲'  'articulated'                            ::  bal
      :-  '🔱'  'triple'                                 ::  tim
      :-  '♨'  'boiling'                                ::  tas
      :-  '😈'  'malicious'                              ::  mal
      :-  '✍'  'meticulous'                             ::  lig
      :-  '👁'  'subjective'                             ::  siv
      :-  '🏷'  'marked'                                 ::  tag
      :-  '🏠'  'settled'                                ::  pad
      :-  '🧂'  'frustrated'                             ::  sal
      :-  '➗'  'separated'                              ::  div
      :-  '👤'  'shadow of'                              ::  dac
      :-  '🍊'  'citric'                                 ::  tan
      :-  '🗣'  'voluble'                                ::  sid
      :-  '🦄'  'flamboyant'                             ::  fab
      :-  '*️⃣'  'surrogate'                              ::  tar
      :-  '🐵'  'simian'                                 ::  mon
      :-  '🏃'  'hurried'                                ::  ran
      :-  '❌'  'incongruent'                            ::  nis
      :-  '🦉'  'symbolic'                               ::  wol
      :-  '🎊'  'festive'                                ::  mis
      :-  '🙂'  'friendly'                               ::  pal
      :-  '👧'  'youthful'                               ::  las
      :-  '⛔'  'rejected'                               ::  dis
      :-  '🗺'  'guiding'                                ::  map
      :-  '🐇'  'fertile'                                ::  rab
      :-  '🪃'  'return of'                              ::  tob
      :-  '🌯'  'packaged'                               ::  rol
      :-  '🦤'  'extinct'                                ::  lat
      :-  '🌐'  'longitudinal'                           ::  lon
      :-  '😪'  'exhausted'                              ::  nod
      :-  '➡'  'directional'                            ::  nav
      :-  '🗿'  'monumental'                             ::  fig
      :-  '🍕'  'edible'                                 ::  nom
      :-  '⏫'  'improved'                               ::  nib
      :-  '📟'  'indicative'                             ::  pag
      :-  '🧼'  'cleansed'                               ::  sop
      :-  '😎'  'radical'                                ::  ral
      :-  '💶'  'owed'                                   ::  bil
      :-  '🈹'  'discounted'                             ::  had
      :-  '🧑‍⚕️'  'shamanic'                               ::  doc
      :-  '🎀'  'giver of'                               ::  rid
      :-  '🦈'  'apex'                                   ::  moc
      :-  '🌝'  'ravenous'                               ::  pac
      :-  '☢'  'decaying'                               ::  rav
      :-  '🪦'  'perished'                               ::  rip
      :-  '🍂'  'waning'                                 ::  fal
      :-  '👶'  'born'                                   ::  tod
      :-  '🚜'  'worker of'                              ::  til
      :-  '🥫'  'preserved'                              ::  tin
      :-  '🐣'  'fledgling'                              ::  hap
      :-  '🎤'  'recorded'                               ::  mic
      :-  '🐘'  'learned'                                ::  fan
      :-  '🌳'  'natural'                                ::  pat
      :-  '📌'  'fastened'                               ::  tac
      :-  '🧪'  'experimental'                           ::  lab
      :-  '💪'  'impressive'                             ::  mog
      :-  '👨‍💼'  'subject to'                             ::  sim
      :-  '👨‍👩‍👦'  'heir to'                                ::  son
      :-  '📍'  'located'                                ::  pin
      :-  '👽'  'demonic'                                ::  lom
      :-  '🦗'  'restless'                               ::  ric
      :-  '🚰'  'dispenser of'                           ::  tap
      :-  '🌲'  'appeal to'                              ::  fir
      :-  '📫'  'recipient of'                           ::  has
      :-  '✝'  'absolute'                               ::  bos
      :-  '🦇'  'echoing'                                ::  bat
      :-  '🆔'  'unique'                                 ::  poc
      :-  '🕶'  'background'                             ::  hac
      :-  '🧄'  'potent'                                 ::  tid
      :-  '✊'  'grasped'                                ::  hav
      :-  '🩸'  'vital'                                  ::  sap
      :-  '🔗'  'attached'                               ::  lin
      :-  '🥇'  'prioritized'                            ::  dib
      :-  '🐎'  'equestrian'                             ::  hos
      :-  '💯'  'maximal'                                ::  dab
      :-  '👄'  'suggestive'  ::TODO  lip biting emoji   ::  bit
      :-  '🍻'  'hospitable'                             ::  bar
      :-  '🦝'  'thieving'                               ::  rac
      :-  '🦜'  'talkative'                              ::  par
      :-  '🔊'  'deafening'                              ::  lod
      :-  '🐫'  'double'                                 ::  dos
      :-  '🐗'  'gallant'                                ::  bor
      :-  '📑'  'arranged'                               ::  toc
      :-  '⛰'  'unyielding'                             ::  hil
      :-  '🍏'  'newtonian'                              ::  mac
      :-  '🥁'  'rumbling'                               ::  tom
      :-  '🅱'  'daring'                                 ::  dig
      :-  '🐡'  'expansive'                              ::  fil
      :-  '👀'  'observed'                               ::  fas
      :-  '🏫'  'scholastic'                             ::  mit
      :-  '🗞'  'punished'                               ::  hob
      :-  '🫀'  'rhythmic'                               ::  har
      :-  '🪄'  'vanishing'                              ::  mig
      :-  '🐈‍⬛'  'unfortunate'                          ::  hin
      :-  '🤙'  'tubular'                                ::  rad
      :-  '🎭'  'masquerading'                           ::  mas
      :-  '🎯'  'particular'                             ::  hal
      :-  '🧻'  'sweeping'                               ::  rag
      :-  '⏳'  'behindhand'                             ::  lag
      :-  '🆕'  'trending'                               ::  fad
      :-  '🔝'  'ascended'                               ::  top
      :-  '🧽'  'retainer of'                            ::  mop
      :-  '🔎'  'seeker of'                              ::  hab
      :-  '0️⃣'  'nullifier of'                           ::  nil
      :-  '👃'  'intuitive'                              ::  nos
      :-  '🌾'  'processor of'                           ::  mil
      :-  '🎰'  'fortuitous'                             ::  fop
      :-  '👨‍👩‍👧‍👦'  'tribal'                                 ::  fam
      :-  '💿'  'digitized'                              ::  dat
      :-  '🎞'  'analog'                                 ::  nol
      :-  '🍲'  'satisfying'                             ::  din
      :-  '🎩'  'dignified'                              ::  hat
      :-  '🪟'  'transparent'                            ::  nac
      :-  '🧗'  'mounting'                               ::  ris
      :-  '📷'  'captured'                               ::  fot
      :-  '🍖'  'scrumptious'                            ::  rib
      :-  '🏑'  'competitive'                            ::  hoc
      :-  '🪁'  'soaring'                                ::  nim
      :-  '🦙'  'corpulent'                              ::  lar
      :-  '🏋'  'lifter of'                              ::  fit
      :-  '🧱'  'obstructive'                            ::  wal
      :-  '🤬'  'censored'                               ::  rap
      :-  '🪢'  'eclectic'                               ::  sar
      :-  '✨'  'magnificant'                            ::  nal
      :-  '🦟'  'humming'                                ::  mos
      :-  '⛓'  'connected'                              ::  lan
      :-  '👕'  'wearer of'                              ::  don
      :-  '🍡'  'sweetened'                              ::  dan
      :-  '👦'  'junior'                                 ::  lad
      :-  '🕊'  'spirit of'                              ::  dov
      :-  '🌊'  'cascading'                              ::  riv
      :-  '🧮'  'adder of'                               ::  bac
      :-  '👮'  'upholder of'                            ::  pol
      :-  '🧎'  'provided'                               ::  lap
      :-  '⛹'  'towering'                               ::  tal
      :-  '🕳'  'abyssal'                                ::  pit
      :-  '📛'  'named'                                  ::  nam
      :-  '🦴'  'skeletal'                               ::  bon
      :-  '🌹'  'passionate'                             ::  ros
      :-  '👅'  'toothsome'                              ::  ton
      :-  '🫕'  'molten'                                 ::  fod
      :-  '🐴'  'stout'                                  ::  pon
      :-  '🗡'  'wielder of'                             ::  sov
      :-  '🔢'  'executive'                              ::  noc
      :-  '🌪'  'forceful'                               ::  sor
      :-  '🚽'  'sanctuary of'                           ::  lav
      :-  '⚛'  'substantial'                            ::  mat
      :-  '🐁'  'squeaking'                              ::  mip
      :-  '🩴'  'flopping'                               ::  fip
    ==
  ::
  ++  suf  ::  suffixes
    ^-  (list [s=@t n=@t])
    :~
      :-  '⚫'  'one'                                    ::  zod
      :-  '🐍'  'whisperer'                              ::  nec
      :-  '🌱'  'potentiality'                           ::  bud
      :-  '⬅'  'escape'                                 ::  wes
      :-  '💰'  'opulence'                               ::  sev
      :-  '🌶'  'spice'                                  ::  per
      :-  '🦸'  'heroism'                                ::  sut
      :-  '🚸'  'yielding'                               ::  let
      :-  '🥛'  'satiety'                                ::  ful
      :-  '✏'  'writing'                                ::  pen
      :-  '🖥'  'presentation'                           ::  syt
      :-  '☠'  'doom'                                   ::  dur
      :-  '🦫'  'engineer'                               ::  wep
      :-  '🔀'  'chaos'                                  ::  ser
      :-  '⚙'  'enabler'                                ::  wyl
      :-  '🌞'  'exuberance'                             ::  sun
      :-  '🍌'  'maturity'                               ::  ryp
      :-  '🃏'  'wildcard'                               ::  syx
      :-  '‼'  'cognizance'                             ::  dyr
      :-  '🗨'  'shibboleth'                             ::  nup
      :-  '🩸'  'blood'                                  ::  heb
      :-  '📌'  'adhesion'                               ::  peg
      :-  '❌'  'denial'                                 ::  lup
      :-  '🐕‍🦺'  'assistant'                              ::  dep
      :-  '🎲'  'chance'                                 ::  dys
      :-  '⛳'  'completion'                             ::  put
      :-  '🧳'  'possessions'                            ::  lug
      :-  '🪀'  'bandalore'                              ::  hec
      :-  '➡'  'signifyer'                              ::  ryt
      :-  '🦠'  'disease'                                ::  tyv
      :-  '🧬'  'programming'                            ::  syd
      :-  '🔜'  'destiny'                                ::  nex
      :-  '🌝'  'satellite'                              ::  lun
      :-  '✉'  'post'                                   ::  mep
      :-  '🧰'  'utility'                                ::  lut
      :-  '↔'  'exchange'                               ::  sep
      :-  '🐟'  'pisces'                                 ::  pes
      :-  '⚗'  'purifier'                               ::  del
      :-  '💀'  'expiration'                             ::  sul
      :-  '🚶'  'wandering'                              ::  ped
      :-  '🌡'  'degree'                                 ::  tem
      :-  '🚥'  'directionality'                         ::  led
      :-  '🌷'  'aesthete'                               ::  tul
      :-  '📐'  'determination'                          ::  met
      :-  '🕓'  'time'                                   ::  wen
      :-  '♾'  'eternities'                             ::  byn
      :-  '🧙‍♀️'  'curse'                                  ::  hex
      :-  '🧀'  'fermentation'                           ::  feb
      :-  '📚'  'chronicles'                             ::  pyl
      :-  '☁'  'monotony'                               ::  dul
      :-  '🚫'  'limits'                                 ::  het
      :-  '⚖'  'balance'                                ::  mev
      :-  '🔁'  'perpetuity'                             ::  rut
      :-  '🀄'  'representation'                         ::  tyl
      :-  '🌌'  'space'                                  ::  wyd
      :-  '🤬'  'expletive'                              ::  tep
      :-  '🏹'  'hunter'                                 ::  bes
      :-  '👆'  'pointer'                                ::  dex
      :-  '🤳'  'reflection'                             ::  sef
      :-  '🧾'  'values'                                 ::  wyc
      :-  '🖨'  'replication'                            ::  bur
      :-  '🦌'  'prey'                                   ::  der
      :-  '📰'  'communique'                             ::  nep
      :-  '🐱'  'feline'                                 ::  pur
      :-  '🍚'  'staple'                                 ::  rys
      :-  '🐀'  'plague'                                 ::  reb
      :-  '🍢'  'victuals'                               ::  den
      :-  '🥜'  'legumes'                                ::  nut
      :-  '➖'  'absence'                                ::  sub
      :-  '🐶'  'companion'                              ::  pet
      :-  '🪧'  'indication'                             ::  rul
      :-  '🌈'  'covenant'                               ::  syn
      :-  '👑'  'sovereign'                              ::  reg
      :-  '🌊'  'torrent'                                ::  tyd
      :-  '🏄'  'shredder'                               ::  sup
      :-  '🎌'  'semaphore'                              ::  sem
      :-  '🍷'  'vintage'                                ::  wyn
      :-  '🔴'  'recording'                              ::  rec
      :-  '🗄'  'database'                               ::  meg
      :-  '🌏'  'worlds'  ::TODO  maybe 🌐?              ::  net
      :-  '👮'  'safekeeper'                             ::  sec
      :-  '🤔'  'contemplation'                          ::  mul
      :-  '📛'  'nomenclature'                           ::  nym
      :-  '👕'  'garnments'                              ::  tev
      :-  '🕸'  'entanglement'                           ::  web
      :-  '🗃'  'aggregate'                              ::  sum
      :-  '🐕'  'canine'                                 ::  mut
      :-  '❄'  'singleton'                              ::  nyx
      :-  '🦖'  'king'                                   ::  rex
      :-  '🏰'  'stronghold'                             ::  teb
      :-  '😠'  'confrontation'                          ::  fus
      :-  '❇'  'deliverance'                            ::  hep
      :-  '🕰'  'hour'                                   ::  ben
      :-  '🏛'  'antiquity'                              ::  mus
      :-  '🎯'  'objective'                              ::  wyx
      :-  '🦉'  'mystery'                                ::  sym
      :-  '🧂'  'condiment'                              ::  sel
      :-  '🪆'  'recursion'                              ::  ruc
      :-  '⤵'  'reduction'                              ::  dec
      :-  '🗻'  'trial'                                  ::  wex
      :-  '⚔'  'knight'                                 ::  syr
      :-  '💦'  'immersion'                              ::  wet
      :-  '✨'  'ideals'                                 ::  dyl
      :-  '🧠'  'mind'                                   ::  myn
      :-  '🔪'  'partitioning'                           ::  mes
      :-  '🌳'  'life'                                   ::  det
      :-  '💸'  'speculation'                            ::  bet
      :-  '🔔'  'herald'                                 ::  bel
      :-  '🐧'  'kernel'                                 ::  tux
      :-  '🫀'  'heart'                                  ::  tug
      :-  '🍯'  'ambrosia'                               ::  myr
      :-  '🫑'  'greens'                                 ::  pel
      :-  '🤡'  'ridicule'                               ::  syp
      :-  '🎸'  'legend'                                 ::  ter
      :-  '👤'  'generalities'                           ::  meb
      :-  '🤞'  'hope'                                   ::  set
      :-  '💢'  'pressure'                               ::  dut
      :-  '🍆'  'debauchery'                             ::  deg
      :-  '🤠'  'independence'                           ::  tex
      :-  '🏳'  'surrender'                              ::  sur
      :-  '😡'  'rage'                                   ::  fel
      :-  '♠'  'spades'                                 ::  tud
      :-  '♥'  'hearts'                                 ::  nux
      :-  '♦'  'diamonds'                               ::  rux
      :-  '♣'  'clubs'                                  ::  ren
      :-  '⚪'  'purity'                                 ::  wyt
      :-  '🔘'  'protrusion'                             ::  nub
      :-  '⚕'  'panacea'                                ::  med
      :-  '💡'  'radiance'                               ::  lyt
      :-  '💨'  'particulates'                           ::  dus
      :-  '🔰'  'beginnings'                             ::  neb
      :-  '🥃'  'spirits'                                ::  rum
      :-  '🎐'  'tranquility'                            ::  tyn
      :-  '🧩'  'segment'                                ::  seg
      :-  '🐈'  'predator'                               ::  lyx
      :-  '⛎'  'meta'                                   ::  pun
      :-  '🈯'  'reservation'                            ::  res
      :-  '🍎'  'crimson'                                ::  red
      :-  '😂'  'hysteria'                               ::  fun
      :-  '❤️‍🔥'  'revelation'                             ::  rev
      :-  '🪑'  'furniture'                              ::  ref
      :-  '🩹'  'mending'                                ::  mec
      :-  '🪂'  'thrill'                                 ::  ted
      :-  '🐚'  'husk'                                   ::  rus
      :-  '♨'  'oracle'                                 ::  bex
      :-  '🪵'  'material'                               ::  leb
      :-  '🦆'  'waterfowl'                              ::  dux
      :-  '🦏'  'panzer'                                 ::  ryn
      :-  '🦬'  'stampede'                               ::  num
      :-  '🧚'  'trickster'                              ::  pyx
      :-  '⚡'  'force'                                  ::  ryg
      :-  '🐝'  'monarchy'                               ::  ryx
      :-  '📴'  'retreat'                                ::  fep
      :-  '🚂'  'locomotion'  ::TODO  wheel emoji        ::  tyr
      :-  '🦣'  'mammoth'                                ::  tus
      :-  '⚠'  'attention'                              ::  tyc
      :-  '🦵'  'support'                                ::  leg
      :-  '🧲'  'attractor'                              ::  nem
      :-  '🌲'  'appeal'                                 ::  fer
      :-  '🧜‍♀️'  'amalgam'                               ::  mer
      :-  '🔟'  'decimal'                                ::  ten
      :-  '➕'  'additive'                               ::  lus
      :-  '💭'  'nous'                                   ::  nus
      :-  '🗝'  'solution'                               ::  syl
      :-  '💻'  'gateway'                                ::  tec
      :-  '🌮'  'standoff'                               ::  mex
      :-  '🍻'  'conviviality'                           ::  pub
      :-  '📝'  'poetry'                                 ::  rym
      :-  '🦃'  'thanksgiving'                           ::  tuc
      :-  '💕'  'lover'                                  ::  fyl
      :-  '🐆'  'panther'                                ::  lep
      :-  '🤵'  'debonair'                               ::  deb
      :-  '🐻'  'ursid'                                  ::  ber
      :-  '🧺'  'container'                              ::  mug
      :-  '🛖'  'compound'                               ::  hut
      :-  '📻'  'attunement'                             ::  tun
      :-  '🤮'  'expeller'                               ::  byl
      :-  '📼'  'excuse'                                 ::  sud
      :-  '♟'  'pawn'                                   ::  pem
      :-  '👨‍💻'  'conductor'                              ::  dev
      :-  '🎣'  'catch'                                  ::  lur
      :-  '🙉'  'ignoramus'                              ::  def
      :-  '🚌'  'carriage'                               ::  bus
      :-  '🔊'  'cacophony'                              ::  bep
      :-  '🏃'  'strider'                                ::  run
      :-  '😵'  'disarray'  ::TODO  melty-face emoji     ::  mel
      :-  '💪'  'strongman'                              ::  pex
      :-  '🌛'  'crepuscule'                             ::  dyt
      :-  '🦈'  'masticator'                             ::  byt
      :-  '⌨'  'translator'                             ::  typ
      :-  '🚅'  'conveyance'                             ::  lev
      :-  '🏎'  'speedster'                              ::  myl
      :-  '🌿'  'herb'                                   ::  wed
      :-  '💫'  'vertigo'                                ::  duc
      :-  '🐺'  'anthropomorph'                          ::  fur
      :-  '🧯'  'extinguisher'                           ::  fex
      :-  '0️⃣'  'void'                                   ::  nul
      :-  '🍀'  'fortune'                                ::  luc
      :-  '📏'  'extent'                                 ::  len
      :-  '🦥'  'sloth'                                  ::  ner
      :-  '💬'  'gab'                                    ::  lex
      :-  '🥠'  'aphorism'                               ::  rup
      :-  '🇳🇱'  'lowlands'                               ::  ned
      :-  '😈'  'sophistry'                              ::  lec
      :-  '🏇'  'roughrider'                             ::  ryd
      :-  '☀'  'light'                                  ::  lyd
      :-  '🪟'  'exposition'                             ::  fen
      :-  '🎻'  'elegance'                               ::  wel
      :-  '😤'  'accomplishment'                         ::  nyd
      :-  '🤫'  'secrecy'                                ::  hus
      :-  '🌋'  'cataclysm'                              ::  rel
      :-  '💃'  'boogaloo'                               ::  rud
      :-  '🕹'  'diversion'                              ::  nes
      :-  '🌬'  'breath'                                 ::  hes
      :-  '☣'  'contaminant'                            ::  fet
      :-  '👁'  'providence'                             ::  des
      :-  '🎱'  'outlook'                                ::  ret
      :-  '🏜'  'wasteland'                              ::  dun
      :-  '⏏'  'emission'                               ::  ler
      :-  '🥄'  'provider'                               ::  nyr
      :-  '🏠'  'abode'                                  ::  seb
      :-  '🚢'  'vessel'                                 ::  hul
      :-  '🧭'  'exploration'                            ::  ryl
      :-  '👴'  'rejector'                               ::  lud
      :-  '🛡'  'protector'                              ::  rem
      :-  '🤥'  'untruths'                               ::  lys
      :-  '💎'  'rarity'                                 ::  fyn
      :-  '🌦'  'conditions'                             ::  wer
      :-  '🗽'  'liberty'                                ::  ryc
      :-  '🍬'  'confection'                             ::  sug
      :-  '👍'  'approval'                               ::  nys
      :-  '🏕'  'conqueror'                              ::  nyl
      :-  '🦁'  'pride'                                  ::  lyn
      :-  '🤸'  'dynamism'                               ::  dyn
      :-  '🐴'  'democracy'                              ::  dem
      :-  '🔆'  'luminosity'                             ::  lux
      :-  '🕴'  'spook'                                  ::  fed
      :-  '🌰'  'genesis'                                ::  sed
      :-  '🥚'  'kiln'                                   ::  bec
      :-  '🌚'  'orbit'                                  ::  mun
      :-  '🎶'  'ballad'                                 ::  lyr
      :-  '🔬'  'examination'                            ::  tes
      :-  '🏍'  'grime'                                  ::  mud
      :-  '🌃'  'eventide'                               ::  nyt
      :-  '🧊'  'preservation'                           ::  byr
      :-  '💠'  'principality'                           ::  sen
      :-  '👻'  'possession'                             ::  weg
      :-  '🔥'  'inferno'                                ::  fyr
      :-  '🗿'  'resolve'                                ::  mur
      :-  '☎'  'mediator'                               ::  tel
      :-  '🐘'  'republic'                               ::  rep
      :-  '🔭'  'gaze'                                   ::  teg
      :-  '🐦'  'avian'                                  ::  pec
      :-  '🤺'  'swashbuckler'                           ::  nel
      :-  '🔱'  'authority'                              ::  nev
      :-  '🎉'  'celebration'                            ::  fes
    ==
  --
::
++  xtra  ::  ops utilities
  |%
  ++  tes
    =|  use=(set @t)
    =|  noz=(set @t)
    |=  [hav=(set @t) all=(list [s=@t n=@t])]
    ^-  (list [c=@t t=@t])
    ?~  all  ~
    =+  i.all
    =*  nex  $(all t.all)
    ?~  s  ~&([%no-emblem n] nex)
    ?~  n  ~&([%no-flavor n] nex)
    ?.  (~(has in hav) (fyl s))
      ~&([%missing n `@ux`s (fyl s)] nex)
    ~?  (~(has in use) s)  [%duplicate s n]
    =.  use  (~(put in use) s)
    ~?  (~(has in noz) n)  [%duplicate n]
    =.  noz  (~(put in noz) n)
    [[s n] nex]
  ::
  ++  fyl
    |=  e=@t
    ^-  @t
    ?:  =('0️⃣' e)  '30-20e3'  ::TODO  what's up with these?
    ?:  =('1️⃣' e)  '31-20e3'
    ?:  =('*️⃣' e)  '2a-20e3'
    (crip (zing (join "-" (turn (rip 5 (taft e)) (x-co:co 1)))))
  --
--

