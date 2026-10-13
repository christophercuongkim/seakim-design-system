import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// A run of [SkListRow]s under one eyebrow heading, with the dividers between
/// them: a [SkColors.borderSubtle] hairline (the one place 0037 keeps one,
/// between rows) or none, for rows that are fills with a gap.
class SkListGroup extends StatelessWidget {
  const SkListGroup({
    super.key,
    required this.children,
    this.heading,
    this.divider = true,
  });

  /// An eyebrow: 'Account', 'Yesterday'.
  final String? heading;
  final List<Widget> children;

  /// A hairline between rows. False leaves a gap instead.
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (heading != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SkSpace.s5),
            child: Semantics(
              header: true,
              child: Text(
                heading!.toUpperCase(),
                style: SkText.eyebrow.copyWith(color: c.textTertiary),
              ),
            ),
          ),
          const SizedBox(height: SkSpace.s3),
        ],
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0)
            divider
                ? Container(height: 1, color: c.borderSubtle)
                : const SizedBox(height: SkSpace.s3),
          children[i],
        ],
      ],
    );
  }
}
