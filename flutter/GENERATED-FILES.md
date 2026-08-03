# Files not mirrored into Claude Design

The Claude Design project carries this port's **sources**, not its build output.
Three things are deliberately absent there and live only in the git repo
(github.com/christophercuongkim/seakim-design-system):

| Missing from the design project | Size | Why |
| --- | --- | --- |
| `lib/src/tokens/sk_icons.g.dart` | ~772 KB | Generated. Reproduce it, never edit it. |
| `tool/phosphor_codepoints.json` | ~186 KB | Extracted input to the generator. |
| `assets/icons/Phosphor-*.ttf` | ~2 MB | Font binaries; four files. |

To get a working checkout from the design project alone you need the fonts and
one command:

```bash
dart run tool/gen_icons.dart      # writes lib/src/tokens/sk_icons.g.dart
```

Without the `.g.dart`, `SkIcons` is undefined and nothing that draws an icon
compiles. Without the `.ttf` files, it compiles but every glyph renders as tofu.

The generator, its documentation, and the hand-written `SkGlyph` type it targets
(`lib/src/tokens/sk_glyph.dart`) **are** mirrored — so the contract is visible
even where the artefacts are not.

The same rule already applied to the text fonts: `pubspec.yaml` declares ten
`.ttf` files under `assets/fonts/` that are committed nowhere, for licensing
reasons. See the README.
