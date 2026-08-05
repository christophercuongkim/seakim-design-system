import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../theme/sk_breakpoints.dart';
import '../theme/sk_theme.dart';
import '../tokens/sk_icons.g.dart';
import 'sk_empty_state.dart';
import 'sk_icon.dart';
import 'sk_pressable.dart';

/* Per spec/Table.md and decision 0003.

   Two layouts from one column definition: a table from md up, stacked list rows at
   sm. The sm layout is not a fallback — a six-column table cannot be read on a
   phone, and horizontal scroll takes the header, and therefore the sort control,
   off screen. */

enum SkTableDensity { comfortable, compact }

enum SkSortDirection { ascending, descending }

@immutable
class SkTableSort {
  const SkTableSort({required this.key, this.direction = SkSortDirection.descending});

  final String key;
  final SkSortDirection direction;

  bool get isDescending => direction == SkSortDirection.descending;
}

/// One column. The responsive metadata is the part that cannot be derived — every
/// table declares by hand which columns drop first, which single figure survives to
/// sm, and what the secondary line says.
@immutable
class SkTableColumn<T> {
  const SkTableColumn({
    required this.key,
    required this.label,
    required this.cell,
    this.numeric = false,
    this.identifying = false,
    this.secondary,
    this.survives = false,
    this.subLabel,
    this.priority = 1,
    this.sortable = true,
    this.width,
  });

  final String key;
  final String label;

  /// Builds the cell. Widgets, so a cell can hold an avatar or a badge.
  final Widget Function(T row) cell;

  /// Mono, tabular, right-aligned. Use for anything compared down a column.
  final bool numeric;

  /// The leftmost identifying column. Never dropped, and it becomes the primary
  /// line at sm.
  final bool identifying;

  /// Plain text for the sm secondary line. Joined with a middle dot.
  final String Function(T row)? secondary;

  /// The one numeric column that survives to sm.
  final bool survives;

  /// Small line under the surviving figure at sm, e.g. "proj 18.4".
  final String Function(T row)? subLabel;

  /// 3 drops at md. Leave at 1 to always show.
  final int priority;

  final bool sortable;
  final double? width;
}

class SkTable<T> extends StatelessWidget {
  const SkTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    this.bp = SkBreakpoint.lg,
    this.density = SkTableDensity.comfortable,
    this.sort,
    this.onSort,
    this.selectedKey,
    this.onSelectRow,
    this.actions,
    this.empty,
    this.matrix = false,
    this.caption,
  });

  final List<SkTableColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowKey;
  final SkBreakpoint bp;
  final SkTableDensity density;
  final SkTableSort? sort;
  final ValueChanged<String>? onSort;
  final Object? selectedKey;
  final ValueChanged<T>? onSelectRow;

  /// Trailing cell. Revealed on hover from md up, always focusable.
  final List<Widget> Function(T row)? actions;

  /// Shown instead of the body when [rows] is empty. Distinguish "empty" from
  /// "filtered to nothing" — they need different copy.
  final Widget? empty;

  /// Every scrolling column shares a unit, so it may scroll at sm rather than
  /// restacking. Only legitimate for a genuine stat matrix.
  final bool matrix;

  /// Screen-reader description of what the table contains.
  final String? caption;

  EdgeInsets get _cellPad => density == SkTableDensity.compact
      ? const EdgeInsets.symmetric(horizontal: SkSpace.s5, vertical: 4)
      : const EdgeInsets.symmetric(horizontal: SkSpace.s5, vertical: SkSpace.s4);

  List<SkTableColumn<T>> get _visible => switch (bp) {
        SkBreakpoint.lg => columns,
        SkBreakpoint.md =>
          columns.where((SkTableColumn<T> c) => c.priority != 3).toList(),
        SkBreakpoint.sm => columns,
      };

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;

    if (rows.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: c.surfaceCard,
          border: Border.all(color: c.borderSubtle, width: SkDepth.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SkSpace.s6),
          child: empty ??
              const SkEmptyState(compact: true, title: 'Nothing here yet'),
        ),
      );
    }

    if (bp.isSm && !matrix) return _listRows(context);
    return _table(context);
  }

  Widget _listRows(BuildContext context) {
    final SkColors c = context.skColors;
    final SkTableColumn<T> id = columns.firstWhere(
      (SkTableColumn<T> col) => col.identifying,
      orElse: () => columns.first,
    );
    final SkTableColumn<T>? figure = columns
        .where((SkTableColumn<T> col) => col.numeric && col.survives)
        .firstOrNull;
    final List<SkTableColumn<T>> secondary =
        columns.where((SkTableColumn<T> col) => col.secondary != null).toList();

    return Semantics(
      container: true,
      label: caption,
      child: DecoratedBox(
        decoration: BoxDecoration(color: c.surfaceCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: rows.map((T row) {
            return SkPressable(
              onPressed: onSelectRow == null ? null : () => onSelectRow!(row),
              isButton: false,
              pressScale: SkMotion.pressScaleLarge,
              builder: (BuildContext context, SkInteraction s) => Container(
                constraints: const BoxConstraints(minHeight: SkControl.touch),
                padding: const EdgeInsets.symmetric(
                    horizontal: SkSpace.s5, vertical: SkSpace.s4),
                decoration: BoxDecoration(
                  color: s.liveHover ? c.surfaceHover : null,
                  border: Border(
                    top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DefaultTextStyle.merge(
                            style: SkText.label.copyWith(
                              fontSize: SkFontSize.md,
                              color: c.textPrimary,
                            ),
                            child: id.cell(row),
                          ),
                          if (secondary.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                secondary
                                    .map((SkTableColumn<T> col) => col.secondary!(row))
                                    .where((String v) => v.isNotEmpty)
                                    .join(' · '),
                                style: SkText.caption.copyWith(color: c.textTertiary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (figure != null) ...<Widget>[
                      const SizedBox(width: SkSpace.s4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DefaultTextStyle.merge(
                            style: SkText.data.copyWith(
                              fontSize: SkFontSize.lg,
                              color: c.textPrimary,
                            ),
                            child: figure.cell(row),
                          ),
                          if (figure.subLabel != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                figure.subLabel!(row),
                                style: SkText.caption.copyWith(color: c.textTertiary),
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (actions != null) ...<Widget>[
                      const SizedBox(width: SkSpace.s4),
                      // No hover on touch, so row actions are inline here.
                      ...actions!(row),
                    ],
                    if (onSelectRow != null) ...<Widget>[
                      const SizedBox(width: SkSpace.s3),
                      SkIcon(SkIcons.caretRight, size: 14, color: c.textTertiary),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _table(BuildContext context) {
    final SkColors c = context.skColors;
    final List<SkTableColumn<T>> cols = _visible;

    final Widget table = Table(
      columnWidths: <int, TableColumnWidth>{
        for (int i = 0; i < cols.length; i++)
          i: cols[i].width != null
              ? FixedColumnWidth(cols[i].width!)
              : const IntrinsicColumnWidth(flex: 1),
        if (actions != null) cols.length: const FixedColumnWidth(96),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          decoration: BoxDecoration(
            color: c.surfaceCard,
            border: Border(
              bottom: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
            ),
          ),
          children: <Widget>[
            for (final SkTableColumn<T> col in cols)
              _HeaderCell<T>(
                column: col,
                sort: sort,
                onSort: onSort,
                padding: _cellPad,
              ),
            if (actions != null) const SizedBox.shrink(),
          ],
        ),
        for (final T row in rows) _bodyRow(context, row, cols),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: c.borderSubtle, width: SkDepth.hairline),
      ),
      child: Semantics(
        label: caption,
        child: matrix && bp.isSm
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: table)
            : table,
      ),
    );
  }

  TableRow _bodyRow(BuildContext context, T row, List<SkTableColumn<T>> cols) {
    final SkColors c = context.skColors;
    final bool selected = selectedKey != null && rowKey(row) == selectedKey;

    return TableRow(
      decoration: BoxDecoration(
        color: selected ? c.surfaceSelected : c.surfaceCard,
        border: Border(
          top: BorderSide(color: c.borderSubtle, width: SkDepth.hairline),
          left: BorderSide(
            color: selected ? c.borderAccent : const Color(0x00000000),
            width: SkDepth.emphasis,
          ),
        ),
      ),
      children: <Widget>[
        for (final SkTableColumn<T> col in cols)
          _BodyCell<T>(
            column: col,
            row: row,
            padding: _cellPad,
            onTap: onSelectRow == null ? null : () => onSelectRow!(row),
          ),
        if (actions != null)
          Padding(
            padding: _cellPad,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: actions!(row),
            ),
          ),
      ],
    );
  }
}

class _HeaderCell<T> extends StatefulWidget {
  const _HeaderCell({
    required this.column,
    required this.sort,
    required this.onSort,
    required this.padding,
  });

  final SkTableColumn<T> column;
  final SkTableSort? sort;
  final ValueChanged<String>? onSort;
  final EdgeInsets padding;

  @override
  State<_HeaderCell<T>> createState() => _HeaderCellState<T>();
}

class _HeaderCellState<T> extends State<_HeaderCell<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final bool active = widget.sort?.key == widget.column.key;
    final bool sortable = widget.column.sortable && widget.onSort != null;

    final Color fg = active
        ? c.textAccent
        : _hover && sortable
            ? c.textSecondary
            : c.textTertiary;

    // The header cell IS the control — no separate icon button, which would either
    // double the header height or halve the label space.
    Widget content = Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: widget.column.numeric
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.column.label.toUpperCase(),
            style: SkText.eyebrow.copyWith(color: fg),
          ),
          if (active)
            SkIcon(
              widget.sort!.isDescending ? SkIcons.arrowDown : SkIcons.arrowUp,
              size: 10,
              weight: SkIconWeight.fill,
              color: fg,
            )
          else if (sortable && _hover)
            SkIcon(SkIcons.arrowDown,
                size: 10, weight: SkIconWeight.bold, color: fg),
        ],
      ),
    );

    if (!sortable) return content;

    return Semantics(
      button: true,
      sortKey: OrdinalSortKey(0),
      label: widget.column.label +
          (active
              ? widget.sort!.isDescending ? ', sorted descending' : ', sorted ascending'
              : ''),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => widget.onSort!(widget.column.key),
          child: content,
        ),
      ),
    );
  }
}

class _BodyCell<T> extends StatelessWidget {
  const _BodyCell({
    required this.column,
    required this.row,
    required this.padding,
    this.onTap,
  });

  final SkTableColumn<T> column;
  final T row;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SkColors c = context.skColors;
    final TextStyle style = column.numeric
        ? SkText.data.copyWith(fontSize: SkFontSize.md, color: c.textPrimary)
        : SkText.bodySm.copyWith(
            color: column.identifying ? c.textPrimary : c.textSecondary,
          );

    final Widget cell = Padding(
      padding: padding,
      child: Align(
        alignment:
            column.numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: DefaultTextStyle.merge(style: style, child: column.cell(row)),
      ),
    );

    if (onTap == null) return cell;
    return GestureDetector(onTap: onTap, child: cell);
  }
}
