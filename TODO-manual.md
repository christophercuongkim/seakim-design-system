# Your manual checklist

Everything in the system that cannot be done from inside this project. Nothing here
blocks any longer — section 1 cleared on 2026-08-05 — so what remains is decisions,
one-time setup, and assets only you can supply.

Last updated 2026-08-05. Light theme verified; house accent is red by decision, not drift.

---

## 1. ~~Blocking — Flutter cannot compile without these~~ — DONE

All five items are complete, and the Flutter binding compiles, analyses clean, and
passes 21 tests. Verified 2026-08-05 on Flutter 3.44 / Dart 3.12.

- [x] **Phosphor icon fonts** — the four `.ttf` files are committed to
      `flutter/assets/icons/`, MIT licence alongside them.
- [x] **Code point table** — `flutter/tool/phosphor_codepoints.json`, all 1512
      glyphs. Note the shape differs from the sketch in this file: it is
      `{"<name>": {"regular": "0x…", "bold": …, "fill": …, "duotone": …,
      "duotoneSecondary": …}}`, because Phosphor's duotone is a *glyph pair* and
      ten glyphs are missing from at least one weight. A flat name→int map cannot
      express either.
- [x] **Generator run** — `dart run tool/gen_icons.dart` writes
      `lib/src/tokens/sk_icons.g.dart`.
- [x] **Text families** — all ten `.ttf` files are committed to
      `flutter/assets/fonts/`, SIL OFL notices alongside, registered with
      `LicenseRegistry` and covered by `test/licenses_test.dart`.
- [x] **`flutter analyze`** — clean. The first-build errors you expected were
      real and are fixed: a nullable `SkGlyph` parameter, two icon fields typed
      as `PhosphorIconData`, two missing imports, and three missing imports in
      the Table/DatePicker/Slider files. `SkApp` also never provided a
      `Directionality`, which crashed any app that did not wrap itself in a
      `WidgetsApp` — caught only by running a widget test.

> Why this section read as blocking for so long: the fonts, the code point
> table, and `sk_icons.g.dart` are deliberately **not mirrored** into the Claude
> Design project — they are binaries and generated artefacts. See
> `flutter/GENERATED-FILES.md`. From inside the design project they look missing;
> in git they have been present since 2026-08-03.

---

## 2. One-time setup

- [ ] **Set the file type to "Design System"** in the Share menu, so your org can pull
      from this project.

- [x] **Token check wired into CI.** `.github/workflows/ci.yml` runs
      `node tool/build-tokens.mjs --check` and `node tool/conformance-check.mjs` on every
      push and PR, plus `flutter analyze` and `flutter test` for both the package and the
      example. The workflow regenerates the icon table first, since `sk_icons.g.dart` is
      not committed.

- [ ] **Decide where the Flutter package lives long-term.** It is currently a folder in
      this repo, which is right while both sides move together. Once Voyage and Bench ship
      on different schedules you will want versioned dependencies — see
      [0007](decisions/0007-token-source-format.md) for the shape.

---

## 3. Assets I cannot produce

I can write SVG and code, but not generate imagery. Nothing has been invented in place of
these — every gap is a labelled placeholder, so they drop in cleanly.

- [ ] **A logo or wordmark.** There is none. Every mark position currently sets the name
      in Outfit SemiBold at `--tracking-tight`. Supply real marks and nothing else changes.

- [ ] **Destination photography for Voyage.** Every image area is a `Placeholder` reading
      `<city> photography`. Do not substitute stock or generated imagery — the placeholders
      are deliberate so the gap stays visible.

- [ ] **Player photos and team crests for Bench.** `Avatar` falls back to initials
      everywhere. Crests are image assets, not icons.

---

## 4. Review passes worth your eyes, not mine

- [ ] **Pick one real screen and tell me where it's wrong.** Still the highest-value thing
      you can give me, and still outstanding. Open either kit, pin the viewport, and be
      specific.

- [ ] **Read the copy against [`guidelines/voice-and-tone.md`](guidelines/voice-and-tone.md).**
      I wrote all of it. You know your audience; I was guessing at register — particularly
      Bench's fast, opinionated tone versus Voyage's reassuring one.

- [x] **Light theme sanity-checked on a real screen** — Chris, 2026-08-05, verdict: good.
      This was the outstanding promise behind [0005](decisions/0005-light-mode-is-first-class.md):
      light is declared first-class, and until now nothing in the Flutter binding had
      ever been rendered in it. Re-check after any change to the disabled or surface
      tokens, since those are the two that collapse toward white rather than failing loudly.
      The `opacity: 0.4` disabled failure you flagged was still live in `SkCheckbox`,
      `SkRadio`, and `SkSwitch` — the conformance checker caught all three and they now
      use `--fill-disabled` / `--text-disabled` / `--border-disabled`.

- [ ] **Confirm the OS-preference call.** [0005](decisions/0005-light-mode-is-first-class.md)
      ignores `prefers-color-scheme` for the initial theme on brand grounds. I flagged it
      as the weakest line in that ADR. If a real user disagrees, that outweighs the
      principle.

---

## 5. Open decisions with no deadline

Nothing is blocked on these; they are the next forks.

- [ ] **App three's name and hue.** Plum (320) is reserved and generated. Adding it is
      four steps in [`tokens/src/README.md`](tokens/src/README.md).

- [ ] **Whether `Sheet` becomes a real component.** Today it is a mode of `Dialog` —
      `showSkSheet` in Flutter, `PlayerSheet` in React. Promote it when a second product
      needs a sheet that is not a dialog. Recorded as item 8 in
      [`conformance.md`](conformance.md).

- [ ] **Token pipeline phases 2 and 3** — dimension, then typography and motion. Low
      value: those files are stable and no binding has duplicated them. Do it when
      something forces the issue, not on principle.

- [ ] **Nothing, on new platforms.** Per
      [0010](decisions/0010-bindings-are-contributed-not-owned.md) a team that needs SwiftUI
      or Compose owns that binding and builds it against the rules — no longer a decision
      waiting on you. Point them at
      [`CONTRIBUTING-A-BINDING.md`](CONTRIBUTING-A-BINDING.md).

---

## What is not on this list

Done and needs nothing from you: the token layer and its generator, 25 React components,
the Flutter widget layer (pending compile), both UI kits responsive across three
breakpoints, the slide templates, nine accepted decisions with visual demos in
[`signoff.html`](signoff.html), the platform-neutral specs, and the conformance tiers.

One caveat on my own record-keeping: while finishing the last round I twice found work
already done that `conformance.md` listed as outstanding. The notes drift from the
filesystem. If precision matters before a handoff, ask me to verify every line in
`conformance.md` against the repo rather than trusting it.
