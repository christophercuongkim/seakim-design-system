import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_pressable.dart';

/// A bordered container for one coherent thing.
///
/// The entire recipe: 1px subtle border, no radius, card surface, 16px padding.
/// No shadow, because a card sits in the layout rather than above it.
class SkCard extends StatelessWidget {
  const SkCard({
    super.key,
    this.child,
    this.eyebrow,
    this.title,
    this.meta,
    this.media,
    this.footer,
    this.onPressed,
    this.padding = SkSpace.s5,
    this.borderless = false,
  });

  final Widget? child;

  /// Uppercase mono label above the title.
  final String? eyebrow;

  final String? title;

  /// One quiet line under the title.
  final String? meta;

  /// Sits flush at the top, outside the padding — an image or a placeholder.
  final Widget? media;

  /// A footer row, separated by a hairline.
  final Widget? footer;

  /// Makes the whole card a target. Uses the gentler press scale, since 0.97 on a
  /// large surface reads as a jolt.
  final VoidCallback? onPressed;

  final double padding;

  /// Drops the border for cards that butt against a container edge, as they do in
  /// full-bleed mobile lists.
  final bool borderless;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (media != null) media!,
        if (eyebrow != null || title != null || meta != null || child != null)
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (eyebrow != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SkSpace.s3),
                    child: Text(
                      eyebrow!.toUpperCase(),
                      style: SkText.eyebrow.copyWith(color: c.textTertiary),
                    ),
                  ),
                if (title != null)
                  Text(
                    title!,
                    style: SkText.subheading.copyWith(color: c.textPrimary),
                  ),
                if (meta != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SkSpace.s2),
                    child: Text(
                      meta!,
                      style: SkText.caption.copyWith(color: c.textTertiary),
                    ),
                  ),
                if (child != null)
                  Padding(
                    padding: EdgeInsets.only(
                        top: (title != null || meta != null) ? SkSpace.s4 : 0),
                    child: child!,
                  ),
              ],
            ),
          ),
        if (footer != null) ...<Widget>[
          Container(height: SkDepth.hairline, color: c.borderSubtle),
          Padding(padding: EdgeInsets.all(padding), child: footer!),
        ],
      ],
    );

    if (onPressed == null) {
      return DecoratedBox(
        decoration: _decoration(c, false),
        child: content,
      );
    }

    return SkPressable(
      onPressed: onPressed,
      isButton: false,
      pressScale: SkMotion.pressScaleLarge,
      builder: (BuildContext context, SkInteraction s) => SkFocusRing(
        visible: s.focused,
        child: AnimatedContainer(
          duration: SkMotion.base,
          curve: SkMotion.out,
          decoration: _decoration(c, s.liveHover),
          child: content,
        ),
      ),
    );
  }

  BoxDecoration _decoration(SkColors c, bool hovered) => BoxDecoration(
        // Hover is a lightness shift, never a lift — nothing in the layout moves,
        // because nothing in the layout has depth.
        color: hovered ? c.surfaceHover : c.surfaceCard,
        border: borderless
            ? Border(
                top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
              )
            : Border.all(color: c.borderSubtle, width: SkDepth.hairline),
      );
}
