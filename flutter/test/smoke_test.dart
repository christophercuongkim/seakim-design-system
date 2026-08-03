import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
                iconLeft: PhosphorIcons.mapPin, // exercises the SkGlyph path
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
}
