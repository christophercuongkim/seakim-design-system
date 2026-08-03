# seakim_example

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running it

```bash
flutter run -d chrome     # or -d linux
flutter build web --release
```

The app-bar grid icon opens **the Material coverage gallery** — every Material
widget the theme claims to brand, on one screen, with no SeaKim widgets in it.
Anything there that still looks like stock Material (rounded corners, a pill
selection indicator, an ink ripple) is a gap in `SkMaterialTheme`. Scan it in
both light and dark after changing the theme.

## Android builds on NixOS

`flutter build apk` fails here, and not because of this project: Gradle's
`includeBuild` needs a writable Flutter SDK directory, and the nixpkgs Flutter
lives in the read-only Nix store.

```
Configuring project ':' without an existing directory is not allowed.
'/nix/store/…-flutter-wrapped-…/packages/flutter_tools/gradle' does not exist,
can't be written to or is not a directory.
```

The `android/` scaffolding is correct and unmodified; build it from a normal
(non-Nix) Flutter install or CI. `ios/` is scaffolded but has never been built —
that needs macOS.
