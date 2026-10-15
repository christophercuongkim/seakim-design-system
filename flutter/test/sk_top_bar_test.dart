import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, {double top = 0}) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(padding: EdgeInsets.only(top: top)),
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        ),
      ),
    );

List<BoxShadow>? shadowOf(WidgetTester t) {
  final AnimatedContainer box = t.widget(find
      .descendant(
          of: find.byType(SkTopBar), matching: find.byType(AnimatedContainer))
      .first);
  return (box.decoration! as BoxDecoration).boxShadow;
}

void main() {
  group('SkTopBar', () {
    testWidgets('raised only while content is scrolled under it',
        (WidgetTester t) async {
      await t.pumpWidget(host(const SkTopBar(title: Text('Lisbon'))));
      expect(shadowOf(t), isEmpty);
      await t.pumpWidget(
          host(const SkTopBar(title: Text('Lisbon'), scrolledUnder: true)));
      expect(shadowOf(t), isNotEmpty);
    });

    testWidgets('52px, plus the safe-area inset above it',
        (WidgetTester t) async {
      await t.pumpWidget(host(const SkTopBar(title: Text('Lisbon'))));
      expect(t.getSize(find.byType(SkTopBar)).height, SkChrome.topBar);
      await t.pumpWidget(host(const SkTopBar(title: Text('Lisbon')), top: 47));
      expect(t.getSize(find.byType(SkTopBar)).height, SkChrome.topBar + 47);
      expect(t.getTopLeft(find.text('Lisbon')).dy, greaterThan(47));
    });

    testWidgets('back wins over close; a tappable title has a caret',
        (WidgetTester t) async {
      bool backed = false;
      bool tapped = false;
      await t.pumpWidget(host(SkTopBar(
        title: const Text('Lisbon'),
        onBack: () => backed = true,
        onClose: () {},
        onTitleTap: () => tapped = true,
        actions: <Widget>[
          SkIconButton(icon: SkIcons.gear, label: 'Settings', onPressed: () {}),
        ],
      )));
      expect(find.byType(SkIconButton), findsNWidgets(2));
      expect(find.byType(SkIcon), findsNWidgets(3)); // back, caret, gear
      await t.tap(find.byType(SkIconButton).first);
      await t.tap(find.text('Lisbon'));
      expect(backed, isTrue);
      expect(tapped, isTrue);
    });

    testWidgets('the title menu shows while open', (WidgetTester t) async {
      Widget bar(bool open) => host(SkTopBar(
            title: const Text('Lisbon'),
            onTitleTap: () {},
            titleMenu: (BuildContext context) => const Text('Other trips'),
            titleMenuOpen: open,
          ));
      await t.pumpWidget(bar(false));
      await t.pumpAndSettle();
      expect(find.text('Other trips'), findsNothing);
      await t.pumpWidget(bar(true));
      await t.pumpAndSettle();
      expect(find.text('Other trips'), findsOneWidget);
    });
  });
}
