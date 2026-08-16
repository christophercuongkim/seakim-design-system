import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

import 'package:seakim_example/sk_showcase.dart';

/// Compiler-checked preview coverage. [skShowcase] references every widget's real
/// Dart type, so the compiler proves the widgets exist and their arguments hold.
/// These two tests close the loop at runtime:
///
///   * completeness — one showcase demo per exported widget file, no more, no less
///   * buildability — every demo actually builds under the app's theme
void main() {
  test('every widget file has exactly one showcase demo', () {
    // cwd at test time is flutter/example; the package is a path dep at ../.
    final String barrel =
        File('../lib/seakim_flutter.dart').readAsStringSync();
    final int widgetFiles =
        RegExp(r"export 'src/widgets/sk_").allMatches(barrel).length;

    expect(
      skShowcase.length,
      widgetFiles,
      reason: 'every widget file must have exactly one showcase demo — '
          'add the new widget to sk_showcase.dart',
    );
  });

  for (final SkDemo demo in skShowcase) {
    testWidgets('demo builds: ${demo.section} / ${demo.label}',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SkMaterialTheme.dark(SkAppBrand.voyage),
          builder: (BuildContext context, Widget? child) =>
              SkThemeScope(brand: SkAppBrand.voyage, child: child!),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(builder: demo.build),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: 'demo ${demo.label} threw');
    });
  }
}
