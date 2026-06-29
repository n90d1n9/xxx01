import 'package:flutter/material.dart';

import '../model/ky_data.dart';
import '../utils/helper.dart';
import '../tabel_controller.dart';
import 'filter_panel.dart';
import 'tabel_pagination.dart';

class KyDataTable extends StatelessWidget {
  final TableController controller;
  final List<KyColumn> columns;
  final List<KyRow> rows;
  const KyDataTable({
    super.key,
    required this.controller,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final sorting = controller.sorting;
    controller.getData(rows);

    // Get filtered and sorted data
    final filteredAndSortedData = controller.getFilteredAndSortedData();

    // Get paginated data
    final paginatedData = controller.getPaginatedData(filteredAndSortedData);

    return Expanded(
      flex: 2,
      child: Column(
        children: [
          // Filter panel
          TableFilterPanel(controller: controller),

          // Table header and body
          Expanded(
            child:
                paginatedData.isEmpty
                    ? const Center(child: Text('No data found'))
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 16,
                          headingRowHeight: 60,
                          showCheckboxColumn: false,
                          columns: _buildColumns(sorting),
                          rows: _buildRows(paginatedData, context),
                        ),
                      ),
                    ),
          ),
          // Pagination
          TablePagination(controller: controller),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(Map<String, dynamic> sorting) {
    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;

    return columns.map((col) {
      return col.isSorted
          ? _buildSortableColumn(
            convertValue(col.label),
            col.name,
            sortField,
            ascending,
          )
          : DataColumn(label: convertValue(col.label), onSort: col.onSort);
    }).toList();
  }

  Widget convertValue(dynamic label) {
    if (label != null && label is Widget) {
      return label;
    } else if (label is num || label is bool) {
      return Text('$label');
    } else if (label is DateTime) {
      return Text(formatDate(label));
    } else if (label != null) {
      return Text(label);
    } else {
      return Text('');
    }
  }

  DataColumn _buildSortableColumn(
    dynamic label,
    String field,
    String sortField,
    bool ascending,
  ) {
    return DataColumn(
      label: Row(
        children: [
          label,
          const SizedBox(width: 4),
          if (sortField == field)
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
      onSort: (_, __) {
        final newSorting = {
          'field': field,
          'ascending': sortField == field ? !ascending : true,
        };
        controller.setSorting(newSorting);
      },
    );
  }

  List<DataRow> _buildRows(List<KyRow> items, BuildContext context) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = controller.selectedItem?.id == item.id;

      // Determine if this row should have colspan or rowspan
      // final bool hasRowSpan = item.priority > 3; // Example condition
      final cells = convertRows(item);

      return DataRow(
        selected: isSelected,
        color: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08);
          }
          return index % 2 == 0 ? Colors.grey.shade50 : null;
        }),
        cells: cells,
      );
    }).toList();
  }

  void _selectItem(KyRow item) {
    final currentSelected = controller.selectedItem;
    if (currentSelected?.id == item.id) {
      controller.setSelectedItem(null);
    } else {
      controller.setSelectedItem(item);
    }
  }

  List<DataCell> convertRows(KyRow row) {
    return row.cells!.map((cell) {
      return DataCell(
        convertValue(cell.widget),
        onTap: () {
          _selectItem(row);
          if (cell.onTap != null) {
            cell.onTap!(cell.value);
          }
        },
      );
    }).toList();
  }
}
