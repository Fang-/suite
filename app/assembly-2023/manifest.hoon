/+  *assembly-2023, rudder
::
^-  (page:rudder state action)
|_  [bowl:gall order:rudder state]
++  argue  !!
++  final  !!
++  build
  |=  *
  ^~  ^-  reply:rudder
  :+  %full
    :-  200
    :~  ['content-type' 'text/json']
        ['cache-control' 'public, max-age=900, immutable']
    ==
  %-  some
  %-  as-octs:mimes:html
  '''
  {
    "name": "Assembly",
    "start_url": "/assembly",
    "display": "standalone",
    "icons": [
      {
        "src": "https://pal.dev/props/assembly/tile.png",
        "type": "image/png",
        "sizes": "any"
      }
    ]
  }
  '''
--
