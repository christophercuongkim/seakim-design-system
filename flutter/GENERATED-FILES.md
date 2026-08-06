# Files not mirrored into Claude Design

The Claude Design project carries this port's **sources**, not its build output,
its binaries, or anything a tool regenerates. Those live only in the git repo
(github.com/christophercuongkim/seakim-design-system):

| Missing from the design project | Size | Why |
| --- | --- | --- |
| `lib/src/tokens/sk_icons.g.dart` | ~790 KB | Generated. Reproduce it, never edit it. |
| `tool/phosphor_codepoints.json` | ~186 KB | Extracted input to the generator. |
| `assets/icons/Phosphor-*.ttf` | ~2 MB | Icon font binaries; four files. |
| `assets/fonts/*.ttf` | ~1 MB | Text font binaries; ten files. |
| `assets/fonts/OFL-*.txt` | ~13 KB | Licence notices; they travel with the binaries above. |
| `example/android/`, `example/ios/`, `example/web/`, `example/.metadata`, `example/analysis_options.yaml` | — | `flutter create` scaffolding; regenerate with the command below. |

To get a working checkout from the design project alone you need the fonts and
one command:

```bash
dart run tool/gen_icons.dart      # writes lib/src/tokens/sk_icons.g.dart
```

Without the `.g.dart`, `SkIcons` is undefined and nothing that draws an icon
compiles. Without the `.ttf` files, it compiles but every glyph renders as tofu
and `flutter test` fails on the asset bundle.

To run the example app, regenerate its platform scaffolding:

```bash
cd example && flutter create --platforms=web,android,ios --project-name seakim_example --org com.seakim .
```

## Why the generated token outputs ARE mirrored

They were removed once, on the theory that a file absent from the project cannot be
hand-edited there. That backfired, and the reasoning is worth keeping.

The design agent cannot run `node`. When it needs a token change to be real, editing the
output is the only move available to it — so removing the outputs did not remove the
temptation, it manufactured one: the files read as *missing*, and the next session
regenerated both by hand, reintroducing precisely the drift the removal was meant to
prevent. A missing file is a visible prompt; a note in a document is not.

So all five outputs are mirrored, and the rule lives where the agent actually reads its
instructions — the `## Generated files` section of [`SKILL.md`](../SKILL.md), which is the
project's brief rather than a document it may or may not open.

| Output | Source |
| --- | --- |
| `tokens/colors.css`, `tokens/theme-light.css`, `tokens/apps.css` | `tokens/src/color.tokens.json` |
| `tokens/generated/colors.ts` | same |
| `flutter/lib/src/tokens/palette.g.dart` | same |

`node tool/build-tokens.mjs --check` exits non-zero when any of them is stale against the
source, and CI runs it — so drift is caught, just after the fact rather than prevented.

`lib/src/tokens/sk_icons.g.dart` stays out: at ~790 KB it is past the read cap and nothing
in the project would consume it anyway.

Everything hand-written **is** mirrored — the generator, the `SkGlyph` type it
targets, `SkMaterialTheme`, every widget, the tests, and `example/lib/main.dart`
— so the contract is visible even where the artefacts are not.
