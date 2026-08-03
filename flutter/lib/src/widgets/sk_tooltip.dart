import 'package:flutter/widgets.dart';

import 'sk_icon_button.dart';

/// Names an unlabelled control on hover and focus.
///
/// One to four words, sentence case, no terminal punctuation. Never holds a link, a
/// button, or information needed to finish the task — tooltips do not exist on
/// touch, so anything essential must live elsewhere.
///
/// [SkIconButton] already carries one; wrap manually only for other controls.
class SkTooltip extends StatelessWidget {
  const SkTooltip({
    super.key,
    required this.label,
    required this.child,
    this.side = AxisDirection.up,
  });

  final String label;
  final Widget child;
  final AxisDirection side;

  @override
  Widget build(BuildContext context) =>
      SkHoverLabel(label: label, side: side, child: child);
}
