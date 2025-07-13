/-  *spots
/+  spots, rudder, ot=owntracks
::
|=  $:  [src=ship secure=? host=@t eny=@]
        [bid=@ta bevy]
    ==
^-  reply:rudder
|^  [%page page]
++  page
  ;html
    ;head
      ;title:"{(trip bid)} setup"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, height=device-height, initial-scale=1");
      ;style:"{(trip style)}"
    ==
    ;body
      # {(trip desc)} location sharing

      ;ol
        ;li
          Install the [Owntracks](https://owntracks.org/) app.
          ;a/"https://play.google.com/store/apps/details?id=org.owntracks.android"
            ;img
              =src     "https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
              =height  "60";
          ==
          ;a/"https://itunes.apple.com/us/app/mqttitude/id692424691?mt=8"
            ;img
              =src     "https://developer.apple.com/app-store/marketing/guidelines/images/badge-example-preferred.png"
              =height  "54";
          ==
        ==
        ;li
          Proceed through its location permission request screens.
        ==
        ;li
          Enter your display name:
          ;input(id "name", type "text", value "John McAffee");
        ==
        ;li
          ;a(id "config", href "#"):"Tap this link for one-tap configuration of the Owntracks app."
        ==
        ;li
          You should appear on the map now! If not, make sure the Owntracks app
          is set up to publish your location, and/or force-push a location update.
        ==
        ;li
          ;a(href "nuke"):"Tap this link to remove yourself from the map."
        ==
      ==

      ;script(type "module"):"{script}"
    ==
  ==
::
++  script
  """
  import \{ clubSetupStart } from "/spots/static/club-setup.js";
  clubSetupStart(
    {(trip (en:json:html config-object))}
  );
  """
::
++  config-object
  ^-  json
  :-  %o
  =/  url=@t
    %+  rap  3
    :~  ?:(secure 'https://' 'http://')
        host
        '/spots/club/'
        bid
        '/post'
    ==
  %-  ~(gas by *(map @t json))
  :~  :-  '_type'         s+'configuration'
      :-  'auth'          b+&
      :-  'extendedData'  b+&
      :-  'mode'          n+'3'  ::  http mode
      :-  'url'           s+url
      :-  'username'      s+(scot %p src)
      :-  'password'      s+(crip ((w-co:co 1) (end 6 eny)))
  ==
::
++  style
  '''
  * {
    font-family: monospace;
  }
  li {
    padding-bottom: 2em;
    margin-bottom: 2em;
    border-bottom: 1px solid black;
  }
  '''
--
