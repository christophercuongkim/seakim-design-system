import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

/// Which job the button is doing. One primary per screen — if two things look
/// primary, one of them is wrong.
enum SkButtonVariant { primary, secondary, ghost, danger }

enum SkButtonSize { sm, md, lg }

/// The system's action primitive.
///
/// Labels are sentence case, verb first, 1 to 3 words: Book, Add leg, Delete trip.
/// Never OK, never Submit.
class SkButton extends StatelessWidget {
  const SkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SkButtonVariant.primary,
    this.size = SkButtonSize.md,
    this.iconLeft,
    this.iconRight,
    this.loading = false,
    this.loadingLabel = 'Working…',
    this.disabled = false,
    this.fullWidth = false,
    this.focusNode,
  });

  final String label;
  final VoidCallback? onPressed;
  final SkButtonVariant variant;
  final SkButtonSize size;
  final SkGlyph? iconLeft;
  final SkGlyph? iconRight;

  /// While loading, the label is replaced in place by a mono progress word and
  /// the control keeps its width. There are no spinners in this system.
  final bool loading;
  final String loadingLabel;

  final bool disabled;
  final bool fullWidth;
  final FocusNode? focusNode;

  double get _height => switch (size) {
        SkButtonSize.sm => SkControl.sm,
        SkButtonSize.md => SkControl.md,
        SkButtonSize.lg => SkControl.lg,
      };

  double get _padX => switch (size) {
        SkButtonSize.sm => SkSpace.s4,
        SkButtonSize.md => SkSpace.s5,
        SkButtonSize.lg => SkSpace.s6,
      };

  double get _fontSize => switch (size) {
        SkButtonSize.sm => SkFontSize.xs,
        SkButtonSize.md => SkFontSize.sm,
        SkButtonSize.lg => SkFontSize.md,
      };

  double get _iconSize => switch (size) {
        SkButtonSize.sm => 14,
        SkButtonSize.md => 16,
        SkButtonSize.lg => 20,
      };

  double get _gap => size == SkButtonSize.sm ? SkSpace.s2 : SkSpace.s3;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool off = disabled || loading || onPressed == null;

    return SkPressable(
      onPressed: onPressed,
      disabled: disabled || loading,
      focusNode: focusNode,
      semanticLabel: loading ? loadingLabel : label,
      builder: (BuildContext context, SkInteraction s) {
        final (Color bg, Color fg, Color border) = _palette(c, s);
        // Bold weight inside solid fills, where regular strokes thin out.
        final SkIconWeight iconWeight =
            variant == SkButtonVariant.primary || variant == SkButtonVariant.danger
                ? SkIconWeight.bold
                : SkIconWeight.regular;

        return SkFocusRing(
          visible: s.focused,
          child: AnimatedOpacity(
            opacity: off ? 0.4 : 1,
            duration: SkMotion.instant,
            child: AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              height: _height,
              width: fullWidth ? double.infinity : null,
              padding: EdgeInsets.symmetric(horizontal: _padX),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: SkDepth.hairline),
                // No borderRadius. No boxShadow. Deliberately not parameterised.
              ),
              child: Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: loading
                    ? <Widget>[
                        Text(
                          loadingLabel,
                          style: SkText.data.copyWith(
                            fontSize: _fontSize,
                            color: fg,
                          ),
                        ),
                      ]
                    : <Widget>[
                        if (iconLeft != null) ...<Widget>[
                          SkIcon(iconLeft!,
                              size: _iconSize, weight: iconWeight, color: fg),
                          SizedBox(width: _gap),
                        ],
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: SkText.label.copyWith(
                            fontSize: _fontSize,
                            color: fg,
                            letterSpacing: _fontSize * 0.005,
                          ),
                        ),
                        if (iconRight != null) ...<Widget>[
                          SizedBox(width: _gap),
                          SkIcon(iconRight!,
                              size: _iconSize, weight: iconWeight, color: fg),
                        ],
                      ],
              ),
            ),
          ),
        );
      },
    );
  }

  (Color, Color, Color) _palette(SkColors c, SkInteraction s) {
    switch (variant) {
      case SkButtonVariant.secondary:
        return (
          s.livePress
              ? c.surfaceActive
              : s.liveHover
                  ? c.surfaceHover
                  : const Color(0x00000000),
          c.textPrimary,
          s.liveHover || s.livePress ? c.borderStrong : c.borderDefault,
        );
      case SkButtonVariant.ghost:
        return (
          s.livePress
              ? c.surfaceActive
              : s.liveHover
                  ? c.surfaceHover
                  : const Color(0x00000000),
          c.textSecondary,
          const Color(0x00000000),
        );
      case SkButtonVariant.danger:
        return (
          s.livePress
              ? SkStatusPalette.danger500
              : s.liveHover
                  ? SkStatusPalette.danger400
                  : c.fillDanger,
          c.onDanger,
          const Color(0x00000000),
        );
      case SkButtonVariant.primary:
        return (
          s.livePress
              ? c.fillAccentActive
              : s.liveHover
                  ? c.fillAccentHover
                  : c.fillAccent,
          c.onAccent,
          const Color(0x00000000),
        );
    }
  }
}
