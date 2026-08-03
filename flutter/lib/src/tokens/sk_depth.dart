import 'package:flutter/widgets.dart';

/// Borders define, shadows lift.
///
/// Anything in the layout gets a 1px hairline and no shadow. Shadow is reserved
/// for things that OVERLAY other content — menus, popovers, sheets, dialogs,
/// toasts, drag ghosts — so elevation carries meaning instead of decoration.
/// [raised] is the one exception: bars that scroll over content.
class SkDepth {
  const SkDepth._();

  static const double hairline = 1;
  static const double emphasis = 2;

  static const List<BoxShadow> none = <BoxShadow>[];

  static List<BoxShadow> raised(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(color: Color(0x121E1C1A), blurRadius: 2, offset: Offset(0, 1)),
        ];

  static List<BoxShadow> popover(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(
              color: Color(0xA6000000),
              blurRadius: 24,
              spreadRadius: -4,
              offset: Offset(0, 8)),
          BoxShadow(color: Color(0x80000000), blurRadius: 6, offset: Offset(0, 2)),
        ]
      : const [
          BoxShadow(
              color: Color(0x241E1C1A),
              blurRadius: 24,
              spreadRadius: -4,
              offset: Offset(0, 8)),
          BoxShadow(color: Color(0x141E1C1A), blurRadius: 6, offset: Offset(0, 2)),
        ];

  static List<BoxShadow> dialog(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(
              color: Color(0xBF000000),
              blurRadius: 64,
              spreadRadius: -12,
              offset: Offset(0, 24)),
          BoxShadow(color: Color(0x80000000), blurRadius: 12, offset: Offset(0, 4)),
        ]
      : const [
          BoxShadow(
              color: Color(0x381E1C1A),
              blurRadius: 64,
              spreadRadius: -12,
              offset: Offset(0, 24)),
          BoxShadow(color: Color(0x1A1E1C1A), blurRadius: 12, offset: Offset(0, 4)),
        ];

  static List<BoxShadow> sheet(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x8C000000), blurRadius: 32, offset: Offset(0, -8)),
        ]
      : const [
          BoxShadow(color: Color(0x1F1E1C1A), blurRadius: 32, offset: Offset(0, -8)),
        ];

  static List<BoxShadow> toast(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(
              color: Color(0x99000000),
              blurRadius: 32,
              spreadRadius: -8,
              offset: Offset(0, 12)),
          BoxShadow(color: Color(0x73000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(
              color: Color(0x291E1C1A),
              blurRadius: 32,
              spreadRadius: -8,
              offset: Offset(0, 12)),
          BoxShadow(color: Color(0x141E1C1A), blurRadius: 2, offset: Offset(0, 1)),
        ];
}
