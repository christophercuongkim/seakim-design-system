import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SkInput forwards autofillHints to its EditableText',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const SkInput(autofillHints: <String>[AutofillHints.email])),
    );

    final EditableText editable =
        tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.autofillHints, <String>[AutofillHints.email]);
  });

  testWidgets('SkInput without autofillHints leaves autofill unset',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const SkInput()));

    final EditableText editable =
        tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.autofillHints, isNull);
  });
}
