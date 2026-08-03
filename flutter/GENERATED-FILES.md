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
| `example/web/`, `example/.metadata`, `example/analysis_options.yaml` | — | `flutter create` scaffolding. |

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
cd example && flutter create --platforms=web --project-name seakim_example .
```

Everything hand-written **is** mirrored — the generator, the `SkGlyph` type it
targets, `SkMaterialTheme`, every widget, the tests, and `example/lib/main.dart`
— so the contract is visible even where the artefacts are not.
