import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Whether the primary pointer is coarse (a finger), so the 44px floor applies.
///
/// Per [0023](decisions/0023-sub-floor-chrome-hit-area.md), the 44px minimum is a
/// *touch* requirement: a control's visible mark may render denser on a precise
/// pointer, but on a coarse pointer its hit area must reach [SkControl.touch]. This
/// is a device axis, not the container-width breakpoint — a compact desktop layout
/// on a mouse keeps its density; the same layout on a phone gets the floor.
bool skCoarsePointer(BuildContext context) => switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.android ||
      TargetPlatform.fuchsia =>
        true,
      _ => false,
    };

/// Expands a sub-floor control's hit area to [SkControl.touch] on coarse pointers,
/// centring the (smaller) visual, and returns the child untouched on precise ones.
///
/// The visual is unchanged — the extra band is transparent, and because every
/// SeaKim control sits inside an opaque-hit-testing [SkPressable], the band is
/// tappable. Give [extent] the visual's painted size (including any focus ring): a
/// mark already at the floor is left alone, and the wrapper never shrinks a visual
/// larger than the floor. When [square] the floor is enforced on both axes
/// (icon-square controls); otherwise on height alone (chips, buttons, tabs — their
/// width is content-driven and already past the floor).
///
/// Wrap the *visual* (inside the SkPressable builder, around the focus ring) so the
/// ring keeps hugging the mark and only the tap band grows. Per 0023.
class SkTouchTarget extends StatelessWidget {
  const SkTouchTarget({
    super.key,
    required this.child,
    required this.extent,
    this.square = false,
  });

  final Widget child;

  /// The painted footprint of the mark this wraps — its height, and its width too
  /// when [square]. A control already at or past [SkControl.touch] is not wrapped.
  final double extent;

  final bool square;

  @override
  Widget build(BuildContext context) {
    final double pad = (SkControl.touch - extent) / 2;
    // Already at the floor (pad <= 0), or a precise pointer: leave it untouched.
    // Padding only ever grows the band, so a slightly-off [extent] can never clip
    // the visual — it just lands a hair above or below 44.
    if (pad <= 0 || !skCoarsePointer(context)) return child;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: pad, horizontal: square ? pad : 0),
      child: child,
    );
  }
}
