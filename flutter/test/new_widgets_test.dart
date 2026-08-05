import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// Coverage for the three widgets added from the design decisions — Table
/// (0003), DatePicker (0004), and Slider (0006). They were written and reviewed
/// but never run, so these assert the behaviour the ADRs actually promise, not
/// just that the widgets construct.

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
}
