import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import '../util/sk_fuzzy_match.dart';
import 'sk_field_trigger.dart';
import 'sk_icon.dart';
import 'sk_input.dart';
import 'sk_popover.dart';
import 'sk_pressable.dart';

@immutable
class SkComboboxOption<T> {
  const SkComboboxOption(
      {required this.value, required this.label, this.disabled = false});

  final T value;
  final String label;
  final bool disabled;
}

/// A searchable single-choice picker for a **long** list — currency, timezone,
/// country, language — the lists `SkSelect` cannot scan.
///
/// The axis is scannability, not row count (decision 0028, `spec/Combobox.md`):
/// reach for `SkSelect` when the user can *scan* for their option and
/// `SkCombobox` when they must *search* for it. Closed it is the shared
/// [SkFieldTrigger] — the same border, focus ring, caret, and 44px floor as
/// `SkSelect`, never re-derived. Open it is the anchored-popover species (0022,
/// via [SkPopover], non-modal): an [SkInput] filter pinned above a scrollable,
/// keyboard-navigable option list.
///
/// Matching is the shared, tiered [skMatchScore] by default — exact, prefix,
/// substring, then original list order within a tier — with [skFuzzyScore]
/// available per picker via [fuzzy]. Ranking is part of the contract, so the same
/// picker ranks the same in every app. When the query matches nothing the list
/// does not go blank: it names the filter and offers to clear it, per
/// `spec/Table.md`'s filtered-to-nothing precedent and
/// `guidelines/voice-and-tone.md`.
class SkCombobox<T> extends StatefulWidget {
  const SkCombobox({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.placeholder,
    this.label,
    this.searchPlaceholder,
    this.size = SkControl.md,
    this.invalid = false,
    this.enabled = true,
    this.fuzzy = false,
  });

  final List<SkComboboxOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;

  /// Shown in the closed trigger when nothing is selected.
  final String? placeholder;

  /// The field's accessible name, announced on the trigger. Falls back to the
  /// selected label or [placeholder] when null.
  final String? label;

  /// Placeholder for the filter input. Defaults to "Search".
  final String? searchPlaceholder;

  final double size;
  final bool invalid;
  final bool enabled;

  /// Opt into the scored-subsequence matcher ([skFuzzyScore]) instead of the
  /// default tiered [skMatchScore]. Reach for it only where the list's shape
  /// (short codes plus long names) justifies a scattered match.
  final bool fuzzy;

  @override
  State<SkCombobox<T>> createState() => _SkComboboxState<T>();
}

class _Ranked<T> {
  const _Ranked(this.option, this.index, this.score);
  final SkComboboxOption<T> option;
  final int index;
  final int score;
}

class _SkComboboxState<T> extends State<SkCombobox<T>> {
  bool _open = false;
  String _query = '';
  int _active = 0;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocus = FocusNode(debugLabel: 'SkCombobox.search');
  final GlobalKey _activeKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openMenu() {
    if (!widget.enabled) return;
    setState(() {
      _open = true;
      _active = 0;
    });
  }

  void _close() {
    if (!_open) return;
    setState(() {
      _open = false;
      _query = '';
      _active = 0;
    });
    _controller.clear();
  }

  void _onQueryChanged(String q) {
    setState(() {
      _query = q;
      _active = 0;
    });
  }

  void _clearQuery() {
    _controller.clear();
    _onQueryChanged('');
    _searchFocus.requestFocus();
  }

  int Function(String, String) get _matcher =>
      widget.fuzzy ? skFuzzyScore : skMatchScore;

  /// Rank per decision 0028: score descending, original index as tiebreaker so
  /// the order is stable within a tier (Dart's sort is not). An empty query
  /// scores everything 1, so the list stays in its authored order.
  List<_Ranked<T>> _ranked() {
    final int Function(String, String) match = _matcher;
    final List<_Ranked<T>> out = <_Ranked<T>>[];
    for (int i = 0; i < widget.options.length; i++) {
      final SkComboboxOption<T> o = widget.options[i];
      final int s = match(_query, o.label);
      if (s > 0) out.add(_Ranked<T>(o, i, s));
    }
    out.sort((_Ranked<T> a, _Ranked<T> b) {
      final int byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.index.compareTo(b.index);
    });
    return out;
  }

  void _pick(SkComboboxOption<T> o) {
    if (o.disabled) return;
    final T v = o.value;
    _close();
    widget.onChanged?.call(v);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!_open || event is KeyUpEvent) return KeyEventResult.ignored;
    final List<_Ranked<T>> ranked = _ranked();
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      if (ranked.isEmpty) return KeyEventResult.handled;
      setState(() => _active = (_active + 1) % ranked.length);
      _scrollActiveIntoView();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      if (ranked.isEmpty) return KeyEventResult.handled;
      setState(
          () => _active = (_active - 1 + ranked.length) % ranked.length);
      _scrollActiveIntoView();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_active >= 0 && _active < ranked.length) {
        _pick(ranked[_active].option);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _scrollActiveIntoView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = _activeKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            alignment: 0.5, duration: SkMotion.instant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool dense = widget.size <= SkControl.sm;
    final SkComboboxOption<T>? selected = widget.options
        .where((SkComboboxOption<T> o) => o.value == widget.value)
        .firstOrNull;

    return SkPopover(
      open: _open,
      onDismiss: _close,
      // decorated: the popover supplies the overlay surface (fill, hairline,
      // shadow); this widget only lays out the filter + list inside it.
      decorated: true,
      overlayBuilder: (BuildContext context) => _Surface<T>(
        onKey: _onKey,
        searchFocus: _searchFocus,
        controller: _controller,
        searchPlaceholder: widget.searchPlaceholder ?? 'Search',
        query: _query,
        onQueryChanged: _onQueryChanged,
        onClearQuery: _clearQuery,
        ranked: _ranked(),
        active: _active,
        activeKey: _activeKey,
        value: widget.value,
        onPick: _pick,
      ),
      child: SkFieldTrigger(
        open: _open,
        invalid: widget.invalid,
        enabled: widget.enabled,
        size: widget.size,
        onPressed: _openMenu,
        semanticLabel: widget.label ?? selected?.label ?? widget.placeholder,
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

class _Surface<T> extends StatelessWidget {
  const _Surface({
    required this.onKey,
    required this.searchFocus,
    required this.controller,
    required this.searchPlaceholder,
    required this.query,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.ranked,
    required this.active,
    required this.activeKey,
    required this.value,
    required this.onPick,
  });

  final FocusValueKeyEvent onKey;
  final FocusNode searchFocus;
  final TextEditingController controller;
  final String searchPlaceholder;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final List<_Ranked<T>> ranked;
  final int active;
  final GlobalKey activeKey;
  final T? value;
  final ValueChanged<SkComboboxOption<T>> onPick;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: SkMotion.base,
      curve: SkMotion.out,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, (1 - t) * -4), child: child),
      ),
      // A Focus above the filter input intercepts Down/Up/Enter before the text
      // field's editing shortcuts see them, so arrows move the active row while
      // the input keeps focus (0028's keyboard model).
      child: Focus(
        onKeyEvent: onKey,
        canRequestFocus: false,
        skipTraversal: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(SkSpace.s3),
                child: SkInput(
                  controller: controller,
                  focusNode: searchFocus,
                  autofocus: true,
                  placeholder: searchPlaceholder,
                  iconLeft: SkIcons.magnifyingGlass,
                  onChanged: onQueryChanged,
                ),
              ),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 264),
                  child: ranked.isEmpty
                      ? _EmptyRow(query: query, onClear: onClearQuery)
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              for (int i = 0; i < ranked.length; i++)
                                _OptionRow<T>(
                                  key: i == active ? activeKey : null,
                                  option: ranked[i].option,
                                  selected: ranked[i].option.value == value,
                                  active: i == active,
                                  onPick: onPick,
                                ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: SkSpace.s2),
            ],
          ),
        ),
      ),
    );
  }
}

typedef FocusValueKeyEvent = KeyEventResult Function(FocusNode, KeyEvent);

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.option,
    required this.selected,
    required this.active,
    required this.onPick,
  });

  final SkComboboxOption<T> option;
  final bool selected;
  final bool active;
  final ValueChanged<SkComboboxOption<T>> onPick;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return SkPressable(
      onPressed: option.disabled ? null : () => onPick(option),
      disabled: option.disabled,
      pressScale: 1,
      semanticLabel: option.label,
      builder: (BuildContext context, SkInteraction s) => Container(
        constraints: const BoxConstraints(minHeight: SkControl.touch),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
            horizontal: SkSpace.s5, vertical: SkSpace.s3),
        color: selected
            ? c.surfaceSelected
            : (active || s.liveHover)
                ? c.surfaceHover
                : const Color(0x00000000),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SkText.bodySm.copyWith(
                  color: option.disabled
                      ? c.textTertiary
                      : selected
                          ? c.textAccent
                          : c.textPrimary,
                ),
              ),
            ),
            if (selected)
              SkIcon(SkIcons.check,
                  size: 14, weight: SkIconWeight.bold, color: c.textAccent),
          ],
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SkSpace.s5, vertical: SkSpace.s4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'No options match "$query"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SkText.bodySm.copyWith(color: c.textTertiary),
            ),
          ),
          const SizedBox(width: SkSpace.s3),
          SkPressable(
            onPressed: onClear,
            pressScale: 1,
            semanticLabel: 'Clear',
            builder: (BuildContext context, SkInteraction s) => Text(
              'Clear',
              style: SkText.bodySm.copyWith(
                color: c.textAccent,
                decoration:
                    s.liveHover ? TextDecoration.underline : TextDecoration.none,
                decorationColor: c.textAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
