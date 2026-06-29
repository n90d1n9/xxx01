import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

// ==================== DATA MODELS ====================

// Model for table cell data that supports rowspan and colspan
class TableCell {
  final dynamic content;
  final int rowSpan;
  final int colSpan;
  final bool isHeader;

  TableCell({
    required this.content,
    this.rowSpan = 1,
    this.colSpan = 1,
    this.isHeader = false,
  });

  @override
  String toString() => content.toString();
}

// Model for table row data
class TableRow {
  final String id;
  final List<TableCell> cells;
  final Map<String, dynamic> originalData;

  TableRow({required this.id, required this.cells, required this.originalData});
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

  TableColumn({
    required this.id,
    required this.label,
    this.width = 100,
    this.sortable = true,
    this.filterable = true,
    this.textAlign = TextAlign.left,
    this.customCell,
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
  });

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
    );
  }
}

// Table notifier class for state management
class TableNotifier extends StateNotifier<TableState> {
  TableNotifier({
    required List<TableRow> rows,
    required List<TableColumn> columns,
    int rowsPerPage = 10,
  }) : super(
         TableState(
           originalRows: rows,
           columns: columns,
           displayRows: rows,
           filters: {},
           rowsPerPage: rowsPerPage,
           totalPages: (rows.length / rowsPerPage).ceil(),
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
    );
    _applyFiltersAndSort();
  }

  // Sets the sorting column and direction
  void setSort(String columnId) {
    final newDirection =
        state.sortColumnId == columnId
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

  // Apply filters, sorting, and pagination
  void _applyFiltersAndSort() {
    state = state.copyWith(isLoading: true);

    // Apply filters
    List<TableRow> filteredRows = List.from(state.originalRows);
    if (state.filters.isNotEmpty) {
      filteredRows =
          filteredRows.where((row) {
            return state.filters.entries.every((filter) {
              final columnId = filter.key;
              final filterValue = filter.value.toLowerCase();
              final cellValue =
                  row.originalData[columnId]?.toString().toLowerCase();
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
  final String providerId;
  final String title;
  final double? width;
  final double? height;
  final bool showFilters;
  final bool showPagination;
  final bool showTitle;
  final List<int> rowsPerPageOptions;
  final Widget Function(BuildContext, TableRow)? customRowBuilder;

  const AdvancedTable({
    Key? key,
    required this.providerId,
    this.title = 'Advanced Table',
    this.width,
    this.height,
    this.showFilters = true,
    this.showPagination = true,
    this.showTitle = true,
    this.rowsPerPageOptions = const [5, 10, 25, 50, 100],
    this.customRowBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider(providerId));
    final tableNotifier = ref.read(tableProvider(providerId).notifier);

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
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

          // Filter row
          if (showFilters)
            Padding(
              padding: const EdgeInsets.all(8.0),
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

          // Table header and data
          Expanded(
            child:
                tableState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            _buildHeaderRow(context, tableState, tableNotifier),

                            // Data rows
                            ...tableState.displayRows.map((row) {
                              if (customRowBuilder != null) {
                                return customRowBuilder!(context, row);
                              }
                              return _buildDataRow(context, row, ref);
                            }).toList(),

                            if (tableState.displayRows.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                alignment: Alignment.center,
                                width: tableState.columns.fold<double>(
                                  0,
                                  (prev, col) => prev + col.width,
                                ),
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
                        items:
                            rowsPerPageOptions.map((count) {
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
                        onPressed:
                            tableState.page > 0
                                ? () => tableNotifier.setPage(0)
                                : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_before),
                        onPressed:
                            tableState.page > 0
                                ? () =>
                                    tableNotifier.setPage(tableState.page - 1)
                                : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_next),
                        onPressed:
                            tableState.page < tableState.totalPages - 1
                                ? () =>
                                    tableNotifier.setPage(tableState.page + 1)
                                : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.last_page),
                        onPressed:
                            tableState.page < tableState.totalPages - 1
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
        children:
            tableState.columns.map((column) {
              final isSorted = tableState.sortColumnId == column.id;
              final sortIcon =
                  tableState.sortDirection == SortDirection.asc
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
                child:
                    column.sortable
                        ? InkWell(
                          onTap: () => tableNotifier.setSort(column.id),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  column.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isSorted &&
                                  tableState.sortDirection !=
                                      SortDirection.none)
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

  // Build data row with cell content
  Widget _buildDataRow(BuildContext context, TableRow row, WidgetRef ref) {
    // Create a matrix to track which cells are occupied by spanning cells
    final List<List<bool>> occupiedCells = List.generate(
      1, // We only need to track one row at a time for colSpan
      (_) => List.generate(row.cells.length, (_) => false),
    );

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < row.cells.length; i++)
            if (!occupiedCells[0][i]) ...[
              _buildDataCell(context, row.cells[i], i, occupiedCells, ref),
            ],
        ],
      ),
    );
  }

  // Build data cell with colspan support
  Widget _buildDataCell(
    BuildContext context,
    TableCell cell,
    int columnIndex,
    List<List<bool>> occupiedCells,
    WidgetRef ref,
  ) {
    // Mark spanned columns as occupied
    for (int i = 0; i < cell.colSpan; i++) {
      if (columnIndex + i < occupiedCells[0].length) {
        occupiedCells[0][columnIndex + i] = true;
      }
    }

    final tableState = ref.read(tableProvider(providerId));
    final column = tableState.columns[columnIndex];
    final effectiveWidth = column.width * cell.colSpan;

    return Container(
      width: effectiveWidth,
      height: cell.isHeader ? 40 : null,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cell.isHeader ? Colors.grey.shade100 : Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Align(
        alignment: _getAlignmentFromTextAlign(column.textAlign),
        child:
            column.customCell != null
                ? column.customCell!(cell.content)
                : Text(
                  cell.content.toString(),
                  style: TextStyle(
                    fontWeight:
                        cell.isHeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
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
  // Define columns
  final columns = [
    TableColumn(id: 'id', label: 'ID', width: 80, textAlign: TextAlign.center),
    TableColumn(id: 'name', label: 'Name', width: 150),
    TableColumn(id: 'age', label: 'Age', width: 80, textAlign: TextAlign.right),
    TableColumn(id: 'email', label: 'Email', width: 200),
    TableColumn(
      id: 'status',
      label: 'Status',
      width: 120,
      customCell:
          (value) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  value == 'Active'
                      ? Colors.green.shade100
                      : value == 'Inactive'
                      ? Colors.red.shade100
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                color:
                    value == 'Active'
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
    final status =
        index % 3 == 0 ? 'Active' : (index % 3 == 1 ? 'Inactive' : 'Pending');

    final originalData = {
      'id': id,
      'name': name,
      'age': age,
      'email': email,
      'status': status,
    };

    // Create special cases for rowspan and colspan
    if (index % 10 == 0) {
      return TableRow(
        id: id,
        originalData: originalData,
        cells: [
          TableCell(content: id, isHeader: true),
          TableCell(content: 'Special User', colSpan: 2, isHeader: true),
          TableCell(content: email),
          TableCell(content: status),
        ],
      );
    }

    // Regular rows
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
    );
  });

  return TableNotifier(rows: rows, columns: columns, rowsPerPage: 10);
});

// Example usage in a Flutter app
class ExampleTablePage extends ConsumerWidget {
  const ExampleTablePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Table Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AdvancedTable(
          providerId: 'example-table',
          title: 'User Management',
          height: MediaQuery.of(context).size.height - 100,
        ),
      ),
    );
  }
}

// Register the provider override in main.dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        tableProvider(
          'example-table',
        ).overrideWithProvider(exampleTableProvider),
      ],
      child: const MaterialApp(home: ExampleTablePage()),
    ),
  );
}
