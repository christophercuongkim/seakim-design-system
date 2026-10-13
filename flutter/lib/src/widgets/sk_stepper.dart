import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

enum SkStepperOrientation { auto, horizontal, vertical }

enum _StepState { done, current, upcoming }

/// One step of an [SkStepper].
class SkStep {
  const SkStep({required this.key, required this.label, this.description});

  final String key;
  final String label;

  /// One short line under the label: a date, a wait.
  final String? description;
}

/// A labelled pipeline: every step named, the current one filled, the ones
/// behind it checked, the ones ahead outlined, a connector between.
///
/// Salesforce is the horizontal reference (every step labelled, current
/// filled); Grab is the vertical one (check circles, a connector, the label
/// beside each node), and it is the only pipeline any phone reference showed.
/// So [SkStepperOrientation.auto] goes vertical under `md`, measured on the
/// container ([SkResponsive]).
///
/// A display of where something is in a known sequence. Not a wizard's
/// progress (that is [SkProgress]) and not a status control on its own; pass
/// [onSelect] only for the moves the app allows, and the steps become buttons.
class SkStepper extends StatelessWidget {
  const SkStepper({
    super.key,
    required this.steps,
    this.current,
    this.orientation = SkStepperOrientation.auto,
    this.onSelect,
  });

  final List<SkStep> steps;

  /// The key of the current step. Steps before it are done, after it upcoming.
  final String? current;
  final SkStepperOrientation orientation;
  final ValueChanged<String>? onSelect;

  static const double _node = SkSpace.s7;

  @override
  Widget build(BuildContext context) {
    return SkResponsive(
      builder: (BuildContext context, SkBreakpoint bp, double _) {
        final bool vertical = orientation == SkStepperOrientation.vertical ||
            (orientation == SkStepperOrientation.auto && bp.isSm);
        return vertical ? _vertical(context) : _horizontal(context);
      },
    );
  }

  int get _currentIndex => steps.indexWhere((SkStep s) => s.key == current);

  _StepState _state(int i) {
    final int c = _currentIndex;
    if (i < c) return _StepState.done;
    if (i == c) return _StepState.current;
    return _StepState.upcoming;
  }

  Widget _nodeFor(SkColors c, int i, _StepState state) {
    final Color fill = switch (state) {
      _StepState.current => c.fillPrimary,
      _StepState.done => c.surfaceSelected,
      _StepState.upcoming => const Color(0x00000000),
    };
    final Color ink = switch (state) {
      _StepState.current => c.onPrimary,
      _StepState.done => c.textAccent,
      _StepState.upcoming => c.textTertiary,
    };
    return Container(
      width: _node,
      height: _node,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(
          color: state == _StepState.upcoming
              ? c.borderStrong
              : const Color(0x00000000),
        ),
      ),
      child: state == _StepState.done
          ? SkIcon(SkIcons.check,
              size: 12, weight: SkIconWeight.bold, color: ink)
          : Text('${i + 1}',
              style: SkText.data
                  .copyWith(fontSize: SkFontSize.xs, color: ink, height: 1)),
    );
  }

  Widget _label(SkColors c, SkStep step, _StepState state, bool centered) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          step.label,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: SkText.label.copyWith(
            color:
                state == _StepState.current ? c.textPrimary : c.textSecondary,
          ),
        ),
        if (step.description != null) ...<Widget>[
          const SizedBox(height: SkSpace.s1),
          Text(
            step.description!,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: SkText.caption.copyWith(color: c.textTertiary),
          ),
        ],
      ],
    );
  }

  Widget _wrap(SkStep step, _StepState state, Widget child) {
    final String announce = switch (state) {
      _StepState.done => '${step.label}, completed',
      _StepState.current => '${step.label}, current step',
      _StepState.upcoming => step.label,
    };
    if (onSelect == null) {
      return Semantics(label: announce, excludeSemantics: true, child: child);
    }
    return SkPressable(
      onPressed: () => onSelect!(step.key),
      semanticLabel: announce,
      builder: (BuildContext context, SkInteraction s) =>
          SkFocusRing(visible: s.focused, child: child),
    );
  }

  Widget _line(SkColors c, bool hidden, bool done, bool vertical) {
    final Color color = hidden
        ? const Color(0x00000000)
        : done
            ? c.borderStrong
            : c.borderSubtle;
    return vertical
        ? Expanded(child: Container(width: 2, color: color))
        : Expanded(child: Container(height: 2, color: color));
  }

  Widget _horizontal(BuildContext context) {
    final SkColors c = context.skColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          Expanded(
            child: _wrap(
              steps[i],
              _state(i),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _line(c, i == 0, _state(i) != _StepState.upcoming, false),
                      _nodeFor(c, i, _state(i)),
                      _line(c, i == steps.length - 1,
                          _state(i) == _StepState.done, false),
                    ],
                  ),
                  const SizedBox(height: SkSpace.s3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SkSpace.s2),
                    child: _label(c, steps[i], _state(i), true),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _vertical(BuildContext context) {
    final SkColors c = context.skColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          _wrap(
            steps[i],
            _state(i),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _nodeFor(c, i, _state(i)),
                      _line(c, i == steps.length - 1,
                          _state(i) == _StepState.done, true),
                    ],
                  ),
                  const SizedBox(width: SkSpace.s4),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: SkSpace.s1,
                        bottom: i == steps.length - 1 ? 0 : SkSpace.s6,
                      ),
                      child: _label(c, steps[i], _state(i), false),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
