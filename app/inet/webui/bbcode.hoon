::  inet/bbcode: bbcode aid
::
/-  *inet
/+  rudder
::
^-  (page:rudder state action)
|_  [bowl:gall * state]
++  argue  |=(* ~)
++  final  !!
::
++  build
  |=  *
  ^-  reply:rudder
  :-  %full
  :-  [200 ['content-type'^'text/plain']~]
  %-  some
  %-  as-octs:mimes:html
  '''
  Supported BBCode tags:

  - [b]bold[/b]
  - [i]italics[/i]
  - [u]underline[/u]
  - [s]strikethrough[/s]
  - [size=14pt]size[/size]
  - [color=red]color[/color]

  - [url]https://pal.dev/[/url]
  - [url=https://pal.dev/]text[/url]
  - [img]https://pal.dev/meme.jpeg[/img]
  - [quote]text[/quote]
  - [quote=author]text[/quote]
  - [code]codeblock[/code]
  - [list]
    [*] bulleted
    [*] list
    [/list]
  - [list=1]
    [*] numbered
    [*] list
    [/list]

  '''
--
