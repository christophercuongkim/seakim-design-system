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
  testWidgets(
      'brand above a 384 card centred in the height, footer at the bottom',
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
    expect(find.byType(SkCard), findsOneWidget);
    expect(t.getSize(find.byType(SkCard)).width, 384);
    expect(t.getTopLeft(find.text('Voyage')).dy,
        lessThan(t.getTopLeft(find.byType(SkCard)).dy));
    expect(t.getTopLeft(find.byType(SkCard)).dy, greaterThan(150));
    expect(t.getBottomLeft(find.text('Legal line')).dy, greaterThan(500));
    expect(t.takeException(), isNull);
  });

  testWidgets(
      'full-bleed at sm; align top puts a wizard column under the brand',
      (WidgetTester t) async {
    await t.pumpWidget(host(
      SkGateLayout(
        width: 576,
        align: SkGateAlign.top,
        brand: const Text('Voyage'),
        child: SkButton(label: 'Go', onPressed: () {}),
      ),
      360,
    ));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(SkCard)).width, 360 - 2 * SkSpace.s5);
    expect(t.getTopLeft(find.byType(SkCard)).dy, lessThan(120));
    expect(t.takeException(), isNull);
  });
}
