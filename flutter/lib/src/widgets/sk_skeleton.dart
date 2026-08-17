import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// A placeholder shaped like the content that is arriving (decision 0021).
///
/// Use it whenever you know *what* is coming — a list row, an [SkStat], a table
/// cell — so it mirrors that geometry and real content drops in without a layout
/// shift. It pulses between [SkColors.surfaceSunken] and [SkColors.surfaceShimmer];
/// it never spins.
///
/// Reduced motion ([MediaQuery.disableAnimations]) renders a static block, never
/// a frozen mid-pulse — a zeroed loop would freeze, so the loop is skipped
/// entirely. It is decorative, so it carries no semantics: the surrounding region
/// owns the busy announcement (see [SkLoadingState]).
class SkSkeleton extends StatefulWidget {
  const SkSkeleton({
    super.key,
    this.width,
    this.height = SkSpace.s6,
    this.radius = 0,
  });

  /// Width in logical pixels. Null stretches to the parent's constraints.
  final double? width;
  final double height;

  /// Corner radius. 0 by default — square, like everything; pass a large value
  /// only for a round mask (an avatar placeholder).
  final double radius;

  @override
  State<SkSkeleton> createState() => _SkSkeletonState();
}

class _SkSkeletonState extends State<SkSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SkMotion.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A zeroed loop freezes mid-pulse, so reduced motion skips the loop outright;
    // build() then renders a static block.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final BorderRadius br = BorderRadius.circular(widget.radius);

    if (MediaQuery.disableAnimationsOf(context)) {
      return _block(c.surfaceSunken, br);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = SkMotion.shimmerEase.transform(_controller.value);
        final Color fill = Color.lerp(c.surfaceSunken, c.surfaceShimmer, t)!;
        return _block(fill, br);
      },
    );
  }

  Widget _block(Color color, BorderRadius br) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: color, borderRadius: br),
      );
}
