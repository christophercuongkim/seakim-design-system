import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets(
      'a short toast fills to its max width and anchors the dismiss to the '
      'trailing edge', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      SkToast(message: 'Saved', onDismiss: () {}),
    ));
    await tester.pumpAndSettle();

    // The message is Expanded, so the panel fills to its 420 max instead of
    // shrinking to the message and leaving the min-width slack after the
    // dismiss (the mid-panel float this fixes).
    expect(tester.getSize(find.byType(SkToast)).width, 420);

    // The dismiss sits at the trailing edge — only the panel's right padding
    // (SkSpace.s4) is between it and the panel edge.
    final Finder dismiss = find.byWidgetPredicate(
        (Widget w) => w is SkIconButton && w.label == 'Dismiss');
    final double panelRight = tester.getBottomRight(find.byType(SkToast)).dx;
    final double dismissRight = tester.getBottomRight(dismiss).dx;
    expect(panelRight - dismissRight, closeTo(SkSpace.s4, 1));
  });
}
