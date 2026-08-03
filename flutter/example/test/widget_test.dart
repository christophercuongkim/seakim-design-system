import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_example/gallery.dart';
import 'package:seakim_example/main.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

void main() {
  testWidgets('the example boots and renders both adoption paths',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    // Stock Material, branded only by the theme.
    expect(find.byType(Card), findsWidgets);
    expect(find.text('Book'), findsOneWidget);
    // SeaKim widgets on the same screen.
    expect(find.byType(SkButton), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the coverage gallery renders every themed Material widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SkMaterialTheme.dark(SkAppBrand.voyage),
        builder: (BuildContext context, Widget? child) =>
            SkThemeScope(brand: SkAppBrand.voyage, child: child!),
        home: const GalleryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Scaffold chrome is always built.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // The rest live in a lazy ListView, so scroll each into existence. This is
    // the real assertion: every themed surface can actually be constructed
    // under this theme without Material rejecting a mapping.
    for (final Finder target in <Finder>[
      find.byType(SegmentedButton<String>),
      find.byType(Slider),
      find.byType(DropdownMenu<String>),
      find.byType(ExpansionTile),
      find.byType(DataTable),
      find.byType(LinearProgressIndicator),
    ]) {
      await tester.scrollUntilVisible(target, 300,
          scrollable: find.byType(Scrollable).first);
      expect(target, findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
