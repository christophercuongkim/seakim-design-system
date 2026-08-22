import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_popover.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

enum SkIconButtonVariant { ghost, secondary }

/// A square control carrying only an icon.
///
/// [label] is required and never optional — it becomes the semantics label and
/// the tooltip. An unlabelled icon control is a bug, not a style choice.
class SkIconButton extends StatelessWidget {
  const SkIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.variant = SkIconButtonVariant.ghost,
    this.size = SkControl.md,
    this.active = false,
    this.disabled = false,
    this.tooltip = true,
  });

  final SkGlyph icon;

  /// Announced by screen readers and shown on hover. Sentence case, 1 to 4 words.
  final String label;

  final VoidCallback? onPressed;
  final SkIconButtonVariant variant;

  /// Box size. Use [SkControl.touch] on mobile-only surfaces.
  final double size;

  /// Marks a persistent on state — saved, pinned, filters open. Switches the
  /// glyph to fill weight and tints it with the accent.
  final bool active;

  final bool disabled;

  /// Set false only when the control already sits inside an SkTooltip.
  final bool tooltip;

  double get _iconSize => size <= SkControl.sm
      ? 14
      : size >= SkControl.lg
          ? 20
          : 16;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    final Widget button = SkPressable(
      onPressed: onPressed,
      disabled: disabled,
      semanticLabel: label,
      builder: (BuildContext context, SkInteraction s) {
        final Color fg = s.disabled
            ? c.textDisabled
            : active
                ? c.textAccent
                : s.liveHover
                    ? c.textPrimary
                    : c.textSecondary;
        final Color bg = s.disabled
            ? const Color(0x00000000)
            : active
                ? c.surfaceSelected
                : s.livePress
                    ? c.surfaceActive
                    : s.liveHover
                        ? c.surfaceHover
                        : const Color(0x00000000);
        final Color border = variant == SkIconButtonVariant.secondary
            ? (s.disabled
                ? c.borderDisabled
                : s.liveHover
                    ? c.borderStrong
                    : c.borderDefault)
            : const Color(0x00000000);

        return SkTouchTarget(
          extent: size + SkFocusRing.overhead,
          square: true,
          child: SkFocusRing(
            visible: s.focused,
            child: AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: SkDepth.hairline),
              ),
              child: SkIcon(
                icon,
                size: _iconSize,
                weight: active ? SkIconWeight.fill : SkIconWeight.regular,
                color: fg,
              ),
            ),
          ),
        );
      },
    );

    return tooltip ? SkHoverLabel(label: label, child: button) : button;
  }
}

/// Minimal hover label used by [SkIconButton] so icon controls are never bare.
/// For a standalone tooltip use SkTooltip, which shares this implementation.
class SkHoverLabel extends StatefulWidget {
  const SkHoverLabel({
    super.key,
    required this.label,
    required this.child,
    this.side = AxisDirection.up,
  });

  final String label;
  final Widget child;
  final AxisDirection side;

  @override
  State<SkHoverLabel> createState() => _SkHoverLabelState();
}

class _SkHoverLabelState extends State<SkHoverLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    // A tooltip is the non-modal popover species (0022): SkPopover owns the
    // OverlayPortal and positioning. It is barrier-less (hover drives show/hide,
    // so no page-blanketing tap-away) and undecorated (the tooltip keeps its own
    // stronger border), and it pins a fixed side, centred on the trigger.
    final (Alignment, Alignment, Offset) placement = switch (widget.side) {
      AxisDirection.up => (
          Alignment.topCenter,
          Alignment.bottomCenter,
          const Offset(0, -6)
        ),
      AxisDirection.down => (
          Alignment.bottomCenter,
          Alignment.topCenter,
          const Offset(0, 6)
        ),
      AxisDirection.left => (
          Alignment.centerLeft,
          Alignment.centerRight,
          const Offset(-6, 0)
        ),
      AxisDirection.right => (
          Alignment.centerRight,
          Alignment.centerLeft,
          const Offset(6, 0)
        ),
    };

    return SkPopover(
      open: _hovered,
      onDismiss: () => setState(() => _hovered = false),
      barrier: false,
      decorated: false,
      placement: placement,
      overlayBuilder: (BuildContext context) => IgnorePointer(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: SkSpace.s4, vertical: 5),
          decoration: BoxDecoration(
            color: c.surfaceOverlay,
            border: Border.all(color: c.borderStrong, width: SkDepth.hairline),
            boxShadow: SkDepth.popover(c.brightness),
          ),
          child: Text(
            widget.label,
            style: SkText.caption.copyWith(color: c.textPrimary),
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: widget.child,
      ),
    );
  }
}
