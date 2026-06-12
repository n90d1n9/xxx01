import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

// Models
class Tenant {
  final String id;
  final String name;
  final String contactInfo;

  Tenant({required this.id, required this.name, required this.contactInfo});
}

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final String sku;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
  });
}

class PriceListItem {
  final String id;
  final String priceListId;
  final Product product;
  final double price;
  final double? discountPercentage;
  final bool isActive;

  PriceListItem({
    required this.id,
    required this.priceListId,
    required this.product,
    required this.price,
    this.discountPercentage,
    this.isActive = true,
  });

  double get effectivePrice => discountPercentage != null
      ? price * (1 - discountPercentage! / 100)
      : price;

  PriceListItem copyWith({
    String? id,
    String? priceListId,
    Product? product,
    double? price,
    double? discountPercentage,
    bool? isActive,
  }) {
    return PriceListItem(
      id: id ?? this.id,
      priceListId: priceListId ?? this.priceListId,
      product: product ?? this.product,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
    );
  }
}

class PriceList {
  final String id;
  final String name;
  final String description;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final Tenant tenant;
  final List<PriceListItem> items;

  PriceList({
    required this.id,
    required this.name,
    required this.description,
    required this.effectiveFrom,
    this.effectiveTo,
    this.isActive = true,
    required this.tenant,
    required this.items,
  });

  PriceList copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    bool? isActive,
    Tenant? tenant,
    List<PriceListItem>? items,
  }) {
    return PriceList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      isActive: isActive ?? this.isActive,
      tenant: tenant ?? this.tenant,
      items: items ?? this.items,
    );
  }
}

// Repositories
abstract class PriceListRepository {
  Future<List<PriceList>> getPriceLists();
  Future<PriceList> getPriceList(String id);
  Future<void> savePriceList(PriceList priceList);
  Future<void> deletePriceList(String id);
}

abstract class ProductRepository {
  Future<List<Product>> getProducts();
}

abstract class TenantRepository {
  Future<List<Tenant>> getTenants();
}

// Providers
final priceListRepositoryProvider = Provider<PriceListRepository>((ref) {
  throw UnimplementedError('Provide an implementation for PriceListRepository');
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  throw UnimplementedError('Provide an implementation for ProductRepository');
});

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  throw UnimplementedError('Provide an implementation for TenantRepository');
});

final priceListsProvider = FutureProvider<List<PriceList>>((ref) async {
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getPriceLists();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});

final tenantsProvider = FutureProvider<List<Tenant>>((ref) async {
  final repository = ref.watch(tenantRepositoryProvider);
  return repository.getTenants();
});

final selectedPriceListIdProvider = StateProvider<String?>((ref) => null);

final selectedPriceListProvider = FutureProvider<PriceList?>((ref) async {
  final id = ref.watch(selectedPriceListIdProvider);
  if (id == null) return null;
  final repository = ref.watch(priceListRepositoryProvider);
  return repository.getPriceList(id);
});

// Controllers/Notifiers
// Replace the PriceListNotifier class with this implementation
class PriceListNotifier extends StateNotifier<AsyncValue<PriceList?>> {
  final PriceListRepository repository;
  final Ref ref; // Changed from Reader to Ref

  PriceListNotifier(this.repository, this.ref)
    : super(const AsyncValue.loading());

  Future<void> loadPriceList(String id) async {
    state = const AsyncValue.loading();
    try {
      final priceList = await repository.getPriceList(id);
      state = AsyncValue.data(priceList);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> savePriceList(PriceList priceList) async {
    try {
      await repository.savePriceList(priceList);
      state = AsyncValue.data(priceList);
      // Refresh the list
      ref.invalidate(priceListsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void updatePriceListItem(PriceListItem updatedItem) {
    state.whenData((priceList) {
      if (priceList == null) return;

      final updatedItems = priceList.items
          .map((item) => item.id == updatedItem.id ? updatedItem : item)
          .toList();

      state = AsyncValue.data(priceList.copyWith(items: updatedItems));
    });
  }

  void addPriceListItem(PriceListItem newItem) {
    state.whenData((priceList) {
      if (priceList == null) return;

      final updatedItems = [...priceList.items, newItem];
      state = AsyncValue.data(priceList.copyWith(items: updatedItems));
    });
  }

  void removePriceListItem(String itemId) {
    state.whenData((priceList) {
      if (priceList == null) return;

      final updatedItems = priceList.items
          .where((item) => item.id != itemId)
          .toList();
      state = AsyncValue.data(priceList.copyWith(items: updatedItems));
    });
  }
}

// Replace the priceListNotifierProvider with this
final priceListNotifierProvider =
    StateNotifierProvider<PriceListNotifier, AsyncValue<PriceList?>>((ref) {
      final repository = ref.watch(priceListRepositoryProvider);
      return PriceListNotifier(repository, ref); // Pass ref instead of ref.read
    });

/* final priceListNotifierProvider =
    StateNotifierProvider<PriceListNotifier, AsyncValue<PriceList?>>((ref) {
      final repository = ref.watch(priceListRepositoryProvider);
      return PriceListNotifier(repository, ref.read);
    });
 */
// UI
class PriceListManagementScreen extends ConsumerWidget {
  const PriceListManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceListsAsync = ref.watch(priceListsProvider);
    final selectedPriceListId = ref.watch(selectedPriceListIdProvider);
    final selectedPriceListAsync = ref.watch(selectedPriceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price List Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreatePriceListDialog(context, ref);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Price List selection
          SizedBox(
            width: 300,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Price Lists',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: priceListsAsync.when(
                      data: (priceLists) => ListView.builder(
                        itemCount: priceLists.length,
                        itemBuilder: (context, index) {
                          final priceList = priceLists[index];
                          return ListTile(
                            title: Text(priceList.name),
                            subtitle: Text(
                              '${DateFormat('MMM d, yyyy').format(priceList.effectiveFrom)} - ${priceList.effectiveTo != null ? DateFormat('MMM d, yyyy').format(priceList.effectiveTo!) : 'Ongoing'}',
                            ),
                            selected: selectedPriceListId == priceList.id,
                            onTap: () {
                              ref
                                  .read(selectedPriceListIdProvider.notifier)
                                  .state = priceList
                                  .id;
                            },
                            leading: Icon(
                              Icons.list_alt,
                              color: priceList.isActive
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Text('Duplicate'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showEditPriceListDialog(
                                      context,
                                      ref,
                                      priceList,
                                    );
                                    break;
                                  case 'duplicate':
                                    _duplicatePriceList(ref, priceList);
                                    break;
                                  case 'delete':
                                    _confirmDeletePriceList(
                                      context,
                                      ref,
                                      priceList.id,
                                    );
                                    break;
                                }
                              },
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) =>
                          Center(child: Text('Error: $error')),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content area - Price List Items
          Expanded(
            child: selectedPriceListAsync.when(
              data: (priceList) {
                if (priceList == null) {
                  return const Center(
                    child: Text('Select a price list to view details'),
                  );
                }

                return _buildPriceListDetails(context, ref, priceList);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceListDetails(
    BuildContext context,
    WidgetRef ref,
    PriceList priceList,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceList.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceList.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Tenant: ${priceList.tenant.name}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Valid: ${DateFormat('MMM d, yyyy').format(priceList.effectiveFrom)} - ${priceList.effectiveTo != null ? DateFormat('MMM d, yyyy').format(priceList.effectiveTo!) : 'Ongoing'}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 16),
                        Chip(
                          label: Text(
                            priceList.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: priceList.isActive
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          backgroundColor: priceList.isActive
                              ? Colors.green
                              : Colors.grey[300],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
                onPressed: () {
                  _showAddProductDialog(context, ref, priceList);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Search and filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    // TODO: Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                hint: const Text('Filter by Category'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Categories')),
                  // TODO: Dynamically populate from available categories
                ],
                onChanged: (value) {
                  // TODO: Implement filter functionality
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                hint: const Text('Sort by'),
                items: const [
                  DropdownMenuItem(
                    value: 'name_asc',
                    child: Text('Name (A-Z)'),
                  ),
                  DropdownMenuItem(
                    value: 'name_desc',
                    child: Text('Name (Z-A)'),
                  ),
                  DropdownMenuItem(
                    value: 'price_asc',
                    child: Text('Price (Low to High)'),
                  ),
                  DropdownMenuItem(
                    value: 'price_desc',
                    child: Text('Price (High to Low)'),
                  ),
                ],
                onChanged: (value) {
                  // TODO: Implement sort functionality
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price list items table
          Expanded(
            child: Card(
              elevation: 2,
              child: priceList.items.isEmpty
                  ? const Center(
                      child: Text(
                        'No products in this price list. Click "Add Product" to add some.',
                      ),
                    )
                  : _buildItemsTable(context, ref, priceList),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.file_download),
                label: const Text('Export'),
                onPressed: () {
                  // TODO: Implement export functionality
                },
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                onPressed: () {
                  final notifier = ref.read(priceListNotifierProvider.notifier);
                  notifier.savePriceList(priceList);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price list saved successfully'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(
    BuildContext context,
    WidgetRef ref,
    PriceList priceList,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Base Price')),
            DataColumn(label: Text('Discount %')),
            DataColumn(label: Text('Final Price')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: priceList.items.map((item) {
            NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');

            return DataRow(
              cells: [
                DataCell(Text(item.product.sku)),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        item.product.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(item.product.category)),
                DataCell(Text(currencyFormat.format(item.price))),
                DataCell(
                  item.discountPercentage != null
                      ? Text('${item.discountPercentage!.toStringAsFixed(1)}%')
                      : const Text('-'),
                ),
                DataCell(
                  Text(
                    currencyFormat.format(item.effectivePrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Switch(
                    value: item.isActive,
                    onChanged: (value) {
                      final notifier = ref.read(
                        priceListNotifierProvider.notifier,
                      );
                      notifier.updatePriceListItem(
                        item.copyWith(isActive: value),
                      );
                    },
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          _showEditItemDialog(context, ref, priceList, item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          _confirmDeleteItem(context, ref, item.id);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCreatePriceListDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement the creation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Price List'),
        content: const Text('Price list creation form goes here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Create price list
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditPriceListDialog(
    BuildContext context,
    WidgetRef ref,
    PriceList priceList,
  ) {
    // TODO: Implement the edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Price List'),
        content: const Text('Price list edit form goes here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update price list
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _duplicatePriceList(WidgetRef ref, PriceList priceList) {
    // TODO: Implement the duplication
  }

  void _confirmDeletePriceList(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Price List'),
        content: const Text(
          'Are you sure you want to delete this price list? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete price list
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(
    BuildContext context,
    WidgetRef ref,
    PriceList priceList,
  ) {
    // TODO: Implement the add product dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product to Price List'),
        content: const Text('Product selection and pricing form goes here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Add product to price list
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    WidgetRef ref,
    PriceList priceList,
    PriceListItem item,
  ) {
    // TODO: Implement the edit item dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Price List Item'),
        content: const Text('Item pricing form goes here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Update price list item
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, WidgetRef ref, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Product'),
        content: const Text(
          'Are you sure you want to remove this product from the price list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final notifier = ref.read(priceListNotifierProvider.notifier);
              notifier.removePriceListItem(itemId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(
    const ProviderScope(child: MaterialApp(home: PriceListManagementScreen())),
  );
}
