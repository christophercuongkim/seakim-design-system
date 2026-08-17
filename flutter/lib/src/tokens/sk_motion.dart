import 'package:flutter/animation.dart';

/// Springy, but disciplined: things that ENTER or TOGGLE overshoot slightly,
/// things that EXIT never do. Never animate a value the user is trying to read —
/// prices, scores, and times cut instantly; their containers may animate.
class SkMotion {
  const SkMotion._();

  static const Duration instant = Duration(milliseconds: 80); // hover, press
  static const Duration fast = Duration(milliseconds: 140); // exits, dismissals
  static const Duration base = Duration(milliseconds: 200); // enters, toggles
  static const Duration slow = Duration(milliseconds: 320); // sheets, layout

  /// Exits and fades. CSS: cubic-bezier(0.22, 0.90, 0.28, 1)
  static const Curve out = Cubic(0.22, 0.90, 0.28, 1);

  /// Enters, toggles, tab indicators. CSS: cubic-bezier(0.34, 1.42, 0.50, 1)
  ///
  /// This overshoots past 1.0. Flutter allows that for a [Curve], but colour
  /// tweens clamp badly on overshoot — use [spring] for transforms and offsets,
  /// and [out] for colour.
  static const Curve spring = Cubic(0.34, 1.42, 0.50, 1);

  /// Badges, switch knobs, chips — punchier overshoot.
  /// CSS: cubic-bezier(0.20, 1.60, 0.40, 1)
  static const Curve pop = Cubic(0.20, 1.60, 0.40, 1);

  /// Skeleton shimmer loop (0021). A continuous pulse, not a one-shot: slow and
  /// symmetric, so it reads as breathing rather than a transition. The overshoot
  /// curves above are meaningless on a loop, so the shimmer eases linearly.
  /// Reduced motion is handled by [SkSkeleton] (a static block), not by zeroing
  /// this — a zeroed loop freezes mid-sweep. CSS: --dur-shimmer / --ease-shimmer.
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Curve shimmerEase = Curves.linear;

  /// Press feedback is scale, not colour alone. Every tappable thing uses it.
  static const double pressScale = 0.97;
  static const double pressScaleLarge = 0.985;
}
