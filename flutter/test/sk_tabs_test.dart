import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

List<SkTab<int>> tabs(int n) => <SkTab<int>>[
      for (int i = 0; i < n; i++) SkTab<int>(value: i, label: 'Day ${i + 1}'),
    ];

double widthOf(WidgetTester t, String label) => t
    .getSize(find
        .ancestor(of: find.text(label), matching: find.byType(SkPressable))
        .first)
    .width;

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding b = TestWidgetsFlutterBinding.instance;
    b.platformDispatcher.views.first.physicalSize = const Size(1400, 900);
    b.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() => TestWidgetsFlutterBinding
      .instance.platformDispatcher.views.first
      .resetPhysicalSize());

  group('SkTabs fill', () {
    testWidgets('wide: four tabs share the width equally',
        (WidgetTester t) async {
      await t.pumpWidget(
          host(SkTabs<int>(tabs: tabs(4), value: 0, fill: true), 1200));
      for (int i = 1; i <= 4; i++) {
        expect(widthOf(t, 'Day $i'), 300);
      }
      expect(t.getSize(find.byType(SkTabs<int>)).width, 1200);
      expect(t.takeException(), isNull);
    });

    testWidgets('without fill the tabs keep their natural width',
        (WidgetTester t) async {
      await t.pumpWidget(host(SkTabs<int>(tabs: tabs(4), value: 0), 1200));
      expect(widthOf(t, 'Day 1'), lessThan(300));
    });

    testWidgets('narrow: tabs that do not fit scroll at natural width',
        (WidgetTester t) async {
      await t.pumpWidget(host(SkTabs<int>(tabs: tabs(20), value: 0), 390));
      final double natural = widthOf(t, 'Day 1');
      await t.pumpWidget(
          host(SkTabs<int>(tabs: tabs(20), value: 0, fill: true), 390));
      expect(widthOf(t, 'Day 1'), natural);
      expect(t.getSize(find.byType(SkTabs<int>)).width, 390);
      final ScrollableState s = t.state(find.byType(Scrollable).first);
      expect(s.position.maxScrollExtent, greaterThan(0));
      expect(t.takeException(), isNull);
    });

    testWidgets('an outside value change scrolls the active tab into view',
        (WidgetTester t) async {
      Widget at(int v) =>
          host(SkTabs<int>(tabs: tabs(20), value: v, fill: true), 390);
      await t.pumpWidget(at(0));
      await t.pumpAndSettle();
      expect(t.getRect(find.text('Day 16')).left, greaterThan(390));

      await t.pumpWidget(at(15));
      await t.pumpAndSettle();
      final Rect r = t.getRect(find
          .ancestor(of: find.text('Day 16'), matching: find.byType(SkPressable))
          .first);
      expect(r.left, greaterThanOrEqualTo(0));
      expect(r.right, lessThanOrEqualTo(390));

      // Already visible: the row does not move.
      final double before = t.getRect(find.text('Day 15')).left;
      await t.pumpWidget(at(14));
      await t.pumpAndSettle();
      expect(t.getRect(find.text('Day 15')).left, before);
    });
  });
}
