import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// The one header every page shares: the title as the page's heading, a
/// [count] in secondary text beside it, a [badge] chip after that, [actions]
/// on the right (the view controls and the primary action), an optional
/// one-line [description], and a [toolbar] row under it for the filters. That
/// is the job-search shell pick; the references (Linear, Asana, Airtable,
/// Todoist, Whop) agree on the two rows and put a chip rather than a number
/// beside the title, which is what [badge] is for. Not sticky.
///
/// On a narrow container the title wraps, the actions stay on the row and the
/// toolbar wraps. No fill, no hairline (0037): type and whitespace.
class SkPageHeader extends StatelessWidget {
  const SkPageHeader({
    super.key,
    required this.title,
    this.count,
    this.badge,
    this.description,
    this.actions = const <Widget>[],
    this.toolbar = const <Widget>[],
  });

  /// The page's name. Rendered as the heading; one per page.
  final String title;

  /// The count, in secondary text beside the title.
  final String? count;

  /// An [SkBadge] or [SkTag] after the title: a status or a plan.
  final Widget? badge;

  /// One line under the title.
  final String? description;

  /// Right of the title: the primary action and at most two more.
  final List<Widget> actions;

  /// The second row: filters, tabs, sort, the view toggle.
  final List<Widget> toolbar;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: SkSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: SkSpace.s3,
                  runSpacing: SkSpace.s2,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: SkText.title.copyWith(color: c.textPrimary),
                      ),
                    ),
                    if (count != null)
                      Text(
                        count!,
                        style: SkText.subheading.copyWith(
                          color: c.textSecondary,
                          fontFeatures: SkText.tabular,
                        ),
                      ),
                    if (badge != null) badge!,
                  ],
                ),
              ),
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(width: SkSpace.s5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int i = 0; i < actions.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: SkSpace.s3),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
          if (description != null) ...<Widget>[
            const SizedBox(height: SkSpace.s4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                description!,
                style: SkText.bodySm.copyWith(color: c.textSecondary),
              ),
            ),
          ],
          if (toolbar.isNotEmpty) ...<Widget>[
            const SizedBox(height: SkSpace.s4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: SkSpace.s3,
              runSpacing: SkSpace.s3,
              children: toolbar,
            ),
          ],
        ],
      ),
    );
  }
}
