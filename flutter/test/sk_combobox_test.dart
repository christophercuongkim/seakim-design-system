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

const List<SkComboboxOption<String>> _currencies = <SkComboboxOption<String>>[
  SkComboboxOption<String>(value: 'usd', label: 'US Dollar'),
  SkComboboxOption<String>(value: 'eur', label: 'Euro'),
  SkComboboxOption<String>(value: 'gbp', label: 'British Pound'),
  SkComboboxOption<String>(value: 'jpy', label: 'Japanese Yen'),
];

// 'port' prefix-matches Portugal (tier 200) and substring-matches supPORT
// (tier 100), so the ranked order must put Portugal first.
const List<SkComboboxOption<String>> _rankOpts = <SkComboboxOption<String>>[
  SkComboboxOption<String>(value: 'sup', label: 'Support'),
  SkComboboxOption<String>(value: 'pt', label: 'Portugal'),
  SkComboboxOption<String>(value: 'br', label: 'Brazil'),
];

Widget _harness(
  List<SkComboboxOption<String>> opts, {
  ValueChanged<String>? onChanged,
}) =>
    _host(StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) =>
          SkCombobox<String>(
        options: opts,
        value: null,
        placeholder: 'Currency',
        onChanged: onChanged ?? (_) {},
      ),
    ));

void main() {
  testWidgets('opens on tap and shows the filter input',
      (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_currencies));

    expect(find.text('Euro'), findsNothing); // closed
    expect(find.byType(EditableText), findsNothing);

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    // Filter input is present and all options render.
    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
  });

  testWidgets('empty query shows every option', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_currencies));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    for (final SkComboboxOption<String> o in _currencies) {
      expect(find.text(o.label), findsOneWidget);
    }
  });

  testWidgets('typing filters and ranks prefix above substring',
      (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_rankOpts));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'port');
    await tester.pumpAndSettle();

    // Brazil filtered out; Portugal (prefix) and Support (substring) remain.
    expect(find.text('Brazil'), findsNothing);
    expect(find.text('Portugal'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);

    // Prefix ranks above substring: Portugal sits above Support.
    final double portugalY = tester.getTopLeft(find.text('Portugal')).dy;
    final double supportY = tester.getTopLeft(find.text('Support')).dy;
    expect(portugalY, lessThan(supportY));
  });

  testWidgets('picking a filtered option fires onChanged and closes',
      (WidgetTester tester) async {
    String? picked;
    await tester
        .pumpWidget(_harness(_currencies, onChanged: (String v) => picked = v));

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'euro');
    await tester.pumpAndSettle();
    expect(find.text('US Dollar'), findsNothing); // filtered away

    await tester.tap(find.text('Euro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(picked, 'eur'); // onChanged fired
    expect(find.byType(EditableText), findsNothing); // popover closed
  });

  testWidgets('a no-match query shows the empty state with a Clear affordance',
      (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_currencies));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No options match "zzz"'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('US Dollar'), findsNothing);

    // Clearing restores the full list.
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('No options match "zzz"'), findsNothing);
    expect(find.text('US Dollar'), findsOneWidget);
  });

  testWidgets('Escape closes the open popover', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_currencies));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('outside-press closes the open popover',
      (WidgetTester tester) async {
    await tester.pumpWidget(_harness(_currencies));
    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('arrow keys move the active option and Enter selects it',
      (WidgetTester tester) async {
    String? picked;
    await tester
        .pumpWidget(_harness(_currencies, onChanged: (String v) => picked = v));

    await tester.tap(find.text('Currency'));
    await tester.pumpAndSettle();

    // Active starts at index 0 (US Dollar). Down moves to Euro; Enter picks it.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(picked, 'eur');
    expect(find.byType(EditableText), findsNothing); // closed
  });
}
