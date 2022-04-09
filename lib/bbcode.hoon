::  bbcode: parsing & rendering
::
::    behavior is mostly what you'd expect. things worth noting:
::    - the parser eats leading and closing whitespace inside of tags.
::    - if parsing a tag fails, it's silently parsed as plaintext instead.
::    - rendering replaces \0a with <br/> and
::      (TODO) wraps \0a\0a-delineated sections in <p> tags.
::
::    since parsing isn't 100% lossless, you may want to store raw user input
::    instead of pre-parsed bbcode nouns if you intend on allowing users to
::    edit what they put in.
::    +return works quite well, but can't restore what has already been lost.
::
::    we considered adding plug-and-play style support for custom tag parsing
::    and rendering, but the complexity didn't seem worth it. for now, if you
::    want to get fancier with this, simply modify the source directly!
::
|%
+$  bbcode  (list bbnode)
+$  bbnode
  $~  ''
  $@  @t  ::TODO  what about <br/> & <p> ?
          ::      i think the answer is you do those during manx rendering,
          ::      inferring from \0a and \0a\0a sequences.
          ::      still a tiny bit weird though.
  $%  [?(%b %i %u %s) etc=bbcode]
      [%url $@(url=@t [url=@t etc=bbcode])]
      [%img src=@t]
      [%quote author=(unit @t) etc=bbcode]
      [%code txt=@t]
      [%size syz=@t etc=bbcode]
      [%color klr=@t etc=bbcode]
      [%list num=(unit @t) etc=(list bbcode)]
  ==
::
::  +obtain: permissively parse cord into bbcode
::
++  obtain
  =<  |=  =cord
      (rash cord apex)
  ::  internal logic will update :ending to indicate the tag we're currently in
  ::
  =|  ending=(unit @t)
  |%
  ++  end
    ?~  ending  fail
    ;~  pose
      (ifix [;~(plug gaw sel fas) ser] (jest u.ending))
      ?:(=(`'list' ending) (ifix [gaw (star ace)] (jest '[*]')) fail)
    ==
  ::
  ++  apex  (cook squash many)
  ++  many  (star both)
  ++  both  ;~(pose node ;~(less end next))
  ++  text  (cook crip (star ;~(less end next)))
  ::
  ++  tag
    %+  ifix  [sel ;~(plug ser gaw)]
    ;~  pose
      ;~((glue tis) sym (ifix [. .]:doq (cook crip (star ;~(less doq next)))))
      ;~((glue tis) sym (cook crip (star ;~(less ser next))))
      sym
    ==
  ::
  ++  node  ::  non-plaintext node
    %+  knee  *bbnode  |.  ~+
    |=  =nail
    ^-  (like bbnode)
    =/  edge=(like $@(@tas [@tas @t]))
      (tag nail)
    ?~  q.edge  edge
    =*  p  p.u.q.edge
    =*  q  q.u.q.edge
    =/  t  [?@(p p -.p)]:u.q.edge
    =.  ending  `t
    =;  r
      ?.  ?=(~ r)
        (;~(sfix r end) q)
      (fail nail)
    ?+  t  fail
        ?(%b %i %u %s)
      ?^  p  ~
      (stag t many)
    ::
        ?(%img %code)
      ?-  t
        %img   (stag t text)
        %code  (stag t text)
      ==
    ::
        ?(%size %color)
      ?@  p  ~
      ?-  t
        %size   (stag t (stag +.p many))
        %color  (stag t (stag +.p many))
      ==
    ::
        %url
      %+  stag  %url
      ?@  p  text
      (stag +.p many)
    ::
        %quote
      =/  a  ?@(p ~ `+.p)
      %+  stag  %quote
      (stag a many)
    ::
        %list
      |^  %+  stag  %list
          ?@  p  (stag ~ items)
          (stag `+.p items)
      ++  items   (star item)
      ++  item    ;~(pfix gack bullet (star ace) many)
      ++  gack    (star (mask ' ' '\0a' '\0d' ~))
      ++  bullet  (jest '[*]')
      --
    ==
  --
::  +return: bbcode to syntax cord
::
++  return
  |=  bb=bbcode
  ^-  @t
  ?~  bb  ''
  =-  (cat 3 - $(bb t.bb))
  ?@  i.bb  i.bb
  =*  etc  $(bb etc.i.bb)
  ?-  -.i.bb
      ?(%b %i %u %s)
    =*  n  -.i.bb
    (rap 3 '[' n ']' $(bb +.i.bb) '[/' n ']' ~)
  ::
      %url
    %+  rap  3
    ?@  +.i.bb
      ~['[url]' url.i.bb '[/url]']
    ~['[url=' url.i.bb ']' etc '[/url]']
  ::
      %img
    (rap 3 '[img]' src.i.bb '[/img]' ~)
  ::
      %quote
    %+  rap  3
    ?~  author.i.bb
      ~['[quote]' etc '[/quote]']
    ~['[quote="' u.author.i.bb '"]' etc '[/quote]']
  ::
    %code   (rap 3 '[code]' txt.i.bb '[/code]' ~)
    %size   (rap 3 '[size=' syz.i.bb ']' etc '[/size]' ~)
    %color  (rap 3 '[color=' klr.i.bb ']' etc '[/size]' ~)
  ::
      %list
    %+  rap  3
    :-  ?~  num.i.bb  '[list]'
        (rap 3 '[list=' u.num.i.bb ']' ~)
    %+  snoc
      %+  turn  etc.i.bb
      |=(b=bbcode (cat 3 '\0a[*] ' ^$(bb b)))
    '\0a[/list]'
  ==
::  +render: bbcode to manx
::
++  render
  |=  bb=bbcode
  ^-  (list manx)
  ?~  bb  ~
  ?@  i.bb
    =-  (weld - $(bb t.bb))  ::TODO  slightly gross
    ::TODO  also recognize \0a\0a for <p> boundaries
    |^  (rash i.bb or)
    ++  or  (star ;~(pose ln br))
    ++  ln  (cook |=(t=tape :/t) (plus ;~(less br next)))
    ++  br  (cold [[%br ~] ~] (just '\0a'))
    --
  :_  $(bb t.bb)
  ?-  -.i.bb
      ?(%b %i %u %s)
    [[-.i.bb ~] $(bb etc.i.bb)]
  ::
      %url
    ?@  +.i.bb
      =+  url=(trip url.i.bb)
      ;a/"{url}":"{url}"
    ;a/"{(trip url.i.bb)}"
      ;*  $(bb etc.i.bb)
    ==
  ::
      %img
    ;img@"{(trip src.i.bb)}";
  ::
      %quote
    ;blockquote
      ;*  ?~  author.i.bb  ~
          ;=  ;span.author:"{(trip u.author.i.bb)}"
          ==
      ;*  $(bb etc.i.bb)
    ==
  ::
      %code
    ;code:"{(trip txt.i.bb)}"
  ::
      %size
    ::TODO  this and %color are vulnerable to arbitrary css injection...
    ;span(style "font-size: {(trip syz.i.bb)};")
      ;*  $(bb etc.i.bb)
    ==
  ::
      %color
    ;span(style "color: {(trip klr.i.bb)};")
      ;*  $(bb etc.i.bb)
    ==
  ::
      %list
    :-  ?~  num.i.bb  [%ul ~]
        =*  num  u.num.i.bb
        ::TODO  consider supporting this more properly
        [%ol [%type (trip num)] [%start (trip num)] ~]
    %+  turn  etc.i.bb
    |=  b=bbcode
    ;li
      ;*  ^$(bb b)
    ==
  ==
::  +squash: sequential @t (char) nodes into single @t (cord) nodes
::
++  squash
  |=  l=(list bbnode)
  ^+  l
  ?~  l  ~
  ?:  ?=([@ @ *] l)
    ::  if current and next are both cords, cat em
    ::
    $(l [(cat 3 i.l i.t.l) t.t.l])
  :_  $(l t.l)
  ::  if current is a cord, produce it
  ::
  ?@  i.l  i.l
  ::  if current is a node, maybe recurse for its contents
  ::
  =*  ful    i.l
  =*  tag  -.i.l
  =*  dat  +.i.l
  ^-  bbnode
  ?-  -.i.l
    ?(%b %i %u %s)   ful(+ $(l dat))
    %url             ful(+ ?@(dat dat dat(etc $(l etc.dat))))
    ?(%img %code)    ful(+ `@t`dat)
    %quote           ful(etc $(l etc.dat))
    ?(%size %color)  ful(+ dat(etc $(l etc.dat)))
    %list            ful(+ dat(etc (turn etc.dat squash)))
  ==
--
