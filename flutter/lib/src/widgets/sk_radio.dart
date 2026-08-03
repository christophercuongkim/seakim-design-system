import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_pressable.dart';

/// One choice in an [SkRadioGroup].
@immutable
class SkRadioOption<T> {
  const SkRadioOption({required this.value, required this.label, this.hint, this.disabled = false});

  final T value;
  final String label;

  /// One line under the label. Use it when options need explaining — that is the
  /// main reason to choose radios over a segmented control.
  final String? hint;

  final bool disabled;
}

/// Mutually exclusive choice with the whole set visible.
///
/// Circular by exception, like [SkAvatar]. Use for 2 to 5 options that each need a
/// sentence; otherwise SkSegmentedControl for short ones, SkSelect for long lists.
/// There is deliberately no single-radio widget — a lone radio is always a mistake.
class SkRadioGroup<T> extends StatelessWidget {
  const SkRadioGroup({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.horizontal = false,
    this.disabled = false,
  });

  final List<SkRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;

  /// Only for two short labels with no hints.
  final bool horizontal;

  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < options.length; i++) {
      if (i > 0) {
        children.add(SizedBox(
          width: horizontal ? SkSpace.s7 : 0,
          height: horizontal ? 0 : SkSpace.s4,
        ));
      }
      children.add(_row(context, options[i]));
    }

    return Semantics(
      container: true,
      child: horizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: children)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }

  Widget _row(BuildContext context, SkRadioOption<T> option) {
    final SkColors c = context.skColors;
    final bool on = value == option.value;
    final bool off = disabled || option.disabled || onChanged == null;

    return SkPressable(
      onPressed: off ? null : () => onChanged!(option.value),
      disabled: off,
      isButton: false,
      pressScale: 1,
      semanticLabel: option.label,
      builder: (BuildContext context, SkInteraction s) => Semantics(
        inMutuallyExclusiveGroup: true,
        checked: on,
        child: SkFocusRing(
          visible: s.focused,
          child: AnimatedOpacity(
            opacity: off ? 0.4 : 1,
            duration: SkMotion.instant,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SkControl.touch),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: option.hint != null
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: option.hint != null ? 2 : 0),
                    child: AnimatedContainer(
                      duration: SkMotion.instant,
                      curve: SkMotion.out,
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surfaceRaised,
                        border: Border.all(
                          color: on
                              ? c.fillAccent
                              : s.liveHover
                                  ? c.borderStrong
                                  : c.borderDefault,
                          width: on ? SkDepth.emphasis : SkDepth.hairline,
                        ),
                      ),
                      child: AnimatedScale(
                        scale: on ? 1 : 0,
                        duration: SkMotion.base,
                        curve: SkMotion.pop,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.fillAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SkSpace.s4),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(option.label,
                            style: SkText.bodySm.copyWith(color: c.textPrimary)),
                        if (option.hint != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(option.hint!,
                                style: SkText.caption
                                    .copyWith(color: c.textTertiary)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
