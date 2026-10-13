import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: SizedBox(width: width, child: child))),
    );

const List<SkStep> _steps = <SkStep>[
  SkStep(key: 'applied', label: 'Applied'),
  SkStep(key: 'recruiter', label: 'Recruiter screen'),
  SkStep(key: 'onsite', label: 'Onsite'),
];

void main() {
  testWidgets('announces done and current, lays out horizontally from md',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(
        host(const SkStepper(steps: _steps, current: 'recruiter'), 700));
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('Applied, completed'), findsOneWidget);
    expect(find.bySemanticsLabel('Recruiter screen, current step'),
        findsOneWidget);
    expect(find.bySemanticsLabel('Onsite'), findsOneWidget);
    final double y1 = t.getTopLeft(find.text('Applied')).dy;
    final double y3 = t.getTopLeft(find.text('Onsite')).dy;
    expect((y1 - y3).abs(), lessThan(1));
    handle.dispose();
  });

  testWidgets('goes vertical under md and steps are buttons with onSelect',
      (WidgetTester t) async {
    String? picked;
    await t.pumpWidget(host(
      SkStepper(
          steps: _steps,
          current: 'recruiter',
          onSelect: (String k) => picked = k),
      360,
    ));
    await t.pumpAndSettle();
    final double y1 = t.getTopLeft(find.text('Applied')).dy;
    final double y3 = t.getTopLeft(find.text('Onsite')).dy;
    expect(y3, greaterThan(y1 + 20));
    await t.tap(find.text('Onsite'));
    await t.pumpAndSettle();
    expect(picked, 'onsite');
    expect(t.takeException(), isNull);
  });
}
