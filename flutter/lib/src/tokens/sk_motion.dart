import 'package:flutter/animation.dart';

/// Quiet (0033, 0034): everything eases out, nothing overshoots, nothing
/// scales. Press is a tint — the widget swaps to its active surface — never a
/// transform. Exits are faster than enters. Never animate a value the user is
/// trying to read — prices, scores, and times cut instantly; their containers
/// may animate.
class SkMotion {
  const SkMotion._();

  static const Duration instant = Duration(milliseconds: 80); // hover, press
  static const Duration fast = Duration(milliseconds: 100); // exits, dismissals
  static const Duration base = Duration(milliseconds: 120); // enters, toggles
  static const Duration slow = Duration(milliseconds: 150); // sheets, layout — the ceiling

  /// The only curve. CSS: cubic-bezier(0.22, 0.90, 0.28, 1)
  static const Curve out = Cubic(0.22, 0.90, 0.28, 1);

  /// Skeleton shimmer loop (0021). A continuous pulse, not a one-shot: slow and
  /// symmetric, so it reads as breathing rather than a transition. Reduced
  /// motion is handled by [SkSkeleton] (a static block), not by zeroing this —
  /// a zeroed loop freezes mid-sweep. CSS: --dur-shimmer / --ease-shimmer.
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Curve shimmerEase = Curves.linear;
}
