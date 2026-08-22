import 'package:flutter/gestures.dart';
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
  // SkHoverLabel now rides SkPopover (0022), barrier-less + undecorated. These
  // prove the tooltip still shows on hover, hides on exit, and pins each side.

  testWidgets('shows on hover and hides on exit', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      SkTooltip(label: 'Add leg', child: const SizedBox(width: 80, height: 40)),
    ));
    expect(find.text('Add leg'), findsNothing);

    final TestGesture g =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await g.addPointer(location: Offset.zero);
    addTearDown(g.removePointer);

    await g.moveTo(tester.getCenter(find.byType(SizedBox).first));
    await tester.pumpAndSettle();
    expect(find.text('Add leg'), findsOneWidget); // tooltip up

    await g.moveTo(const Offset(0, 0));
    await tester.pumpAndSettle();
    expect(find.text('Add leg'), findsNothing); // hidden on exit
  });

  testWidgets('the tooltip content is pointer-inert', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      SkTooltip(label: 'Saved', child: const SizedBox(width: 80, height: 40)),
    ));
    final TestGesture g =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await g.addPointer(location: Offset.zero);
    addTearDown(g.removePointer);
    await g.moveTo(tester.getCenter(find.byType(SizedBox).first));
    await tester.pumpAndSettle();

    // The label sits inside an IgnorePointer so it never eats the host's events.
    expect(find.text('Saved'), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(IgnorePointer), matching: find.text('Saved')),
      findsOneWidget,
    );
  });

  for (final AxisDirection side in AxisDirection.values) {
    testWidgets('pins to $side without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        SkTooltip(
            label: 'Tip',
            side: side,
            child: const SizedBox(width: 80, height: 40)),
      ));
      final TestGesture g =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await g.addPointer(location: Offset.zero);
      addTearDown(g.removePointer);
      await g.moveTo(tester.getCenter(find.byType(SizedBox).first));
      await tester.pumpAndSettle();
      expect(find.text('Tip'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
