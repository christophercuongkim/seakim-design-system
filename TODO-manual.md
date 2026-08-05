# Your manual checklist

Everything in the system that cannot be done from inside this project. Three of these
are blockers, the rest are decisions or one-time setup.

Last updated 2026-08-04.

---

## 1. Blocking — Flutter cannot compile without these

The Flutter binding is written and reviewed but **unbuilt**. Two missing files, both
consequences of [decision 0009](decisions/0009-bundle-phosphor-icon-font.md) moving icon
delivery in-house.

- [ ] **Drop in the Phosphor icon fonts.** Four files into `flutter/assets/icons/`:
      `Phosphor-Regular.ttf`, `Phosphor-Bold.ttf`, `Phosphor-Fill.ttf`,
      `Phosphor-Duotone.ttf`. MIT licensed, from the Phosphor release.
      `pubspec.yaml` already declares them.

- [ ] **Extract the code point table.** Produce `flutter/tool/phosphor_codepoints.json`
      from those fonts — a flat `{"caret-right": 57345, …}` map. `tool/gen_icons.dart`
      reads it; the file is the checked-in artefact, same as `palette.g.dart`'s inputs.

- [ ] **Run the generator.** `cd flutter && dart run tool/gen_icons.dart`, which writes
      `lib/src/tokens/sk_icons.g.dart`. Seven widgets have unresolved imports until it
      exists: `SkCheckbox`, `SkToast`, `SkDialog`, `SkSelect`, `SkStat`, `SkEmptyState`,
      `SkTable`.

- [ ] **Drop in the three text families.** Ten `.ttf` files into
      `flutter/assets/fonts/` — Outfit (4 weights), Plus Jakarta Sans (4), IBM Plex Mono
      (2). All SIL OFL 1.1, all on Google Fonts. Filenames are listed in `pubspec.yaml`.
      The web bindings fetch theirs at runtime, so this blocks Flutter only.

- [ ] **Then run `flutter analyze`** and paste me the output. I have written and reviewed
      the Dart but never compiled it, so expect a handful of first-build errors.

> Licence notices are already committed and wired to `showLicensePage()`, so attribution
> is handled once the binaries land.

---

## 2. One-time setup

- [ ] **Set the file type to "Design System"** in the Share menu, so your org can pull
      from this project.

- [ ] **Wire the token check into CI**, whenever CI exists:
      `node tool/build-tokens.mjs --check` — exits non-zero if the generated CSS, Dart, or
      TS is stale relative to `tokens/src/`. Without it, someone will hand-edit a generated
      file and it will silently revert on the next build.

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

- [ ] **Sanity-check the light theme on a real screen.** I fixed the one Tier 0 failure I
      found (disabled state was `opacity: 0.4`, which collapses toward white), but I
      verified by screenshot, not by using the app for ten minutes.

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
