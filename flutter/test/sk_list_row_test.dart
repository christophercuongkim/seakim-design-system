import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: SizedBox(width: 360, child: child)),
    );

void main() {
  testWidgets('a pressable row fires and a selected row announces selected',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    int presses = 0;
    await t.pumpWidget(host(SkListGroup(
      heading: 'Today',
      children: <Widget>[
        SkListRow(
          eyebrow: const Text('Northwind Labs'),
          title: const Text('Senior frontend engineer'),
          meta: const Text('Remote'),
          trailing: const Text('2h'),
          selected: true,
          onPressed: () => presses++,
        ),
        const SkListRow(title: Text('Sign out')),
      ],
    )));
    await t.pumpAndSettle();

    expect(find.text('TODAY'), findsOneWidget);
    await t.tap(find.text('Senior frontend engineer'));
    await t.pumpAndSettle();
    expect(presses, 1);
    expect(
      t.getSemantics(find.byType(SkListRow).first),
      containsSemantics(isSelected: true),
    );
    expect(find.byType(SkListRow), findsNWidgets(2));
    expect(t.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('a one-line row is at least the touch floor on a coarse pointer',
      (WidgetTester t) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await t.pumpWidget(host(const SkListRow(title: Text('Appearance'))));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(SkListRow)).height,
        greaterThanOrEqualTo(SkControl.touch));
    debugDefaultTargetPlatformOverride = null;
  });
}
