import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: child),
    );

const List<SkNavGroup<int>> _groups = <SkNavGroup<int>>[
  SkNavGroup<int>(items: <SkNavItem<int>>[
    SkNavItem<int>(value: 0, label: 'Trips', icon: SkIcons.mapTrifold),
    SkNavItem<int>(value: 1, label: 'Groups', icon: SkIcons.usersThree),
  ]),
];

void main() {
  testWidgets('collapsed rail hides labels but gives each item a tooltip',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const SkSideNav<int>(active: 0, groups: _groups, collapsed: true),
    ));

    expect(find.byType(SkTooltip), findsNWidgets(2));
    expect(find.text('Trips'), findsNothing);
  });

  testWidgets('expanded rail shows labels and no tooltip',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const SkSideNav<int>(active: 0, groups: _groups),
    ));

    expect(find.text('Trips'), findsOneWidget);
    expect(find.byType(SkTooltip), findsNothing);
  });

  testWidgets(
      'a widget brand shows expanded and its collapsed mark on the rail',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const SkSideNav<int>(
        active: 0,
        groups: _groups,
        brandWidget: Text('Lisbon trip'),
        brandCollapsed: Text('L'),
      ),
    ));
    expect(find.text('Lisbon trip'), findsOneWidget);
    expect(
        tester
            .getSize(find
                .ancestor(
                    of: find.text('Lisbon trip'),
                    matching: find.byType(Container))
                .first)
            .height,
        SkChrome.topBar);

    await tester.pumpWidget(_host(
      const SkSideNav<int>(
        active: 0,
        groups: _groups,
        collapsed: true,
        brandWidget: Text('Lisbon trip'),
        brandCollapsed: Text('L'),
      ),
    ));
    expect(find.text('Lisbon trip'), findsNothing);
    expect(find.text('L'), findsOneWidget);
  });

  testWidgets('a widget brand without brandCollapsed collapses to nothing',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const SkSideNav<int>(
          active: 0,
          groups: _groups,
          collapsed: true,
          brandWidget: Text('Lisbon trip')),
    ));
    expect(find.text('Lisbon trip'), findsNothing);
    expect(find.text('L'), findsNothing);

    await tester.pumpWidget(_host(
      const SkSideNav<int>(
          active: 0, groups: _groups, collapsed: true, brand: 'Juntio'),
    ));
    expect(find.text('J'), findsOneWidget);
  });

  test('brand and brandWidget cannot both be set', () {
    expect(
      () => SkSideNav<int>(
          active: 0, groups: _groups, brand: 'A', brandWidget: Text('B')),
      throwsAssertionError,
    );
  });
}
