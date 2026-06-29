import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:flutter_riverpod/legacy.dart';

// ==================== DATA MODELS ====================

// ==================== DATA MODELS ====================

// Model for table cell data that supports rowspan and colspan
class TableCell {
  final dynamic content;
  final int rowSpan;
  final int colSpan;
  final bool isHeader;
  final String? tooltip;

  TableCell({
    required this.content,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.isHeader = false,
    this.tooltip,
  });

  @override
  String toString() => content.toString();
}

// Model for table row data
class TableRow {
  final String id;
  final List<TableCell> cells;
  final Map<String, dynamic> originalData;
  final List<TableRow>? detailRows;
  final bool hasDetail;

  TableRow({
    required this.id,
    required this.cells,
    required this.originalData,
    this.detailRows,
    this.hasDetail = false,
  });
}

// Model for table column configuration
class TableColumn {
  final String id;
  final String label;
  final double width;
  final bool sortable;
  final bool filterable;
  final TextAlign textAlign;
  final Widget Function(dynamic)? customCell;
  final int columnIndex; // Store the actual index in the full column list

  TableColumn({
    required this.id,
    required this.label,
    this.width = 100,
    this.sortable = true,
    this.filterable = true,
    this.textAlign = TextAlign.left,
    this.customCell,
    required this.columnIndex,
  });
}

// Enum for sorting direction
enum SortDirection { asc, desc, none }

// ==================== STATE MANAGEMENT ====================

// Table state class
class TableState {
  final List<TableRow> originalRows;
  final List<TableColumn> columns;
  final List<TableRow> displayRows;
  final Map<String, String> filters;
  final String? sortColumnId;
  final SortDirection sortDirection;
  final int page;
  final int rowsPerPage;
  final int totalPages;
  final bool isLoading;
  final Set<String> expandedRows;
  final bool masterDetailEnabled;

  TableState({
    required this.originalRows,
    required this.columns,
    required this.displayRows,
    required this.filters,
    this.sortColumnId,
    this.sortDirection = SortDirection.none,
    this.page = 0,
    this.rowsPerPage = 10,
    this.totalPages = 1,
    this.isLoading = false,
    Set<String>? expandedRows,
    this.masterDetailEnabled = false,
  }) : expandedRows = expandedRows ?? {};

  TableState copyWith({
    List<TableRow>? originalRows,
    List<TableColumn>? columns,
    List<TableRow>? displayRows,
    Map<String, String>? filters,
    String? sortColumnId,
    SortDirection? sortDirection,
    int? page,
    int? rowsPerPage,
    int? totalPages,
    bool? isLoading,
    Set<String>? expandedRows,
    bool? masterDetailEnabled,
  }) {
    return TableState(
      originalRows: originalRows ?? this.originalRows,
      columns: columns ?? this.columns,
      displayRows: displayRows ?? this.displayRows,
      filters: filters ?? this.filters,
      sortColumnId: sortColumnId ?? this.sortColumnId,
      sortDirection: sortDirection ?? this.sortDirection,
      page: page ?? this.page,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      totalPages: totalPages ?? this.totalPages,
      isLoading: isLoading ?? this.isLoading,
      expandedRows: expandedRows ?? this.expandedRows,
      masterDetailEnabled: masterDetailEnabled ?? this.masterDetailEnabled,
    );
  }
}

// Table notifier class for state management
class TableNotifier extends StateNotifier<TableState> {
  TableNotifier({
    required List<TableRow> rows,
    required List<TableColumn> columns,
    int rowsPerPage = 10,
    bool masterDetailEnabled = false,
  }) : super(
         TableState(
           originalRows: rows,
           columns: columns,
           displayRows: rows,
           filters: {},
           rowsPerPage: rowsPerPage,
           totalPages: (rows.length / rowsPerPage).ceil(),
           masterDetailEnabled: masterDetailEnabled,
         ),
       ) {
    _applyFiltersAndSort();
  }

  // Sets new data for the table
  void setData(List<TableRow> rows) {
    state = state.copyWith(
      originalRows: rows,
      totalPages: (rows.length / state.rowsPerPage).ceil(),
      page: 0,
      expandedRows: {}, // Reset expanded rows
    );
    _applyFiltersAndSort();
  }

  // Sets the sorting column and direction
  void setSort(String columnId) {
    final newDirection = state.sortColumnId == columnId
        ? state.sortDirection == SortDirection.asc
              ? SortDirection.desc
              : state.sortDirection == SortDirection.desc
              ? SortDirection.none
              : SortDirection.asc
        : SortDirection.asc;

    state = state.copyWith(sortColumnId: columnId, sortDirection: newDirection);
    _applyFiltersAndSort();
  }

  // Sets a filter for a specific column
  void setFilter(String columnId, String value) {
    final newFilters = Map<String, String>.from(state.filters);
    if (value.isEmpty) {
      newFilters.remove(columnId);
    } else {
      newFilters[columnId] = value.toLowerCase();
    }

    state = state.copyWith(filters: newFilters, page: 0);
    _applyFiltersAndSort();
  }

  // Sets the current page
  void setPage(int page) {
    state = state.copyWith(page: page);
    _applyFiltersAndSort();
  }

  // Sets rows per page
  void setRowsPerPage(int rowsPerPage) {
    state = state.copyWith(
      rowsPerPage: rowsPerPage,
      totalPages: (state.originalRows.length / rowsPerPage).ceil(),
      page: 0,
    );
    _applyFiltersAndSort();
  }

  // Toggle row expansion for master-detail view
  void toggleRowExpansion(String rowId) {
    final newExpandedRows = Set<String>.from(state.expandedRows);
    if (newExpandedRows.contains(rowId)) {
      newExpandedRows.remove(rowId);
    } else {
      newExpandedRows.add(rowId);
    }

    state = state.copyWith(expandedRows: newExpandedRows);
  }

  // Toggle master-detail mode
  void toggleMasterDetail(bool enabled) {
    state = state.copyWith(
      masterDetailEnabled: enabled,
      expandedRows: enabled ? state.expandedRows : {},
    );
  }

  // Apply filters, sorting, and pagination
  void _applyFiltersAndSort() {
    state = state.copyWith(isLoading: true);

    // Apply filters
    List<TableRow> filteredRows = List.from(state.originalRows);
    if (state.filters.isNotEmpty) {
      filteredRows = filteredRows.where((row) {
        return state.filters.entries.every((filter) {
          final columnId = filter.key;
          final filterValue = filter.value.toLowerCase();
          final cellValue = row.originalData[columnId]
              ?.toString()
              .toLowerCase();
          return cellValue?.contains(filterValue) ?? false;
        });
      }).toList();
    }

    // Apply sorting
    if (state.sortColumnId != null &&
        state.sortDirection != SortDirection.none) {
      filteredRows.sort((a, b) {
        final aValue = a.originalData[state.sortColumnId!];
        final bValue = b.originalData[state.sortColumnId!];

        int comparison;
        if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is String && bValue is String) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }

        return state.sortDirection == SortDirection.asc
            ? comparison
            : -comparison;
      });
    }

    // Calculate total pages
    final totalPages = (filteredRows.length / state.rowsPerPage).ceil();

    // Apply pagination
    final startIndex = state.page * state.rowsPerPage;
    final endIndex = math.min(
      startIndex + state.rowsPerPage,
      filteredRows.length,
    );

    List<TableRow> pagedRows = [];
    if (startIndex < filteredRows.length) {
      pagedRows = filteredRows.sublist(startIndex, endIndex);
    }

    state = state.copyWith(
      displayRows: pagedRows,
      totalPages: totalPages,
      isLoading: false,
    );
  }
}

// Provider for table state
final tableProvider =
    StateNotifierProvider.family<TableNotifier, TableState, String>(
      (ref, id) =>
          throw UnimplementedError('Provider must be overridden with data'),
    );

// ==================== UI COMPONENTS ====================

// Advanced table widget
class AdvancedTable extends ConsumerWidget {
  // final String providerId;
  final String title;
  final double? width;
  final double? height;
  final bool showFilters;
  final bool showPagination;
  final bool showTitle;
  final List<int> rowsPerPageOptions;
  final Widget Function(BuildContext, TableRow)? customRowBuilder;
  final Widget Function(BuildContext, TableRow)? detailBuilder;
  final bool enableMasterDetail;

  const AdvancedTable({
    Key? key,
    // required this.providerId,
    this.title = 'Advanced Table',
    this.width,
    this.height,
    this.showFilters = true,
    this.showPagination = true,
    this.showTitle = true,
    this.rowsPerPageOptions = const [5, 10, 25, 50, 100],
    this.customRowBuilder,
    this.detailBuilder,
    this.enableMasterDetail = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider(providerId));
    final tableNotifier = ref.read(tableProvider(providerId).notifier);

    // Enable master-detail if it's requested
    if (enableMasterDetail && !tableState.masterDetailEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tableNotifier.toggleMasterDetail(true);
      });
    }

    // Calculate the total width of the table
    final totalWidth = tableState.columns.fold<double>(
      0,
      (prev, col) => prev + col.width,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title bar
          if (showTitle)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (detailBuilder != null)
                    Switch(
                      value: tableState.masterDetailEnabled,
                      onChanged: (value) {
                        tableNotifier.toggleMasterDetail(value);
                      },
                      activeColor: Colors.blue,
                      activeTrackColor: Colors.blue.shade200,
                    ),
                ],
              ),
            ),

          // Filter row
          if (showFilters)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...tableState.columns.where((col) => col.filterable).map((
                      column,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: column.width,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Filter ${column.label}',
                              isDense: true,
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade300,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              tableNotifier.setFilter(column.id, value);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

          // Table header and data
          Expanded(
            child: tableState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width != null
                            ? math.max(width!, totalWidth)
                            : totalWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            _buildHeaderRow(context, tableState, tableNotifier),

                            // Data rows with master-detail
                            ...tableState.displayRows.expand((row) {
                              final List<Widget> rowWidgets = [];

                              // Main row
                              if (customRowBuilder != null) {
                                rowWidgets.add(customRowBuilder!(context, row));
                              } else {
                                rowWidgets.add(
                                  _buildDataRow(context, ref, row),
                                );
                              }

                              // Detail row if expanded
                              if (tableState.masterDetailEnabled &&
                                  row.hasDetail &&
                                  detailBuilder != null &&
                                  tableState.expandedRows.contains(row.id)) {
                                rowWidgets.add(
                                  Container(
                                    width: totalWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: detailBuilder!(context, row),
                                    ),
                                  ),
                                );
                              }

                              return rowWidgets;
                            }).toList(),

                            if (tableState.displayRows.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                width: totalWidth,
                                child: const Text(
                                  'No data available',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),

          // Pagination
          if (showPagination)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rows per page selector
                  Row(
                    children: [
                      const Text('Rows per page:'),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: tableState.rowsPerPage,
                        items: rowsPerPageOptions.map((count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text(count.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            tableNotifier.setRowsPerPage(value);
                          }
                        },
                      ),
                    ],
                  ),

                  // Page navigator
                  Row(
                    children: [
                      Text(
                        '${tableState.page + 1} of ${tableState.totalPages}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.first_page),
                        onPressed: tableState.page > 0
                            ? () => tableNotifier.setPage(0)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed: tableState.page > 0
                            ? () => tableNotifier.setPage(tableState.page - 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed: tableState.page < tableState.totalPages - 1
                            ? () => tableNotifier.setPage(tableState.page + 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed: tableState.page < tableState.totalPages - 1
                            ? () => tableNotifier.setPage(
                                tableState.totalPages - 1,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Build table header row with sorting functionality
  Widget _buildHeaderRow(
    BuildContext context,
    TableState tableState,
    TableNotifier tableNotifier,
  ) {
    return Container(
      color: Colors.grey.shade200,
      child: Row(
        children: tableState.columns.map((column) {
          final isSorted = tableState.sortColumnId == column.id;
          final sortIcon = tableState.sortDirection == SortDirection.asc
              ? Icons.arrow_upward
              : Icons.arrow_downward;

          return Container(
            width: column.width,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: column.sortable
                ? InkWell(
                    onTap: () => tableNotifier.setSort(column.id),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            column.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isSorted &&
                            tableState.sortDirection != SortDirection.none)
                          Icon(sortIcon, size: 16),
                      ],
                    ),
                  )
                : Text(
                    column.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          );
        }).toList(),
      ),
    );
  }

  // Build data row with cell content and master-detail support
  Widget _buildDataRow(BuildContext context, WidgetRef ref, TableRow row) {
    final tableState = ref.watch(tableProvider(providerId));
    final tableNotifier = ref.read(tableProvider(providerId).notifier);

    // Track which columns have content
    final columnWidths = List<double>.filled(tableState.columns.length, 0.0);
    final effectiveColumnSpans = List<int>.filled(tableState.columns.length, 0);

    // Calculate effective column spans
    for (int i = 0; i < row.cells.length; i++) {
      final cell = row.cells[i];
      final column = tableState.columns.firstWhere(
        (col) => col.columnIndex == i,
        orElse: () =>
            tableState.columns[math.min(i, tableState.columns.length - 1)],
      );

      // Mark this column and the next (colSpan-1) columns as occupied
      for (int j = 0; j < cell.colSpan; j++) {
        if (i + j < effectiveColumnSpans.length) {
          effectiveColumnSpans[i + j] = j == 0 ? cell.colSpan : 0;
          columnWidths[i] += j == 0 ? column.width * cell.colSpan : 0;
        }
      }
    }

    return InkWell(
      onTap: row.hasDetail && tableState.masterDetailEnabled
          ? () => tableNotifier.toggleRowExpansion(row.id)
          : null,
      child: Container(
        color: tableState.expandedRows.contains(row.id)
            ? Colors.blue.shade50.withValues(alpha: 0.3)
            : Colors.white,
        child: Row(
          children: [
            for (int i = 0; i < row.cells.length; i++)
              if (effectiveColumnSpans[i] > 0) ...[
                _buildDataCell(
                  context,
                  ref,
                  row,
                  row.cells[i],
                  i,
                  columnWidths[i],
                ),
              ],
          ],
        ),
      ),
    );
  }

  // Build data cell with colspan support
  Widget _buildDataCell(
    BuildContext context,
    WidgetRef ref,
    TableRow row,
    TableCell cell,
    int columnIndex,
    double effectiveWidth,
  ) {
    final tableState = ref.read(tableProvider(providerId));
    final column = tableState.columns.firstWhere(
      (col) => col.columnIndex == columnIndex,
      orElse: () =>
          tableState.columns[math.min(
            columnIndex,
            tableState.columns.length - 1,
          )],
    );

    Widget cellContent;
    if (column.customCell != null) {
      cellContent = column.customCell!(cell.content);
    } else {
      cellContent = Text(
        cell.content.toString(),
        style: TextStyle(
          fontWeight: cell.isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    // Apply tooltip if provided
    if (cell.tooltip != null) {
      cellContent = Tooltip(message: cell.tooltip!, child: cellContent);
    }

    return Container(
      width: effectiveWidth > 0 ? effectiveWidth : column.width,
      height: cell.isHeader ? 40 : null,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cell.isHeader ? Colors.grey.shade100 : Colors.transparent,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          // Expandable icon for master-detail rows
          if (columnIndex == 0 &&
              row.hasDetail &&
              tableState.masterDetailEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                tableState.expandedRows.contains(row.id)
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 16,
              ),
            ),

          // Cell content with alignment
          Expanded(
            child: Align(
              alignment: _getAlignmentFromTextAlign(column.textAlign),
              child: cellContent,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to convert TextAlign to Alignment
  Alignment _getAlignmentFromTextAlign(TextAlign align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }
}

// ==================== EXAMPLE IMPLEMENTATION ====================

// Example data provider
final exampleTableProvider = StateNotifierProvider<TableNotifier, TableState>((
  ref,
) {
  // Define columns with proper columnIndex values
  final columns = [
    TableColumn(
      id: 'id',
      label: 'ID',
      width: 80,
      textAlign: TextAlign.center,
      columnIndex: 0,
    ),
    TableColumn(id: 'name', label: 'Name', width: 150, columnIndex: 1),
    TableColumn(
      id: 'age',
      label: 'Age',
      width: 80,
      textAlign: TextAlign.right,
      columnIndex: 2,
    ),
    TableColumn(id: 'email', label: 'Email', width: 200, columnIndex: 3),
    TableColumn(
      id: 'status',
      label: 'Status',
      width: 120,
      columnIndex: 4,
      customCell: (value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value == 'Active'
              ? Colors.green.shade100
              : value == 'Inactive'
              ? Colors.red.shade100
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value.toString(),
          style: TextStyle(
            color: value == 'Active'
                ? Colors.green.shade800
                : value == 'Inactive'
                ? Colors.red.shade800
                : Colors.grey.shade800,
          ),
        ),
      ),
    ),
  ];

  // Generate sample data
  final rows = List.generate(100, (index) {
    final id = (index + 1).toString();
    final name = 'User ${index + 1}';
    final age = 20 + (index % 50);
    final email = 'user${index + 1}@example.com';
    final status = index % 3 == 0
        ? 'Active'
        : (index % 3 == 1 ? 'Inactive' : 'Pending');

    final originalData = {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'status': status,
    };

    // Create special cases for special users with rowspan and colspan
    if (index % 10 == 0) {
      return TableRow(
        id: id,
        originalData: originalData,
        cells: [
          TableCell(content: id, isHeader: true),
          TableCell(
            content: 'Special User',
            colSpan: 2, // Span over the name and age columns
            isHeader: true,
          ),
          TableCell(content: email),
          TableCell(content: status),
        ],
        hasDetail: true,
        detailRows: [
          TableRow(
            id: 'detail-$id-1',
            originalData: {'property': 'Address', 'value': '123 Main St, City'},
            cells: [
              TableCell(content: 'Address'),
              TableCell(content: '123 Main St, City', colSpan: 4),
            ],
          ),
          TableRow(
            id: 'detail-$id-2',
            originalData: {
              'property': 'Notes',
              'value': 'This is a VIP user with special requirements',
            },
            cells: [
              TableCell(content: 'Notes'),
              TableCell(
                content: 'This is a VIP user with special requirements',
                colSpan: 4,
              ),
            ],
          ),
        ],
      );
    }

    // Regular rows with detail capability
    return TableRow(
      id: id,
      originalData: originalData,
      cells: [
        TableCell(content: id),
        TableCell(content: name),
        TableCell(content: age),
        TableCell(content: email),
        TableCell(content: status),
      ],
      hasDetail: true,
      detailRows: [
        TableRow(
          id: 'detail-$id-1',
          originalData: {
            'property': 'Address',
            'value': '${index + 100} Example Ave, Town',
          },
          cells: [
            TableCell(content: 'Address'),
            TableCell(content: '${index + 100} Example Ave, Town', colSpan: 4),
          ],
        ),
        TableRow(
          id: 'detail-$id-2',
          originalData: {'property': 'Notes', 'value': 'Regular user notes'},
          cells: [
            TableCell(content: 'Notes'),
            TableCell(content: 'Regular user notes', colSpan: 4),
          ],
        ),
      ],
    );
  });

  return TableNotifier(
    rows: rows,
    columns: columns,
    rowsPerPage: 10,
    masterDetailEnabled: true,
  );
});

// Detail builder for master-detail view
Widget buildDetailSection(BuildContext context, TableRow row) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'User Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 8),
      if (row.detailRows != null)
        ...row.detailRows!.map((detailRow) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    detailRow.cells[0].content.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(child: Text(detailRow.cells[1].content.toString())),
              ],
            ),
          );
        }).toList(),
    ],
  );
}

// Example implementation page
class ExampleTablePage extends ConsumerWidget {
  const ExampleTablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Table Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Table with Master-Detail View',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AdvancedTable(
                //providerId: 'example',
                title: 'User Data',
                showFilters: true,
                showPagination: true,
                enableMasterDetail: true,
                detailBuilder: buildDetailSection,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Override the provider for the example page
/* final tableProviderOverride =
    Provider<StateNotifierProvider<TableNotifier, TableState>>(
      (ref) => exampleTableProvider,
    ); */

// Main app with provider overrides
/* class TableApp extends ConsumerWidget {
  const TableApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      /*  overrides: [
        tableProvider(
          'example',
        ).overrideWith((ref) => ref.watch(tableProviderOverride).notifier),
      ], */
      child: MaterialApp(
        title: 'Advanced Table Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ExampleTablePage(),
      ),
    );
  }
}
 */
// Export table in Excel format (example function)
Future<void> exportTableToExcel(TableState tableState) async {
  // This would be implemented with excel or csv library
  print('Exporting table with ${tableState.originalRows.length} rows');

  // Example implementation would include:
  // 1. Create a new Excel workbook
  // 2. Add a worksheet
  // 3. Add header row based on tableState.columns
  // 4. Add data rows based on tableState.originalRows
  // 5. Save the Excel file
  // 6. Open/share the file
}

// Print table (example function)
Future<void> printTable(TableState tableState) async {
  // This would use the printing package
  print('Printing table with ${tableState.displayRows.length} visible rows');

  // Example implementation would include:
  // 1. Format the table for printing
  // 2. Create a PDF document
  // 3. Add the table to the PDF
  // 4. Print the PDF
}

// Additional utilities for working with the table
extension TableRowUtils on TableRow {
  // Get a specific value by column ID
  dynamic getValue(String columnId) => originalData[columnId];

  // Create a copy with modified data
  TableRow copyWith({
    Map<String, dynamic>? originalData,
    List<TableCell>? cells,
    bool? hasDetail,
    List<TableRow>? detailRows,
  }) {
    return TableRow(
      id: this.id,
      originalData: originalData ?? this.originalData,
      cells: cells ?? this.cells,
      hasDetail: hasDetail ?? this.hasDetail,
      detailRows: detailRows ?? this.detailRows,
    );
  }
}

// Example of creating a table with custom row builders
class CustomRowTable extends ConsumerWidget {
  const CustomRowTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdvancedTable(
      providerId: 'custom',
      title: 'Custom Row Examples',
      customRowBuilder: (context, row) {
        // Create completely custom rows based on the data
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            color: row.originalData['status'] == 'Active'
                ? Colors.green.shade50
                : Colors.transparent,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(row.originalData['id'].toString()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.originalData['name'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(row.originalData['email'].toString()),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: row.originalData['status'] == 'Active'
                      ? Colors.green.shade100
                      : row.originalData['status'] == 'Inactive'
                      ? Colors.red.shade100
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(row.originalData['status'].toString()),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Example of setting up the table with server-side pagination
class ServerSideTableExample extends ConsumerWidget {
  const ServerSideTableExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Server-side pagination would handle data fetching in the provider
    return Scaffold(
      appBar: AppBar(title: const Text('Server-side Table')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AdvancedTable(
          providerId: 'server-side',
          title: 'Server Paginated Data',
          showFilters: true,
        ),
      ),
    );
  }
}

// Example server-side table provider
final serverSideTableProvider =
    StateNotifierProvider<ServerSideTableNotifier, TableState>((ref) {
      final columns = [
        TableColumn(
          id: 'id',
          label: 'ID',
          width: 80,
          textAlign: TextAlign.center,
          columnIndex: 0,
        ),
        TableColumn(id: 'name', label: 'Name', width: 150, columnIndex: 1),
        // Add more columns as needed
      ];

      return ServerSideTableNotifier(columns: columns);
    });

// Server-side table notifier that fetches data on demand
class ServerSideTableNotifier extends StateNotifier<TableState> {
  ServerSideTableNotifier({required List<TableColumn> columns})
    : super(
        TableState(
          originalRows: [],
          columns: columns,
          displayRows: [],
          filters: {},
          rowsPerPage: 10,
          totalPages: 1,
          isLoading: true,
        ),
      ) {
    // Initial data fetch
    fetchData();
  }

  Future<void> fetchData() async {
    state = state.copyWith(isLoading: true);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));

    // This would be replaced with an actual API call
    final data = await _mockFetchFromServer(
      page: state.page,
      pageSize: state.rowsPerPage,
      sortColumn: state.sortColumnId,
      sortDirection: state.sortDirection,
      filters: state.filters,
    );

    state = state.copyWith(
      originalRows: data.rows,
      displayRows: data.rows,
      totalPages: data.totalPages,
      isLoading: false,
    );
  }

  // Override methods to fetch from server instead of client-side filtering
  void setPage(int page) {
    state = state.copyWith(page: page);
    fetchData();
  }

  void setSort(String columnId) {
    final newDirection = state.sortColumnId == columnId
        ? state.sortDirection == SortDirection.asc
              ? SortDirection.desc
              : state.sortDirection == SortDirection.desc
              ? SortDirection.none
              : SortDirection.asc
        : SortDirection.asc;

    state = state.copyWith(sortColumnId: columnId, sortDirection: newDirection);
    fetchData();
  }

  void setFilter(String columnId, String value) {
    final newFilters = Map<String, String>.from(state.filters);
    if (value.isEmpty) {
      newFilters.remove(columnId);
    } else {
      newFilters[columnId] = value.toLowerCase();
    }

    state = state.copyWith(filters: newFilters, page: 0);
    fetchData();
  }

  // Mock server response
  Future<ServerResponse> _mockFetchFromServer({
    required int page,
    required int pageSize,
    String? sortColumn,
    SortDirection? sortDirection,
    required Map<String, String> filters,
  }) async {
    // This would be replaced with actual API calls
    final totalRows = 150; // Total rows on server
    final totalPages = (totalRows / pageSize).ceil();

    // Generate mock data for this page
    final rows = List.generate(pageSize, (index) {
      final actualIndex = page * pageSize + index;
      if (actualIndex >= totalRows) {
        return null; // Beyond total rows
      }

      final id = (actualIndex + 1).toString();
      final name = 'Server User ${actualIndex + 1}';

      final originalData = {
        'id': id,
        'name': name,
        // Add more fields as needed
      };

      return TableRow(
        id: id,
        originalData: originalData,
        cells: [
          TableCell(content: id),
          TableCell(content: name),
          // Add more cells as needed
        ],
      );
    }).whereType<TableRow>().toList();

    return ServerResponse(
      rows: rows,
      totalPages: totalPages,
      totalRows: totalRows,
    );
  }
}

// Mock server response model
class ServerResponse {
  final List<TableRow> rows;
  final int totalPages;
  final int totalRows;

  ServerResponse({
    required this.rows,
    required this.totalPages,
    required this.totalRows,
  });
}

// Entry point

// Register the provider override in main.dart
void main() {
  runApp(
    const ProviderScope(
      /*  overrides: [
        tableProvider(
          'example-table',
        ).overrideWithProvider(exampleTableProvider),
      ], */
      child: MaterialApp(home: ExampleTablePage()),
    ),
  );
}
