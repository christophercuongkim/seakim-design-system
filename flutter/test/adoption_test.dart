import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// The app-first adoption path: an app already written in stock Material
/// widgets, which then has SeaKim dropped in without any widget being rewritten.
///
/// If these fail, adopting the design system requires a rewrite — which is the
/// thing this path exists to avoid.
void main() {
  // Deliberately plain Material. Nothing here knows SeaKim exists.
  Widget existingApp({ThemeData? theme}) => MaterialApp(
        theme: theme,
        builder: theme == null
            ? null
            : (BuildContext context, Widget? child) =>
                SkThemeScope(brand: SkAppBrand.voyage, child: child!),
        home: Scaffold(
          appBar: AppBar(title: const Text('Trips')),
          body: Column(
            children: <Widget>[
              const Card(child: ListTile(title: Text('Lisbon'))),
              TextField(decoration: const InputDecoration(hintText: 'Search')),
              FilledButton(onPressed: () {}, child: const Text('Book')),
            ],
          ),
        ),
      );

  testWidgets('stock Material widgets adopt SeaKim colour and square corners',
      (WidgetTester tester) async {
    await tester.pumpWidget(existingApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
    ));
    await tester.pumpAndSettle();

    final SkColors expected = SkColors.dark(SkAppBrand.voyage.ramp);

    // The page takes the system's surface, not Material's grey.
    final Scaffold scaffold = tester.widget(find.byType(Scaffold));
    final ThemeData theme =
        Theme.of(tester.element(find.byType(Scaffold)));
    expect(theme.scaffoldBackgroundColor, expected.surfacePage);
    expect(scaffold.backgroundColor ?? theme.scaffoldBackgroundColor,
        expected.surfacePage);

    // 0px radius is the loudest decision; a stock Card must obey it.
    final CardThemeData card = theme.cardTheme;
    expect((card.shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.zero);
    expect(card.elevation, 0, reason: 'a card does not float');

    // Accent flows into Material's primary.
    expect(theme.colorScheme.primary, expected.fillAccent);

    // No ink ripple anywhere.
    expect(theme.splashFactory, NoSplash.splashFactory);
  });

  testWidgets('typography resolves to the bundled fonts, namespaced',
      (WidgetTester tester) async {
    await tester.pumpWidget(existingApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
    ));
    final ThemeData theme = Theme.of(tester.element(find.byType(Scaffold)));

    // A package-bundled font only resolves for a consuming app when the style
    // carries package:, which rewrites the family. Without it every glyph
    // silently falls back to the platform font.
    expect(theme.textTheme.bodyLarge!.fontFamily,
        'packages/seakim_flutter/${SkFonts.sans}');
    expect(theme.textTheme.headlineMedium!.fontFamily,
        'packages/seakim_flutter/${SkFonts.display}');
    expect(SkText.data.fontFamily, 'packages/seakim_flutter/${SkFonts.mono}');
  });

  testWidgets('Sk* widgets can be mixed into the Material app, and overlays work',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? child) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: child!),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => Column(
            children: <Widget>[
              // A SeaKim widget beside the Material ones, reading tokens.
              SkButton(label: 'Sk beside Material', onPressed: () {}),
              FilledButton(
                onPressed: () => showSkToast(
                  context,
                  message: 'Trip saved',
                  duration: const Duration(milliseconds: 100),
                ),
                child: const Text('Toast'),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Sk beside Material'), findsOneWidget);

    // MaterialApp supplies the Overlay that SkToast needs — under a bare SkApp
    // this throws "No Overlay widget found".
    await tester.tap(find.text('Toast'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Trip saved'), findsOneWidget);

    // Let the auto-dismiss timer run out, so it is not still pending at
    // teardown. (showSkToast schedules an uncancellable Future.delayed; harmless
    // in an app, noisy in a test.)
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });

  testWidgets('SkThemeScope follows the ambient Material brightness',
      (WidgetTester tester) async {
    Future<SkColors> resolve(ThemeData theme) async {
      late SkColors seen;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        builder: (BuildContext context, Widget? child) =>
            SkThemeScope(brand: SkAppBrand.voyage, child: child!),
        home: Builder(builder: (BuildContext context) {
          seen = context.skColors;
          return const SizedBox();
        }),
      ));
      await tester.pumpAndSettle();
      return seen;
    }

    final SkColors dark = await resolve(SkMaterialTheme.dark(SkAppBrand.voyage));
    expect(dark.isDark, isTrue);

    final SkColors light =
        await resolve(SkMaterialTheme.light(SkAppBrand.voyage));
    expect(light.isDark, isFalse,
        reason: 'one wrapper should track themeMode, not need telling twice');
  });
}
