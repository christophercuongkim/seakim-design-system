import 'package:flutter/foundation.dart';

/// Registers the licences of the third-party assets this package bundles.
///
/// [SkApp] calls this, so every SeaKim app satisfies the attribution terms
/// without each team remembering to. The entries surface through Flutter's
/// standard `showLicensePage()` / `AboutDialog`.
///
/// Bundling a font means shipping its licence: MIT and the SIL OFL both require
/// the notice to travel with any copy, including a compiled app binary. Neither
/// requires the app itself to be open source.
void registerSkLicenses() {
  if (_registered) return;
  _registered = true;

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      <String>['seakim_flutter', 'Phosphor Icons'],
      _phosphorMit,
    );
  });
}

bool _registered = false;

/// Verbatim copy of `assets/icons/LICENSE-phosphor.txt`. Kept inline rather than
/// loaded from the asset bundle so registration cannot fail silently at runtime;
/// if the bundled font is ever updated, update both.
const String _phosphorMit = '''
MIT License

Copyright (c) 2020-2021 Phosphor Icons

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';

// TODO(fonts): when the Outfit / Plus Jakarta Sans / IBM Plex Mono binaries are
// committed to assets/fonts/, add their SIL OFL 1.1 notices here too. The OFL
// carries terms the MIT does not — the fonts may not be sold on their own, and
// the reserved font names may not be reused on a modified copy — so the notice
// has to ship with the app the same way this one does.
