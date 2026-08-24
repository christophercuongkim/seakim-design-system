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
  // SkErrorState (0029): a distinct error treatment — retry as the default
  // affordance, a navigational escape for terminal errors, an assertive alert.

  testWidgets('renders the failure and a default retry that fires onRetry',
      (WidgetTester tester) async {
    int retried = 0;
    await tester.pumpWidget(_host(SkErrorState(
      title: "Couldn't load places",
      description: 'Check your connection and try again.',
      onRetry: () => retried++,
    )));
    await tester.pump();

    expect(find.text("Couldn't load places"), findsOneWidget);
    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(retried, 1);
  });

  testWidgets('a terminal error swaps retry for a navigational escape',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(SkErrorState(
      title: "You don't have access",
      // A terminal 403 — retrying fails identically, so escape instead.
      action: SkButton(label: 'Go back', onPressed: () {}),
      onRetry: () {}, // ignored when action is supplied
    )));
    await tester.pump();

    expect(find.text('Go back'), findsOneWidget);
    expect(find.text('Try again'), findsNothing); // action wins over the default
  });

  testWidgets('is an announced live region, and carries no dashed border',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const SkErrorState(title: 'It failed')));
    await tester.pump();

    // The frame is the shared centred one, not the empty state's dashed border —
    // SkErrorState pulls in no CustomPaint of its own.
    expect(
      find.descendant(
          of: find.byType(SkErrorState), matching: find.byType(CustomPaint)),
      findsNothing,
    );
    // A live region carrying the title.
    final SemanticsHandle handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(SkErrorState)).label,
      contains('It failed'),
    );
    handle.dispose();
  });
}
