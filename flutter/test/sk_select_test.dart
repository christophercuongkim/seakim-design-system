import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: child)),
    );

const List<SkSelectOption<String>> _opts = <SkSelectOption<String>>[
  SkSelectOption<String>(value: 'lis', label: 'Lisbon'),
  SkSelectOption<String>(value: 'osl', label: 'Oslo'),
  SkSelectOption<String>(value: 'tyo', label: 'Tokyo'),
];

void main() {
  // SkSelect now rides SkPopover (0022). These prove the anchored menu still
  // opens, picks, and dismisses through the primitive.

  testWidgets('opens on tap and picks an option', (WidgetTester tester) async {
    String? picked;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => SkSelect<String>(
        options: _opts,
        value: picked,
        placeholder: 'Where to?',
        onChanged: (String v) => setState(() => picked = v),
      ),
    )));

    // Closed: the options are not in the tree.
    expect(find.text('Oslo'), findsNothing);

    await tester.tap(find.text('Where to?'));
    await tester.pumpAndSettle();
    expect(find.text('Oslo'), findsOneWidget); // menu open

    await tester.tap(find.text('Oslo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(picked, 'osl'); // onChanged fired
    // Menu closed: Tokyo (only ever in the menu) is gone. Oslo now shows in the
    // trigger, so it stays present — assert on an unselected option instead.
    expect(find.text('Tokyo'), findsNothing);
    expect(find.text('Oslo'), findsOneWidget); // the trigger's selected label
  });

  testWidgets('outside-press dismisses the open menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(SkSelect<String>(
      options: _opts,
      value: null,
      placeholder: 'Where to?',
      onChanged: (_) {},
    )));

    await tester.tap(find.text('Where to?'));
    await tester.pumpAndSettle();
    expect(find.text('Tokyo'), findsOneWidget);

    // Tap the far corner — the full-screen tap-away catcher SkPopover renders.
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tokyo'), findsNothing);
  });

  testWidgets('the closed trigger rings on keyboard focus (the 0028 fix)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(SkSelect<String>(
      options: _opts,
      value: null,
      placeholder: 'Where to?',
      onChanged: (_) {},
    )));
    await tester.pump();

    Border borderNow() {
      final AnimatedContainer box = tester.widget<AnimatedContainer>(
        find
            .descendant(
                of: find.byType(SkSelect<String>),
                matching: find.byType(AnimatedContainer))
            .first,
      );
      return (box.decoration! as BoxDecoration).border! as Border;
    }

    // Closed and unfocused: the plain hairline.
    expect(borderNow().top.width, SkDepth.hairline);

    // Move keyboard focus to the trigger — no tap, so the menu stays closed.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    // The trigger thickens to the 2px inset accent border — the ring the old
    // select only showed while open, and a hand-rolled trigger forgot entirely.
    expect(borderNow().top.width, SkDepth.emphasis);
    expect(find.text('Oslo'), findsNothing); // still closed
  });
}
