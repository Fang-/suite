::  config: example config file & docs for foo-fileserver
::
::    do not modify /app/foo-fileserver directly.
::    copy it into /app/yourname-fileserver instead.
::    provide at least a minimal /app/fileserver/config,
::    containing |%  ++  web-root  /yourname  --
::
::    ALWAYS rename the /app/foo-fileserver file, and
::    ALWAYS provide a custom +web-root in the config file.
::
::    this file contains both required and optional configuration,
::    so that it can give examples and documentation,
::    but you can omit optional arms entirely to use their defaults instead.
::
|%
::    required config parameters
::
::  +web-root: url under which your files will be served
::
::    the remainder of the request path (under the +web-root) will be
::    retrieved from the +file-root.
::    for example, here, /foo/static/bar.html will serve from /web/bar/html.
::
::    in other configuration parameters, per-path configuration applies to
::    the remainder of the request path, never includes the +web-root prefix.
::
++  web-root  ^-  (list @t)
  /foo/static
::
::    optional config parameters
::
::  +file-root: path on this desk under which the files to serve live
::
::    default: /web
::
++  file-root  ^-  path
  /web
::  +auth: whether authentication is required to access the files
::
::    true for "local auth required", false for "publicly accessible".
::    if just a flag is provided, it applies globally.
::    if a path-flag list is also provided, longest matching prefix applies.
::    all paths are under the +web-root.
::
::    default: true, "local auth required"
::
++  auth  ^-  $@(? [? (list [path ?])])
  :-  &
  :~  [/public |]
      [/public/hidden &]
  ==
--
