import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';
// SkPopover is not yet in the barrel (a shared-file edit owed to whoever wires
// it in); import the source directly so this test is self-contained.

Widget _host(Widget child) => MaterialApp(
      theme: SkMaterialTheme.dark(SkAppBrand.voyage),
      builder: (BuildContext context, Widget? c) =>
          SkThemeScope(brand: SkAppBrand.voyage, child: c!),
      home: Scaffold(body: Center(child: child)),
    );

/// Mutable harness state: the controlled `open` flag, whether onDismiss fired,
/// and a focus node on the trigger so the focus obligations can be asserted.
class _Env {
  bool open = false;
  bool dismissed = false;
  final FocusNode trigger = FocusNode(debugLabel: 'trigger');
  late void Function(bool) setOpen;
}

Future<_Env> _pump(WidgetTester tester, {required bool modal}) async {
  final _Env env = _Env();
  await tester.pumpWidget(_host(
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        env.setOpen = (bool v) => setState(() => env.open = v);
        return SkPopover(
          open: env.open,
          modal: modal,
          onDismiss: () {
            env.dismissed = true;
            setState(() => env.open = false);
          },
          overlayBuilder: (BuildContext context) => const Padding(
            padding: EdgeInsets.all(SkSpace.s4),
            child: Text('Popover panel'),
          ),
          child: Focus(
            focusNode: env.trigger,
            child: const SizedBox(width: 120, height: 40),
          ),
        );
      },
    ),
  ));
  await tester.pumpAndSettle();
  return env;
}

void main() {
  testWidgets('opens and renders its content in the overlay',
      (WidgetTester tester) async {
    final _Env env = await _pump(tester, modal: false);
    expect(find.text('Popover panel'), findsNothing);

    env.setOpen(true);
    await tester.pumpAndSettle();
    expect(find.text('Popover panel'), findsOneWidget);
  });

  testWidgets('Escape dismisses', (WidgetTester tester) async {
    final _Env env = await _pump(tester, modal: false);
    env.trigger.requestFocus();
    await tester.pump();
    env.setOpen(true);
    await tester.pumpAndSettle();
    expect(find.text('Popover panel'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(env.dismissed, isTrue);
    expect(find.text('Popover panel'), findsNothing);
  });

  testWidgets('outside-press dismisses', (WidgetTester tester) async {
    final _Env env = await _pump(tester, modal: false);
    env.setOpen(true);
    await tester.pumpAndSettle();
    expect(find.text('Popover panel'), findsOneWidget);

    // Tap the far corner — the full-screen tap-away catcher, not the surface.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(env.dismissed, isTrue);
    expect(find.text('Popover panel'), findsNothing);
  });

  testWidgets('modal moves focus into the content and restores it on close',
      (WidgetTester tester) async {
    final _Env env = await _pump(tester, modal: true);
    env.trigger.requestFocus();
    await tester.pump();
    expect(env.trigger.hasFocus, isTrue);

    env.setOpen(true);
    await tester.pumpAndSettle();
    // Focus moved off the trigger, into the popover content.
    expect(env.trigger.hasFocus, isFalse);

    env.setOpen(false);
    await tester.pumpAndSettle();
    // Closing restores focus to the trigger.
    expect(env.trigger.hasFocus, isTrue);
  });

  testWidgets('non-modal leaves focus on the trigger',
      (WidgetTester tester) async {
    final _Env env = await _pump(tester, modal: false);
    env.trigger.requestFocus();
    await tester.pump();

    env.setOpen(true);
    await tester.pumpAndSettle();
    expect(env.trigger.hasFocus, isTrue);
  });
}
