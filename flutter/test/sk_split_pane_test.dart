import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

Widget host(Widget child, double width) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: 400, child: child),
        ),
      ),
    );

Widget pane({bool detailOpen = false, VoidCallback? onBack}) => SkSplitPane(
      detailOpen: detailOpen,
      onBack: onBack,
      list: const Text('LIST'),
      detail: const Column(
        children: <Widget>[
          SkSplitPaneHeader(title: 'Lisbon', counter: '2 of 3'),
          Text('DETAIL'),
        ],
      ),
      aside: const Text('ASIDE'),
    );

void main() {
  group('SkSplitPane', () {
    testWidgets('lg shows list, detail and aside', (WidgetTester t) async {
      t.view.physicalSize = const Size(1400, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      await t.pumpWidget(host(pane(), 1200));
      await t.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);
      expect(find.text('DETAIL'), findsOneWidget);
      expect(find.text('ASIDE'), findsOneWidget);
      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsNothing);
    });

    testWidgets('md shows list and detail, no aside', (WidgetTester t) async {
      await t.pumpWidget(host(pane(), 700));
      await t.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);
      expect(find.text('DETAIL'), findsOneWidget);
      expect(find.text('ASIDE'), findsNothing);
    });

    testWidgets('sm shows the list, or the detail with a back control',
        (WidgetTester t) async {
      bool backed = false;
      await t.pumpWidget(host(pane(onBack: () => backed = true), 360));
      await t.pumpAndSettle();
      expect(find.text('LIST'), findsOneWidget);
      expect(find.text('DETAIL'), findsNothing);

      await t.pumpWidget(
          host(pane(detailOpen: true, onBack: () => backed = true), 360));
      await t.pumpAndSettle();
      expect(find.text('LIST'), findsNothing);
      expect(find.text('DETAIL'), findsOneWidget);
      await t.tap(find.byType(SkIconButton).first);
      await t.pumpAndSettle();
      expect(backed, isTrue);
      expect(t.takeException(), isNull);
    });
  });
}
