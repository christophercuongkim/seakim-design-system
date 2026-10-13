import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: SizedBox(width: 360, child: child)),
    );

void main() {
  testWidgets(
      'the zone picks; the row shows the file with its size and removes',
      (WidgetTester t) async {
    int picks = 0;
    int removes = 0;
    await t.pumpWidget(host(SkFileDrop(
      hint: 'PDF up to 5 MB',
      onPick: () => picks++,
      file: const SkFileInfo(name: 'resume.pdf', size: 82261),
      onRemove: () => removes++,
    )));
    await t.pumpAndSettle();
    expect(find.text('PDF up to 5 MB'), findsOneWidget);
    expect(find.text('resume.pdf'), findsOneWidget);
    expect(find.text('80.3 KB'), findsOneWidget);
    await t.tap(find.text('PDF up to 5 MB'));
    await t.pumpAndSettle();
    expect(picks, 1);
    await t.tap(find.byType(SkIconButton));
    await t.pumpAndSettle();
    expect(removes, 1);
    expect(t.takeException(), isNull);
  });

  testWidgets('uploading: the zone shows the labelled wait, the row waits',
      (WidgetTester t) async {
    await t.pumpWidget(host(SkFileDrop(
      onPick: () {},
      file: const SkFileInfo(name: 'resume.pdf'),
      onRemove: () {},
      uploading: true,
      uploadingLabel: 'Reading your résumé…',
    )));
    await t.pumpAndSettle();
    expect(find.text('Reading your résumé…'), findsOneWidget);
    expect(find.text('resume.pdf'), findsNothing);
    expect(find.byType(SkIconButton), findsNothing);
  });

  testWidgets('error: the zone is an error state with a Try again that fires',
      (WidgetTester t) async {
    int retries = 0;
    await t.pumpWidget(host(SkFileDrop(
      onPick: () {},
      error: "We couldn't read text from that PDF.",
      onRetry: () => retries++,
    )));
    await t.pumpAndSettle();
    expect(find.byType(SkErrorState), findsOneWidget);
    expect(find.text("We couldn't read text from that PDF."), findsOneWidget);
    await t.tap(find.text('Try again'));
    await t.pumpAndSettle();
    expect(retries, 1);
    expect(t.takeException(), isNull);
  });
}
