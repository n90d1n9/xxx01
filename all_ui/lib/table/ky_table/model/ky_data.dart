import 'package:flutter/material.dart';

class KyData {
  final List<KyColumn> columns;
  final List<KyRow> rows;

  KyData({required this.columns, required this.rows});
}

class KyColumn {
  /// Column name must unique
  final String name;

  /// Column label to display, if empty used name instead.
  final dynamic label;
  final bool isSorted;
  final bool ascending;
  final String? sortField;
  final void Function(int, bool)? onSort;
  KyColumn({
    required this.name,
    dynamic label,
    this.isSorted = true,
    this.ascending = false,
    this.onSort,
    this.sortField,
  }) : label = label ?? name;
}

class KyRow {
  final int id;
  final List<KyCell>? cells;
  KyRow({required this.id, this.cells});
}

class KyCell {
  final int? id;
  final dynamic value;
  final Widget? widget;
  void Function(dynamic value)? onTap;

  KyCell({this.id, this.value, this.widget, this.onTap});
}
