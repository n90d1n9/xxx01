import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Data Table Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductsTableScreen(),
    );
  }
}

// ----- MODEL -----
class DataItem {
  final String id;
  final Map<String, dynamic> data;

  DataItem({required this.id, required this.data});
}

// ----- PROVIDERS -----
class TableState {
  final List<DataItem> allItems;
  final List<DataItem> filteredItems;
  final List<DataItem> displayedItems;
  final int currentPage;
  final int itemsPerPage;
  final Map<String, bool> sortConfig; // column name -> isAscending
  final Map<String, dynamic> filterValues;

  TableState({
    required this.allItems,
    required this.filteredItems,
    required this.displayedItems,
    required this.currentPage,
    required this.itemsPerPage,
    required this.sortConfig,
    required this.filterValues,
  });

  TableState copyWith({
    List<DataItem>? allItems,
    List<DataItem>? filteredItems,
    List<DataItem>? displayedItems,
    int? currentPage,
    int? itemsPerPage,
    Map<String, bool>? sortConfig,
    Map<String, dynamic>? filterValues,
  }) {
    return TableState(
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      displayedItems: displayedItems ?? this.displayedItems,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      sortConfig: sortConfig ?? this.sortConfig,
      filterValues: filterValues ?? this.filterValues,
    );
  }

  int get totalPages => (filteredItems.length / itemsPerPage).ceil();
}

class TableNotifier extends StateNotifier<TableState> {
  TableNotifier()
    : super(
        TableState(
          allItems: [],
          filteredItems: [],
          displayedItems: [],
          currentPage: 1,
          itemsPerPage: 10,
          sortConfig: {},
          filterValues: {},
        ),
      );

  void setData(List<DataItem> items) {
    state = state.copyWith(allItems: items);
    _applyFiltersAndSort();
  }

  void setItemsPerPage(int count) {
    state = state.copyWith(
      itemsPerPage: count,
      currentPage: 1, // Reset to first page
    );
    _updateDisplayedItems();
  }

  void goToPage(int page) {
    if (page < 1 || page > state.totalPages) return;
    state = state.copyWith(currentPage: page);
    _updateDisplayedItems();
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      goToPage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }

  void toggleSort(String column) {
    final currentSortConfig = Map<String, bool>.from(state.sortConfig);

    // If this column isn't being sorted, sort ascending
    if (!currentSortConfig.containsKey(column)) {
      currentSortConfig[column] = true;
    } else {
      // If it's already ascending, switch to descending
      if (currentSortConfig[column] == true) {
        currentSortConfig[column] = false;
      } else {
        // If it's already descending, remove sorting
        currentSortConfig.remove(column);
      }
    }

    state = state.copyWith(sortConfig: currentSortConfig);
    _applyFiltersAndSort();
  }

  void setFilter(String column, dynamic value) {
    final newFilters = Map<String, dynamic>.from(state.filterValues);

    if (value == null || value == '' || (value is List && value.isEmpty)) {
      newFilters.remove(column);
    } else {
      newFilters[column] = value;
    }

    state = state.copyWith(
      filterValues: newFilters,
      currentPage: 1, // Reset to first page when filter changes
    );
    _applyFiltersAndSort();
  }

  void clearFilters() {
    state = state.copyWith(filterValues: {}, currentPage: 1);
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    List<DataItem> filtered = List.from(state.allItems);

    // Apply filters
    state.filterValues.forEach((column, filterValue) {
      filtered =
          filtered.where((item) {
            final value = item.data[column];

            // Handle different filter types
            if (filterValue is String) {
              return value.toString().toLowerCase().contains(
                filterValue.toLowerCase(),
              );
            } else if (filterValue is num) {
              return value == filterValue;
            } else if (filterValue is List) {
              return filterValue.contains(value);
            } else if (filterValue is bool) {
              return value == filterValue;
            } else if (filterValue is RangeValues) {
              if (value is num) {
                return value >= filterValue.start && value <= filterValue.end;
              }
            }
            return false;
          }).toList();
    });

    // Apply sorting
    if (state.sortConfig.isNotEmpty) {
      state.sortConfig.forEach((column, isAscending) {
        filtered.sort((a, b) {
          final aValue = a.data[column];
          final bValue = b.data[column];

          int compareResult;
          if (aValue is num && bValue is num) {
            compareResult = aValue.compareTo(bValue);
          } else {
            compareResult = aValue.toString().compareTo(bValue.toString());
          }

          return isAscending ? compareResult : -compareResult;
        });
      });
    }

    state = state.copyWith(filteredItems: filtered);
    _updateDisplayedItems();
  }

  void _updateDisplayedItems() {
    final start = (state.currentPage - 1) * state.itemsPerPage;
    final end = start + state.itemsPerPage;

    List<DataItem>? displayItems =
        state.filteredItems.length > start
            ? state.filteredItems.sublist(
              start,
              end > state.filteredItems.length
                  ? state.filteredItems.length
                  : end,
            )
            : [];

    state = state.copyWith(displayedItems: displayItems);
  }
}

final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  return TableNotifier();
});

// ----- WIDGETS -----
class AdvancedDataTable extends ConsumerWidget {
  final List<String> columns;
  final List<DataItem> data;
  final Map<String, Widget Function(BuildContext, String, dynamic)>
  filterBuilders;
  final Widget Function(BuildContext, DataItem) rowBuilder;
  final String? title;
  final List<int> availablePageSizes;

  const AdvancedDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.filterBuilders,
    required this.rowBuilder,
    this.title,
    this.availablePageSizes = const [5, 10, 25, 50],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize data if needed
    final tableState = ref.watch(tableProvider);
    final tableNotifier = ref.read(tableProvider.notifier);

    if (tableState.allItems.isEmpty && data.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tableNotifier.setData(data);
      });
    }

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header with title and controls
          _buildTableHeader(context, ref),

          // Filter row
          _buildFilterRow(context, ref),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Column headers
          _buildColumnHeaders(context, ref),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Table body
          _buildTableBody(context, ref),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Pagination controls
          _buildPaginationControls(context, ref),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final tableNotifier = ref.read(tableProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (title != null)
            Text(title!, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          // Items per page dropdown
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: tableState.itemsPerPage,
                items:
                    availablePageSizes.map((size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text('$size'),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    tableNotifier.setItemsPerPage(value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Clear filters button
          OutlinedButton.icon(
            icon: const Icon(Icons.filter_list_off),
            label: const Text('Clear Filters'),
            onPressed:
                tableState.filterValues.isEmpty
                    ? null
                    : () => tableNotifier.clearFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, WidgetRef ref) {
    final tableNotifier = ref.read(tableProvider.notifier);
    final filterValues = ref.watch(tableProvider).filterValues;

    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            columns.map((column) {
              if (filterBuilders.containsKey(column)) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: filterBuilders[column]!(
                      context,
                      column,
                      filterValues[column],
                    ),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Filter $column',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          filterValues.containsKey(column)
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed:
                                    () => tableNotifier.setFilter(column, null),
                              )
                              : null,
                    ),
                    onChanged:
                        (value) => tableNotifier.setFilter(column, value),
                    initialValue: filterValues[column] as String? ?? '',
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildColumnHeaders(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final tableNotifier = ref.read(tableProvider.notifier);

    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children:
            columns.map((column) {
              final isSorted = tableState.sortConfig.containsKey(column);
              final isAscending =
                  isSorted ? tableState.sortConfig[column]! : null;

              return Expanded(
                child: InkWell(
                  onTap: () => tableNotifier.toggleSort(column),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            column,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isSorted)
                          Icon(
                            isAscending!
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTableBody(BuildContext context, WidgetRef ref) {
    final displayedItems = ref.watch(tableProvider).displayedItems;

    if (displayedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: const Text(
          'No data to display',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      children:
          displayedItems.mapIndexed((index, item) {
            return Container(
              decoration: BoxDecoration(
                color:
                    index.isEven
                        ? Colors.transparent
                        : Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withValues(alpha: 0.1),
              ),
              child: rowBuilder(context, item),
            );
          }).toList(),
    );
  }

  Widget _buildPaginationControls(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final tableNotifier = ref.read(tableProvider.notifier);

    final totalPages = tableState.totalPages;
    final currentPage = tableState.currentPage;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${tableState.displayedItems.length} of ${tableState.filteredItems.length} items',
          ),
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed:
                      currentPage > 1 ? () => tableNotifier.goToPage(1) : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      currentPage > 1
                          ? () => tableNotifier.previousPage()
                          : null,
                ),
                // Page number indicator
                _buildPageNumbers(context, ref),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      currentPage < totalPages
                          ? () => tableNotifier.nextPage()
                          : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed:
                      currentPage < totalPages
                          ? () => tableNotifier.goToPage(totalPages)
                          : null,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableProvider);
    final tableNotifier = ref.read(tableProvider.notifier);

    final totalPages = tableState.totalPages;
    final currentPage = tableState.currentPage;

    // Show five page numbers at most
    const maxVisiblePages = 5;

    List<int> visiblePages = [];

    if (totalPages <= maxVisiblePages) {
      // Show all pages
      visiblePages = List.generate(totalPages, (index) => index + 1);
    } else {
      // Show a subset of pages
      final middle = maxVisiblePages ~/ 2;

      if (currentPage <= middle + 1) {
        // Near the start
        visiblePages = List.generate(maxVisiblePages, (index) => index + 1);
      } else if (currentPage >= totalPages - middle) {
        // Near the end
        visiblePages = List.generate(
          maxVisiblePages,
          (index) => totalPages - maxVisiblePages + index + 1,
        );
      } else {
        // In the middle
        visiblePages = List.generate(
          maxVisiblePages,
          (index) => currentPage - middle + index,
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          visiblePages.map((page) {
            final isCurrentPage = page == currentPage;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap:
                    isCurrentPage ? null : () => tableNotifier.goToPage(page),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isCurrentPage
                            ? Theme.of(context).colorScheme.primary
                            : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color:
                          isCurrentPage
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                      fontWeight: isCurrentPage ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ----- PRODUCT DATA & SCREEN -----
class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final bool inStock;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.inStock,
    required this.createdAt,
  });
}

class ProductsTableScreen extends ConsumerWidget {
  const ProductsTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sample product data
    final categories = [
      'Electronics',
      'Fashion',
      'Home & Kitchen',
      'Beauty',
      'Sports',
    ];

    final products = List.generate(200, (index) {
      final category = categories[index % categories.length];
      final price = (15 + (index % 85) * 1.5);
      final stock = (index % 5 == 0) ? 0 : (index % 30) + 1;

      return Product(
        id: 1000 + index,
        name: '${category} Item ${index + 1}',
        price: price,
        stock: stock,
        category: category,
        inStock: stock > 0,
        createdAt: DateTime.now().subtract(Duration(days: index % 365)),
      );
    });

    // Convert products to DataItems
    final data =
        products.map((product) {
          return DataItem(
            id: product.id.toString(),
            data: {
              'id': product.id,
              'name': product.name,
              'price': product.price,
              'stock': product.stock,
              'category': product.category,
              'inStock': product.inStock,
              'createdAt': product.createdAt,
            },
          );
        }).toList();

    // Define columns
    final columns = [
      'id',
      'name',
      'price',
      'stock',
      'category',
      'inStock',
      'createdAt',
    ];

    // Custom filter builders
    final filterBuilders = {
      'category': (BuildContext context, String column, dynamic value) {
        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Filter Category',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          value: value as String?,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Categories'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }),
          ],
          onChanged: (newValue) {
            ref.read(tableProvider.notifier).setFilter(column, newValue);
          },
        );
      },
      'inStock': (BuildContext context, String column, dynamic value) {
        return DropdownButtonFormField<bool?>(
          decoration: const InputDecoration(
            labelText: 'In Stock',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          value: value as bool?,
          items: const [
            DropdownMenuItem<bool?>(value: null, child: Text('All')),
            DropdownMenuItem<bool?>(value: true, child: Text('In Stock')),
            DropdownMenuItem<bool?>(value: false, child: Text('Out of Stock')),
          ],
          onChanged: (newValue) {
            ref.read(tableProvider.notifier).setFilter(column, newValue);
          },
        );
      },
      'price': (BuildContext context, String column, dynamic value) {
        // Price range slider
        final currentRange =
            value is RangeValues ? value : const RangeValues(0, 150);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Price: \$${currentRange.start.toStringAsFixed(0)} - \$${currentRange.end.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            RangeSlider(
              values: currentRange,
              min: 0,
              max: 150,
              divisions: 15,
              labels: RangeLabels(
                '\$${currentRange.start.toStringAsFixed(0)}',
                '\$${currentRange.end.toStringAsFixed(0)}',
              ),
              onChanged: (RangeValues newRange) {
                ref.read(tableProvider.notifier).setFilter(column, newRange);
              },
            ),
          ],
        );
      },
      'createdAt': (BuildContext context, String column, dynamic value) {
        // We'll just use a simple text field for date filtering
        // In a real app, you might want to use a date picker
        return TextFormField(
          decoration: const InputDecoration(
            labelText: 'Filter by Date (yyyy-MM-dd)',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          initialValue: value as String? ?? '',
          onChanged: (newValue) {
            ref.read(tableProvider.notifier).setFilter(column, newValue);
          },
        );
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Inventory'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: AdvancedDataTable(
        title: 'Products',
        columns: columns,
        data: data,
        filterBuilders: filterBuilders,
        rowBuilder:
            (context, item) => ProductRowBuilder(item: item, columns: columns),
      ),
    );
  }
}

class ProductRowBuilder extends StatelessWidget {
  final DataItem item;
  final List<String> columns;

  const ProductRowBuilder({
    super.key,
    required this.item,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          columns.map((column) {
            final value = item.data[column];

            // Format the cell value based on column type
            Widget cellContent;
            switch (column) {
              case 'price':
                cellContent = Text(
                  '\$${(value as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: value > 100 ? FontWeight.bold : null,
                    color: value > 100 ? Colors.green.shade700 : null,
                  ),
                );
                break;
              case 'inStock':
                cellContent = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (value as bool)
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      color:
                          value ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
                break;
              case 'stock':
                cellContent = Text(
                  value.toString(),
                  style: TextStyle(
                    color:
                        (value as int) < 5 && value > 0
                            ? Colors.orange.shade700
                            : (value <= 0 ? Colors.red.shade700 : null),
                    fontWeight: value < 5 ? FontWeight.bold : null,
                  ),
                );
                break;
              case 'createdAt':
                // Format the date
                cellContent = Text(
                  DateFormat('yyyy-MM-dd').format(value as DateTime),
                );
                break;
              default:
                cellContent = Text(value?.toString() ?? '');
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: cellContent,
              ),
            );
          }).toList(),
    );
  }
}
