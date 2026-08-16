# Lessons

Things that went wrong here, what they cost, and the rule that prevents a repeat. Each
one is from a real incident — if a lesson could have been written before the incident, it
belongs in `CLAUDE.md` as a rule, not here as a lesson.

Newest last.

---

## 1. Generated files drift from their source, and the source is not automatically right

**Twice.** `tool/build-tokens.mjs` lost its chart-emitting stage, so regenerating silently
deleted `--chart-1..6` and `SkChartPalette`. Separately, `tokens/src/` still said
`clay: 55` while every generated output said `brick: 8` — regenerating would have reverted
the house accent from crimson to orange across every product surface.

The trap in both: the instinct is *"the generator is authoritative, regenerate."* That
would have destroyed correct work both times. The outputs held the intent; the source and
generator lagged.

**Rule.** When outputs and source disagree, do not assume either. Establish which is
authoritative by asking whether the generator *can reproduce* the outputs — feed the
source through the generator's own helpers and compare. In both cases the outputs turned
out to be this generator's own work from a version whose stage had been lost, which is
knowable only by that test. Byte-match is the proof; plausibility is not.

## 2. Byte-size comparison cannot see same-length edits

Used as the integrity check on every sync, and it silently missed:

- `VERSION` `3.0.0` → `3.0.1` — six bytes either way
- `package.json` `3.0.1` → `3.1.0` — five characters either way
- `color.tokens.json` `clay`→`brick` (+1) cancelling `55`→`8` (−1)

The last one was the house-hue fix — the single most important file in that push.

**Rule.** Size is excellent for truncation and corruption, which is the failure that
actually recurs, and blind to same-length edits. Use `git diff --name-only <since>..HEAD`
to decide *what* changed; use size to verify *how it arrived*. For a same-length edit,
read the content back and assert on it.

## 3. A clean analyzer says nothing about runtime

`SkApp` never provided a `Directionality`, despite its own doc comment claiming it did.
`flutter analyze` was clean; the first widget test crashed on the first `Icon`. Any app
using `SkApp` without a `WidgetsApp` above it would have died immediately.

Six bugs in one session were invisible to static checks: that one, two silent font
fallbacks, a cross-font code point in the icon generator, a text font exposed to the icon
tree-shaker, and three widgets that would not compile.

**Rule.** Static checks prove a narrow thing. Run it, render it, build it for release.

## 4. Verification has to sit as far from the code as a real consumer does

`next/example` consumed the package by `file:` path and built fine. A brand-new app
installing the published tag failed immediately with `TS7016` — the barrel had no type
declarations. The `file:` install resolved types differently, so the example could not
see the bug it existed to catch.

**Rule.** An example inside the repo verifies less than it appears to. Before claiming a
package is consumable, install it the way a stranger would — from the published ref, in a
directory that shares nothing with this one.

## 5. Removing a file to stop it being edited invites it being recreated

`palette.g.dart` and `tokens/generated/colors.ts` were deleted from the Claude Design
project so they could not be hand-edited there. The next session read their absence as a
gap and regenerated both by hand — reintroducing exactly the drift the deletion was meant
to prevent.

Both files carried a `GENERATED — DO NOT EDIT` header at the time. The header did not
help, and neither did a document explaining the exclusion.

**Rule.** A missing file is a visible prompt to create one; a note is not. Put the
instruction where the actor reads instructions — for the design project that is
`SKILL.md`, its brief — and keep the file present.

## 6. A rule that binds one binding is worse than no rule

`literal-colour` caught `rgb(var(--x) / 0.5)` in CSS but never saw Dart's
`.withValues(alpha:)`, so Flutter had been composing alpha freely since it was written
while CSS could not. Neither position had been chosen; the difference was an artefact of
which patterns the checker happened to match.

Separately, `disabled-opacity` only fired on lines containing "disabled" or "off" — so
`opacity: widget.enabled ? 1 : 0.5` read straight past it in three widgets for months.

**Rule.** When adding or changing a Tier 0 rule, write the check for **every** binding and
for the inverse phrasing. Decision 0012 exists because divergent interpretations are the
failure mode.

## 7. Test the hook; do not trust it

The pre-push gate stage had two bugs that only running it revealed:

- it consumed stdin, leaving the design-mirror stage with nothing to read — a silent
  failure in which the mirror would simply never fire again
- `DS_SKIP_DESIGN_PUSH` returned before the gates, so every push that session would have
  skipped the checks entirely

**Rule.** A hook is a program. Drive it with synthetic stdin and assert the exit code for
every path: pass, fail, out-of-scope, and override.

## 8. A history rewrite takes open PRs with it

Rewriting `main` to strip commit trailers moved three tags — anticipated — and also
**closed PR #1**, which GitHub then refused to reopen because its head commit was
unreachable. The PR had to be recreated.

**Rule.** Before rewriting published history, enumerate everything that references a
commit: tags, open PRs, lockfiles that pinned a SHA, CI caches. Tags are the obvious one
and not the only one.

## 9. `json.dumps` mangles non-ASCII by default

Bumping a version with `json.dumps(d, indent=2)` silently rewrote an em dash in
`package.json` as a `—` escape. Valid JSON, identical when parsed, three bytes
different on disk — enough to make local and remote disagree forever.

Related: a literal `\uXXXX` **escape sequence** in source cannot survive an MCP JSON
string field. It arrives decoded as the character, every time, whatever the escaping.

**Rule.** `ensure_ascii=False` when rewriting any file a human wrote. If a file needs a
literal backslash-u sequence, do not transport it through a JSON field — write the real
character instead, which is more readable anyway.

## 10. The design agent is strong on decisions and cannot verify anything

Every failure originating from the Claude Design side traced to one cause: it cannot run
code. It produced genuinely good design work — the Tier 1 reasoning in decision 0014, the
four-step sequential ramp in 0015 — and alongside it shipped three Dart files that would
not compile, a duplicate JSON key that deleted six tokens, a generator that crashed, and a
version that went backwards.

**Rule.** Take its decisions seriously and its code as a draft. Run the gates before
believing any of it. Do not round-trip code through it; the round trip adds a corruption
surface without adding confidence.

## 11. A deploy branch only CI writes goes stale the moment CI fails

`qa` is force-pushed by the `deploy-qa` workflow and by nothing else. The workflow failed
twice on missing Tailscale secrets, so `qa` kept pointing at the commit before
`ENV HOSTNAME=0.0.0.0` — the fix that stops Next binding the container's own IP instead of
all interfaces. Deploying from `qa` in that state builds cleanly and serves nothing, which
presents as a port misconfiguration and sends you into the proxy settings.

The branch looked current because it existed and had a recent commit. Nothing about it
announces that it is one commit behind the thing you are trying to test.

**Rule.** Before deploying from a CI-written branch, diff it against the commit you
believe you are deploying: `git log --oneline <branch>..HEAD`, empty or it is not what you
think. When CI is down, that branch is stale by definition rather than by exception.

## 12. An intermittent blank page is a cache layer, not a slow one

The Flutter binding served a blank page — engine booted, `flt-semantics-placeholder` and
the announcement host both injected, no `flutter-view`, no paint. It reproduced 1 run in 3
against clean browser profiles, failing DOM byte-identical every time (2555b against
4304b). Because it was intermittent it read as a slow load, and the first three
explanations attempted — payload size, the user's VPN, the user's browser cache — were all
wrong. `flutter build web` defaults to `--pwa-strategy=offline-first`, which registers a
service worker whose install races the entrypoint load.

Two things made this expensive. The symptom is shared by every plausible network cause, so
each guess costs a full round trip. And a service worker survives the deploy that removes
it: shipping a build that no longer registers one does not unregister the one a browser
already holds.

**Rule.** Intermittent means measure the rate, not the instance — run the load N times
against clean profiles and count. A stable failure *rate* points at a race; a stable
failure points at config. For any QA surface build with `--pwa-strategy=none`: a service
worker caches a deploy hard enough to hide the next one, which defeats the only thing a QA
site is for.

## 13. Headless Chrome denies WebGL, and a Flutter app then boots without painting

The first headless render of the Flutter binding produced no `flutter-view` and a 2555b
DOM — identical to the real service-worker failure above. It was an artifact: headless
Chrome refuses WebGL by default, CanvasKit cannot initialise, and the engine bootstraps
and stops. Two unrelated causes, one indistinguishable symptom, and the artifact was
briefly mistaken for the bug.

**Rule.** `--enable-unsafe-swiftshader` before any headless check of a canvas-rendering
app, or the run proves nothing. And when a headless result matches the bug being hunted,
reproduce it once in a real browser before believing it — a testing artifact that mimics
the defect will confirm whatever you already suspect.

## 14. The preview cards have a source registry, and no gate renders them

A new `Range` component was added, specced, reviewed, built in both bindings, and passed
all four gates — while its demo card rendered a **blank page**. `ds-shim.js` keeps an
explicit `FILES` list of component sources it fetches; a component missing from it cannot
be resolved, so the whole card fails to mount. Range was never added, so its demo had
silently rendered nothing since it first shipped. Moving it `core → data` didn't cause
this and didn't reveal it either — only loading the page did.

The gates are blind here by construction: `version-check`, `build-tokens --check`, and
`conformance-check` read source and tokens, and `flutter analyze/test` never touches the
web preview. Every one was green over a blank card. This is lesson 3 one level out — a
clean checker says nothing about what actually paints — but with a specific mechanism: a
second registry (`ds-shim.js` `FILES`) that must be edited in lockstep with adding a
component, and that nothing enforces.

**Rule.** Adding a component to a demo card means adding its path to `ds-shim.js` `FILES`
in the same change. And before claiming a demo shows anything, render the card — serve the
repo, load the `.card.html`, and confirm the component is in the DOM. A card that 404s a
source mounts blank, not with an error.

## 15. A component is not delivered until it runs in the two demo apps

`Range` was built in both bindings, exported from the barrel, tested, and — after lesson
14 — rendered in the preview card. It still did not appear in the **Next.js app** (`/next`)
or the **Flutter gallery** (`/flutter`), because each demo app hand-picks which components
it shows, and neither picked Range. "Built and exported" reads as done; "a consumer can see
it running" is the actual bar, and the gap between them is invisible until someone asks
"does it show in Next or Flutter?"

Next.js and Flutter are the two bindings real products consume — fantasy-hub on Next/React,
triptogether on Flutter. Those two demo apps are the closest proxy for a shipping consumer,
so a component absent from them is untested in exactly the place that matters, no matter how
green the gates are.

**Rule.** Adding or changing a component is not complete until it is placed in **both**
primary demo apps — the Next example (`next/example/app`) and the Flutter gallery
(`flutter/example/lib/gallery.dart`) — and each is rendered to confirm it draws (`npm run
build` + load `/next`; `flutter build web` + open the gallery). The preview card is a third
surface, not a substitute. Treat the two apps as the definition of done, because they are
what a consumer actually runs.

## 16. A binding's declared version drifts silently unless you bump it in the same change

0018 exported `SkDepth` and added the role-named raised accessors to the Flutter binding.
While wiring the version, the binding turned out to be sitting at `version: 1.0.0` /
`seakim_rules: "1.0"` — unchanged since import, *through* the entire `SkRange` addition at
rules 3.2.0. The binding had gained a whole widget and still claimed to conform to rules
1.0. Nothing caught it: no gate reads `pubspec.yaml`, `version-check.mjs` only reconciles
the rules number across VERSION/package.json/CHANGELOG, and the binding compiled and tested
green the whole time. The one field whose entire job is to make lag *visible* (0011) had
gone stale invisibly — the exact failure 0011 was written to prevent.

The trap: the rules version and the binding version live in different files and only one is
gated. Bumping VERSION/package.json for a rules change feels like "the version is done," and
the binding's own semver + `seakim_rules` sit unbumped in `pubspec.yaml` where no check
looks. "Rules bumped" reads as done; "the binding that gained the API also declared it" is
the actual bar.

**Rule.** When a change adds or alters a binding's public API for a rules change, bump that
binding's own version **and** `seakim_rules` in the same commit — never only the rules
number. If a rules release changed a binding, its `pubspec.yaml` / `package.json` moved too,
or the release is half-recorded. And only raise `seakim_rules` to a version the binding has
actually been checked against (it passes machine-checkable conformance at that rules
version); 0011 forbids claiming one it has not.
