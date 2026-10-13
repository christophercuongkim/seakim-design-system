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
  testWidgets(
      'SkMeter fills the fraction, shows the value text, announces both',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(
        host(const SkMeter(label: 'Skills', value: 0.84, valueText: '84')));
    await t.pump();
    final FractionallySizedBox fill =
        t.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fill.widthFactor, closeTo(0.84, 0.001));
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('84'), findsOneWidget);
    expect(t.getSemantics(find.bySemanticsLabel('Skills')).value, '84');
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(t.takeException(), isNull);
    handle.dispose();
  });
}
