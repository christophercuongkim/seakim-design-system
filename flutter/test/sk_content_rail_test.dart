import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: 600, child: child),
        ),
      ),
    );

Widget rail({bool railBelow = true}) => SkContentRail(
      railBelow: railBelow,
      content: const SizedBox(height: 200, child: Text('CONTENT')),
      rail: const <Widget>[Text('BALANCE'), Text('PLAN')],
    );

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding b = TestWidgetsFlutterBinding.instance;
    b.platformDispatcher.views.first.physicalSize = const Size(1400, 900);
    b.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() => TestWidgetsFlutterBinding
      .instance.platformDispatcher.views.first
      .resetPhysicalSize());

  group('SkContentRail', () {
    testWidgets('lg puts the rail beside the content, 300 wide',
        (WidgetTester t) async {
      await t.pumpWidget(host(rail(), 1200));
      final Offset content = t.getTopLeft(find.text('CONTENT'));
      final Offset balance = t.getTopLeft(find.text('BALANCE'));
      expect(balance.dx, greaterThan(content.dx + 800));
      expect(balance.dy, lessThan(content.dy + 100));
      final Size column = t.getSize(find
          .ancestor(of: find.text('BALANCE'), matching: find.byType(SizedBox))
          .first);
      expect(column.width, 300);
    });

    testWidgets('md with railBelow stacks the rail under the content',
        (WidgetTester t) async {
      await t.pumpWidget(host(rail(), 800));
      final Offset content = t.getTopLeft(find.text('CONTENT'));
      final Offset balance = t.getTopLeft(find.text('BALANCE'));
      final Offset plan = t.getTopLeft(find.text('PLAN'));
      expect(balance.dy, greaterThanOrEqualTo(content.dy + 200));
      expect(plan.dy, greaterThan(balance.dy));
      expect(balance.dx, lessThan(content.dx + 50));
    });

    testWidgets('sm with railBelow false hides the rail',
        (WidgetTester t) async {
      await t.pumpWidget(host(rail(railBelow: false), 360));
      expect(find.text('CONTENT'), findsOneWidget);
      expect(find.text('BALANCE'), findsNothing);

      await t.pumpWidget(host(rail(railBelow: false), 1200));
      expect(find.text('BALANCE'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });
}
