import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_field_trigger.dart';
import 'sk_icon.dart';
import 'sk_popover.dart';
import 'sk_pressable.dart';

@immutable
class SkSelectOption<T> {
  const SkSelectOption(
      {required this.value, required this.label, this.disabled = false});

  final T value;
  final String label;
  final bool disabled;
}

/// Single choice from a list of four or more.
///
/// Opens a hairline-bordered popover anchored to the control — one of the few
/// shadowed surfaces, because it floats above the page. For two or three short
/// options use SkSegmentedControl instead; it shows every choice at once.
class SkSelect<T> extends StatefulWidget {
  const SkSelect({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.placeholder,
    this.size = SkControl.md,
    this.invalid = false,
    this.enabled = true,
  });

  final List<SkSelectOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final double size;
  final bool invalid;
  final bool enabled;

  @override
  State<SkSelect<T>> createState() => _SkSelectState<T>();
}

class _SkSelectState<T> extends State<SkSelect<T>> {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  void _close() {
    if (_open) setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool dense = widget.size <= SkControl.sm;
    final SkSelectOption<T>? selected = widget.options
        .where((SkSelectOption<T> o) => o.value == widget.value)
        .firstOrNull;

    // The anchored menu is the popover species (0022): SkPopover owns the
    // OverlayPortal, follower positioning, tap-away, and Escape; the menu only
    // supplies its list. Non-modal — focus is free to move into the options.
    return SkPopover(
      open: _open,
      onDismiss: _close,
      overlayBuilder: (BuildContext context) => _Menu<T>(
        options: widget.options,
        value: widget.value,
        onPick: (T v) {
          _close();
          widget.onChanged?.call(v);
        },
      ),
      // The closed-state chrome (border, focus ring, caret, touch floor) is the
      // shared SkFieldTrigger — the same part SkCombobox uses (0028). Reading the
      // focus ring from that one place is why the select can no longer ship
      // without it, and why a keyboard-focused-but-closed select now rings.
      child: SkFieldTrigger(
        open: _open,
        invalid: widget.invalid,
        enabled: widget.enabled,
        size: widget.size,
        onPressed: _toggle,
        semanticLabel: selected?.label ?? widget.placeholder,
        child: Text(
          selected?.label ?? widget.placeholder ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: SkText.bodySm.copyWith(
            fontSize: dense ? SkFontSize.xs : SkFontSize.sm,
            color: !widget.enabled
                ? c.textDisabled
                : selected == null
                    ? c.textTertiary
                    : c.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu(
      {required this.options, required this.value, required this.onPick});

  final List<SkSelectOption<T>> options;
  final T? value;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: SkMotion.base,
      curve: SkMotion.out,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, (1 - t) * -4), child: child),
      ),
      // Surface (overlay fill, hairline, popover shadow) is supplied by SkPopover;
      // the menu only sizes and scrolls its options.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180, maxHeight: 280),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: options.map((SkSelectOption<T> o) {
              final bool on = o.value == value;
              return SkPressable(
                onPressed: o.disabled ? null : () => onPick(o.value),
                disabled: o.disabled,
                pressScale: 1,
                semanticLabel: o.label,
                builder: (BuildContext context, SkInteraction s) => Container(
                  constraints: const BoxConstraints(minHeight: SkControl.touch),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                      horizontal: SkSpace.s5, vertical: SkSpace.s3),
                  color: on
                      ? c.surfaceSelected
                      : s.liveHover
                          ? c.surfaceHover
                          : const Color(0x00000000),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          o.label,
                          style: SkText.bodySm.copyWith(
                            color: o.disabled
                                ? c.textTertiary
                                : on
                                    ? c.textAccent
                                    : c.textPrimary,
                          ),
                        ),
                      ),
                      if (on)
                        SkIcon(SkIcons.check,
                            size: 14,
                            weight: SkIconWeight.bold,
                            color: c.textAccent),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
