/-  *spots
/+  *pal, rudder
::
|=  $:  =bowl:gall
        mine=(map @t device)
        auth=@t
        open=(map @ta [did=@t fro=@da til=(unit @da)])
        hunt=(mip @p @t [now=(unit node) bat=(unit batt)])
        line=(jug @t @p)
        dogs=(set @p)
    ==
^-  reply:rudder
|^  [%page page]
++  page
  ;html
    ;head
      ;title:"spots: home"
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;style:"""
             body \{ max-width: 40em; margin: 0 auto; background-color: white; }
             pre, code \{ background-color: #eee; padding: 0.2em; }
             table \{ background-color: #fafafa; }
             """
    ==
    ;body
      # Spots (private alpha)

      Welcome to the Spots alpha. Thank you for trying it out! Please have dojo
      access ready, you will be running commands instead of clicking buttons.

      Spots tracks the locations of your devices. To get started, follow the
      setup instructions.

      ;+  %-  (bool-prop %open =(~ mine))
      ;details
        ;summary:"Setup instructions"

        ## Setup

        ;ol(style "border: 2px solid brown; padding: 1em 2em;")
          ;li
            Install the [Owntracks](https://owntracks.org/) phone app.
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
            Once you are presented with the *Preferences* screen (or after going
            into that through the menu), tap *Connection*.
          ==
          ;li
            Fill in the configuration as follows:
            - *Mode:* HTTP
            - *URL:* `[this-domain]/spots/post`
              - HTTPS _strongly_ recommended!
            - *Device ID:* `phone`
              - Or some other, custom string.
              - Distinguishes it from your other devices, must be unique among those!
              - May be visible to others.
            - *Tracker ID:* any two-character value
              - Used by Owntracks, but not relevant to Spots in practice.
            - *Username:* {(scow %p our.bowl)}
            - *Password:* {(trip auth)}
              - To change the password, `:spots [%set-auth 'hunter2']`
          ==
          ;li
            Going back to the *Preferences* screen, it is also recommended to
            go into *Reporting* and enable *Extended data*. This will let
            Spots detect and share your battery status.
          ==
          ;li
            Going back to the *Preferences* screen, it is also recommended to
            go into *Advanced* and enable *Remote commands*. This will let
            Spots sync ("waypoint") data with the app more reliably.
          ==
          ;li
            Go into the map view and force the app the publish your location.
            If you set everything up correctly, your device should appear in
            the list below!
          ==
        ==
      ==

      ## Devices

      Below are your active devices.

      ;table(cellpadding "5", style "border: 2px solid black; padding: 1em;")
        ;tr(style "font-weight: bold;")
          ;td:"device"
          ;td:"battery"
          ;td:"last update"
          ;td:"shared with"
        ==
        ;*  %+  turn  ~(tap by mine)
            |=  [did=@t device]
            ;tr
              ;td:"{(trip did)}"
              ;td:"{?~(bat "??" (scow %ud cen.u.bat))}%"
              ;td:"{?~(bac "~" (scow %da msg.wen.i.bac))}"
              ;td:"{(join ' , ' (turn ~(tap in (~(get ju line) did)) (cury scot %p)))}"
            ==
      ==

      ## Sharing

      To allow another ship to see the location of one of your devices, for
      example letting ~sampel see the `phone` device, run the following in dojo:

      ```
      :spots [%bait ~sampel 'phone' %.y]
      ```

      Re-run with `%.n` to revoke. Doing so will also send a final location
      update that sets your location to "unknown".

      Currently, the following ships are trying to get your location, and will
      see any device that you have granted them permission on:

      ;+  ?:  =(~ dogs)  ;pre:"none"
      ;pre(style "border: 1px solid black; padding: 0.5em;"):"{(join '\0a' (turn ~(tap in dogs) (cury scot %p)))}"

      ## Subscribing

      Subscribing to a ship causes their devices (that you are allowed to see)
      to _show up in the Owntracks app_. To subscribe to ~sampel:

      ```
      :spots [%hunt ~sampel]
      ```

      Below are the ships you are subscribed to and their devices.

      ;+  ?:  =(~ hunt)  ;pre:"nobody"
      ;pre(style "border: 1px solid black; padding: 0.5em;"):"{(join ', ' (turn ~(tap in ~(key by hunt)) (cury scot %p)))}"

      ;table(cellpadding "5", style "border: 2px solid black; padding: 1em;")
        ;tr(style "font-weight: bold;")
          ;td:"owner"
          ;td:"device"
          ;td:"battery"
          ;td:"last update"
        ==
        ;*  %+  turn  ~(tap bi hunt)
            |=  [who=@p did=@t now=(unit node) bat=(unit batt)]
            ;tr
              ;td:"{(scow %p who)}"
              ;td:"{(trip did)}"
              ;td:"{?~(bat "??" (scow %ud cen.u.bat))}%"
              ;td:"{?~(now "~" (scow %da msg.wen.u.now))}"
            ==
      ==

      ## Clearweb

      You can create clearweb links for sharing a live location. These links may
      be set to expire after some time. (No affordance rn to revoke them early.)
      To share the location for `phone` for the next twelve hours:

      ```
      :spots [%share 'phone' `~h12]
      ```

      Below are your active clearweb links.

      ;table(cellpadding "5", style "border: 1px solid black; padding: 1em;")
        ;tr(style "font-weight: bold;")
          ;td:"link"
          ;td:"device"
          ;td:"expires"
        ==
        ;*  %+  turn  ~(tap by open)
            |=  [sid=@ta did=@t fro=@da til=(unit @da)]
            ;tr
              ;td
                ;a/"/spots/share/{(trip sid)}"
                  ; {(trip sid)}
                ==
              ==
              ;td:"{(trip did)}"
              ;td:"{?~(til "forever" (scow %da u.til))}"
            ==
      ==

      ## Testing

      Try to `[%hunt ~palfun-foslup]`.
    ==
  ==
::
++  bool-prop
  |=  [=mane bool=?]
  |=  m=manx
  =?  a.g.m  bool  [[mane ~] a.g.m]
  m
--
