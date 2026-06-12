import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_models.dart';
import '../../models/employee_directory_table_layout_models.dart';
import '../../models/employee_directory_table_models.dart';
import 'employee_directory_table_cells.dart';

class EmployeeDirectoryTablePanel extends StatelessWidget {
  final EmployeeDirectoryTableView view;
  final EmployeeDirectoryTableLayout layout;
  final Set<String> selectedEmployeeIds;
  final DateTime asOfDate;
  final ValueChanged<EmployeeDirectoryTableSortField> onSort;
  final void Function(EmployeeDirectoryMember employee, bool selected)
  onSelectionChanged;
  final ValueChanged<EmployeeDirectoryMember> onOpenProfile;
  final ValueChanged<EmployeeDirectoryMember> onEdit;
  final ValueChanged<EmployeeDirectoryMember> onMessage;
  final ValueChanged<EmployeeDirectoryMember> onSchedule;
  final ValueChanged<EmployeeDirectoryMember> onRemove;

  const EmployeeDirectoryTablePanel({
    super.key,
    required this.view,
    required this.layout,
    required this.selectedEmployeeIds,
    required this.asOfDate,
    required this.onSort,
    required this.onSelectionChanged,
    required this.onOpenProfile,
    required this.onEdit,
    required this.onMessage,
    required this.onSchedule,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.table_chart_outlined,
      title: 'Employee list table',
      subtitle: _subtitle,
      emptyMessage: 'No employee rows match the current table filters',
      children:
          view.rows.isEmpty
              ? const []
              : [
                _EmployeeDirectoryDataTable(
                  employees: view.rows,
                  layout: layout,
                  selectedEmployeeIds: selectedEmployeeIds,
                  asOfDate: asOfDate,
                  sort: view.sort,
                  onSort: onSort,
                  onSelectionChanged: onSelectionChanged,
                  onOpenProfile: onOpenProfile,
                  onEdit: onEdit,
                  onMessage: onMessage,
                  onSchedule: onSchedule,
                  onRemove: onRemove,
                ),
              ],
    );
  }

  String get _subtitle {
    final sortDirection = view.sort.ascending ? 'ascending' : 'descending';
    return '${view.visibleCount} rows, ${view.attentionCount} watchlist, sorted by ${view.sort.field.label.toLowerCase()} $sortDirection';
  }
}

class _EmployeeDirectoryDataTable extends StatelessWidget {
  final List<EmployeeDirectoryMember> employees;
  final EmployeeDirectoryTableLayout layout;
  final Set<String> selectedEmployeeIds;
  final DateTime asOfDate;
  final EmployeeDirectoryTableSort sort;
  final ValueChanged<EmployeeDirectoryTableSortField> onSort;
  final void Function(EmployeeDirectoryMember employee, bool selected)
  onSelectionChanged;
  final ValueChanged<EmployeeDirectoryMember> onOpenProfile;
  final ValueChanged<EmployeeDirectoryMember> onEdit;
  final ValueChanged<EmployeeDirectoryMember> onMessage;
  final ValueChanged<EmployeeDirectoryMember> onSchedule;
  final ValueChanged<EmployeeDirectoryMember> onRemove;

  const _EmployeeDirectoryDataTable({
    required this.employees,
    required this.layout,
    required this.selectedEmployeeIds,
    required this.asOfDate,
    required this.sort,
    required this.onSort,
    required this.onSelectionChanged,
    required this.onOpenProfile,
    required this.onEdit,
    required this.onMessage,
    required this.onSchedule,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth =
            constraints.maxWidth < _tableWidthFor(layout.visibleColumns)
                ? _tableWidthFor(layout.visibleColumns)
                : constraints.maxWidth;
        final compact = layout.density == EmployeeDirectoryTableDensity.compact;
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: HrisColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              key: const ValueKey('employee-directory-table-horizontal-scroll'),
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                    HrisColors.surfaceSubtle,
                  ),
                  dataRowMinHeight: compact ? 52 : 64,
                  dataRowMaxHeight: compact ? 58 : 72,
                  columnSpacing: compact ? 14 : 20,
                  horizontalMargin: compact ? 14 : 18,
                  columns: layout.visibleColumns
                      .map(_columnFor)
                      .toList(growable: false),
                  rows: employees
                      .map((employee) => _row(context, employee))
                      .toList(growable: false),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _column(String label, EmployeeDirectoryTableSortField field) {
    return DataColumn(
      label: _EmployeeDirectorySortHeader(
        key: ValueKey('employee-directory-table-column-${field.name}'),
        label: label,
        isActive: sort.field == field,
        ascending: sort.ascending,
        onTap: () => onSort(field),
      ),
    );
  }

  DataColumn _columnFor(EmployeeDirectoryTableColumn column) {
    switch (column) {
      case EmployeeDirectoryTableColumn.employee:
        return _column(column.label, EmployeeDirectoryTableSortField.name);
      case EmployeeDirectoryTableColumn.department:
        return _column(
          column.label,
          EmployeeDirectoryTableSortField.department,
        );
      case EmployeeDirectoryTableColumn.role:
        return _plainColumn(column);
      case EmployeeDirectoryTableColumn.manager:
        return _plainColumn(column);
      case EmployeeDirectoryTableColumn.status:
        return _column(column.label, EmployeeDirectoryTableSortField.status);
      case EmployeeDirectoryTableColumn.rating:
        return _column(
          column.label,
          EmployeeDirectoryTableSortField.performance,
        );
      case EmployeeDirectoryTableColumn.tenure:
        return _column(column.label, EmployeeDirectoryTableSortField.tenure);
      case EmployeeDirectoryTableColumn.joinDate:
        return _column(
          column.label,
          EmployeeDirectoryTableSortField.joiningDate,
        );
      case EmployeeDirectoryTableColumn.contact:
        return _plainColumn(column);
      case EmployeeDirectoryTableColumn.actions:
        return _plainColumn(column);
    }
  }

  DataColumn _plainColumn(EmployeeDirectoryTableColumn column) {
    return DataColumn(
      label: Text(
        column.label,
        key: ValueKey('employee-directory-table-column-${column.name}'),
      ),
    );
  }

  DataRow _row(BuildContext context, EmployeeDirectoryMember employee) {
    return DataRow(
      key: ValueKey('employee-directory-table-row-${employee.id}'),
      selected: selectedEmployeeIds.contains(employee.id),
      onSelectChanged:
          (selected) => onSelectionChanged(employee, selected ?? false),
      cells: layout.visibleColumns
          .map((column) => _cellFor(context, employee, column))
          .toList(growable: false),
    );
  }

  DataCell _cellFor(
    BuildContext context,
    EmployeeDirectoryMember employee,
    EmployeeDirectoryTableColumn column,
  ) {
    switch (column) {
      case EmployeeDirectoryTableColumn.employee:
        return DataCell(
          SizedBox(
            width: 250,
            child: EmployeeDirectoryIdentityCell(
              key: ValueKey('employee-directory-table-name-${employee.id}'),
              employee: employee,
            ),
          ),
          onTap: () => onOpenProfile(employee),
        );
      case EmployeeDirectoryTableColumn.department:
        return DataCell(_boundedText(context, employee.department, width: 130));
      case EmployeeDirectoryTableColumn.role:
        return DataCell(_boundedText(context, employee.position, width: 160));
      case EmployeeDirectoryTableColumn.manager:
        return DataCell(_boundedText(context, employee.manager, width: 150));
      case EmployeeDirectoryTableColumn.status:
        return DataCell(EmployeeDirectoryStatusCell(status: employee.status));
      case EmployeeDirectoryTableColumn.rating:
        return DataCell(
          EmployeeDirectoryPerformanceCell(performance: employee.performance),
        );
      case EmployeeDirectoryTableColumn.tenure:
        return DataCell(Text('${employee.tenureMonths(asOfDate)} mo'));
      case EmployeeDirectoryTableColumn.joinDate:
        return DataCell(Text(_formatDate(employee.joiningDate)));
      case EmployeeDirectoryTableColumn.contact:
        return DataCell(
          SizedBox(
            width: 150,
            child: EmployeeDirectoryContactCell(employee: employee),
          ),
        );
      case EmployeeDirectoryTableColumn.actions:
        return DataCell(
          EmployeeDirectoryActionCell(
            onOpenProfile: () => onOpenProfile(employee),
            onEdit: () => onEdit(employee),
            onMessage: () => onMessage(employee),
            onSchedule: () => onSchedule(employee),
            onRemove: () => onRemove(employee),
            moreActionsKey: ValueKey(
              'employee-directory-table-more-actions-${employee.id}',
            ),
          ),
        );
    }
  }

  Widget _boundedText(
    BuildContext context,
    String value, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

double _tableWidthFor(List<EmployeeDirectoryTableColumn> columns) {
  final contentWidth = columns.fold<double>(0, (total, column) {
    return total + _columnWidth(column);
  });

  return contentWidth + 180;
}

double _columnWidth(EmployeeDirectoryTableColumn column) {
  switch (column) {
    case EmployeeDirectoryTableColumn.employee:
      return 250;
    case EmployeeDirectoryTableColumn.department:
      return 130;
    case EmployeeDirectoryTableColumn.role:
      return 160;
    case EmployeeDirectoryTableColumn.manager:
      return 150;
    case EmployeeDirectoryTableColumn.status:
      return 110;
    case EmployeeDirectoryTableColumn.rating:
      return 90;
    case EmployeeDirectoryTableColumn.tenure:
      return 90;
    case EmployeeDirectoryTableColumn.joinDate:
      return 110;
    case EmployeeDirectoryTableColumn.contact:
      return 150;
    case EmployeeDirectoryTableColumn.actions:
      return 130;
  }
}

class _EmployeeDirectorySortHeader extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool ascending;
  final VoidCallback onTap;

  const _EmployeeDirectorySortHeader({
    super.key,
    required this.label,
    required this.isActive,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? HrisColors.primary : HrisColors.muted;

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive
                  ? ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded
                  : Icons.unfold_more_rounded,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
