::  million: the million dollar urbit app
::
|%
+$  spot  [x=@ud y=@ud]
+$  grid  (map spot tile)  ::  100x100, each tile 10x10px
++  size  100  ::  ^2
::
+$  tile  ::  content at coordinate
  $~  [%forsale ~]
  $%  [%forsale ~]
      [%pending who=ship]           ::  pending sale to
      [%managed who=ship body]      ::  controlled by
      [%mystery new=*]              ::  incompatible update
      [%unacked old=tile new=tile]  ::  display optimistically
  ==
::
::  display
::
+$  body  [=tint =show =echo =link]
::
+$  show
  $~  [%nothing ~]
  $%  [%nothing ~]         ::  empty
      :: [%pngdata dat=@ux]   ::  png image data  ::TODO  max 400 bytes... right?
      :: [%bmpdata dat=@ux]   ::  bmp image data
      :: [%svgdata dat=@t]    ::  svg syntax
      [%sourced url=@t]    ::  image src url
      [%similar src=spot]  ::  sync with source
      ::TODO  %textual, fg, bg, [@c @c] for tui display?
  ==
::
+$  echo  ::  on-hover
  $~  [%nothing ~]
  $%  [%nothing ~]         ::  silent
      [%display txt=@t]    ::  hovertext
      [%similar src=spot]  ::  sync with source
  ==
::
+$  link  ::  on-click
  $~  [%nothing ~]
  $%  [%nothing ~]         ::  no-op
      [%weblink url=@t]    ::  navigate to
      [%similar src=spot]  ::  sync with source
  ==
::
::  networking
::
+$  action
  $%  [%buy =ship spos=(set spot)]  ::  intent, only for %forsale tiles, intent
      [%giv =ship spos=(set spot)]  ::  gottem, only for tiles you own
      [%set =spot =body]            ::  render, only for tiles you own
  ==
::
+$  update
  $%  [%ful =grid]
      [%new =grid]
  ==
--
