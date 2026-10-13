import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Center(child: SizedBox(width: width, height: 400, child: child)),
      ),
    );

List<SkBoardColumn> columns() => <SkBoardColumn>[
      const SkBoardColumn(
        label: 'Pursuing',
        count: 1,
        children: <Widget>[SkCard(title: 'Senior frontend engineer')],
      ),
      const SkBoardColumn(label: 'Applied', count: 0),
      const SkBoardColumn(label: 'Offer', count: 0),
    ];

void main() {
  testWidgets('wide with collapseEmpty off: every column at full width',
      (WidgetTester t) async {
    await t.pumpWidget(host(
        SkBoard(columns: columns(), collapseEmpty: false, columnWidth: 200),
        900));
    await t.pumpAndSettle();
    expect(find.text('PURSUING'), findsOneWidget);
    expect(find.text('APPLIED'), findsOneWidget);
    expect(find.text('OFFER'), findsOneWidget);
    expect(find.byType(SkPressable), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('the default folds the empties into buttons that expand',
      (WidgetTester t) async {
    await t
        .pumpWidget(host(SkBoard(columns: columns(), columnWidth: 200), 900));
    await t.pumpAndSettle();
    expect(find.byType(SkPressable), findsNWidgets(2));
    await t.tap(find.byType(SkPressable).first);
    await t.pumpAndSettle();
    expect(find.byType(SkPressable), findsNWidgets(1));
    expect(t.takeException(), isNull);
  });

  testWidgets('sm: a tabs row over a page view, no collapse',
      (WidgetTester t) async {
    await t.pumpWidget(host(SkBoard(columns: columns()), 360));
    await t.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(SkTabs<int>), findsOneWidget);
    expect(find.text('Applied'), findsOneWidget);
    expect(find.text('PURSUING'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
