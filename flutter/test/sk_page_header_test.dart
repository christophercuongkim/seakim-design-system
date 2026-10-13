import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, {double width = 600}) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: SizedBox(width: width, child: child)),
    );

void main() {
  testWidgets(
      'SkPageHeader renders title as a header with badge, actions and toolbar',
      (WidgetTester t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(host(SkPageHeader(
      title: 'Trips',
      count: '12',
      badge:
          const SkBadge(label: 'Synced', tone: SkBadgeTone.success, dot: true),
      description: 'Everything booked and everything still a plan.',
      actions: <Widget>[SkButton(label: 'New trip', onPressed: () {})],
      toolbar: <Widget>[
        SkSegmentedControl<String>(
          segments: const <SkSegment<String>>[
            SkSegment<String>(value: 'list', label: 'List'),
            SkSegment<String>(value: 'board', label: 'Board'),
          ],
          value: 'list',
          onChanged: (String _) {},
        ),
      ],
    )));
    await t.pumpAndSettle();

    expect(find.text('Trips'), findsOneWidget);
    expect(t.getSemantics(find.text('Trips')).flagsCollection.isHeader, isTrue);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Synced'), findsOneWidget);
    expect(find.text('New trip'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
    expect(t.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('a long title wraps and the actions stay on the row at sm',
      (WidgetTester t) async {
    await t.pumpWidget(host(
      SkPageHeader(
        title: 'A title long enough to need a second line on a phone',
        actions: <Widget>[SkButton(label: 'Act', onPressed: () {})],
      ),
      width: 320,
    ));
    await t.pumpAndSettle();
    final Offset act = t.getTopLeft(find.text('Act'));
    final Offset title = t.getTopLeft(find.textContaining('A title'));
    expect(act.dx, greaterThan(title.dx));
    expect(t.takeException(), isNull);
  });
}
