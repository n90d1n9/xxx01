// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Master-Detail Table',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MasterDetailTableScreen(),
    );
  }
}

// Models
class TableItem {
  final String id;
  final String category;
  final String name;
  final double value;
  final DateTime date;
  final bool active;
  final String status;
  final int priority;

  TableItem({
    required this.id,
    required this.category,
    required this.name,
    required this.value,
    required this.date,
    required this.active,
    required this.status,
    required this.priority,
  });

  TableItem copyWith({
    String? id,
    String? category,
    String? name,
    double? value,
    DateTime? date,
    bool? active,
    String? status,
    int? priority,
  }) {
    return TableItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      value: value ?? this.value,
      date: date ?? this.date,
      active: active ?? this.active,
      status: status ?? this.status,
      priority: priority ?? this.priority,
    );
  }
}

// Providers
final tableDataProvider =
    StateNotifierProvider<TableDataNotifier, List<TableItem>>((ref) {
      return TableDataNotifier();
    });

final selectedItemProvider = StateProvider<TableItem?>((ref) => null);

final filterProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final sortingProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {'field': 'name', 'ascending': true},
);

final pageInfoProvider = StateProvider<Map<String, dynamic>>(
  (ref) => {'currentPage': 0, 'itemsPerPage': 10},
);

// Notifiers
class TableDataNotifier extends StateNotifier<List<TableItem>> {
  TableDataNotifier() : super([]) {
    _initializeData();
  }

  void _initializeData() {
    final random = Random();
    final categories = ['Hardware', 'Software', 'Services', 'Infrastructure'];
    final statuses = ['Pending', 'Approved', 'Rejected', 'On Hold'];

    // Generate sample data
    final data = List.generate(100, (index) {
      final categoryIndex = random.nextInt(categories.length);
      return TableItem(
        id: 'ID-${1000 + index}',
        category: categories[categoryIndex],
        name: 'Item ${index + 1}',
        value: double.parse((random.nextDouble() * 1000).toStringAsFixed(2)),
        date: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        active: random.nextBool(),
        status: statuses[random.nextInt(statuses.length)],
        priority: random.nextInt(5) + 1,
      );
    });

    state = data;
  }

  List<TableItem> getFilteredAndSortedData(
    Map<String, dynamic> filters,
    String sortField,
    bool ascending,
  ) {
    List<TableItem> filteredItems = List.from(state);

    // Apply filters
    if (filters.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        bool matchesAll = true;

        if (filters.containsKey('category') && filters['category'] != null) {
          matchesAll = matchesAll && item.category == filters['category'];
        }

        if (filters.containsKey('active') && filters['active'] != null) {
          matchesAll = matchesAll && item.active == filters['active'];
        }

        if (filters.containsKey('status') && filters['status'] != null) {
          matchesAll = matchesAll && item.status == filters['status'];
        }

        if (filters.containsKey('search') && filters['search'] != null) {
          final search = filters['search'].toString().toLowerCase();
          matchesAll =
              matchesAll &&
              (item.name.toLowerCase().contains(search) ||
                  item.id.toLowerCase().contains(search) ||
                  item.category.toLowerCase().contains(search));
        }

        return matchesAll;
      }).toList();
    }

    // Apply sorting
    if (sortField.isNotEmpty) {
      filteredItems.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortField) {
          case 'id':
            aValue = a.id;
            bValue = b.id;
            break;
          case 'name':
            aValue = a.name;
            bValue = b.name;
            break;
          case 'category':
            aValue = a.category;
            bValue = b.category;
            break;
          case 'value':
            aValue = a.value;
            bValue = b.value;
            break;
          case 'date':
            aValue = a.date;
            bValue = b.date;
            break;
          case 'priority':
            aValue = a.priority;
            bValue = b.priority;
            break;
          default:
            aValue = a.name;
            bValue = b.name;
        }

        int comparison;
        if (aValue is String && bValue is String) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is num && bValue is num) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is DateTime && bValue is DateTime) {
          comparison = aValue.compareTo(bValue);
        } else if (aValue is bool && bValue is bool) {
          comparison = aValue ? 1 : 0;
          comparison -= bValue ? 1 : 0;
        } else {
          comparison = 0;
        }

        return ascending ? comparison : -comparison;
      });
    }

    return filteredItems;
  }

  List<TableItem> getPaginatedData(
    List<TableItem> data,
    int page,
    int itemsPerPage,
  ) {
    final startIndex = page * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, data.length);

    if (startIndex >= data.length) {
      return [];
    }

    return data.sublist(startIndex, endIndex);
  }

  void updateItem(TableItem item) {
    state = state.map((e) => e.id == item.id ? item : e).toList();
  }

  void addItem(TableItem item) {
    state = [...state, item];
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

// Widgets
class MasterDetailTableScreen extends ConsumerWidget {
  const MasterDetailTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    final sorting = ref.watch(sortingProvider);
    final pageInfo = ref.watch(pageInfoProvider);
    final selectedItem = ref.watch(selectedItemProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Master-Detail Table')),
      body: Row(
        children: [
          // Master view (table)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Filter panel
                TableFilterPanel(),

                // Table header and body
                Expanded(child: AdvancedDataTable()),

                // Pagination
                TablePagination(),
              ],
            ),
          ),

          // Detail view
          if (selectedItem != null)
            Expanded(flex: 1, child: DetailPanel(item: selectedItem)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context, ref);
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        onSave: (item) {
          ref.read(tableDataProvider.notifier).addItem(item);
        },
      ),
    );
  }
}

class TableFilterPanel extends ConsumerWidget {
  const TableFilterPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final currentFilters = Map<String, dynamic>.from(filters);
                    currentFilters['search'] = value.isNotEmpty ? value : null;
                    ref.read(filterProvider.notifier).state = currentFilters;
                  },
                ),
              ),
              const SizedBox(width: 16),
              _buildCategoryDropdown(ref, filters),
              const SizedBox(width: 16),
              _buildStatusDropdown(ref, filters),
              const SizedBox(width: 16),
              _buildActiveFilter(ref, filters),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(WidgetRef ref, Map<String, dynamic> filters) {
    final categories = [
      'All',
      'Hardware',
      'Software',
      'Services',
      'Infrastructure',
    ];
    final selectedCategory = filters['category'] ?? 'All';

    return DropdownButton<String>(
      value: selectedCategory,
      hint: const Text('Category'),
      onChanged: (value) {
        final currentFilters = Map<String, dynamic>.from(filters);
        currentFilters['category'] = value != 'All' ? value : null;
        ref.read(filterProvider.notifier).state = currentFilters;
      },
      items: categories.map((category) {
        return DropdownMenuItem<String>(value: category, child: Text(category));
      }).toList(),
    );
  }

  Widget _buildStatusDropdown(WidgetRef ref, Map<String, dynamic> filters) {
    final statuses = ['All', 'Pending', 'Approved', 'Rejected', 'On Hold'];
    final selectedStatus = filters['status'] ?? 'All';

    return DropdownButton<String>(
      value: selectedStatus,
      hint: const Text('Status'),
      onChanged: (value) {
        final currentFilters = Map<String, dynamic>.from(filters);
        currentFilters['status'] = value != 'All' ? value : null;
        ref.read(filterProvider.notifier).state = currentFilters;
      },
      items: statuses.map((status) {
        return DropdownMenuItem<String>(value: status, child: Text(status));
      }).toList(),
    );
  }

  Widget _buildActiveFilter(WidgetRef ref, Map<String, dynamic> filters) {
    return ToggleButtons(
      isSelected: [
        filters['active'] == null,
        filters['active'] == true,
        filters['active'] == false,
      ],
      onPressed: (index) {
        final currentFilters = Map<String, dynamic>.from(filters);
        switch (index) {
          case 0:
            currentFilters['active'] = null;
            break;
          case 1:
            currentFilters['active'] = true;
            break;
          case 2:
            currentFilters['active'] = false;
            break;
        }
        ref.read(filterProvider.notifier).state = currentFilters;
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('All'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Active'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Inactive'),
        ),
      ],
    );
  }
}

class AdvancedDataTable extends ConsumerWidget {
  const AdvancedDataTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableDataNotifier = ref.watch(tableDataProvider.notifier);
    final filters = ref.watch(filterProvider);
    final sorting = ref.watch(sortingProvider);
    final pageInfo = ref.watch(pageInfoProvider);

    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;
    final currentPage = pageInfo['currentPage'] as int;
    final itemsPerPage = pageInfo['itemsPerPage'] as int;

    // Get filtered and sorted data
    final filteredAndSortedData = tableDataNotifier.getFilteredAndSortedData(
      filters,
      sortField,
      ascending,
    );

    // Get paginated data
    final paginatedData = tableDataNotifier.getPaginatedData(
      filteredAndSortedData,
      currentPage,
      itemsPerPage,
    );

    // Update total pages
    if (filteredAndSortedData.isEmpty) {
      Future.microtask(() {
        final newPageInfo = Map<String, dynamic>.from(pageInfo);
        newPageInfo['totalPages'] = 1;
        newPageInfo['totalItems'] = 0;
        ref.read(pageInfoProvider.notifier).state = newPageInfo;
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

        ref.read(pageInfoProvider.notifier).state = newPageInfo;
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
                columns: _buildColumns(ref, sorting),
                rows: _buildRows(ref, paginatedData),
              ),
            ),
          );
  }

  List<DataColumn> _buildColumns(WidgetRef ref, Map<String, dynamic> sorting) {
    final sortField = sorting['field'] as String;
    final ascending = sorting['ascending'] as bool;

    return [
      _buildSortableColumn(ref, 'ID', 'id', sortField, ascending),
      _buildSortableColumn(ref, 'Category', 'category', sortField, ascending),
      _buildSortableColumn(ref, 'Name', 'name', sortField, ascending),
      _buildSortableColumn(ref, 'Value', 'value', sortField, ascending),
      _buildSortableColumn(ref, 'Date', 'date', sortField, ascending),
      _buildSortableColumn(ref, 'Status', 'status', sortField, ascending),
      _buildSortableColumn(ref, 'Priority', 'priority', sortField, ascending),
      DataColumn(label: const Text('Active'), onSort: null),
      DataColumn(label: const Text('Actions'), onSort: null),
    ];
  }

  DataColumn _buildSortableColumn(
    WidgetRef ref,
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
        ref.read(sortingProvider.notifier).state = newSorting;
      },
    );
  }

  List<DataRow> _buildRows(WidgetRef ref, List<TableItem> items) {
    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = ref.watch(selectedItemProvider)?.id == item.id;

      // Determine if this row should have colspan or rowspan
      final bool hasRowSpan = item.priority > 3; // Example condition

      return DataRow(
        selected: isSelected,
        color: MaterialStateProperty.resolveWith<Color?>((
          Set<MaterialState> states,
        ) {
          if (states.contains(MaterialState.selected)) {
            return Theme.of(
              ref.context,
            ).colorScheme.primary.withValues(alpha: 0.08);
          }
          return index % 2 == 0 ? Colors.grey.shade50 : null;
        }),
        cells: [
          DataCell(Text(item.id), onTap: () => _selectItem(ref, item)),
          DataCell(Text(item.category), onTap: () => _selectItem(ref, item)),
          DataCell(Text(item.name), onTap: () => _selectItem(ref, item)),
          DataCell(
            Text('\$${item.value.toStringAsFixed(2)}'),
            onTap: () => _selectItem(ref, item),
          ),
          DataCell(
            Text(_formatDate(item.date)),
            onTap: () => _selectItem(ref, item),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(item.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onTap: () => _selectItem(ref, item),
          ),
          DataCell(
            Row(
              children: List.generate(
                item.priority,
                (i) => const Icon(Icons.star, size: 16, color: Colors.amber),
              ),
            ),
            onTap: () => _selectItem(ref, item),
          ),
          DataCell(
            Icon(
              item.active ? Icons.check_circle : Icons.cancel,
              color: item.active ? Colors.green : Colors.red,
            ),
            onTap: () => _selectItem(ref, item),
          ),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editItem(ref, item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteItem(ref, item),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  void _selectItem(WidgetRef ref, TableItem item) {
    final currentSelected = ref.read(selectedItemProvider);
    if (currentSelected?.id == item.id) {
      ref.read(selectedItemProvider.notifier).state = null;
    } else {
      ref.read(selectedItemProvider.notifier).state = item;
    }
  }

  void _editItem(WidgetRef ref, TableItem item) {
    showDialog(
      context: ref.context,
      builder: (context) => ItemFormDialog(
        item: item,
        onSave: (updatedItem) {
          ref.read(tableDataProvider.notifier).updateItem(updatedItem);

          // Update selected item if it's the one being edited
          final currentSelected = ref.read(selectedItemProvider);
          if (currentSelected?.id == updatedItem.id) {
            ref.read(selectedItemProvider.notifier).state = updatedItem;
          }
        },
      ),
    );
  }

  void _deleteItem(WidgetRef ref, TableItem item) {
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
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
              ref.read(tableDataProvider.notifier).deleteItem(item.id);

              // Clear selected item if it's the one being deleted
              final currentSelected = ref.read(selectedItemProvider);
              if (currentSelected?.id == item.id) {
                ref.read(selectedItemProvider.notifier).state = null;
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'On Hold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class TablePagination extends ConsumerWidget {
  const TablePagination({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageInfo = ref.watch(pageInfoProvider);

    final currentPage = pageInfo['currentPage'] as int;
    final totalPages = pageInfo['totalPages'] as int? ?? 1;
    final totalItems = pageInfo['totalItems'] as int? ?? 0;
    final itemsPerPage = pageInfo['itemsPerPage'] as int;

    final startItem = currentPage * itemsPerPage + 1;
    final endItem = min((currentPage + 1) * itemsPerPage, totalItems);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page
          Row(
            children: [
              const Text('Items per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: itemsPerPage,
                onChanged: (value) {
                  if (value != null) {
                    final newPageInfo = Map<String, dynamic>.from(pageInfo);
                    newPageInfo['itemsPerPage'] = value;
                    newPageInfo['currentPage'] = 0;
                    ref.read(pageInfoProvider.notifier).state = newPageInfo;
                  }
                },
                items: [10, 25, 50, 100].map((pageSize) {
                  return DropdownMenuItem<int>(
                    value: pageSize,
                    child: Text('$pageSize'),
                  );
                }).toList(),
              ),
            ],
          ),

          // Page info
          Text(
            totalItems > 0
                ? 'Showing $startItem-$endItem of $totalItems items'
                : 'No items',
          ),

          // Pagination controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 0
                    ? () {
                        final newPageInfo = Map<String, dynamic>.from(pageInfo);
                        newPageInfo['currentPage'] = 0;
                        ref.read(pageInfoProvider.notifier).state = newPageInfo;
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0
                    ? () {
                        final newPageInfo = Map<String, dynamic>.from(pageInfo);
                        newPageInfo['currentPage'] = currentPage - 1;
                        ref.read(pageInfoProvider.notifier).state = newPageInfo;
                      }
                    : null,
              ),
              for (
                int i = max(0, currentPage - 1);
                i <= min(totalPages - 1, currentPage + 1);
                i++
              )
                InkWell(
                  onTap: i != currentPage
                      ? () {
                          final newPageInfo = Map<String, dynamic>.from(
                            pageInfo,
                          );
                          newPageInfo['currentPage'] = i;
                          ref.read(pageInfoProvider.notifier).state =
                              newPageInfo;
                        }
                      : null,
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == currentPage
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: i == currentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == currentPage ? Colors.white : null,
                        ),
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages - 1
                    ? () {
                        final newPageInfo = Map<String, dynamic>.from(pageInfo);
                        newPageInfo['currentPage'] = currentPage + 1;
                        ref.read(pageInfoProvider.notifier).state = newPageInfo;
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages - 1
                    ? () {
                        final newPageInfo = Map<String, dynamic>.from(pageInfo);
                        newPageInfo['currentPage'] = totalPages - 1;
                        ref.read(pageInfoProvider.notifier).state = newPageInfo;
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailPanel extends ConsumerWidget {
  final TableItem item;

  const DetailPanel({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(selectedItemProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailHeader(),
                  const SizedBox(height: 24),
                  _buildDetailItem('ID', item.id),
                  _buildDetailItem('Name', item.name),
                  _buildDetailItem('Category', item.category),
                  _buildDetailItem(
                    'Value',
                    '\$${item.value.toStringAsFixed(2)}',
                  ),
                  _buildDetailItem('Date', _formatDate(item.date)),
                  _buildDetailItem(
                    'Status',
                    item.status,
                    customWidget: _buildStatusBadge(),
                  ),
                  _buildDetailItem(
                    'Priority',
                    '${item.priority}',
                    customWidget: Row(
                      children: List.generate(
                        item.priority,
                        (i) => const Icon(Icons.star, color: Colors.amber),
                      ),
                    ),
                  ),
                  _buildDetailItem(
                    'Active',
                    item.active ? 'Yes' : 'No',
                    customWidget: Icon(
                      item.active ? Icons.check_circle : Icons.cancel,
                      color: item.active ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          item.category,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Widget? customWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: customWidget ?? Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(item.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        item.status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () => _editItem(ref, item),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          onPressed: () => _deleteItem(ref, item),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'On Hold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _editItem(WidgetRef ref, TableItem item) {
    showDialog(
      context: ref.context,
      builder: (context) => ItemFormDialog(
        item: item,
        onSave: (updatedItem) {
          ref.read(tableDataProvider.notifier).updateItem(updatedItem);
          ref.read(selectedItemProvider.notifier).state = updatedItem;
        },
      ),
    );
  }

  void _deleteItem(WidgetRef ref, TableItem item) {
    showDialog(
      context: ref.context,
      builder: (context) => AlertDialog(
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
              ref.read(tableDataProvider.notifier).deleteItem(item.id);
              ref.read(selectedItemProvider.notifier).state = null;
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ItemFormDialog extends ConsumerStatefulWidget {
  final TableItem? item;
  final Function(TableItem) onSave;

  const ItemFormDialog({Key? key, this.item, required this.onSave})
    : super(key: key);

  @override
  ConsumerState<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends ConsumerState<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _name;
  late String _category;
  late double _value;
  late DateTime _date;
  late bool _active;
  late String _status;
  late int _priority;

  @override
  void initState() {
    super.initState();

    // Initialize with existing item data or defaults
    final item = widget.item;
    if (item != null) {
      _id = item.id;
      _name = item.name;
      _category = item.category;
      _value = item.value;
      _date = item.date;
      _active = item.active;
      _status = item.status;
      _priority = item.priority;
    } else {
      // Defaults for new item
      _id = 'ID-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
      _name = '';
      _category = 'Hardware';
      _value = 0.0;
      _date = DateTime.now();
      _active = true;
      _status = 'Pending';
      _priority = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add New Item' : 'Edit Item'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _id,
                  decoration: const InputDecoration(
                    labelText: 'ID',
                    enabled: false,
                  ),
                  enabled: false,
                ),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) => _name = value,
                ),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Hardware', 'Software', 'Services', 'Infrastructure']
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _category = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  initialValue: _value.toString(),
                  decoration: const InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (double.tryParse(value) != null) {
                      _value = double.parse(value);
                    }
                  },
                ),
                InkWell(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        _date = selectedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Pending', 'Approved', 'Rejected', 'On Hold']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Priority'),
                Slider(
                  value: _priority.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _priority.toString(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value.toInt();
                    });
                  },
                ),
                Row(
                  children: [
                    const Text('Active'),
                    Switch(
                      value: _active,
                      onChanged: (value) {
                        setState(() {
                          _active = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final item = TableItem(
                id: _id,
                name: _name,
                category: _category,
                value: _value,
                date: _date,
                active: _active,
                status: _status,
                priority: _priority,
              );

              widget.onSave(item);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
