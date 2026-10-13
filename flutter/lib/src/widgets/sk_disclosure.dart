import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';
import 'sk_touch_target.dart';

/// One collapsible section: the summary row, an optional [meta] on its right
/// ("1 of 1", "4 items"), a chevron that turns, and the body below.
///
/// Several stack; more than one may be open; nothing closes a sibling. The
/// references (Twenty, Attio, Salesforce, Revolut) agree on all of that. The
/// web binding is native `<details>`; this is the same contract on a
/// [SkPressable] row and an [AnimatedSize] fold.
///
/// Controlled with [isOpen] + [onToggle], or uncontrolled with [initiallyOpen].
/// The row takes the hover tint and the touch floor on coarse pointers (0023);
/// the body is not indented (the references never indent). No border, no fill
/// (0037). Reduced motion skips the fold and the chevron turn (§0.9).
class SkDisclosure extends StatefulWidget {
  const SkDisclosure({
    super.key,
    required this.summary,
    required this.child,
    this.meta,
    this.isOpen,
    this.initiallyOpen = false,
    this.onToggle,
  });

  /// The row's text. A short noun phrase.
  final Widget summary;

  /// A count or value on the closed row, right of the summary.
  final Widget? meta;

  /// Controlled open state. Null for uncontrolled.
  final bool? isOpen;

  /// Initial state when uncontrolled.
  final bool initiallyOpen;

  /// Called with the new state after the user toggles.
  final ValueChanged<bool>? onToggle;

  final Widget child;

  @override
  State<SkDisclosure> createState() => _SkDisclosureState();
}

class _SkDisclosureState extends State<SkDisclosure> {
  late bool _internal = widget.initiallyOpen;

  bool get _open => widget.isOpen ?? _internal;

  void _toggle() {
    final bool next = !_open;
    if (widget.isOpen == null) setState(() => _internal = next);
    widget.onToggle?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool still = MediaQuery.disableAnimationsOf(context);
    final Duration d = still ? Duration.zero : SkMotion.base;
    final bool coarse = skCoarsePointer(context);

    final Widget row = SkPressable(
      onPressed: _toggle,
      semanticLabel: null,
      builder: (BuildContext context, SkInteraction s) => SkFocusRing(
        visible: s.focused,
        child: AnimatedContainer(
          duration: SkMotion.instant,
          curve: SkMotion.out,
          constraints: BoxConstraints(
              minHeight: coarse ? SkControl.touch : SkControl.md),
          padding: const EdgeInsets.symmetric(horizontal: SkSpace.s3),
          decoration: BoxDecoration(
            color: s.liveHover ? c.surfaceHover : const Color(0x00000000),
            borderRadius: BorderRadius.circular(SkRadius.lg),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: DefaultTextStyle.merge(
                  style: SkText.body.copyWith(color: c.textPrimary),
                  child: widget.summary,
                ),
              ),
              if (widget.meta != null) ...<Widget>[
                const SizedBox(width: SkSpace.s4),
                DefaultTextStyle.merge(
                  style: SkText.bodySm.copyWith(color: c.textSecondary),
                  child: widget.meta!,
                ),
              ],
              const SizedBox(width: SkSpace.s4),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: d,
                curve: SkMotion.out,
                child:
                    SkIcon(SkIcons.caretDown, size: 16, color: c.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(expanded: _open, child: row),
        ClipRect(
          child: AnimatedSize(
            duration: d,
            curve: SkMotion.out,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: SkSpace.s3, bottom: SkSpace.s5),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ),
      ],
    );
  }
}
