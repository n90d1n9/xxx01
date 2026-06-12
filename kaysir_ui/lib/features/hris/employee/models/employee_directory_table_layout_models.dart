enum EmployeeDirectoryTableDensity { comfortable, compact }

extension EmployeeDirectoryTableDensityLabel on EmployeeDirectoryTableDensity {
  String get label {
    switch (this) {
      case EmployeeDirectoryTableDensity.comfortable:
        return 'Comfortable';
      case EmployeeDirectoryTableDensity.compact:
        return 'Compact';
    }
  }
}

enum EmployeeDirectoryTableColumn {
  employee,
  department,
  role,
  manager,
  status,
  rating,
  tenure,
  joinDate,
  contact,
  actions,
}

extension EmployeeDirectoryTableColumnLabel on EmployeeDirectoryTableColumn {
  String get label {
    switch (this) {
      case EmployeeDirectoryTableColumn.employee:
        return 'Employee';
      case EmployeeDirectoryTableColumn.department:
        return 'Dept';
      case EmployeeDirectoryTableColumn.role:
        return 'Role';
      case EmployeeDirectoryTableColumn.manager:
        return 'Manager';
      case EmployeeDirectoryTableColumn.status:
        return 'Status';
      case EmployeeDirectoryTableColumn.rating:
        return 'Rating';
      case EmployeeDirectoryTableColumn.tenure:
        return 'Tenure';
      case EmployeeDirectoryTableColumn.joinDate:
        return 'Join date';
      case EmployeeDirectoryTableColumn.contact:
        return 'Contact';
      case EmployeeDirectoryTableColumn.actions:
        return 'Actions';
    }
  }

  bool get isPinned {
    switch (this) {
      case EmployeeDirectoryTableColumn.employee:
      case EmployeeDirectoryTableColumn.actions:
        return true;
      case EmployeeDirectoryTableColumn.department:
      case EmployeeDirectoryTableColumn.role:
      case EmployeeDirectoryTableColumn.manager:
      case EmployeeDirectoryTableColumn.status:
      case EmployeeDirectoryTableColumn.rating:
      case EmployeeDirectoryTableColumn.tenure:
      case EmployeeDirectoryTableColumn.joinDate:
      case EmployeeDirectoryTableColumn.contact:
        return false;
    }
  }
}

class EmployeeDirectoryTableLayout {
  final List<EmployeeDirectoryTableColumn> visibleColumns;
  final EmployeeDirectoryTableDensity density;

  const EmployeeDirectoryTableLayout({
    required this.visibleColumns,
    required this.density,
  });

  factory EmployeeDirectoryTableLayout.defaults() {
    return const EmployeeDirectoryTableLayout(
      visibleColumns: EmployeeDirectoryTableColumn.values,
      density: EmployeeDirectoryTableDensity.comfortable,
    );
  }

  int get visibleColumnCount => visibleColumns.length;

  int get hiddenColumnCount {
    return EmployeeDirectoryTableColumn.values.length - visibleColumns.length;
  }

  bool isVisible(EmployeeDirectoryTableColumn column) {
    return visibleColumns.contains(column);
  }

  EmployeeDirectoryTableLayout toggleColumn(
    EmployeeDirectoryTableColumn column,
  ) {
    if (column.isPinned) return this;

    final nextColumns = visibleColumns.toSet();
    if (nextColumns.contains(column)) {
      nextColumns.remove(column);
    } else {
      nextColumns.add(column);
    }

    nextColumns.add(EmployeeDirectoryTableColumn.employee);
    nextColumns.add(EmployeeDirectoryTableColumn.actions);

    return copyWith(visibleColumns: _orderedColumns(nextColumns));
  }

  EmployeeDirectoryTableLayout copyWith({
    List<EmployeeDirectoryTableColumn>? visibleColumns,
    EmployeeDirectoryTableDensity? density,
  }) {
    return EmployeeDirectoryTableLayout(
      visibleColumns: _orderedColumns(
        (visibleColumns ?? this.visibleColumns).toSet()
          ..add(EmployeeDirectoryTableColumn.employee)
          ..add(EmployeeDirectoryTableColumn.actions),
      ),
      density: density ?? this.density,
    );
  }

  static List<EmployeeDirectoryTableColumn> _orderedColumns(
    Set<EmployeeDirectoryTableColumn> columns,
  ) {
    return EmployeeDirectoryTableColumn.values
        .where(columns.contains)
        .toList(growable: false);
  }
}
