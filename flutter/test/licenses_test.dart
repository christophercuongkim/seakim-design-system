import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// Bundling a font means shipping its licence. These notices are loaded from the
/// asset bundle rather than inlined, which is only safe if a missing or renamed
/// asset fails here instead of silently shipping an app with no attribution.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled licence asset exists and is non-empty', () async {
    expect(skLicenseAssets, isNotEmpty);
    for (final MapEntry<String, String> e in skLicenseAssets.entries) {
      final String text = await rootBundle.loadString(e.value);
      expect(text.trim(), isNotEmpty, reason: '${e.key} licence is empty');
      expect(text, contains('Copyright'), reason: '${e.key} lacks a copyright line');
    }
  });

  test('all four notices reach LicenseRegistry for showLicensePage', () async {
    registerSkLicenses();
    final List<LicenseEntry> entries = await LicenseRegistry.licenses.toList();
    final Set<String> packages = entries
        .expand((LicenseEntry e) => e.packages)
        .toSet();

    for (final String name in skLicenseAssets.keys) {
      expect(packages, contains(name),
          reason: '$name must appear in showLicensePage()');
    }
  });

  test('the OFL notices carry their reserved-name terms', () async {
    // The OFL is not MIT: it also reserves the font names and forbids selling
    // the fonts on their own. Shipping the text is what keeps that binding.
    for (final String key in <String>['Outfit', 'Plus Jakarta Sans', 'IBM Plex Mono']) {
      final String text = await rootBundle.loadString(skLicenseAssets[key]!);
      expect(text, contains('SIL OPEN FONT LICENSE'), reason: '$key is OFL');
    }
  });
}
