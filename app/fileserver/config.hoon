::  config: example config file & docs for foo-fileserver
::
::    do not modify /app/foo-fileserver directly.
::    copy it into /app/yourname-fileserver and
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
::    all clay files with this path prefix will be served.
::    files' marks are expected to have a %mime mark conversion available.
::    if +tombstone is enabled, clay history for this path gets obliterated.
::
::    default: /web
::
++  file-root  ^-  path
  /web
::  +tombstone: whether to tombstone +file-root's history
::
::    careful! this hard-sets the tombstoning policy for the desk the
::    fileserver is running on, and may clobber any other policies configured
::    for that desk.
::    careful! turning this on immediately obliterates *all* clay history
::    at and under the configured +file-root.
::    whenever files under +file-root change, the fileserver will trigger
::    clay's tombstoning/garbage collection.
::
::    default: false
::
++  tombstone  ^-  ?
  |
::  +index: file to serve on requests with trailing /
::
::    requests coming in on paths like /foo/ will never resolve to a file
::    directly, because they would resolve to clay files with the %$ mark.
::    if +index is ~, such requests will receive a 404 response.
::    if +index specifies a path, such requests will serve from
::    /foo/[index-path] instead (even if that still 404s).
::
::    default: `/index/html
::
++  index  ^-  $@(~ [~ path])
  `/index/php
::  +auth: whether authentication is required to access the files
::
::    true for "local auth required", false for "publicly accessible".
::    if just a flag is provided, it applies globally.
::    if a path-flag list is also provided, longest matching prefix applies.
::    all paths are relative to the +web-root.
::
::    default: true, "local auth required"
::
++  auth  ^-  $@(? [? (list [path ?])])
  :-  &
  :~  [/public |]
      [/public/hidden &]
  ==
--
