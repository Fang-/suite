# cliff @ 408K — Phase 0 findings

Verification pass for updating `%cliff` to 408K and adding fine-grained Clay
permission management. Nothing here is speculative: every issue below was
reproduced on a live 408K ship. Assumptions that turned out to be wrong are
recorded in [Corrections](#corrections) rather than quietly dropped.

- **Branch:** `sigilante/cliffs-notes`
- **Baseline:** `2417ed8` (fork is identical to `Fang-/suite` master)
- **Kernel:** `[%zuse 408]`, confirmed by
  `.^(* %cx /<our>/base/<now>/sys/kelvin)` → `[1.702.065.530 408]`

`pkg/cliff/sys.kelvin` already declares `[%zuse 408]` (upstream `d8332ec`,
"All others unaffected"). That claim holds *at the compile level* — cliff
builds, installs and boots clean at 408K. Every issue below is runtime
behaviour.

## Test environment

Harness lives outside the repo at `~/urbit/ships/cliff-dev/`:

| | |
|---|---|
| `drive.sh` | boot / dojo / read / install / sync / kill, tmux session `cliff` |
| `dj.sh` | send one dojo command, capture just the new output |
| ships | `~zod` (http :80), `~nec` (http :8080), both fake |
| pill | `~/urbit/urbit-408k-rc1.pill`, vere 4.6 |
| kernel source | `~/urbit/urbit/pkg/arvo` |

Nothing in `~/urbit/ships` was usable as-is: `emissary-dev/*` and
`fopfen-witpun-lagrev-nocfep` are all `[%zuse 409]`, and the only 408K pier
(`comet-caderno`) is a comet and out of scope. Both harness ships are booted
fresh from the rc1 pill.

Scratch desk `%tomby` on `~zod` holds the fixtures: `/note/txt` (two
revisions, aeon 2 tombstoned), `/doc/pdf`, `/doc/mime`.

Line references are `path:line` against this branch for cliff, and against
`~/urbit/urbit/pkg/arvo` for kernel source.

---

## Issue 1 — any non-`now` case returns 500

**Severity:** high. Breaks all history browsing, which is most of cliff's point.

```
GET /cliff/view/our/base/1   ->  HTTP 500
GET /cliff/view/our/base/now ->  HTTP 200
```

`app/cliff.hoon:400` builds the desk-selector dropdown with:

```hoon
.^((set desk) %cd rend(q.beam %$, s.beam ~))
```

This overrides the desk and the spur but **keeps the browsed case**. At 408K
the empty-desk fast path is gated on the case being `now`
(`sys/vane/clay.hoon:5881`):

```hoon
?:  &(=(our his) ?=(?(%d %x) ren) =(%$ syd) =([%da now] u.luk))
```

With any other case the request falls past `+read-buc-d`
(`sys/vane/clay.hoon:5905`) into the general path against desk `%$`, which has
no dome, and crashes. Reproduced bare:

```hoon
.^((set desk) %cd [(scot %p our) %$ (scot %da now) ~])  ::  {%groups %base ...}
.^((set desk) %cd [(scot %p our) %$ (scot %ud 1) ~])    ::  bail: 4
```

**Fix:** pin this scry to `da+now` — the desk list is a property of the ship,
not of the browsed revision. Better, move to `.^(cone %cx /=$=/now/domes)`
(`sys/vane/clay.hoon:5905` region, `read-buc-x` `%domes`), which returns
`(map [ship desk] dome)` and hands us `let` and `lab` per desk for free. That
also unblocks label navigation, currently rejected at `app/cliff.hoon:97`
where only `%ud`, `%da` and the literal `%now` are accepted.

---

## Issue 2 — tombstoned files return 500, and `arch` hides it

**Severity:** high. Any desk with `|tomb`'d history has landmines in it, and
the directory listing links straight to them.

```
GET /cliff/view/our/tomby/2/note/txt ->  HTTP 500
GET /cliff/down/our/tomby/2/note/txt ->  HTTP 500
```

The nasty part is that the arch still claims the file is there:

```hoon
.^(arch %cy /<our>/tomby/<ud 2>/note/txt)
::  [fil=[~ 0v3.aucko...] dir={}]      <-- looks present
.^(*    %cq /<our>/tomby/<ud 2>/note/txt)
::  bail: 4                            <-- data is gone
```

So `+have` (`app/cliff.hoon:151`), which is just `?=(^ [fil:arch])`, returns
true, `+show` (`app/cliff.hoon:179`) proceeds to `%cx`/`%cr`, and the whole
page dies. `+meta` (`app/cliff.hoon:527`) has the same exposure via its
`(need show)`.

**Fix:** guard with the dedicated tombstone scry (`sys/vane/clay.hoon:5973`),
verified in both directions:

```hoon
.^(? %cx /<our>/$/<now>/tomb/<full-beam-as-path>)
::  %.n at aeon 2 (tombstoned), %.y at aeon 3 (live)
```

`+have` must incorporate this, not just `fil.arch`, so listings can render
tombstoned entries as dead rather than linking to a 500.

---

## Issue 3 — a mark the desk lacks takes down the page

**Severity:** medium-high. Common on 408K, where `%base` carries few
mime-capable marks.

`+show` (`app/cliff.hoon:192`) builds the `mark → mime` tube **on the browsed
desk**. Fang's own `::TODO want to detect tube scry failures ahead of time
somehow?` sits directly above it. When the mark is absent or has no mime cast:

```hoon
.^(tube:clay %cc /<our>/base/<now>/pdf/mime)
::  [%error-building-tube %pdf %mime]
::  [%error-building-cast %pdf %mime]
::  [%no-cast-between %pdf %mime]
::  bail: 2
```

**Fix:** pre-flight the mark before building any tube (does `mar/<mark>/hoon`
exist on the target desk?), and fall back to `%cq` — the typeless read, which
needs no mark at all — plus a static mark → mimetype table for the
content-type. Never let a tube build escape unchecked. See
[Correction 1](#correction-1--mule-does-not-catch-scry-failures) for why
wrapping it is not an option.

---

## Issue 4 — every unauthenticated request returns 500 *(new; not in the original plan)*

**Severity:** high, and it is the precondition for the whole "serve public
files to logged-out visitors" idea.

```
GET /cliff/view/our/base/now            ->  HTTP 500   (no cookie)
GET /cliff/view/our/base/now  + cookie  ->  HTTP 200
```

`app/cliff.hoon:120`, in `on-watch`:

```hoon
?>  =(our.bowl src.bowl)
```

Eyre does not subscribe to `/http-response/...` as us. It subscribes **as the
requester's identity** (`sys/vane/eyre.hoon:1302-1310`, `deal-as identity`),
which for an anonymous visitor is a synthesized comet. Observed live after
relaxing the assertion:

```
[%cliff-on-watch
  src=~pasnel-ravtul-nopfed-tacsyn--tipnyl-rivbyl-dolbyn-silwel
  our=~zod
  path=/http-response/~.eyre_0v1.jmt5b.tbd4v.u22ej.e8i8d.s3niu ]
[%cliff-got-request auth=%.n url='/cliff/view/our/base/now']
```

The assertion fails, the subscription crashes, and eyre 500s before cliff's
poke can respond. Consequence: the 307-to-login redirect at
`app/cliff.hoon:58-67` **has never run at 408K** — it is dead code, and so is
the `::TODO depend on publicness of requested file?` that sits on top of it.

This was hard to see because `+internal-server-error`
(`sys/vane/eyre.hoon:643`) deliberately omits the tang when the requester is
not authorized, so the console stays silent and the 500 page is blank. Bisect
that pinned it: replacing the redirect body with a plain 403 payload still
500'd; removing the `on-watch` assertion produced the 403 and let `on-poke`
run with `auth=%.n`.

**Fix:** drop or relax the assertion so eyre's subscription is accepted. That
restores the login redirect and is what makes Phase 5 (public files for
logged-out visitors) implementable at all.

---

## Permissions — verified working

No defects; recording the mechanics that the UI will be built on.

**`%cp` read and inheritance.** `.^([r=dict:clay w=dict:clay] %cp <beam>)`.
Local-only by construction (`may-read` for `%p` requires `=(who our)`,
`sys/vane/clay.hoon:4041`). Default with nothing set anywhere is
`[src=/ rul=[mod=%white who=[p={} q={}]]]` — empty whitelist, fully private.
After `[%c %perm %tomby /doc [%r `[%black ~]]]`:

```
/doc/pdf  ->  r=[src=/doc rul=[mod=%black ...]]   ::  inherited from /doc
/note/txt ->  r=[src=/   rul=[mod=%white ...]]    ::  untouched
```

`src` is the path the rule was found at, so **`=(src pax)` is exactly "there
is an explicit rule here"** — that is how the UI distinguishes set from
inherited, and how a desk-wide rule listing can be built by walking `%ct`
paths plus their prefixes.

**Crews.** `[%c %cred %pals (silt ~[~nec ~bud])]` then referencing
`[%| %pals]` in a rule yields:

```
r=[src=/note rul=[mod=%white who=[p={} q={[p=~.pals q={~nec ~bud}]}]]]
```

`%cp` expands the crew to its **membership**, so cliff gets crew contents for
free on any path that references one. Empty `crew` deletes the group
(`sys/vane/clay.hoon:4676-4679`).

**Gifts reach Gall.** `sign-arvo` includes `[%clay gift:clay]`
(`sys/lull.hoon:4752`). Confirmed with a throwaway probe agent:

```
[%c %crew ~]        ->  on-arvo  [%clay %cruz {[p=~.pals q={~nec ~bud}]}]
[%c %crow %pals]    ->  on-arvo  [%clay %croz {[p=%tomby q=[r={[p=/note q=[mod=%white who={[%.n p=~.pals]}]]} w={}]]}]
```

There is **no scry for `cez`**, so the crew map has to be mirrored in agent
state and refreshed on `on-init` / `on-load` / after every `%cred`. Note
`%croz` returns raw `rule`s (unexpanded `whom`), unlike `%cp`.

### Permissions — two traps for the UI

**`%perm` with an unknown crew is a silent no-op.** `+perm`
(`sys/vane/clay.hoon:2963`) guards its error reporting on the duct shape
(`sys/vane/clay.hoon:2980` and `:2989`, flagged `TODO remove this nasty hack`).
From a Gall duct there is no `%done` ack and no `%perm-fail`. Reproduced: a
`%perm` naming a nonexistent crew `%ghosts` was acked `>=` and the rule was
**not applied** — `%cp` still showed the previous rule, with no diagnostic
anywhere.

> The UI must validate crew names against the cached `cez` before sending, and
> read back with `%cp` afterwards to confirm. Never report success on the ack.

**`may-write` is dead code.** Defined at `sys/vane/clay.hoon:4062`, **zero
call sites** in the vane (`may-read` is called from `:4379`; `may-write` is
called from nowhere). Write rules are stored, inherited, scryable and
reportable via `%crow` — and enforce nothing.

> Per project decision the write-rule editor still ships, labeled to say so
> ("call your local core dev"). It is real state that merges and future
> kernels will care about, and hiding it would make cliff a worse debugging
> tool — but presenting it as a security control would be a lie.

---

## Corrections

Three assumptions from the pre-Phase-0 plan were wrong. They are recorded
because the fixes depend on them.

### Correction 1 — `mule` does not catch scry failures

A crashing vane scry bails the entire event and escapes virtualization:

```hoon
=t  (mule |.(.^(tube:clay %cc /<our>/base/<now>/pdf/mime)))
::  bail: 2 — and `t` is never bound (-find.+2.t)
```

Same for Issue 1. The originally-planned defensive `+mule` wrappers are
worthless here. **Every fix must be a pre-flight check**, not a catch.

### Correction 2 — the target desk needs the mark, for read *and* commit

The plan assumed cliff could cast a file on its own desk (carrying yard's
marks) and commit the correctly-marked page anywhere, because
`+validate-page` (`sys/vane/clay.hoon:1069`) short-circuits when the page mark
already equals the path mark. That is true but irrelevant: `+park` validates
at commit through `build-dais`, **even on an unmounted desk**, and
`+page-to-cage` (`sys/vane/clay.hoon:1080`) builds a dais for every mark
except `%hoon` and `%mime`. Committing `/doc/pdf` to a desk without `mar/pdf`:

```
[%error-validating /doc/pdf]
[%validate-page-fail /doc/pdf %from %pdf]
[%error-building-dais %pdf]
clay: no files match /mar/pdf/hoon
```

Two escape hatches, both verified working:

- **A — store as `%mime`.** A `%mime`-marked page at a path ending `/mime`
  commits and reads back on a desk with no marks beyond the `|new-desk`
  defaults, because both `+validate-page` and `+page-to-cage` short-circuit.
  The mime type rides in the page, so `+down` can serve the right
  content-type. Universal, but the on-desk extension is lost — the file is
  `doc/mime`, not `doc/pdf`.
- **B — install the mark.** cliff commits the mark source into the target
  desk, **including its `grad` chain**: `mar/pdf` alone still failed with
  `clay: no files match /mar/mime/hoon`; adding `mar/mime` made the `/doc/pdf`
  commit succeed. This is where `~/urbit/yard`'s 49 mime-capable marks (~31 of
  which `base-dev` lacks) actually earn their place.

Once the marks were present, cliff served both fixtures correctly:

```
down/our/tomby/now/doc/pdf   ->  200  content-type: application/pdf
down/our/tomby/now/doc/mime  ->  200  content-type: application/pdf
```

### Correction 3 — `%cq` is the safe read path

`read-q` returns the raw page with no mark build, and correctly fails on
tombstoned data. It is the right primitive for display and download fallback,
in place of the `%cx`/`%cr` calls that Issues 2 and 3 crash on.

---

## Not verified

**Cross-ship read enforcement.** A `|merge` from `~nec` of a desk on `~zod`
transferred nothing with the desk root private *and* nothing with it public
(`%black ~`, confirmed set via `%cp` on `~zod`) — the target desk stayed at
aeon 0 in both states, with no warp traffic on either side. `|hi` succeeds
between the ships, so basic ames works; clay sync in this fakeship pair does
not. The A/B is therefore **inconclusive**, and it is an environment problem,
not a permissions result.

This does not block Issues 1–4 or the permission UI, all of which are verified
locally. It does mean the publicness gate that Phase 5 would rely on
(`sys/vane/clay.hoon:5881` region treats `[%black ~ ~]` as public for
anonymous scries) is still unproven end to end. Needs remote scry or real
networking before Phase 5 ships.

---

## Pre-existing gaps (not 408K regressions)

- `+load` — upload — is a bare `!!` (`app/cliff.hoon:255`); the upload form is
  commented out. Never implemented.
- Case parsing (`app/cliff.hoon:94-98`) rejects `%tas` labels other than the
  literal `%now`, so desk labels are unreachable. The `domes` scry from
  Issue 1's fix supplies `lab` and removes the excuse.

---

## Phase 1 scope

Issues 1–4, as their own commit:

1. Pin the desk-list scry to `da+now`, or move to `/=$=/now/domes`.
2. Tombstone pre-check via `/=$=/now/tomb/<beam>`; fold into `+have`.
3. Mark pre-flight before any tube build; `%cq` + static mark→mimetype
   fallback.
4. Accept eyre's anonymous `on-watch` subscription; restore the login
   redirect.
