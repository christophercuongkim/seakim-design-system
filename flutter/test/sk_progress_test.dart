import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: SizedBox(width: 300, child: child)),
    );

void main() {
  group('SkProgress', () {
    testWidgets('fills the fraction of its track and announces the value',
        (WidgetTester t) async {
      final SemanticsHandle handle = t.ensureSemantics();
      await t.pumpWidget(
          host(const SkProgress(value: 4, max: 13, label: '4 of 13')));
      await t.pumpAndSettle();

      final FractionallySizedBox fill =
          t.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fill.widthFactor, closeTo(4 / 13, 0.001));
      expect(find.text('4 of 13'), findsOneWidget);
      expect(
        t.getSemantics(find.bySemanticsLabel('4 of 13')).value,
        '31%',
      );
      expect(t.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('clamps out-of-range values', (WidgetTester t) async {
      await t
          .pumpWidget(host(const SkProgress(value: 140, semanticLabel: 'x')));
      await t.pumpAndSettle();
      final FractionallySizedBox fill =
          t.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fill.widthFactor, 1.0);
    });
  });
}
