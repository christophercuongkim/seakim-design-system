import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: child),
    );

Widget _opener() => Builder(
      builder: (BuildContext ctx) => Center(
        child: TextButton(
          onPressed: () => showSkSheet<void>(
            context: ctx,
            builder: (_) => const Text('SHEET BODY'),
          ),
          child: const Text('open'),
        ),
      ),
    );

void main() {
  testWidgets('wide viewport wraps sheet content in a surface panel',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_opener()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('SHEET BODY'), findsOneWidget);
    // The content sits inside the panel wrapper (maxWidth 460), not bare.
    expect(
      find.ancestor(
        of: find.text('SHEET BODY'),
        matching: find.byWidgetPredicate(
          (Widget w) => w is ConstrainedBox && w.constraints.maxWidth == 460,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('narrow viewport uses the bottom sheet, no dialog panel',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_opener()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('SHEET BODY'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is ConstrainedBox && w.constraints.maxWidth == 460,
      ),
      findsNothing,
    );
  });
}
