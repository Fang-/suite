::  merch: quick-and-dirty merch collector
::
/+  rudder, lp=pal, dbug
::
|%
+$  state-0  [%0 dez=(map ship deets)]
+$  deets
  $:  size=@t
      color=@t
      address=@t
      comments=@t
  ==
--
=,  agent:gall
=,  mimes:html
::
%-  agent:dbug
^-  agent:gall
::
=|  state-0
=*  state  -
|_  =bowl:gall
+*  this  .
::
++  on-init  [[%pass / %arvo %e %connect [~ /merch] dap.bowl]~ this]
++  on-save  !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  [~ this(state !<(state-0 old))]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?=(%handle-http-request mark)
  =+  !<([rid=@ta inbound-request:eyre] vase)
  =|  err=(unit @t)
  =,  request
  |-
  =/  =deets  (~(gut by dez) src.bowl 'S' 'lighter' '' '')
  ?+  method.request  [(spout:rudder rid [405 ~] `(as-octs 'bad method')) this]
      %'GET'
    :_  this
    %+  spout:rudder  rid
    :-  [200 ['content-type' 'text/html; charset=utf-8']~]
    %-  some
    %-  as-octt
    :-  '<!doctype html>\0a'
    %-  en-xml:html
    =/  style=tape
      %-  trip
      '''
      body {
        background-color: #fffdfb;
      }
      h1, h2, h3 {
        font-family: serif;
      }
      main {
        max-width: 35em;
        margin: 2em auto;
        padding: 2em;
        border: 1px solid black;
        border-radius: 2px;
        background-color: white;
        font-family: sans-serif;
      }
      img.preview {
        border: 1px solid black;
        border-radius: 2px;
        float: right;
        margin: 1em;
        max-width: 40%;
      }
      form {
        padding: 0.4em;
        border-radius: 2px;
        font-family: monospace;
      }
      p.err {
        background-color: rgba(255,0,0,0.1);
        padding: 1em;
      }
      fieldset {
        border-radius: 2px;
        padding: 1em;
        margin: 0 1em 1em;
      }
      label {
        margin-right: 1em;
      }
      input[type="radio"] {
        margin-right
      }
      footer {
        color: #777;
        text-align: center;
        font-size: 0.8em;
      }
      '''
    ;html
      ;head
        ;title:"~paldev merch (LIMITED)"
        ;style:"{style}"
      ==
      ;body
      ;main
        ;h1:"Limited edition ~paldev merch"

        ;img.preview@"https://pal.dev/props/tmp-mc/shirt.png";

        ;span(style "font-size: 1.2em")
          On ~2016.06.07, I sent my first chat message on Urbit. To celebrate
          this ten-year anniversary, I will be issuing limited-edition ~paldev
          merch.
        ==

        I do not have a Merch Product yet to take photographs of, so the lead
        time will be a bit stretched here. But there is
        [proven demand](https://x.com/mdfang/status/1668726773633228800)
        for this. The final Product will probably not be too far off the mockup
        presented here, but know that your order does not come with any
        guarantees beyond "receiving something, eventually".

        ;h2:"➡️ Phase 1: order collection"

        ;blink
          *Live now! Closes July 27!*
        ==

        _{(a-co:co ~(wyt by dez))} orders received._

        Merch Product costs a flat $50 (about 80k sats), shipping included.
        If you own space in the [Million Dollar Urbit App](/million),
        you are entitled to a free Merch Product.

        To place an order, fill in the form below. A sales representative will
        reach out to you to complete the order. You are free to update form
        details until the end of Phase 1.

        _If EAuth does not work with your setup, or you are ordering on behalf
        of someone else, please put your own `@p` into the comments field._

        ;form(method "post")
          *Hi {(cite:title src.bowl)}! (Not you? Please [log in](/~/login?eauth).)*

          ;*  ?~  err  ~  :_  ~
          ;p.err:"{(trip u.err)}"

          ;fieldset
            ;legend:"Shirt size"
            ;*  =/  a
              %+  cork
                (bart:lp %checked)
              (mort:lp [%type "radio"] [%name "size"] [%autocomplete "off"] ~)
            :~  (a =(size.deets 'S') ;input(id "small", value "S");)
                ;label(for "small"):"S"
                (a =(size.deets 'M') ;input(id "medium", value "M");)
                ;label(for "medium"):"M"
                (a =(size.deets 'L') ;input(id "large", value "L");)
                ;label(for "large"):"L"
                (a =(size.deets 'XL') ;input(id "xlarge", value "XL");)
                ;label(for "xlarge"):"XL"
            ==
          ==

          ;fieldset
            ;legend:"Clothing color preference (no guarantee about final product)"
            ;*  =/  a
              %+  cork
                (bart:lp %checked)
              (mort:lp [%type "radio"] [%name "color"] [%autocomplete "off"] ~)
            :~  (a =(color.deets 'lighter') ;input(id "lighter", value "lighter");)
                ;label(for "lighter"):"Lighter colors"
                (a =(color.deets 'darker') ;input(id "darker", value "darker");)
                ;label(for "darker"):"Darker colors"
            ==
          ==

          ;fieldset
            ;legend(for "address"):"Mailing address"
            ;textarea
                =id  "address"
                =name  "address"
                =placeholder  "62 West Wallaby Street,\0aWigan WN1 1PD\0aUnited Kingdom"
                =cols  "40"
                =rows  "3"
                =autocomplete  "off"
              ; {(trip address.deets)}
            ==
          ==

          ;fieldset
            ;legend(for "comments"):"Comments"
            ;textarea
                =id  "comments"
                =name  "comments"
                =placeholder  "🌱"
                =cols  "40"
                =autocomplete  "off"
              ; {(trip comments.deets)}
            ==
          ==

          ;button(type "submit"):"Save"
        ==

        In the exceedingly unlikely event this endeavor does not turn out to be
        a loss leader, any profits will be put towards the development of
        ~paldev software and the organization of ~paldev events.

        ;h2:"⏺️ Phase 2: sweatshop arc"
        ;b:"Timeline TBD."

        We will source high-quality garnments and enhance them with tasteful
        embroidery, or do whatever else it takes to construct a satisfying
        Merch Product.

        ;h2:"⏺️ Phase 3: fulfillment"
        ;b:"Before Christmas, ~zod willing."

        You will receive a track-and-trace link when your order ships!
      ==  ;footer
        powered, always and forever, by urbit
      ==  ==
    ==
  ::
      %'POST'
    ?~  body.request  $(err `'blank submit')
    =/  args  (frisk:rudder q.u.body.request)
    ?~  size=(~(get by args) 'size')  $(err `'bad submit')
    ?~  color=(~(get by args) 'color')  $(err `'bad submit')
    ?~  address=(~(get by args) 'address')  $(err `'bad submit')
    ?~  comments=(~(get by args) 'comments')  $(err `'bad submit')
    ::
    %_  $
      dez  (~(put by dez) src.bowl u.size u.color u.address u.comments)
      method.request  %'GET'
    ==
  ==
::
++  on-watch
  |=  =path
  ?>  ?=([%http-response @ ~] path)
  [~ this]
::
++  on-leave  |=(* [~ this])
++  on-agent  |=(* [~ this])
++  on-arvo   |=(* [~ this])
++  on-peek   |=(* ~)
::
++  on-fail
  |=  [=term =tang]
  %.  [~ this]
  (slog 'tmp-mc on-fail' term tang)
--
