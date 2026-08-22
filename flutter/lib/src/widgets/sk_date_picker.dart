import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_icon_button.dart';
import 'sk_input.dart';
import 'sk_popover.dart';

/* Per spec/DatePicker.md and decision 0004.

   Square cells with a 1px hairline gap, so a selected range renders as ONE
   CONTINUOUS BAR — no notches, nothing to reconcile at the joins. This is the rare
   case where the 0px rule produces a better object than the platform default.

   The grid is an affordance over a text field, never the only way in. There is no
   time picker: a time is a mono SkInput, or an SkSelect when the choices are
   genuinely enumerable. */

const List<String> _dow = <String>['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? _parseIso(String s) {
  final RegExp re = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  final RegExpMatch? m = re.firstMatch(s.trim());
  if (m == null) return null;
  final int y = int.parse(m.group(1)!);
  final int mo = int.parse(m.group(2)!);
  final int d = int.parse(m.group(3)!);
  final DateTime dt = DateTime(y, mo, d);
  return dt.year == y && dt.month == mo && dt.day == d ? dt : null;
}

bool _sameDay(DateTime? a, DateTime? b) =>
    a != null &&
    b != null &&
    a.year == b.year &&
    a.month == b.month &&
    a.day == b.day;

bool _between(DateTime d, DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  final DateTime lo = a.isBefore(b) ? a : b;
  final DateTime hi = a.isBefore(b) ? b : a;
  return d.isAfter(lo) && d.isBefore(hi);
}

/// Monday-first grid, six rows, including leading and trailing days.
List<DateTime> _monthGrid(int year, int month) {
  final DateTime first = DateTime(year, month, 1);
  final int offset = (first.weekday - 1) % 7;
  return List<DateTime>.generate(
      42, (int i) => DateTime(year, month, 1 - offset + i));
}

/// A date field, and the calendar grid that opens from it.
class SkDatePicker extends StatefulWidget {
  const SkDatePicker({
    super.key,
    this.value,
    this.rangeValue,
    this.onChanged,
    this.onRangeChanged,
    this.range = false,
    this.label,
    this.hint,
    this.error,
    this.isDateDisabled,
    this.bp = SkBreakpoint.lg,
    this.months,
  });

  final DateTime? value;
  final (DateTime?, DateTime?)? rangeValue;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<(DateTime?, DateTime?)>? onRangeChanged;

  /// Two endpoints. Picking before the start reorders rather than rejecting.
  final bool range;

  final String? label;
  final String? hint;

  /// Replaces [hint]. Cause, consequence, next step.
  final String? error;

  /// Return true to make a date unselectable.
  final bool Function(DateTime date)? isDateDisabled;

  /// At sm the overlay becomes a bottom sheet and cells grow to 44px.
  final SkBreakpoint bp;

  /// Months side by side. Defaults to 2 for a range at lg, otherwise 1.
  final int? months;

  @override
  State<SkDatePicker> createState() => _SkDatePickerState();
}

class _SkDatePickerState extends State<SkDatePicker> {
  late final TextEditingController _controller = TextEditingController();
  bool _open = false;
  DateTime? _hover;
  late DateTime _cursor;

  @override
  void initState() {
    super.initState();
    final DateTime anchor = widget.range
        ? (widget.rangeValue?.$1 ?? DateTime.now())
        : (widget.value ?? DateTime.now());
    _cursor = DateTime(anchor.year, anchor.month);
    _controller.text = _display;
  }

  @override
  void didUpdateWidget(SkDatePicker old) {
    super.didUpdateWidget(old);
    _controller.text = _display;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (DateTime?, DateTime?) get _selection =>
      widget.range ? (widget.rangeValue ?? (null, null)) : (widget.value, null);

  String get _display {
    final (DateTime? a, DateTime? b) = _selection;
    if (widget.range) {
      if (a == null) return '';
      return b == null ? _iso(a) : '${_iso(a)} – ${_iso(b)}';
    }
    return a == null ? '' : _iso(a);
  }

  int get _monthCount =>
      widget.months ?? (widget.range && widget.bp.isLg ? 2 : 1);

  void _pick(DateTime d) {
    if (!widget.range) {
      widget.onChanged?.call(d);
      setState(() => _open = false);
      return;
    }
    final (DateTime? a, DateTime? b) = _selection;
    if (a == null || b != null) {
      widget.onRangeChanged?.call((d, null));
      return;
    }
    widget.onRangeChanged?.call(d.isBefore(a) ? (d, a) : (a, d));
    setState(() {
      _hover = null;
      _open = false;
    });
  }

  void _commitText(String v) {
    if (widget.range) {
      final List<String> parts = v.split(RegExp(r'\s*[–-]\s*'));
      if (parts.length == 2) {
        final DateTime? a = _parseIso(parts[0]);
        final DateTime? b = _parseIso(parts[1]);
        if (a != null && b != null) widget.onRangeChanged?.call((a, b));
      }
      return;
    }
    final DateTime? d = _parseIso(v);
    if (d != null) widget.onChanged?.call(d);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    final Widget field = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: SkSpace.s3),
            child: Text(widget.label!,
                style: SkText.label.copyWith(color: c.textSecondary)),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: SkInput(
                controller: _controller,
                mono: true,
                invalid: widget.error != null,
                placeholder:
                    widget.range ? '2026-03-14 – 2026-03-21' : '2026-03-14',
                onChanged: _commitText,
              ),
            ),
            const SizedBox(width: SkSpace.s3),
            SkIconButton(
              icon: SkIcons.calendarBlank,
              label: 'Choose date',
              variant: SkIconButtonVariant.secondary,
              active: _open,
              onPressed: () => setState(() => _open = !_open),
            ),
          ],
        ),
        if (widget.error != null || widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(top: SkSpace.s3),
            child: Text(
              widget.error ?? widget.hint!,
              style: SkText.caption.copyWith(
                color: widget.error != null ? c.textDanger : c.textTertiary,
              ),
            ),
          ),
      ],
    );

    // The grid is the anchored popover species (0022): SkPopover owns the
    // OverlayPortal, positioning, tap-away, and Escape, and supplies the overlay
    // surface (fill, hairline, popover shadow). The grid escapes the field's clip
    // and width instead of pushing content down, which the old inline column could
    // not. At sm cells still grow to 44px via [_Month.touch].
    return SkPopover(
      open: _open,
      onDismiss: () => setState(() => _open = false),
      overlayBuilder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < _monthCount; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  left: i == 0
                      ? BorderSide.none
                      : BorderSide(
                          color: c.borderSubtle, width: SkDepth.hairline),
                ),
              ),
              child: _Month(
                year: _cursor.year + ((_cursor.month - 1 + i) ~/ 12),
                month: (_cursor.month - 1 + i) % 12 + 1,
                selection: _selection,
                hover: _hover,
                touch: widget.bp.isSm,
                showNav: i == 0,
                isDateDisabled: widget.isDateDisabled,
                onPick: _pick,
                onHover: widget.range
                    ? (DateTime d) => setState(() => _hover = d)
                    : null,
                onShift: (int delta) => setState(() {
                  _cursor = DateTime(_cursor.year, _cursor.month + delta);
                }),
              ),
            ),
        ],
      ),
      child: field,
    );
  }
}

class _Month extends StatelessWidget {
  const _Month({
    required this.year,
    required this.month,
    required this.selection,
    required this.hover,
    required this.touch,
    required this.showNav,
    required this.onPick,
    required this.onShift,
    this.onHover,
    this.isDateDisabled,
  });

  final int year;
  final int month;
  final (DateTime?, DateTime?) selection;
  final DateTime? hover;
  final bool touch;
  final bool showNav;
  final ValueChanged<DateTime> onPick;
  final ValueChanged<int> onShift;
  final ValueChanged<DateTime>? onHover;
  final bool Function(DateTime)? isDateDisabled;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final double size = touch ? SkControl.touch : SkControl.lg;
    final DateTime today = DateTime.now();
    final (DateTime? a, DateTime? b) = selection;
    // Preview the provisional span while the second endpoint is being chosen.
    final DateTime? provisional =
        a != null && b == null && hover != null ? hover : b;
    final List<DateTime> cells = _monthGrid(year, month);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SkSpace.s5, vertical: SkSpace.s4),
          decoration: BoxDecoration(
            border: Border(
              bottom:
                  BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
            ),
          ),
          child: Row(
            children: <Widget>[
              if (showNav)
                SkIconButton(
                  icon: SkIcons.caretLeft,
                  label: 'Previous month',
                  size: SkControl.sm,
                  onPressed: () => onShift(-1),
                ),
              Expanded(
                child: Text(
                  '${_months[month - 1]} $year',
                  textAlign: showNav ? TextAlign.center : TextAlign.center,
                  style: SkText.subheading.copyWith(color: c.textPrimary),
                ),
              ),
              if (showNav)
                SkIconButton(
                  icon: SkIcons.caretRight,
                  label: 'Next month',
                  size: SkControl.sm,
                  onPressed: () => onShift(1),
                ),
            ],
          ),
        ),
        // 1px gap showing the subtle border through, so the month reads as a ruled
        // grid and a range renders as one continuous bar.
        Container(
          color: c.borderSubtle,
          padding: const EdgeInsets.all(1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final String d in _dow)
                    Container(
                      width: size,
                      height: 26,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 1, bottom: 1),
                      color: c.surfaceOverlay,
                      child: Text(d,
                          style:
                              SkText.eyebrow.copyWith(color: c.textTertiary)),
                    ),
                ],
              ),
              for (int row = 0; row < 6; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (int col = 0; col < 7; col++)
                      _Cell(
                        date: cells[row * 7 + col],
                        size: size,
                        inMonth: cells[row * 7 + col].month == month,
                        today: _sameDay(cells[row * 7 + col], today),
                        endpoint: _sameDay(cells[row * 7 + col], a) ||
                            _sameDay(cells[row * 7 + col], provisional),
                        inRange: _between(cells[row * 7 + col], a, provisional),
                        disabled:
                            isDateDisabled?.call(cells[row * 7 + col]) ?? false,
                        onPick: onPick,
                        onHover: onHover,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatefulWidget {
  const _Cell({
    required this.date,
    required this.size,
    required this.inMonth,
    required this.today,
    required this.endpoint,
    required this.inRange,
    required this.disabled,
    required this.onPick,
    this.onHover,
  });

  final DateTime date;
  final double size;
  final bool inMonth;
  final bool today;
  final bool endpoint;
  final bool inRange;
  final bool disabled;
  final ValueChanged<DateTime> onPick;
  final ValueChanged<DateTime>? onHover;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    final Color bg = widget.endpoint
        ? c.fillAccent
        : widget.inRange
            ? c.surfaceSelected
            : _hover && !widget.disabled
                ? c.surfaceHover
                : c.surfaceRaised;

    final Color fg = widget.disabled
        ? c.textDisabled
        : widget.endpoint
            ? c.onAccent
            : widget.inRange
                ? c.textAccent
                : widget.inMonth
                    ? c.textPrimary
                    : c.textTertiary;

    return MouseRegion(
      cursor:
          widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        widget.onHover?.call(widget.date);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : () => widget.onPick(widget.date),
        child: Semantics(
          label:
              '${widget.date.day} ${_months[widget.date.month - 1]} ${widget.date.year}',
          selected: widget.endpoint || widget.inRange,
          enabled: !widget.disabled,
          button: true,
          child: Container(
            width: widget.size,
            height: widget.size,
            margin: const EdgeInsets.only(right: 1, bottom: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              // Today is an UNDERLINE: a fill means selected, a ring means focused,
              // and a ring vanishes once the date sits inside a range.
              border: widget.today
                  ? Border(
                      bottom: BorderSide(
                          color: c.borderAccent, width: SkDepth.emphasis))
                  : null,
            ),
            child: Text(
              '${widget.date.day}',
              style: SkText.data.copyWith(
                fontSize: SkFontSize.sm,
                color: fg,
                fontWeight: widget.endpoint ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
