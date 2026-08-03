import 'package:flutter/material.dart' show Theme, ThemeData, TextSelectionThemeData;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';

/// Multi-line text entry — trip notes, trade messages, feedback.
///
/// Same chrome as [SkInput]. Grows to [maxLines] then scrolls, so it can never
/// break a column. Like SkInput, it keeps a minimal Material ancestor for selection
/// handles and the platform context menu.
class SkTextarea extends StatefulWidget {
  const SkTextarea({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.minLines = 4,
    this.maxLines = 10,
    this.invalid = false,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final int minLines;
  final int maxLines;
  final bool invalid;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<SkTextarea> createState() => _SkTextareaState();
}

class _SkTextareaState extends State<SkTextarea> {
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

    final TextStyle style = SkText.bodySm.copyWith(color: c.textPrimary);

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
          padding: const EdgeInsets.all(SkSpace.s4),
          decoration: BoxDecoration(
            color: widget.enabled ? c.surfaceRaised : c.surfaceInset,
            border: Border.all(
              color: border,
              width: _focused ? SkDepth.emphasis : SkDepth.hairline,
            ),
          ),
          child: Theme(
            data: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: c.textAccent,
                selectionColor: c.fillAccent.withValues(alpha: 0.32),
                selectionHandleColor: c.fillAccent,
              ),
            ),
            child: Stack(
              children: <Widget>[
                if (widget.placeholder != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (BuildContext context, TextEditingValue v, _) =>
                        v.text.isEmpty
                            ? Text(widget.placeholder!,
                                style: style.copyWith(color: c.textTertiary))
                            : const SizedBox.shrink(),
                  ),
                EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: style,
                  cursorColor: c.textAccent,
                  backgroundCursorColor: c.borderSubtle,
                  onChanged: widget.onChanged,
                  readOnly: !widget.enabled,
                  minLines: widget.minLines,
                  maxLines: widget.maxLines,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  selectionColor: c.fillAccent.withValues(alpha: 0.32),
                  cursorWidth: 1.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
