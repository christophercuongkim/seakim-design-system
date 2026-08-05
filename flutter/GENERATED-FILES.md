# Files not mirrored into Claude Design

The Claude Design project carries this port's **sources**, not its build output,
its binaries, or anything a tool regenerates. Those live only in the git repo
(github.com/christophercuongkim/seakim-design-system):

| Missing from the design project | Size | Why |
| --- | --- | --- |
| `lib/src/tokens/sk_icons.g.dart` | ~790 KB | Generated. Reproduce it, never edit it. |
| `lib/src/tokens/palette.g.dart` | ~6 KB | Generated from `tokens/src/`. See the note below. |
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

## Why the generated token outputs are split

`tool/build-tokens.mjs` emits five files from `tokens/src/color.tokens.json`. Two of them
are **not** mirrored into the design project and two more sit outside this folder:

| Output | Mirrored? | Why |
| --- | --- | --- |
| `tokens/colors.css`, `tokens/theme-light.css`, `tokens/apps.css` | **Yes** | `styles.css` `@import`s them, so every rendered preview in the design tool needs them present. |
| `flutter/lib/src/tokens/palette.g.dart` | No | Dart. Nothing in the design project consumes it. |
| `tokens/generated/colors.ts` | No | TypeScript. Same. |

The split exists because hand-editing a generated file has already caused two silent
regressions — a lost chart-token stage, and the house accent reverting from crimson to
orange because `tokens/src/` still said `clay: 55` while every output said `brick: 8`.
Both files carried a `DO NOT EDIT` header at the time. The header did not help.

Removing an output from the mirror removes the temptation structurally. The three CSS
files cannot be removed without breaking rendering, so for those the rule stands and CI is
the backstop: `node tool/build-tokens.mjs --check` exits non-zero when any output is stale
against the source.

**To change a colour:** edit `tokens/src/color.tokens.json`, then have someone run
`node tool/build-tokens.mjs` on the repo side. Editing `colors.css` directly will be
reverted by the next regeneration, silently.

Everything hand-written **is** mirrored — the generator, the `SkGlyph` type it
targets, `SkMaterialTheme`, every widget, the tests, and `example/lib/main.dart`
— so the contract is visible even where the artefacts are not.
