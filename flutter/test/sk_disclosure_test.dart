import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: SizedBox(width: 320, child: child)),
    );

void main() {
  group('SkDisclosure', () {
    testWidgets('starts closed, opens on tap, reports the toggle',
        (WidgetTester t) async {
      bool? reported;
      await t.pumpWidget(host(SkDisclosure(
        summary: const Text('Fare breakdown'),
        meta: const Text('4 items'),
        onToggle: (bool v) => reported = v,
        child: const Text('Base fare 312'),
      )));
      await t.pumpAndSettle();

      expect(find.text('4 items'), findsOneWidget);
      expect(t.getSize(find.byType(AnimatedSize)).height, 0);

      await t.tap(find.text('Fare breakdown'));
      await t.pumpAndSettle();
      expect(reported, isTrue);
      expect(t.getSize(find.byType(AnimatedSize)).height, greaterThan(0));
      expect(find.text('Base fare 312'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('controlled: isOpen wins and the tap only reports',
        (WidgetTester t) async {
      bool? reported;
      await t.pumpWidget(host(SkDisclosure(
        summary: const Text('Cancellation'),
        isOpen: false,
        onToggle: (bool v) => reported = v,
        child: const Text('Free until 12 Mar'),
      )));
      await t.pumpAndSettle();
      await t.tap(find.text('Cancellation'));
      await t.pumpAndSettle();
      expect(reported, isTrue);
      expect(t.getSize(find.byType(AnimatedSize)).height, 0);
    });
  });
}
