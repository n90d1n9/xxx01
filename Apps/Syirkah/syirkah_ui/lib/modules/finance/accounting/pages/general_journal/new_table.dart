import 'package:flutter/material.dart';

class NewColumn extends DataColumn {
  final Widget title;

  /// The column heading's tooltip.
  ///
  /// This is a longer description of the column heading, for cases
  /// where the heading might have been abbreviated to keep the column
  /// width to a reasonable size.
  final String? tooltip;

  /// Whether this column represents numeric data or not.
  ///
  /// The contents of cells of columns containing numeric data are
  /// right-aligned.
  final bool numeric;

  /// Called when the user asks to sort the table using this column.
  ///
  /// If null, the column will not be considered sortable.
  ///
  /// See [DataTable.sortColumnIndex] and [DataTable.sortAscending].
  final DataColumnSortCallback? onSort;

  bool get _debugInteractive => onSort != null;

  final WidgetStateProperty<MouseCursor?>? mouseCursor;

  /// Defines the horizontal layout of the [label] and sort indicator in the
  /// heading row.
  ///
  /// If [headingRowAlignment] value is [MainAxisAlignment.center] and [onSort] is
  /// not null, then a [SizedBox] with a width of sort arrow icon size and sort
  /// arrow padding will be placed before the [label] to ensure the label is
  /// centered in the column.
  ///
  /// If null, then defaults to [MainAxisAlignment.start].
  final MainAxisAlignment? headingRowAlignment;
  const NewColumn({
    required this.title,
    this.tooltip,
    this.numeric = false,
    this.onSort,
    this.mouseCursor,
    this.headingRowAlignment,
  }) : super(
            label: title,
            tooltip: tooltip,
            numeric: numeric,
            onSort: onSort,
            mouseCursor: mouseCursor,
            headingRowAlignment: headingRowAlignment);
}
