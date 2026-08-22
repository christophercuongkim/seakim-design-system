import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';
// Imported directly: the barrel export lands with the same change, but the test
// stands on its own file so it is green before the barrel row is added.

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: child)),
    );

List<SkAvatarData> _people(int n) => <SkAvatarData>[
      for (int i = 0; i < n; i++) SkAvatarData(name: 'Person $i'),
    ];

void main() {
  testWidgets('caps at max and collapses the remainder into a "+k" pill',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      SkAvatarStack(items: _people(20), max: 3),
    ));
    await tester.pumpAndSettle();

    // Three avatars survive; the other seventeen become one count pill.
    expect(find.byType(SkAvatar), findsNWidgets(3));
    expect(find.text('+17'), findsOneWidget);
  });

  testWidgets('a remainder of one shows the avatar, not a "+1" pill',
      (WidgetTester tester) async {
    // max + 1 people: the pill would save no space, so every avatar shows.
    await tester.pumpWidget(_host(
      SkAvatarStack(items: _people(4), max: 3),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SkAvatar), findsNWidgets(4));
    expect(find.textContaining('+'), findsNothing);
  });

  testWidgets('the stack announces itself as one labelled group',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      SkAvatarStack(items: _people(20), max: 3),
    ));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('3 people, and 17 more'), findsOneWidget);
  });
}
