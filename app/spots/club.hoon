/-  *spots
/+  spots, rudder, ot=owntracks
::
|=  $:  src=ship
        [bid=@ta bevy]
    ==
^-  reply:rudder
|^  [%page page]
++  page
  ;html
    ;head
      ;title:"spots: shared location"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, height=device-height, initial-scale=1");
      ;link(rel "stylesheet", href "/spots/static/ol.css");
      ;style:"{(trip style)}"
    ==
    ;body
      ;div#map.map;
      ;script(type "module"):"{script}"
    ==
  ==
::
++  style
  '''
  body {
    margin: 0; padding: 0;
    overflow: hidden;
  }
  .map {
    position: relative;
    width: 100dvw;
    height: 100dvh;
  }

  .bum {
    border-radius: 50%;
    width: 1em; height: 1em;
    background-color: white;
    border: 2px solid black;
    text-align: center;
    font-size: 2em;
    overflow: hidden;
    font-family: serif;
  }
  .bum.our {
    border-color: blue;
  }
  .bum.focus {
    border-width: 4px;
  }

  #panel {
    position: absolute;
    bottom: 0.5em;
    left: 0.5em; right: 0.5em;
    max-width: 500px;
    border-radius: 0.5em;
    background-color: white;
    border: 1px solid grey;
    padding: 1em;
    overflow: hidden;
    max-height: 1em;
    transition-property: height, max-height;
    transition-timing-function: linear;
    transition-duration: 0.1s;
  }
  #panel.open {
    max-height: 10em;
    overflow-y: auto;
  }
  #panel.focus {
    min-height: 10em;
  }

  #focusView {
    display: none;
    position: absolute;
    top: 0; bottom: 0;
    left: 0; right: 0;
    padding: 0.5em;
  }
  #panel.focus #focusView {
    display: block;
  }
  #focusView div {
    padding: 0.2em;
  }
  #focusIcon, #focusName {
    display: inline-block;
  }
  #focusIcon {
    display: none;
  }
  #focusName {
    font-size: 1.2em;
    font-weight: bold;
    font-family: sans-serif;
  }
  #focusTime::before {
    content: '🕓 ';
  }
  #focusBattery::before {
    content: '🔋 ';
  }
  #focusLocation::before {
    content: '📍 ';
  }
  #focusAccuracy::before {
    content: '🎯 ';
  }
  #focusDelete {
    color: red;
  }

  .item {
    display: block;
    border: 1px solid grey;
    padding: 0.2em;
    margin: 0.2em;
  }
  #panel.focus .item {
    display: none;
  }
  .item > * {
    display: inline-block;
  }
  .item.focus {
    border: 2px solid black;
  }
  .item .shorthand {
    width: 1em; height: 1em;
    border-radius: 50%;
    padding: 0.2em;
    overflow: hidden;
    border: 1px solid black;
    font-family: serif;
  }
  .our .shorthand {
    border-color: blue;
  }
  .item .name {
    font-weight: bold;
    margin-left: 0.5em;
  }
  '''
::
++  script
  """
  import \{ clubStart } from "/spots/static/club.js";
  clubStart(
    '{(trip desc)}',
    '{(scow %p src)}',
    {(trip (en:json:html (bums:enjs:spots bums)))}
  );
  """
--
