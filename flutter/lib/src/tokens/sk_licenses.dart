import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Every third-party licence this package is obliged to ship.
///
/// Key is the name shown in `showLicensePage()`; value is the bundled file.
/// Asset paths carry the `packages/<name>/` prefix so they resolve from a
/// consuming app, not just from this repo.
const Map<String, String> _bundledLicences = <String, String>{
  // Icon font. MIT: permissive, but the notice must travel with the binary.
  'Phosphor Icons': 'packages/seakim_flutter/assets/icons/LICENSE-phosphor.txt',
  // Text fonts. SIL OFL 1.1: the notice must ship, the fonts may not be sold on
  // their own, and the reserved names may not be reused on a modified copy.
  'Outfit': 'packages/seakim_flutter/assets/fonts/OFL-Outfit.txt',
  'Plus Jakarta Sans':
      'packages/seakim_flutter/assets/fonts/OFL-PlusJakartaSans.txt',
  'IBM Plex Mono': 'packages/seakim_flutter/assets/fonts/OFL-IBMPlexMono.txt',
};

/// Registers the licences of the fonts this package bundles.
///
/// [SkApp] calls this, and so does [SkMaterialTheme]'s scope, so every SeaKim
/// app satisfies the attribution terms without each team remembering to. The
/// entries surface through Flutter's standard `showLicensePage()` /
/// `AboutDialog`.
///
/// Bundling a font means shipping its licence. Neither MIT nor the OFL requires
/// the app itself to be open source — both require the notice to be present.
///
/// Idempotent: safe to call from a `build` method.
void registerSkLicenses() {
  if (_registered) return;
  _registered = true;

  LicenseRegistry.addLicense(() async* {
    for (final MapEntry<String, String> e in _bundledLicences.entries) {
      // Read from the bundle rather than inlining ~13 KB of licence text in
      // Dart. `sk_licenses_test.dart` asserts every entry actually loads, so a
      // missing or renamed asset fails a test instead of silently shipping an
      // app with no notice.
      final String text = await rootBundle.loadString(e.value);
      yield LicenseEntryWithLineBreaks(
        <String>['seakim_flutter', e.key],
        text,
      );
    }
  });
}

bool _registered = false;

/// The licence assets, for tests and for callers that want to render them
/// somewhere other than `showLicensePage()`.
@visibleForTesting
Map<String, String> get skLicenseAssets => Map<String, String>.unmodifiable(_bundledLicences);
