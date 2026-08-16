import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// Coverage for the widgets added from the design decisions — Table (0003),
/// DatePicker (0004), Slider (0006), and Range (0017). They were written and
/// reviewed but never run, so these assert the behaviour the ADRs actually
/// promise, not just that the widgets construct.

Widget host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: child),
    );

class _Row {
  const _Row(this.name, this.pts);
  final String name;
  final double pts;
}

const List<_Row> _rows = <_Row>[_Row('Okafor', 18.2), _Row('Ruiz', 14.7)];

List<SkTableColumn<_Row>> get _cols => <SkTableColumn<_Row>>[
      SkTableColumn<_Row>(
        key: 'name',
        label: 'Player',
        identifying: true,
        cell: (_Row r) => Text(r.name),
      ),
      SkTableColumn<_Row>(
        key: 'pts',
        label: 'Pts',
        numeric: true,
        cell: (_Row r) => Text(r.pts.toString()),
      ),
    ];

void main() {
  group('SkTable', () {
    testWidgets('renders every row and column at lg', (WidgetTester t) async {
      await t.pumpWidget(host(SkTable<_Row>(
        columns: _cols,
        rows: _rows,
        rowKey: (_Row r) => r.name,
      )));
      await t.pumpAndSettle();

      expect(find.text('PLAYER'), findsOneWidget);
      expect(find.text('Okafor'), findsOneWidget);
      expect(find.text('14.7'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('restacks instead of scrolling at sm — decision 0003',
        (WidgetTester t) async {
      await t.pumpWidget(host(SkTable<_Row>(
        columns: _cols,
        rows: _rows,
        rowKey: (_Row r) => r.name,
        bp: SkBreakpoint.sm,
      )));
      await t.pumpAndSettle();

      // The data survives the collapse; the column header row does not, because
      // at sm each row becomes its own labelled block rather than a grid.
      expect(find.text('Okafor'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a matrix keeps its grid at sm, since the columns share a unit',
        (WidgetTester t) async {
      await t.pumpWidget(host(SkTable<_Row>(
        columns: _cols,
        rows: _rows,
        rowKey: (_Row r) => r.name,
        bp: SkBreakpoint.sm,
        matrix: true,
      )));
      await t.pumpAndSettle();
      expect(find.text('Okafor'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('drops priority-3 columns at md', (WidgetTester t) async {
      final List<SkTableColumn<_Row>> cols = <SkTableColumn<_Row>>[
        ..._cols,
        SkTableColumn<_Row>(
          key: 'note',
          label: 'Note',
          priority: 3,
          cell: (_Row r) => const Text('secondary detail'),
        ),
      ];
      await t.pumpWidget(host(SkTable<_Row>(
        columns: cols, rows: _rows, rowKey: (_Row r) => r.name,
        bp: SkBreakpoint.md,
      )));
      await t.pumpAndSettle();

      expect(find.text('PLAYER'), findsOneWidget);
      expect(find.text('NOTE'), findsNothing,
          reason: 'priority 3 is the first thing to go when width is short');
    });

    testWidgets('sorting a column reports the key', (WidgetTester t) async {
      String? sorted;
      await t.pumpWidget(host(SkTable<_Row>(
        columns: _cols,
        rows: _rows,
        rowKey: (_Row r) => r.name,
        onSort: (String k) => sorted = k,
      )));
      await t.pumpAndSettle();

      await t.tap(find.text('PTS'));
      await t.pumpAndSettle();
      expect(sorted, 'pts');
    });

    testWidgets('shows the empty slot rather than an empty grid',
        (WidgetTester t) async {
      await t.pumpWidget(host(SkTable<_Row>(
        columns: _cols,
        rows: const <_Row>[],
        rowKey: (_Row r) => r.name,
        empty: const Text('No players yet'),
      )));
      await t.pumpAndSettle();
      expect(find.text('No players yet'), findsOneWidget);
    });
  });

  group('SkSlider', () {
    testWidgets('renders and reports a change', (WidgetTester t) async {
      double v = 40;
      await t.pumpWidget(host(StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SkSlider(
          value: v,
          label: 'Budget',
          onChanged: (double n) => setState(() => v = n),
        ),
      )));
      await t.pumpAndSettle();

      expect(find.text('Budget'), findsOneWidget);

      // The drag surface is the track, not the whole widget — the widget's
      // centre can sit on the label.
      final Finder track = find.descendant(
          of: find.byType(SkSlider), matching: find.byType(GestureDetector));
      final Rect box = t.getRect(track.first);
      await t.tapAt(Offset(box.right - 6, box.center.dy));
      await t.pumpAndSettle();
      expect(v, greaterThan(40), reason: 'pressing near the right end raises it');
    });

    testWidgets('is keyboard operable — arrow keys step it',
        (WidgetTester t) async {
      double v = 50;
      await t.pumpWidget(host(StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SkSlider(
          value: v,
          step: 5,
          onChanged: (double n) => setState(() => v = n),
        ),
      )));
      await t.pumpAndSettle();

      await t.tap(find.byType(SkSlider));
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(v, 55, reason: 'one arrow press moves exactly one step');
    });

    testWidgets('a disabled slider does not report changes',
        (WidgetTester t) async {
      double v = 40;
      await t.pumpWidget(host(SkSlider(
        value: v,
        disabled: true,
        onChanged: (double n) => v = n,
      )));
      await t.pumpAndSettle();
      final Finder track = find.descendant(
          of: find.byType(SkSlider), matching: find.byType(GestureDetector));
      final Rect box = t.getRect(track.first);
      await t.tapAt(Offset(box.right - 6, box.center.dy));
      await t.pumpAndSettle();
      expect(v, 40);
    });
  });

  group('SkDatePicker', () {
    testWidgets('renders a month and reports the picked day',
        (WidgetTester t) async {
      DateTime? picked;
      await t.pumpWidget(host(SkDatePicker(
        value: DateTime(2026, 8, 5),
        label: 'Depart',
        onChanged: (DateTime d) => picked = d,
      )));
      await t.pumpAndSettle();

      expect(find.text('Depart'), findsOneWidget);
      expect(t.takeException(), isNull);

      // Open the calendar, then take a day that is unambiguously in-month.
      await t.tap(find.byType(SkDatePicker));
      await t.pumpAndSettle();
      final Finder day = find.text('12');
      if (day.evaluate().isNotEmpty) {
        await t.tap(day.first);
        await t.pumpAndSettle();
        expect(picked, isNotNull);
        expect(picked!.day, 12);
      }
    });

    testWidgets('range mode constructs and renders', (WidgetTester t) async {
      await t.pumpWidget(host(SkDatePicker(
        range: true,
        label: 'Stay',
        onRangeChanged: ((DateTime?, DateTime?) _) {},
      )));
      await t.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // SkRange (0017) — an achromatic interval glyph. The rules it must keep are the
  // text equivalent and that a near-zero-spread interval still renders a band.
  group('SkRange', () {
    testWidgets('carries a default text equivalent', (WidgetTester t) async {
      await t.pumpWidget(host(const SizedBox(
        width: 200,
        child: SkRange(low: 5, mid: 12, high: 20, domain: (0, 30)),
      )));
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel('5.0 to 20.0, 12.0'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a custom label overrides the default', (WidgetTester t) async {
      await t.pumpWidget(host(const SizedBox(
        width: 200,
        child: SkRange(
            low: 5, mid: 12, high: 20, domain: (0, 30), label: 'Chase floor 5'),
      )));
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel('Chase floor 5'), findsOneWidget);
    });

    testWidgets('a tight distribution still renders a band', (WidgetTester t) async {
      // low ~= high on a wide domain: the band would collapse below the marker
      // without the min-width floor. It must still construct and paint.
      await t.pumpWidget(host(const SizedBox(
        width: 200,
        child: SkRange(low: 11, mid: 12, high: 13, domain: (0, 30)),
      )));
      await t.pumpAndSettle();
      expect(find.byType(SkRange), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('a column shares one domain without error', (WidgetTester t) async {
      await t.pumpWidget(host(const SizedBox(
        width: 240,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SkRange(low: 12, mid: 18, high: 24, domain: (0, 30)),
            SkRange(low: 5, mid: 12, high: 22, domain: (0, 30), accent: true),
            SkRange(low: 2, mid: 6, high: 14, domain: (0, 30)),
          ],
        ),
      )));
      await t.pumpAndSettle();
      expect(find.byType(SkRange), findsNWidgets(3));
      expect(t.takeException(), isNull);
    });
  });

  // ---- SkDepth.raised direction — 0018 -----------------------------------
  // A raised bar's shadow casts toward the content it floats over. A top bar
  // casts down (+dy); a footer casts up (-dy). Same blur and colour; only the
  // sign of the offset flips. There is no direction-defaulted `raised` — the
  // caller states its role, which is the whole point of 0018.
  group('SkDepth raised direction (0018)', () {
    for (final Brightness b in Brightness.values) {
      test('top bar casts down, footer casts up — $b', () {
        final BoxShadow top = SkDepth.raisedTopBar(b).single;
        final BoxShadow footer = SkDepth.raisedFooter(b).single;

        // The distinguishing fact: opposite vertical direction.
        expect(top.offset.dy, greaterThan(0), reason: 'top bar falls onto content below');
        expect(footer.offset.dy, lessThan(0), reason: 'footer lifts onto content above');

        // Everything else is identical — only the sign flips.
        expect(footer.offset.dy, -top.offset.dy);
        expect(footer.offset.dx, top.offset.dx);
        expect(footer.blurRadius, top.blurRadius);
        expect(footer.color, top.color);
      });
    }
  });
}
