import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/helper.dart';
import 'item_form_dialog.dart';
import '../tabel_controller.dart';
import '../model/tabel_item.dart';

class KyDataTable extends StatelessWidget {
  final TableController controller;
  const KyDataTable({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = controller.filters;
    final sorting = controller.sorting;
    final pageInfo = controller.pageInfo;

    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;
    final currentPage = pageInfo['currentPage'] as int;
    final itemsPerPage = pageInfo['itemsPerPage'] as int;

    // Get filtered and sorted data
    final filteredAndSortedData = controller.getFilteredAndSortedData();

    // Get paginated data
    final paginatedData = controller.getPaginatedData(filteredAndSortedData);

    // Update total pages
    if (filteredAndSortedData.isEmpty) {
      Future.microtask(() {
        final newPageInfo = Map<String, dynamic>.from(pageInfo);
        newPageInfo['totalPages'] = 1;
        newPageInfo['totalItems'] = 0;
        controller.setPageInfo(newPageInfo);
      });
    } else if (pageInfo['totalItems'] != filteredAndSortedData.length) {
      Future.microtask(() {
        final totalPages = (filteredAndSortedData.length / itemsPerPage).ceil();
        final newPageInfo = Map<String, dynamic>.from(pageInfo);
        newPageInfo['totalPages'] = totalPages;
        newPageInfo['totalItems'] = filteredAndSortedData.length;

        // Adjust current page if needed
        if (currentPage >= totalPages) {
          newPageInfo['currentPage'] = max(0, totalPages - 1);
        }

        controller.setPageInfo(newPageInfo);
      });
    }

    return paginatedData.isEmpty
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
        );
  }

  List<DataColumn> _buildColumns(Map<String, dynamic> sorting) {
    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;

    return [
      _buildSortableColumn('ID', 'id', sortField, ascending),
      _buildSortableColumn('Category', 'category', sortField, ascending),
      _buildSortableColumn('Name', 'name', sortField, ascending),
      _buildSortableColumn('Value', 'value', sortField, ascending),
      _buildSortableColumn('Date', 'date', sortField, ascending),
      _buildSortableColumn('Status', 'status', sortField, ascending),
      _buildSortableColumn('Priority', 'priority', sortField, ascending),
      DataColumn(label: const Text('Active'), onSort: null),
      DataColumn(label: const Text('Actions'), onSort: null),
    ];
  }

  DataColumn _buildSortableColumn(
    String label,
    String field,
    String sortField,
    bool ascending,
  ) {
    return DataColumn(
      label: Row(
        children: [
          Text(label),
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

  List<DataRow> _buildRows(List<TableItem> items, BuildContext context) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = controller.selectedItem?.id == item.id;

      // Determine if this row should have colspan or rowspan
      final bool hasRowSpan = item.priority > 3; // Example condition

      return DataRow(
        selected: isSelected,
        color: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }
          return index % 2 == 0 ? Colors.grey.shade50 : null;
        }),
        cells: [
          DataCell(Text(item.id), onTap: () => _selectItem(item)),
          DataCell(Text(item.category), onTap: () => _selectItem(item)),
          DataCell(Text(item.name), onTap: () => _selectItem(item)),
          DataCell(
            Text('\$${item.value.toStringAsFixed(2)}'),
            onTap: () => _selectItem(item),
          ),
          DataCell(Text(formatDate(item.date)), onTap: () => _selectItem(item)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(item.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onTap: () => _selectItem(item),
          ),
          DataCell(
            Row(
              children: List.generate(
                item.priority,
                (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
              ),
            ),
            onTap: () => _selectItem(item),
          ),
          DataCell(
            Icon(
              item.active ? Icons.check_circle : Icons.cancel,
              color: item.active ? Colors.green : Colors.red,
            ),
            onTap: () => _selectItem(item),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editItem(item, context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteItem(item, context),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  void _selectItem(TableItem item) {
    final currentSelected = controller.selectedItem;
    if (currentSelected?.id == item.id) {
      controller.setSelectedItem(null);
    } else {
      controller.setSelectedItem(item);
    }
  }

  void _editItem(TableItem item, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => ItemFormDialog(
            item: item,
            onSave: (updatedItem) {
              controller.updateItem(updatedItem);

              // Update selected item if it's the one being edited
              final currentSelected = controller.selectedItem;
              if (currentSelected?.id == updatedItem.id) {
                controller.setSelectedItem(updatedItem);
              }
            },
          ),
    );
  }

  void _deleteItem(TableItem item, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete ${item.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.deleteItem(item.id);

                  // Clear selected item if it's the one being deleted
                  final currentSelected = controller.selectedItem;
                  if (currentSelected?.id == item.id) {
                    controller.setSelectedItem(null);
                  }
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
