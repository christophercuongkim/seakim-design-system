/// Space and size. 4px grid, with a 2px half-step for optical nudges only.
///
/// Density 7/10 means compact controls but generous section gaps — that contrast
/// is what keeps a dense screen legible.
class SkSpace {
  const SkSpace._();

  static const double s0 = 0;
  static const double s1 = 2;
  static const double s2 = 4;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 20;
  static const double s7 = 24;
  static const double s8 = 32;
  static const double s9 = 40;
  static const double s10 = 48;
  static const double s11 = 64;
  static const double s12 = 80;

  /// Standard card inset.
  static const double padCard = s5;

  /// Standard section inset.
  static const double padSection = s8;
}

/// Control heights. [touch] is the floor for anything tappable, on every
/// platform, regardless of density.
class SkControl {
  const SkControl._();

  static const double sm = 28;
  static const double md = 34;
  static const double lg = 42;
  static const double touch = 44;
}

/// Fixed chrome dimensions.
class SkChrome {
  const SkChrome._();

  static const double topBar = 52;
  static const double subBar = 44;
  static const double sideNav = 232;
  static const double sideNavCollapsed = 56;
  static const double tabBar = 56;
  static const double statusBar = 44;

  /// Dialog panel max-width. The one overlay width shared across bindings —
  /// mirrored in CSS as `--overlay-w-dialog` and held equal by the
  /// `overlay-width-parity` check in tool/conformance-check.mjs. (The sheet width
  /// is deliberately not here: the sheet is not a promoted system component yet,
  /// per conformance.md item 8.)
  static const double overlayDialogW = 440;
}

/// Corners are square. The only exceptions are shapes that are conceptually
/// circular — avatars, status dots, switch tracks, count pills. There is
/// deliberately no 4px option.
class SkRadius {
  const SkRadius._();

  static const double none = 0;
  static const double pill = 999;
}
