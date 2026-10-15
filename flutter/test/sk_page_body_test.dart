import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, child: child),
        ),
      ),
    );

const Key body = Key('body');

Widget page(SkPageWidth w) =>
    SkPageBody(width: w, child: const SizedBox(key: body, height: 40));

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding b = TestWidgetsFlutterBinding.instance;
    b.platformDispatcher.views.first.physicalSize = const Size(1600, 900);
    b.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() => TestWidgetsFlutterBinding
      .instance.platformDispatcher.views.first
      .resetPhysicalSize());

  group('SkPageBody', () {
    testWidgets('list caps at 768 and centres in a wide main',
        (WidgetTester t) async {
      await t.pumpWidget(host(page(SkPageWidth.list), 1400));
      expect(t.getSize(find.byKey(body)).width, 768);
      expect(t.getTopLeft(find.byKey(body)).dx, (1400 - 768) / 2);
      expect(t.getTopLeft(find.byKey(body)).dy, SkSpace.s7);
    });

    testWidgets('form caps at 620; full takes everything inside the padding',
        (WidgetTester t) async {
      await t.pumpWidget(host(page(SkPageWidth.form), 1400));
      expect(t.getSize(find.byKey(body)).width, 620);
      await t.pumpWidget(host(page(SkPageWidth.full), 1400));
      expect(t.getSize(find.byKey(body)).width, 1400 - 2 * SkSpace.s6);
    });

    testWidgets('prose is 68 body-text zeros wide', (WidgetTester t) async {
      await t.pumpWidget(host(page(SkPageWidth.prose), 1400));
      final double w = t.getSize(find.byKey(body)).width;
      // The test font draws every glyph one em wide, so only the identity holds
      // here; the real face lands near 590.
      expect(w, SkPageBody.maxWidthOf(SkPageWidth.prose));
    });

    testWidgets('sm takes the phone padding and the full width under it',
        (WidgetTester t) async {
      await t.pumpWidget(host(page(SkPageWidth.list), 390));
      expect(t.getSize(find.byKey(body)).width, 390 - 2 * SkSpace.s5);
      expect(
          t.getTopLeft(find.byKey(body)), const Offset(SkSpace.s5, SkSpace.s5));
      expect(skPagePad(SkBreakpoint.sm).bottom, SkSpace.s9);
      expect(skPagePad(SkBreakpoint.lg).bottom, SkSpace.s11);
    });
  });
}
