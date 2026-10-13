import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// The one header every page shares: the title as the page's heading, a
/// [badge] beside it (a count or a status chip), [actions] on the right, an
/// optional one-line [description], and a [toolbar] row under it for filters,
/// tabs, sort and the view toggle.
///
/// The references (Linear, Asana, Airtable, Todoist, Whop) put the title
/// top-left at title size, the primary action right of it, and a second row for
/// everything that filters or switches the view. The count is a chip after the
/// title, never text; the view toggle lives in the toolbar. Not sticky.
///
/// On a narrow container the title wraps, the actions stay on the row and the
/// toolbar wraps. No fill, no hairline (0037): type and whitespace.
class SkPageHeader extends StatelessWidget {
  const SkPageHeader({
    super.key,
    required this.title,
    this.badge,
    this.description,
    this.actions = const <Widget>[],
    this.toolbar = const <Widget>[],
  });

  /// The page's name. Rendered as the heading; one per page.
  final String title;

  /// An [SkBadge] or [SkTag] after the title: a count or a status.
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
