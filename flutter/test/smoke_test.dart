import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

void main() {
  testWidgets('SkButton renders inside SkApp, exposes tokens, and taps',
      (WidgetTester tester) async {
    var taps = 0;

    await tester.pumpWidget(
      SkApp(
        brand: SkAppBrand.voyage,
        mode: SkThemeMode.dark,
        child: Builder(
          builder: (BuildContext context) {
            // Proves the token InheritedWidget resolves from context.
            final SkColors c = context.skColors;
            expect(c.textPrimary, isA<Color>());
            return Center(
              child: SkButton(
                label: 'Book trip',
                iconLeft: SkIcons.mapPin, // exercises the SkGlyph path
                onPressed: () => taps++,
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Book trip'), findsOneWidget);

    await tester.tap(find.text('Book trip'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('every icon weight renders, duotone as a layered pair',
      (WidgetTester tester) async {
    for (final SkIconWeight weight in SkIconWeight.values) {
      await tester.pumpWidget(
        SkApp(
          child: Center(child: SkIcon(SkIcons.tray, weight: weight)),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'weight $weight threw');

      // Duotone stacks a knocked-back backdrop under the line layer; the other
      // weights are a single glyph.
      expect(
        find.byType(Icon),
        weight == SkIconWeight.duotone ? findsNWidgets(2) : findsOneWidget,
        reason: 'unexpected glyph count for $weight',
      );
    }
  });

  test('bundled font licences are registered for showLicensePage', () async {
    registerSkLicenses();
    final List<LicenseEntry> entries = await LicenseRegistry.licenses.toList();
    expect(
      entries.any((LicenseEntry e) => e.packages.contains('Phosphor Icons')),
      isTrue,
      reason: 'the MIT notice for the bundled icon font must ship with the app',
    );
  });
}
