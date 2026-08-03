import 'package:flutter/material.dart' show Theme, ThemeData, TextSelectionThemeData;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import 'sk_icon.dart';

enum SkInputSize { sm, md, lg }

/// Single-line text entry.
///
/// Square, hairline-bordered, with a 2px inset accent ring on focus. Always inside
/// an [SkField] so it has a label.
///
/// This is the one widget that keeps a Material ancestor underneath: [EditableText]
/// alone gives no selection handles, no context menu, no autofill, and no
/// platform-correct keyboard behaviour. Those are invisible until they are missing,
/// and rebuilding them faithfully is not worth it — so the chrome is ours and the
/// text machinery is Flutter's.
class SkInput extends StatefulWidget {
  const SkInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.size = SkInputSize.md,
    this.iconLeft,
    this.suffix,
    this.invalid = false,
    this.enabled = true,
    this.mono = false,
    this.obscure = false,
    this.keyboardType,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// An example, never a restatement of the label.
  final String? placeholder;

  final SkInputSize size;
  final SkGlyph? iconLeft;

  /// Static trailing text — USD, nights, a unit.
  final String? suffix;

  final bool invalid;
  final bool enabled;

  /// Set for codes, prices, and dates — anything that should align in a column.
  final bool mono;

  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  State<SkInput> createState() => _SkInputState();
}

class _SkInputState extends State<SkInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue);
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _ownsController = false;
  bool _ownsFocus = false;
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocus = widget.focusNode == null;
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    if (_ownsFocus) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  double get _height => switch (widget.size) {
        SkInputSize.sm => SkControl.sm,
        SkInputSize.md => SkControl.md,
        SkInputSize.lg => SkControl.lg,
      };

  double get _fontSize => switch (widget.size) {
        SkInputSize.sm => SkFontSize.xs,
        SkInputSize.md => SkFontSize.sm,
        SkInputSize.lg => SkFontSize.md,
      };

  double get _iconSize => switch (widget.size) {
        SkInputSize.sm => 14,
        SkInputSize.md => 16,
        SkInputSize.lg => 18,
      };

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    final Color border = widget.invalid
        ? c.textDanger
        : _focused
            ? c.borderFocus
            : _hovered && widget.enabled
                ? c.borderStrong
                : c.borderDefault;

    final TextStyle style = (widget.mono ? SkText.data : SkText.bodySm).copyWith(
      fontSize: _fontSize,
      color: c.textPrimary,
      height: 1.2,
    );

    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.text : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1 : 0.5,
        duration: SkMotion.instant,
        child: AnimatedContainer(
          duration: SkMotion.instant,
          curve: SkMotion.out,
          height: _height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.size == SkInputSize.lg ? SkSpace.s5 : SkSpace.s4,
          ),
          decoration: BoxDecoration(
            color: widget.enabled ? c.surfaceRaised : c.surfaceInset,
            border: Border.all(
              color: border,
              // The focus ring is inset here rather than outset, so a field inside a
              // tight grid does not overlap its neighbour.
              width: _focused ? SkDepth.emphasis : SkDepth.hairline,
            ),
          ),
          child: Row(
            children: <Widget>[
              if (widget.iconLeft != null) ...<Widget>[
                SkIcon(widget.iconLeft!, size: _iconSize, color: c.textTertiary),
                const SizedBox(width: SkSpace.s3),
              ],
              Expanded(
                child: Theme(
                  // Only the selection colours are borrowed from Material.
                  data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: c.textAccent,
                      selectionColor: c.fillAccent.withValues(alpha: 0.32),
                      selectionHandleColor: c.fillAccent,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      if (widget.placeholder != null)
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _controller,
                          builder: (BuildContext context, TextEditingValue v, _) =>
                              v.text.isEmpty
                                  ? Text(
                                      widget.placeholder!,
                                      style: style.copyWith(color: c.textTertiary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const SizedBox.shrink(),
                        ),
                      EditableText(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: style,
                        cursorColor: c.textAccent,
                        backgroundCursorColor: c.borderSubtle,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        readOnly: !widget.enabled,
                        obscureText: widget.obscure,
                        keyboardType: widget.keyboardType ?? TextInputType.text,
                        textInputAction: widget.textInputAction,
                        inputFormatters: widget.inputFormatters,
                        autofocus: widget.autofocus,
                        maxLines: 1,
                        selectionColor: c.fillAccent.withValues(alpha: 0.32),
                        cursorWidth: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.suffix != null) ...<Widget>[
                const SizedBox(width: SkSpace.s3),
                Text(
                  widget.suffix!,
                  style: SkText.data
                      .copyWith(fontSize: SkFontSize.xs, color: c.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
