import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

@immutable
class SkSelectOption<T> {
  const SkSelectOption({required this.value, required this.label, this.disabled = false});

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
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  bool _open = false;

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _portal.show() : _portal.hide();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool dense = widget.size <= SkControl.sm;
    final SkSelectOption<T>? selected = widget.options
        .where((SkSelectOption<T> o) => o.value == widget.value)
        .firstOrNull;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (BuildContext context) => Stack(
          children: <Widget>[
            // Tap-away catcher. Transparent, full-screen, below the menu.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: const SizedBox.shrink(),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: _Menu<T>(
                options: widget.options,
                value: widget.value,
                onPick: (T v) {
                  _close();
                  widget.onChanged?.call(v);
                },
              ),
            ),
          ],
        ),
        child: SkPressable(
          onPressed: widget.enabled ? _toggle : null,
          disabled: !widget.enabled,
          pressScale: 1,
          semanticLabel: selected?.label ?? widget.placeholder,
          builder: (BuildContext context, SkInteraction s) {
            final Color border = !widget.enabled
                ? c.borderDisabled
                : widget.invalid
                    ? c.textDanger
                    : _open
                        ? c.borderFocus
                        : s.liveHover
                            ? c.borderStrong
                            : c.borderDefault;
            // Disabled is a token, not an opacity pass — every colour in the
            // subtree resolves to its disabled counterpart.
            final Color contentMuted =
                widget.enabled ? c.textTertiary : c.textDisabled;
            return AnimatedContainer(
              duration: SkMotion.instant,
              curve: SkMotion.out,
              height: widget.size,
              padding: const EdgeInsets.symmetric(horizontal: SkSpace.s4),
              decoration: BoxDecoration(
                color: widget.enabled ? c.surfaceRaised : c.fillDisabled,
                border: Border.all(
                  color: border,
                  width: _open ? SkDepth.emphasis : SkDepth.hairline,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
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
                  const SizedBox(width: SkSpace.s4),
                  SkIcon(SkIcons.caretDown, size: 14, color: contentMuted),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Menu<T> extends StatelessWidget {
  const _Menu({required this.options, required this.value, required this.onPick});

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
        child: Transform.translate(offset: Offset(0, (1 - t) * -4), child: child),
      ),
      child: Container(
        constraints: const BoxConstraints(minWidth: 180, maxHeight: 280),
        decoration: BoxDecoration(
          color: c.surfaceOverlay,
          border: Border.all(color: c.borderDefault, width: SkDepth.hairline),
          boxShadow: SkDepth.popover(c.brightness),
        ),
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
