import 'package:flutter/widgets.dart';

/// Borders define, shadows lift.
///
/// Anything in the layout gets a 1px hairline and no shadow. Shadow is reserved
/// for things that OVERLAY other content — menus, popovers, sheets, dialogs,
/// toasts, drag ghosts — so elevation carries meaning instead of decoration.
/// A raised bar is the one in-layout exception: a bar that scrolls over content
/// earns a shadow (per 0002). Per [0018] that shadow casts toward the content it
/// floats over — away from the edge the bar is anchored to — so the accessor is
/// role-named, never a single direction: [raisedTopBar] casts down onto content
/// below it, [raisedFooter] casts up onto content above it. There is no
/// axis-defaulted `raised`; a caller states its role, so a footer wearing the
/// top-bar orientation cannot compile.
class SkDepth {
  const SkDepth._();

  static const double hairline = 1;
  static const double emphasis = 2;

  static const List<BoxShadow> none = <BoxShadow>[];

  /// A bar anchored at the TOP of the content it covers (header, app bar).
  /// Casts downward, onto the content below.
  static List<BoxShadow> raisedTopBar(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, 1)),
        ]
      : const [
          BoxShadow(color: Color(0x121E1C1A), blurRadius: 2, offset: Offset(0, 1)),
        ];

  /// A bar anchored at the BOTTOM of the content it covers (sticky footer, per
  /// 0002's `sm` primary-action bar). Casts upward, onto the content above —
  /// only the sign of the vertical offset differs from [raisedTopBar].
  static List<BoxShadow> raisedFooter(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x80000000), blurRadius: 2, offset: Offset(0, -1)),
        ]
      : const [
          BoxShadow(color: Color(0x121E1C1A), blurRadius: 2, offset: Offset(0, -1)),
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
