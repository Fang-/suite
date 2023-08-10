::  %then index
::
::TODO  would be nice if we had an easy way to re-fill form fields with the
::      submitted data on re-render of the page...
::
/+  *then  ::TODO  changing the lib doesn't rebuild this file???
/+  rudder
::
^-  (page:rudder xxxx task)
::
|_  [=bowl:gall order:rudder xxxx]
++  argue
  |=  [headers=header-list:http body=(unit octs)]
  ^-  $@(brief:rudder task)
  =/  args=(map @t @t)
    ?~(body ~ (frisk:rudder q.u.body))
  ::
  ?-  step.draft
      %when
    =/  made=$@(brief:rudder [=from =^args =when])
      (make-step %when args yards bowl +>.draft)
    ?@  made  made
    [%draft draft(when made(when `[%good when.made]), step %fold)]
  ::
      %fold
    ?:  (~(has by args) 'back')
      :-  %draft
      ?:  =(~ fold.draft)  draft(step %when)
      draft(fold (snip fold.draft))
    ?:  (~(has by args) 'skip')
      [%draft draft(step %then)]
    ::
    =/  made=$@(brief:rudder [=from =^args =fold])
      (make-step %fold args yards bowl +>.draft)
    ?@  made  made
    :-  %draft
    %=  draft
      fold  (snoc fold.draft made(fold `[%good fold.made]))
      step  ?:((~(has by args) 'mult') %fold %then)
    ==
  ::
      %then
    ?:  (~(has by args) 'back')
      :-  %draft
      ?:  =(~ then.draft)  draft(step %fold)
      draft(then (snip then.draft))
    ?:  (~(has by args) 'skip')
      [%draft draft(step %last)]
    ::
    =/  made=$@(brief:rudder [=from =^args =then])
      (make-step %then args yards bowl +>.draft)
    ?@  made  made
    :-  %draft
    %=  draft
      then  (snoc then.draft made(then `[%good then.made]))
      step  ?:((~(has by args) 'mult') %then %last)
    ==
  ::
      %last
    ?:  (~(has by args) 'back')
      [%draft draft(step %then)]
    ::
    =/  nom=@t
      ?^  nom=(~(get by args) 'name')
        u.nom
      ?.  =(*@t name.draft)  name.draft
      =*  try  (scot %uv (end 4 eny.bowl))
      |-
      ?.  (~(has by flows) try)  try
      $(eny.bowl +(eny.bowl))
    ::  if we were editing a flow, re-use its id.
    ::  otherwise, turn the :nom into a valid flow id.
    ::
    =/  fid=@ta
      ?.  =(*@ta have.draft)  have.draft
      ?:  ((sane %ta) nom)  nom
      =/  fid
        %^  run  3  nom
        |=  a=@
        ?:  &((gte a 'A') (lte a 'Z'))  (add 32 a)
        ?:(((sane %ta) a) a '-')
      |-
      ?.  (~(has by flows) fid)  fid
      $(fid (cat 3 fid '-'))
    ::
    :-  %multi
    :~  [%draft *^draft]
        ::TODO  want to persist logs etc from pre-existing flow
        [%build fid nom `rope`+>+>+.draft]
    ==
  ==
::
++  final
  |=  [success=? =brief:rudder]
  =/  args=(map @t @t)
    ?~(body.request ~ (frisk:rudder q.u.body.request))
  ?:  &(success (~(has by args) 'save'))
    [%next (cat 3 '/' dap.bowl) brief]
  [%next (rap 3 '/' dap.bowl '/build' ~) brief]
::
++  build
  |=  $:  arg=(list [k=@t v=@t])
          msg=(unit [o=? =@t])
      ==
  ^-  reply:rudder
  ::
  ~&  [%build step.draft]
  |^  [%page page]
  ::
  ++  style
    '''
    * { margin: 0.2em; padding: 0.2em; font-family: monospace; }
    .hidden { display: none; }
    .vars label { display: block; }
    form, .when, .fold, .then { padding: 1em; position: relative; }
    .when { border: 3px solid green; background-color: rgb(200,240,200); }
    .fold { border: 3px solid blue; background-color: rgb(200,210,240); }
    .then { border: 3px solid purple; background-color: rgb(230,200,250); }
    form { border-width: 2px; border-style: dashed !important; }

    .when::after, .when::before, .fold::after, .fold::before {
      width: 0;
      height: 0;
      content: '';
      border-left: 15px solid transparent;
      border-right: 15px solid transparent;
      border-top: 20px solid;
      position: absolute;
      z-index: 10;
      bottom: -19px;
      right: 0;
      left: 0;
      margin: auto;
    }
    .when::before, .fold::before {
      border-left-width: 20px;
      border-right-width: 20px;
      border-top-width: 23px;
      border-top-color: red;
      bottom: -22px;
    }
    .when::before { border-top-color: green; }
    .when::after  { border-top-color: rgb(200,240,200); }
    .fold::before { border-top-color: blue; }
    .fold::after  { border-top-color: rgb(200,210,240); }
    '''
  ::
  ++  page
    ^-  manx
    ;html
      ;head
        ;title:"%then, building new flow {(trip name.draft)}"
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1");
        ;style:"{(trip style)}"
      ==
      ;body
        ;h2:"when, then: building {(trip name.draft)}"
        ;+  ?~  msg  ;/("")
            ;/("[[ {(trip t.u.msg)} ]]")
        ;br;
        ;+  ?~  have.draft  ;/("Creating new flow...")
            ;/("Updating {(trip name.draft)}...")
        ;br;
        ;div.flow
          ;*  show-flow
          ;+  ?-  step.draft
                %when  edit-when
                %fold  edit-fold
                %then  edit-then
                %last  edit-last
              ==
        ==
      ==
    ==
  ::
  ++  show-flow
    |^  ^-  marl
        %-  zing
        :~  ?:  ?=(%when step.draft)  ~
            [(show "when" when.draft)]~
          ::
            (turn fold.draft (cury show "fold"))
            (turn then.draft (cury show "then"))
        ==
    ::
    ++  show
      |=  [kind=tape =(made)]
      ^-  manx
      ?>  ?=(%desk -.from.made)  ::TODO  %ship
      ?~  yard=(~(get by yards) desk.from.made)
        ;div(class kind):"missing app..."
      ?~  part=(~(get by +.u.yard) id.from.made)
        ;div(class kind):"missing part..."
      ;div(class kind)
        ;h4:"{(trip name.u.part)}"
        ;i:"{(trip desc.u.part)}"
        TODO show your inputs?
        Produces:
        TODO show output bill?
      ==
    ::
    --
  ::
  +$  thing  [=from name=@t desc=@t =vars good=?]
  ::
  ::TODO  should we also show incompatible things, but have them be greyed out?
  ++  seek
    |=  [what=?(%when %fold %then) give=bill]
    ^-  (list thing)
    %-  zing
    %+  turn  ~(tap by yards)
    |=  [=desk =yard]
    ?>  ?=(%0 -.yard)
    %+  murn  ~(tap by +.yard)
    |=  [part=@ta part]
    ?.  =(what -.make)  ~
    =;  [take=bill =vars]
      (some [%desk desk part] name desc vars (fits give take))
    ?:  ?=(%vary +<.make)
      [bill vars]:make
    :_  ~
    ?-  -.make
      %when  ~
      %fold  take.easy.make
      %then  (till easy.make)
    ==
  ::
  ++  edit-when
    ^-  manx
    ;form.when(method "post")
      ; First, choose a trigger.
      ;br;
      ;*  (selector "when" (seek %when ~) | |)
    ==
  ::
  ++  edit-fold
    =/  =bill
      ?~  fold.draft
        (will form:(need have.when.draft))
      give.form:(need have:(rear fold.draft))
    ;form.fold(method "post")
      ;input(type "submit", name "back", value "back");
      ;br;
      ; Optionally, filter the trigger output.
      ;br;
      ;input(type "submit", name "skip", value "skip");
      ;br;
      ;*  (selector "fold" (seek %fold bill) & |)
    ==
  ::
  ++  edit-then
    =/  =bill
      ?~  fold.draft
        (will form:(need have.when.draft))
      give.form:(need have:(rear fold.draft))
    ;form.then(method "post")
      ;input(type "submit", name "back", value "back");
      ;br;
      ; Lastly, choose actions to run.
      ;br;
      ;input(type "submit", name "skip", value "skip");
      ;br;
      ;*  (selector "then" (seek %then bill) & &)
    ==
  ::
  ++  edit-last
    ;form.last(method "post")
      ;input(type "submit", name "back", value "back");
      ;br;
      ; Give your flow a name and save it!
      ;br;
      ;label
        ; flow name
        ;input(type "text", name "name", placeholder "my cool flow");
      ==
      ;input(type "submit", name "save", value "save");
    ==
  ::
  ++  selector
    |=  [name=tape opts=(list thing) mult=? last=?]
    ::TODO  if we already have a thing for this step, pre-fill fields?
    ^-  marl
    %-  zing
    :~
      ;+  ;label
        ;select(name name, id name)
          ::TODO  optgroups
          ;*  :-  ;option(value "");
              (turn opts option)
        ==
      ==
    ::
      ;*  (turn opts detail)
      ;+  ;script
        ;+  ;/
        %+  weld
          "let select = document.getElementById('{name}');\0a"
        ^~  %-  trip
        '''
        let prev = null;
        let f = () => {
          if (prev) {
            document.getElementById(prev).classList.add('hidden');
          }
          prev = select.value;
          document.getElementById(prev).classList.remove('hidden');
        };
        select.addEventListener('change', f);
        f();
        '''
      ==
    ::
      ;*  ?.  mult  ~
          :_  ~
          ;label
            ;input(type "checkbox", name "mult");
            ; add another one
          ==
      ;+  ;input(type "submit", name "next", value "{?:(last "save" "proceed")}");
    ==
  ::
  ++  option
    |=  thing
    ?:  good  ;option(value (trip (de-from from))):"{(trip name)}"
    ;option(value (trip (de-from from)), disabled "true"):"{(trip name)}"
  ::
  ++  detail
    |=  thing
    =/  id  (trip (de-from from))
    ;div.detail.hidden(id id)
      ;h3:"{(trip name)}"
      ;p:"{(trip desc)}"
      ;+  (inputs id vars)
    ==
  ::
  ++  inputs
    |=  [lead=tape =vars]
    ?~  vars  ;div.vars:"Takes no inputs."
    ;div.vars
      ;*  %+  turn  vars
      |=  hole
      =/  name=tape  "{lead}.{(trip face)}"
      ;label
        ;+  ;/("%{(trip face)}: ")
      ::
        ::TODO  specialize further
        ;+
        ?:  =(%f aura)
          ;input(name name, type "checkbox");
        ?:  =(%da aura)
          ;input(name name, type "datetime-local");
        ?:  =(%ud aura)
          ;input(name name, type "number");
        ;input(name name, type "text", placeholder "{(scow aura ~)}");
      ::
        ;br;
        ;+  ;/((trip desc))
      ==
    ==
  --
--
