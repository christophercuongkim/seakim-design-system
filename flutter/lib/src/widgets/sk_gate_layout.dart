import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import 'sk_card.dart';

enum SkGateAlign { center, top }

/// The page outside the shell: sign-in, a gate, a paywall, a wizard. The
/// [brand] centred at the top, one [SkCard] centred in the remaining height
/// ([width] 384, full width on a phone), the [footer] at the bottom: the
/// job-search gates pick. A wizard passes `width: 576` and
/// [SkGateAlign.top]. [card] is on by default.
///
/// Fills its parent and scrolls when the content is taller; the footer stays
/// at the bottom of the viewport until the content pushes it down.
class SkGateLayout extends StatelessWidget {
  const SkGateLayout({
    super.key,
    required this.child,
    this.brand,
    this.footer,
    this.card = true,
    this.width = 384,
    this.align = SkGateAlign.center,
  });

  /// The wordmark or mark. Not a heading; the page's heading is in [child].
  final Widget? brand;
  final Widget child;
  final Widget? footer;
  final bool card;
  final double width;

  /// Where the column sits in the remaining height: centred for a gate, top
  /// for a wizard whose screens change length.
  final SkGateAlign align;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) {
        final bool narrow = bp.isSm;
        final Widget body =
            card ? SkCard(padding: SkSpace.s7, child: child) : child;
        return ColoredBox(
          color: c.surfacePage,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: narrow
                      ? const EdgeInsets.fromLTRB(
                          SkSpace.s5, SkSpace.s7, SkSpace.s5, SkSpace.s5)
                      : const EdgeInsets.fromLTRB(
                          SkSpace.s7, SkSpace.s11, SkSpace.s7, SkSpace.s7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (brand != null) ...<Widget>[
                        DefaultTextStyle.merge(
                          style: SkText.heading.copyWith(color: c.textPrimary),
                          child: brand!,
                        ),
                        const SizedBox(height: SkSpace.s8),
                      ],
                      Expanded(
                        child: Align(
                          alignment: align == SkGateAlign.center
                              ? Alignment.center
                              : Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width),
                            child:
                                SizedBox(width: double.infinity, child: body),
                          ),
                        ),
                      ),
                      if (footer != null) ...<Widget>[
                        const SizedBox(height: SkSpace.s8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width),
                          child: DefaultTextStyle.merge(
                            style:
                                SkText.caption.copyWith(color: c.textTertiary),
                            textAlign: TextAlign.center,
                            child: footer!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
