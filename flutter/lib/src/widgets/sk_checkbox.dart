import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

/// One independent yes or no, or a list of them.
///
/// Takes effect on save, not on tap. If the change applies immediately it is an
/// SkSwitch, not a checkbox.
class SkCheckbox extends StatelessWidget {
  const SkCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.indeterminate = false,
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  /// One line under the label.
  final String? hint;

  /// Mixed state for a parent of partially selected children.
  final bool indeterminate;

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool marked = value || indeterminate;

    return SkPressable(
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      disabled: disabled,
      isButton: false,
      pressScale: 1,
      semanticLabel: label,
      builder: (BuildContext context, SkInteraction s) => Semantics(
        checked: value,
        mixed: indeterminate,
        child: SkFocusRing(
          visible: s.focused,
          child: AnimatedOpacity(
            opacity: s.disabled ? 0.4 : 1,
            duration: SkMotion.instant,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SkControl.touch),
              child: Row(
                crossAxisAlignment: hint != null
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: hint != null ? 2 : 0),
                    child: AnimatedScale(
                      scale: marked ? 1 : 0.94,
                      duration: SkMotion.instant,
                      curve: SkMotion.pop,
                      child: AnimatedContainer(
                        duration: SkMotion.instant,
                        curve: SkMotion.out,
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: marked ? c.fillAccent : c.surfaceRaised,
                          border: Border.all(
                            color: marked
                                ? c.fillAccent
                                : s.liveHover
                                    ? c.borderStrong
                                    : c.borderDefault,
                            width: SkDepth.hairline,
                          ),
                        ),
                        child: marked
                            ? SkIcon(
                                indeterminate
                                    ? SkIcons.minus
                                    : SkIcons.check,
                                size: 11,
                                weight: SkIconWeight.bold,
                                color: c.onAccent,
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (label != null || hint != null) ...<Widget>[
                    const SizedBox(width: SkSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (label != null)
                            Text(label!,
                                style:
                                    SkText.bodySm.copyWith(color: c.textPrimary)),
                          if (hint != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(hint!,
                                  style: SkText.caption
                                      .copyWith(color: c.textTertiary)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
