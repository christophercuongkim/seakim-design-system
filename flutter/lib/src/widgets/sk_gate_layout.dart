import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import 'sk_card.dart';

/// The page outside the shell: sign-in, a gate, a paywall, a wizard. The
/// [brand] centred above, one column of content ([width], 576 by default),
/// top-aligned under a fixed margin, an optional [footer] for the legal line,
/// full-bleed on a phone. [card] wraps the column in an [SkCard]; off by
/// default, because most references put the content straight on the page.
///
/// Fills its parent and scrolls when the content is taller; the footer stays
/// at the bottom of the viewport until the content pushes it down.
class SkGateLayout extends StatelessWidget {
  const SkGateLayout({
    super.key,
    required this.child,
    this.brand,
    this.footer,
    this.card = false,
    this.width = 576,
  });

  /// The wordmark or mark. Not a heading; the page's heading is in [child].
  final Widget? brand;
  final Widget child;
  final Widget? footer;
  final bool card;
  final double width;

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
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width),
                        child: SizedBox(width: double.infinity, child: body),
                      ),
                      if (footer != null) ...<Widget>[
                        const Spacer(),
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
