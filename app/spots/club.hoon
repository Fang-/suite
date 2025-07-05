/-  *spots
/+  spots, rudder
::
|=  [bid=@ta bevy]
^-  reply:rudder
|^  [%page page]
++  page
  ;html
    ;head
      ;title:"spots: shared location"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;link(rel "stylesheet", href "/spots/static/ol.css");
      ;style:".map \{ width: 100vw; height: 100vh; } .bum \{ border-radius: 50%; width: 3em; height: 3em; background-color: red; border: 2px solid black; }"
    ==
    ;body
      ; todo instructions
      ;div#map.map;

      ;script(type "module"):"{script}"
    ==
  ==
::
++  script
  """
  import \{ clubStart } from "/spots/static/club.js";
  clubStart({(trip (en:json:html (bums:enjs:spots bums)))});
  """
--
