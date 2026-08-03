import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Interaction states, resolved once so every widget reacts identically.
typedef SkStateBuilder = Widget Function(BuildContext context, SkInteraction state);

@immutable
class SkInteraction {
  const SkInteraction({
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.disabled = false,
  });

  final bool hovered;
  final bool pressed;
  final bool focused;
  final bool disabled;

  /// Hover only counts when the widget can actually be used.
  bool get liveHover => hovered && !disabled;
  bool get livePress => pressed && !disabled;
}

/// The interaction primitive every SeaKim control is built on.
///
/// Deliberately not [InkWell]: Material's ink ripple contradicts the system's
/// press rule, which is a 0.97 scale over 80ms. This gives hover, press, focus,
/// keyboard activation, a pointer cursor, and [Semantics] without any ink.
class SkPressable extends StatefulWidget {
  const SkPressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.disabled = false,
    this.pressScale,
    this.semanticLabel,
    this.isButton = true,
    this.focusNode,
    this.autofocus = false,
    this.cursor = SystemMouseCursors.click,
    this.behavior = HitTestBehavior.opaque,
  });

  final SkStateBuilder builder;
  final VoidCallback? onPressed;
  final bool disabled;

  /// Defaults to [SkMotion.pressScale]. Pass [SkMotion.pressScaleLarge] for big
  /// surfaces like cards, where 0.97 reads as a jolt, or 1.0 to opt out.
  final double? pressScale;

  final String? semanticLabel;

  /// False for rows and cards that are tappable but should not announce as buttons.
  final bool isButton;

  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor cursor;
  final HitTestBehavior behavior;

  @override
  State<SkPressable> createState() => _SkPressableState();
}

class _SkPressableState extends State<SkPressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _off => widget.disabled || widget.onPressed == null;

  void _set(void Function() fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final SkInteraction state = SkInteraction(
      hovered: _hovered,
      pressed: _pressed,
      focused: _focused,
      disabled: _off,
    );
    final double scale = _off || !_pressed
        ? 1.0
        : (widget.pressScale ?? SkMotion.pressScale);

    Widget result = AnimatedScale(
      scale: scale,
      duration: SkMotion.instant,
      curve: SkMotion.out,
      child: widget.builder(context, state),
    );

    result = MouseRegion(
      cursor: _off ? SystemMouseCursors.basic : widget.cursor,
      onEnter: (_) => _set(() => _hovered = true),
      onExit: (_) => _set(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: _off ? null : widget.onPressed,
        onTapDown: _off ? null : (_) => _set(() => _pressed = true),
        onTapUp: _off ? null : (_) => _set(() => _pressed = false),
        onTapCancel: _off ? null : () => _set(() => _pressed = false),
        child: result,
      ),
    );

    return Semantics(
      label: widget.semanticLabel,
      button: widget.isButton,
      enabled: !_off,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: !_off,
        onShowFocusHighlight: (bool v) => _set(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: result,
      ),
    );
  }
}

/// The focus ring: 2px accent, offset 2px from the control by a page-coloured gap.
///
/// Painted as an outer box rather than a BoxShadow so it survives on any
/// background, matching how the CSS token composes two rings.
class SkFocusRing extends StatelessWidget {
  const SkFocusRing({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return AnimatedContainer(
      duration: SkMotion.instant,
      curve: SkMotion.out,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(
          color: visible ? c.borderFocus : const Color(0x00000000),
          width: SkDepth.emphasis,
        ),
      ),
      child: child,
    );
  }
}
