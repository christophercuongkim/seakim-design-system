import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/* Per spec/Slider.md and decision 0006.

   A fader, not a dial. The thumb is taller than the track and narrower than it is
   tall — that is what lets it read at 12px with no shadow, and a shadow would
   promise "floats above the page". A round thumb needs either a shadow or bulk. */

/// Coarse adjustment along a continuous or stepped range.
///
/// **Not for** exact values that matter — a price cap, a budget, a passenger count.
/// Pair with a mono [SkInput] or use the input alone.
class SkSlider extends StatefulWidget {
  const SkSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.label,
    this.hint,
    this.format,
    this.ticks = false,
    this.disabled = false,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  /// 0 for a continuous range.
  final double step;

  final String? label;
  final String? hint;

  /// Formats the value text. Defaults to a trimmed number.
  final String Function(double value)? format;

  /// Only honoured when [step] is set and there are fewer than 12 steps.
  final bool ticks;

  final bool disabled;

  @override
  State<SkSlider> createState() => _SkSliderState();
}

class _SkSliderState extends State<SkSlider> {
  bool _hover = false;
  bool _pressed = false;
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  double _snap(double v) {
    final double clamped = v.clamp(widget.min, widget.max);
    if (widget.step <= 0) return clamped;
    final double snapped =
        ((clamped - widget.min) / widget.step).round() * widget.step + widget.min;
    return snapped.clamp(widget.min, widget.max);
  }

  String get _text {
    if (widget.format != null) return widget.format!(widget.value);
    final double v = widget.value;
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  }

  void _emitFromLocal(double dx, double width) {
    if (widget.disabled || widget.onChanged == null) return;
    final double fraction = (dx / width).clamp(0.0, 1.0);
    widget.onChanged!(_snap(widget.min + fraction * (widget.max - widget.min)));
  }

  void _nudge(double delta) {
    if (widget.disabled || widget.onChanged == null) return;
    widget.onChanged!(_snap(widget.value + delta));
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double span = widget.max - widget.min;
    final double fraction = span == 0 ? 0 : (widget.value - widget.min) / span;
    final int tickCount = widget.ticks && widget.step > 0
        ? (span / widget.step).round() + 1
        : 0;
    final bool showTicks = tickCount > 1 && tickCount < 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: SkSpace.s3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.label!,
                    style: SkText.label.copyWith(
                      color: widget.disabled ? c.textDisabled : c.textSecondary,
                    ),
                  ),
                ),
                // The value is always text, never a tooltip on the thumb: a tooltip
                // is hidden by the finger on touch and animates a number the user is
                // trying to read.
                Text(
                  _text,
                  style: SkText.data.copyWith(
                    color: widget.disabled ? c.textDisabled : c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            return Focus(
              focusNode: _focus,
              onKeyEvent: (FocusNode node, KeyEvent event) {
                if (event is! KeyDownEvent) return KeyEventResult.ignored;
                final double small = widget.step > 0 ? widget.step : span / 100;
                final double big = widget.step > 0
                    ? (widget.step > span / 10 ? widget.step : span / 10)
                    : span / 10;
                switch (event.logicalKey.keyLabel) {
                  case 'Arrow Left':
                  case 'Arrow Down':
                    _nudge(-small);
                    return KeyEventResult.handled;
                  case 'Arrow Right':
                  case 'Arrow Up':
                    _nudge(small);
                    return KeyEventResult.handled;
                  case 'Page Down':
                    _nudge(-big);
                    return KeyEventResult.handled;
                  case 'Page Up':
                    _nudge(big);
                    return KeyEventResult.handled;
                  case 'Home':
                    if (!widget.disabled) widget.onChanged?.call(widget.min);
                    return KeyEventResult.handled;
                  case 'End':
                    if (!widget.disabled) widget.onChanged?.call(widget.max);
                    return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: MouseRegion(
                cursor: widget.disabled
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: GestureDetector(
                  onTapDown: (TapDownDetails d) {
                    setState(() => _pressed = true);
                    _focus.requestFocus();
                    _emitFromLocal(d.localPosition.dx, width);
                  },
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onHorizontalDragStart: (DragStartDetails d) {
                    setState(() => _pressed = true);
                    _focus.requestFocus();
                    _emitFromLocal(d.localPosition.dx, width);
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails d) =>
                      _emitFromLocal(d.localPosition.dx, width),
                  onHorizontalDragEnd: (_) => setState(() => _pressed = false),
                  child: Semantics(
                    slider: true,
                    label: widget.label,
                    value: _text,
                    increasedValue: _text,
                    decreasedValue: _text,
                    enabled: !widget.disabled,
                    child: AnimatedScale(
                      scale: _pressed && !widget.disabled
                          ? SkMotion.pressScale
                          : 1.0,
                      duration: SkMotion.instant,
                      curve: SkMotion.out,
                      child: SizedBox(
                        height: SkControl.touch,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            // Track: 4px, square ends.
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: c.surfaceInset,
                                border: Border.all(
                                    color: c.borderSubtle, width: SkDepth.hairline),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: fraction,
                              child: Container(
                                height: 4,
                                color: widget.disabled ? c.fillDisabled : c.fillAccent,
                              ),
                            ),
                            if (showTicks)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: SkControl.touch / 2 + 6,
                                child: SizedBox(
                                  height: 6,
                                  child: Stack(
                                    children: <Widget>[
                                      for (int i = 0; i < tickCount; i++)
                                        Positioned(
                                          left: (width - 1) * (i / (tickCount - 1)),
                                          child: Container(
                                              width: 1, height: 6, color: c.borderDefault),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            // Thumb: 12 x 20. Taller than the track, narrower than
                            // it is tall — a mechanical fader position.
                            Positioned(
                              left: (width - 12) * fraction,
                              child: Container(
                                width: 12,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: widget.disabled ? c.fillDisabled : c.fillAccent,
                                  border: Border.all(
                                    color: widget.disabled
                                        ? c.borderDisabled
                                        : (_focus.hasFocus || _hover)
                                            ? c.borderFocus
                                            : c.borderStrong,
                                    width: SkDepth.hairline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(top: SkSpace.s3),
            child: Text(
              widget.hint!,
              style: SkText.caption.copyWith(color: c.textTertiary),
            ),
          ),
      ],
    );
  }
}
