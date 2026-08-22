import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  // 0023: a mark may render below the 44px floor only if its hit area is not —
  // and that floor is a *touch* requirement, so it appears on coarse pointers and
  // not on precise ones.

  group('SkIconButton (sm, 28px visual) hit area', () {
    testWidgets('reaches the 44px floor on a coarse pointer', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(_host(
        SkIconButton(
            icon: SkIcons.x, label: 'Close', size: SkControl.sm, onPressed: () {}),
      ));
      await tester.pumpAndSettle();

      final Size hit = tester.getSize(find.byType(SkTouchTarget));
      expect(hit.height, SkControl.touch);
      expect(hit.width, SkControl.touch);
      // The painted mark stays at its dense 28px — only the tap band grew.
      expect(tester.getSize(find.byType(SkIcon)).height, lessThan(SkControl.touch));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('stays compact on a precise pointer', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(_host(
        SkIconButton(
            icon: SkIcons.x, label: 'Close', size: SkControl.sm, onPressed: () {}),
      ));
      await tester.pumpAndSettle();

      // No touch band on desktop — the control keeps its compact footprint,
      // comfortably below the 44px floor.
      final Size hit = tester.getSize(find.byType(SkTouchTarget));
      expect(hit.height, lessThan(SkControl.touch));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('SkTag (28px chip) grows to the floor on touch', () {
    testWidgets('a removable tag is 44px tall on a coarse pointer',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await tester.pumpWidget(_host(
        SkTag(label: 'Nature', onPressed: () {}, onRemove: () {}),
      ));
      await tester.pumpAndSettle();
      // Tap area reaches the floor (the painted chip grows to 44, plus the always-
      // present focus-ring gap) so the dismiss within it is finger-sized too.
      expect(tester.getSize(find.byType(SkTag)).height,
          greaterThanOrEqualTo(SkControl.touch));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('keeps its dense chip on a precise pointer', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await tester.pumpWidget(_host(
        SkTag(label: 'Nature', onPressed: () {}, onRemove: () {}),
      ));
      await tester.pumpAndSettle();
      // Desktop keeps the compact 28px chip (well under the floor).
      expect(tester.getSize(find.byType(SkTag)).height, lessThan(SkControl.touch));
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
