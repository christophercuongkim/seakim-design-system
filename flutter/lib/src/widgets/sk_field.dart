import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Label, hint, and error scaffold. Every form control sits in one.
///
/// Labels are sentence case with no colon. Hints are one line. Errors replace the
/// hint rather than stacking, and follow the three-facts rule: cause, consequence,
/// next step.
class SkField extends StatelessWidget {
  const SkField({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.error,
    this.required = false,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? error;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final String? footer = error ?? hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (label != null) ...<Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label!, style: SkText.label.copyWith(color: c.textSecondary)),
              if (required)
                Padding(
                  padding: const EdgeInsets.only(left: SkSpace.s2),
                  child: ExcludeSemantics(
                    child: Text('*',
                        style: SkText.label.copyWith(color: c.textDanger)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SkSpace.s3),
        ],
        child,
        if (footer != null) ...<Widget>[
          const SizedBox(height: SkSpace.s3),
          Text(
            footer,
            style: SkText.caption
                .copyWith(color: error != null ? c.textDanger : c.textTertiary),
          ),
        ],
      ],
    );
  }
}
