import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, height: 600, child: child)),
      ),
    );

void main() {
  testWidgets('brand above a column no wider than width, footer at the bottom',
      (WidgetTester t) async {
    await t.pumpWidget(host(
      SkGateLayout(
        brand: const Text('Voyage'),
        footer: const Text('Legal line'),
        child: SkButton(label: 'Continue with email', onPressed: () {}),
      ),
      700,
    ));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(SkButton)).width, lessThanOrEqualTo(576));
    expect(t.getTopLeft(find.text('Voyage')).dy,
        lessThan(t.getTopLeft(find.byType(SkButton)).dy));
    expect(t.getBottomLeft(find.text('Legal line')).dy, greaterThan(500));
    expect(t.takeException(), isNull);
  });

  testWidgets('full-bleed at sm, and the column is a card when asked',
      (WidgetTester t) async {
    await t.pumpWidget(host(
      SkGateLayout(card: true, child: SkButton(label: 'Go', onPressed: () {})),
      360,
    ));
    await t.pumpAndSettle();
    expect(find.byType(SkCard), findsOneWidget);
    expect(t.getSize(find.byType(SkCard)).width, 360 - 2 * SkSpace.s5);
    expect(t.takeException(), isNull);
  });
}
