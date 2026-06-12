class KyData {
  final List<KyColumn> columns;
  final Map<dynamic, dynamic> rows;

  KyData({required this.columns, required this.rows});
}

class KyColumn {
  final String id;
  final String label;
  final bool ascending;
  final String? sortField;
  final void Function(int, bool)? onSort;
  KyColumn({
    required this.id,
    this.ascending = false,
    this.onSort,
    this.sortField,
    String? label,
  }) : label = label ?? id;
}

class KYRow {}
