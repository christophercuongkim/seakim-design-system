import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_pressable.dart';

enum SkSwitchSize { sm, md }

/// An immediate on or off for a setting. No save step, no confirmation.
///
/// The knob springs across with [SkMotion.spring] — the one place overshoot is
/// visible inside a control. If the change needs saving, that is an SkCheckbox.
class SkSwitch extends StatelessWidget {
  const SkSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.size = SkSwitchSize.md,
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Sits at the leading edge; the switch pushes to the trailing edge.
  final String? label;

  final String? hint;
  final SkSwitchSize size;
  final bool disabled;

  double get _w => size == SkSwitchSize.sm ? 30 : 38;
  double get _h => size == SkSwitchSize.sm ? 18 : 22;
  double get _knob => size == SkSwitchSize.sm ? 12 : 16;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double pad = (_h - _knob) / 2;

    final Widget track = AnimatedContainer(
      duration: SkMotion.base,
      curve: SkMotion.out,
      width: _w + pad * 2,
      height: _h,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: value ? c.fillAccent : c.fillNeutral,
        borderRadius: BorderRadius.circular(SkRadius.pill),
        border: Border.all(
          color: value ? c.fillAccent : c.borderDefault,
          width: SkDepth.hairline,
        ),
      ),
      child: Stack(
        children: <Widget>[
          AnimatedAlign(
            duration: SkMotion.base,
            curve: SkMotion.spring,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: _knob,
              height: _knob,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? c.onAccent : SkStone.s400,
              ),
            ),
          ),
        ],
      ),
    );

    return SkPressable(
      onPressed: onChanged == null ? null : () => onChanged!(!value),
      disabled: disabled,
      isButton: false,
      pressScale: 1,
      semanticLabel: label,
      builder: (BuildContext context, SkInteraction s) => Semantics(
        toggled: value,
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
                  if (label != null || hint != null)
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
                  if (label != null || hint != null)
                    const SizedBox(width: SkSpace.s4),
                  Padding(
                    padding: EdgeInsets.only(top: hint != null ? 2 : 0),
                    child: track,
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
