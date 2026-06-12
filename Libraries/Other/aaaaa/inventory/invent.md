// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InventoryPage(),
    );
  }
}

// models/product.dart
class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    this.description = '',
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}

// models/warehouse.dart
class Warehouse {
  final String id;
  final String name;
  final String location;
  final String description;

  final num? capacity;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    this.description = '',
    this.capacity,
  });
}

// models/inventory_item.dart
class InventoryItem {
  final String id;
  final String productId;
  final String warehouseId;
  final int currentQuantity;
  final int reorderPoint;
  final int reorderQuantity;

  InventoryItem({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.currentQuantity,
    required this.reorderPoint,
    required this.reorderQuantity,
  });

  InventoryItem copyWith({
    String? id,
    String? productId,
    String? warehouseId,
    int? currentQuantity,
    int? reorderPoint,
    int? reorderQuantity,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
    );
  }

  bool get needsReorder => currentQuantity <= reorderPoint;
}

// models/inventory_movement.dart
enum MovementType { purchase, sale, transfer, adjustment, stockOpname }

class InventoryMovement {
  final String id;
  final String productId;
  final String sourceWarehouseId;
  final String? destinationWarehouseId;
  final int quantity;
  final MovementType type;
  final DateTime date;
  final String reference;
  final String notes;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.sourceWarehouseId,
    this.destinationWarehouseId,
    required this.quantity,
    required this.type,
    required this.date,
    required this.reference,
    this.notes = '',
  });
}

// models/stock_opname.dart
class StockOpname {
  final String id;
  final String warehouseId;
  final DateTime date;
  final String conductedBy;
  final StockOpnameStatus status;
  final List<StockOpnameItem> items;

  StockOpname({
    required this.id,
    required this.warehouseId,
    required this.date,
    required this.conductedBy,
    required this.status,
    required this.items,
  });
}

enum StockOpnameStatus { draft, inProgress, completed, cancelled }

class StockOpnameItem {
  final String id;
  final String productId;
  final int systemQuantity;
  final int actualQuantity;
  final String notes;

  StockOpnameItem({
    required this.id,
    required this.productId,
    required this.systemQuantity,
    required this.actualQuantity,
    this.notes = '',
  });

  int get discrepancy => actualQuantity - systemQuantity;
}

// providers/providers.dart

// Products
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) {
    return ProductsNotifier();
  },
);

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier()
    : super([
        Product(
          id: '1',
          name: 'Laptop',
          sku: 'LT-001',
          category: 'Electronics',
          price: 1200,
        ),
        Product(
          id: '2',
          name: 'Smartphone',
          sku: 'SP-001',
          category: 'Electronics',
          price: 800,
        ),
        Product(
          id: '3',
          name: 'Desk Chair',
          sku: 'DC-001',
          category: 'Furniture',
          price: 150,
        ),
      ]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void updateProduct(Product product) {
    state = state.map((p) => p.id == product.id ? product : p).toList();
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

// Warehouses
final warehousesProvider =
    StateNotifierProvider<WarehousesNotifier, List<Warehouse>>((ref) {
      return WarehousesNotifier();
    });

class WarehousesNotifier extends StateNotifier<List<Warehouse>> {
  WarehousesNotifier()
    : super([
        Warehouse(id: '1', name: 'Main Warehouse', location: 'Jakarta'),
        Warehouse(id: '2', name: 'North Warehouse', location: 'Surabaya'),
        Warehouse(id: '3', name: 'South Warehouse', location: 'Bandung'),
      ]);

  void addWarehouse(Warehouse warehouse) {
    state = [...state, warehouse];
  }

  void updateWarehouse(Warehouse warehouse) {
    state = state.map((w) => w.id == warehouse.id ? warehouse : w).toList();
  }

  void deleteWarehouse(String id) {
    state = state.where((w) => w.id != id).toList();
  }
}

// Inventory Items
final inventoryItemsProvider =
    StateNotifierProvider<InventoryItemsNotifier, List<InventoryItem>>((ref) {
      return InventoryItemsNotifier();
    });

class InventoryItemsNotifier extends StateNotifier<List<InventoryItem>> {
  InventoryItemsNotifier()
    : super([
        InventoryItem(
          id: '1',
          productId: '1',
          warehouseId: '1',
          currentQuantity: 15,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: '2',
          productId: '1',
          warehouseId: '2',
          currentQuantity: 8,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
        InventoryItem(
          id: '3',
          productId: '2',
          warehouseId: '1',
          currentQuantity: 20,
          reorderPoint: 10,
          reorderQuantity: 15,
        ),
        InventoryItem(
          id: '4',
          productId: '3',
          warehouseId: '1',
          currentQuantity: 4,
          reorderPoint: 5,
          reorderQuantity: 10,
        ),
      ]);

  void addInventoryItem(InventoryItem item) {
    state = [...state, item];
  }

  void updateInventoryItem(InventoryItem item) {
    state = state.map((i) => i.id == item.id ? item : i).toList();
  }

  void deleteInventoryItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateQuantity(String id, int newQuantity) {
    state =
        state
            .map(
              (i) => i.id == id ? i.copyWith(currentQuantity: newQuantity) : i,
            )
            .toList();
  }
}

// Inventory Movements
final inventoryMovementsProvider =
    StateNotifierProvider<InventoryMovementsNotifier, List<InventoryMovement>>((
      ref,
    ) {
      return InventoryMovementsNotifier();
    });

class InventoryMovementsNotifier
    extends StateNotifier<List<InventoryMovement>> {
  InventoryMovementsNotifier()
    : super([
        InventoryMovement(
          id: '1',
          productId: '1',
          sourceWarehouseId: '1',
          quantity: 5,
          type: MovementType.sale,
          date: DateTime.now().subtract(const Duration(days: 5)),
          reference: 'SO-001',
        ),
        InventoryMovement(
          id: '2',
          productId: '2',
          sourceWarehouseId: '1',
          quantity: 10,
          type: MovementType.purchase,
          date: DateTime.now().subtract(const Duration(days: 10)),
          reference: 'PO-001',
        ),
      ]);

  void addMovement(InventoryMovement movement) {
    state = [...state, movement];
  }
}

// Stock Opname
final stockOpnameProvider =
    StateNotifierProvider<StockOpnameNotifier, List<StockOpname>>((ref) {
      return StockOpnameNotifier();
    });

class StockOpnameNotifier extends StateNotifier<List<StockOpname>> {
  StockOpnameNotifier()
    : super([
        StockOpname(
          id: '1',
          warehouseId: '1',
          date: DateTime.now().subtract(const Duration(days: 30)),
          conductedBy: 'John Doe',
          status: StockOpnameStatus.completed,
          items: [
            StockOpnameItem(
              id: '1',
              productId: '1',
              systemQuantity: 20,
              actualQuantity: 18,
            ),
            StockOpnameItem(
              id: '2',
              productId: '2',
              systemQuantity: 15,
              actualQuantity: 15,
            ),
          ],
        ),
      ]);

  void addStockOpname(StockOpname stockOpname) {
    state = [...state, stockOpname];
  }

  void updateStockOpname(StockOpname stockOpname) {
    state = state.map((s) => s.id == stockOpname.id ? stockOpname : s).toList();
  }
}

// Low Stock Items Provider (for Automatic Reorder Point alerts)
final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventoryItems = ref.watch(inventoryItemsProvider);
  return inventoryItems.where((item) => item.needsReorder).toList();
});

// inventory_page.dart

class InventoryPage extends ConsumerWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(warehousesProvider);
    final products = ref.watch(productsProvider);
    final selectedWarehouse = warehouses.isNotEmpty ? warehouses[0] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              final lowStockItems = ref.read(lowStockItemsProvider);
              _showLowStockDialog(context, lowStockItems, products);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add inventory item dialog
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Row(
        children: [
          // Side panel for warehouse selection (for large screens)
          SizedBox(
            width: 250,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Warehouses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: warehouses.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(warehouses[index].name),
                          subtitle: Text(warehouses[index].location),
                          selected:
                              selectedWarehouse?.id == warehouses[index].id,
                          onTap: () {
                            // Select warehouse logic
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content area with inventory table
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inventory for ${selectedWarehouse?.name ?? "All Warehouses"}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.assessment),
                            label: const Text('Stock Opname'),
                            onPressed: () {
                              // Navigate to stock opname screen
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.sync),
                            label: const Text('Movements'),
                            onPressed: () {
                              // Navigate to inventory movements screen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildInventoryTable(context, ref, selectedWarehouse),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Inventory Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to products page
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('Warehouses'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to warehouses page
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Stock Opname'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to stock opname page
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to inventory movements page
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Low Stock Alerts'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to low stock alerts page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable(
    BuildContext context,
    WidgetRef ref,
    Warehouse? selectedWarehouse,
  ) {
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final products = ref.watch(productsProvider);
    final warehouses = ref.watch(warehousesProvider);

    // Filter inventory items by warehouse if one is selected
    final filteredItems =
        selectedWarehouse != null
            ? inventoryItems
                .where((item) => item.warehouseId == selectedWarehouse.id)
                .toList()
            : inventoryItems;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('SKU')),
            DataColumn(label: Text('Warehouse')),
            DataColumn(label: Text('Quantity'), numeric: true),
            DataColumn(label: Text('Reorder Point'), numeric: true),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              filteredItems.map((item) {
                final product = products.firstWhere(
                  (p) => p.id == item.productId,
                  orElse:
                      () => Product(
                        id: '',
                        name: 'Unknown',
                        sku: '',
                        category: '',
                        price: 0,
                      ),
                );

                final warehouse = warehouses.firstWhere(
                  (w) => w.id == item.warehouseId,
                  orElse:
                      () => Warehouse(id: '', name: 'Unknown', location: ''),
                );

                return DataRow(
                  cells: [
                    DataCell(Text(product.name)),
                    DataCell(Text(product.sku)),
                    DataCell(Text(warehouse.name)),
                    DataCell(Text(item.currentQuantity.toString())),
                    DataCell(Text(item.reorderPoint.toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              item.needsReorder
                                  ? Colors.red[100]
                                  : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.needsReorder ? 'Low Stock' : 'In Stock',
                          style: TextStyle(
                            color:
                                item.needsReorder
                                    ? Colors.red[900]
                                    : Colors.green[900],
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Increase Stock',
                            onPressed: () {
                              _showAdjustStockDialog(
                                context,
                                ref,
                                item,
                                product,
                                warehouse,
                                true,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            tooltip: 'Decrease Stock',
                            onPressed: () {
                              _showAdjustStockDialog(
                                context,
                                ref,
                                item,
                                product,
                                warehouse,
                                false,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: 'Transfer Stock',
                            onPressed: () {
                              _showTransferStockDialog(
                                context,
                                ref,
                                item,
                                product,
                                warehouse,
                                warehouses,
                              );
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

  void _showLowStockDialog(
    BuildContext context,
    List<InventoryItem> lowStockItems,
    List<Product> products,
  ) {
    if (lowStockItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No low stock items at the moment')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Low Stock Alert'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: lowStockItems.length,
              itemBuilder: (context, index) {
                final item = lowStockItems[index];
                final product = products.firstWhere(
                  (p) => p.id == item.productId,
                  orElse:
                      () => Product(
                        id: '',
                        name: 'Unknown',
                        sku: '',
                        category: '',
                        price: 0,
                      ),
                );

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Current quantity: ${item.currentQuantity}'),
                  trailing: Text(
                    'Reorder Point: ${item.reorderPoint}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAdjustStockDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
    Product product,
    Warehouse warehouse,
    bool isIncrease,
  ) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${isIncrease ? 'Increase' : 'Decrease'} Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${product.name}'),
              Text('Current Quantity: ${item.currentQuantity}'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity to adjust',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for adjustment',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final adjustmentQuantity =
                    int.tryParse(quantityController.text) ?? 0;
                if (adjustmentQuantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                    ),
                  );
                  return;
                }

                // Update inventory quantity
                final newQuantity =
                    isIncrease
                        ? item.currentQuantity + adjustmentQuantity
                        : item.currentQuantity - adjustmentQuantity;

                if (!isIncrease && newQuantity < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot reduce stock below zero'),
                    ),
                  );
                  return;
                }

                // Update inventory item
                ref
                    .read(inventoryItemsNotifier.notifier)
                    .updateQuantity(item.id, newQuantity);

                // Add movement record
                final movementType =
                    isIncrease
                        ? MovementType.adjustment
                        : MovementType.adjustment;
                final movement = InventoryMovement(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productId: product.id,
                  sourceWarehouseId: warehouse.id,
                  quantity: adjustmentQuantity,
                  type: movementType,
                  date: DateTime.now(),
                  reference: 'ADJ-${DateTime.now().millisecondsSinceEpoch}',
                  notes: reasonController.text,
                );

                ref
                    .read(inventoryMovementsProvider.notifier)
                    .addMovement(movement);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Stock ${isIncrease ? 'increased' : 'decreased'} successfully',
                    ),
                  ),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferStockDialog(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
    Product product,
    Warehouse sourceWarehouse,
    List<Warehouse> warehouses,
  ) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    String? destinationWarehouseId;

    // Filter out the source warehouse
    final destinationWarehouses =
        warehouses.where((w) => w.id != sourceWarehouse.id).toList();

    if (destinationWarehouses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No other warehouses available for transfer'),
        ),
      );
      return;
    }

    destinationWarehouseId = destinationWarehouses.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Transfer Stock'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product: ${product.name}'),
                  Text('Source Warehouse: ${sourceWarehouse.name}'),
                  Text('Available Quantity: ${item.currentQuantity}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Destination Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: destinationWarehouseId,
                    items:
                        destinationWarehouses.map((warehouse) {
                          return DropdownMenuItem<String>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          destinationWarehouseId = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity to transfer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final transferQuantity =
                        int.tryParse(quantityController.text) ?? 0;
                    if (transferQuantity <= 0 ||
                        transferQuantity > item.currentQuantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid quantity'),
                        ),
                      );
                      return;
                    }

                    if (destinationWarehouseId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a destination warehouse',
                          ),
                        ),
                      );
                      return;
                    }

                    // Update source inventory item
                    final newSourceQuantity =
                        item.currentQuantity - transferQuantity;
                    ref
                        .read(inventoryItemsNotifier.notifier)
                        .updateQuantity(item.id, newSourceQuantity);

                    // Find or create destination inventory item
                    final inventoryItems = ref.read(inventoryItemsProvider);
                    final destinationItemOpt =
                        inventoryItems
                            .where(
                              (i) =>
                                  i.productId == product.id &&
                                  i.warehouseId == destinationWarehouseId,
                            )
                            .toList();

                    if (destinationItemOpt.isNotEmpty) {
                      // Update existing destination item
                      final destinationItem = destinationItemOpt.first;
                      final newDestQuantity =
                          destinationItem.currentQuantity + transferQuantity;
                      ref
                          .read(inventoryItemsNotifier.notifier)
                          .updateQuantity(destinationItem.id, newDestQuantity);
                    } else {
                      // Create new destination item
                      final newDestinationItem = InventoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        productId: product.id,
                        warehouseId: destinationWarehouseId!,
                        currentQuantity: transferQuantity,
                        reorderPoint: item.reorderPoint,
                        reorderQuantity: item.reorderQuantity,
                      );
                      ref
                          .read(inventoryItemsNotifier.notifier)
                          .addInventoryItem(newDestinationItem);
                    }

                    // Add movement record
                    // Add movement record
                    final movement = InventoryMovement(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      productId: product.id,
                      sourceWarehouseId: sourceWarehouse.id,
                      destinationWarehouseId: destinationWarehouseId,
                      quantity: transferQuantity,
                      type: MovementType.transfer,
                      date: DateTime.now(),
                      reference: 'TRF-${DateTime.now().millisecondsSinceEpoch}',
                      notes: notesController.text,
                    );

                    ref
                        .read(inventoryMovementsProvider.notifier)
                        .addMovement(movement);

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stock transferred successfully'),
                      ),
                    );
                  },
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// stock_opname_page.dart

class StockOpnamePage extends ConsumerStatefulWidget {
  const StockOpnamePage({Key? key}) : super(key: key);

  @override
  _StockOpnamePageState createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends ConsumerState<StockOpnamePage> {
  late String selectedWarehouseId;
  late List<StockOpnameItem> stockOpnameItems;
  final TextEditingController conductedByController = TextEditingController();
  StockOpnameStatus currentStatus = StockOpnameStatus.draft;

  @override
  void initState() {
    super.initState();
    WidgetBinding.instance.addPostFrameCallback((_) {
      final warehouses = ref.read(warehousesProvider);
      if (warehouses.isNotEmpty) {
        selectedWarehouseId = warehouses[0].id;
        _initializeStockOpnameItems();
      }
    });
  }

  void _initializeStockOpnameItems() {
    final inventoryItems = ref.read(inventoryItemsProvider);
    final warehouseItems =
        inventoryItems
            .where((item) => item.warehouseId == selectedWarehouseId)
            .toList();

    setState(() {
      stockOpnameItems =
          warehouseItems.map((item) {
            return StockOpnameItem(
              id: DateTime.now().millisecondsSinceEpoch.toString() + item.id,
              productId: item.productId,
              systemQuantity: item.currentQuantity,
              actualQuantity:
                  item.currentQuantity, // Default to system quantity
            );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = ref.watch(warehousesProvider);
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Opname')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Opname',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _saveStockOpname,
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _completeStockOpname,
                      child: const Text('Complete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: warehouses.isNotEmpty ? selectedWarehouseId : null,
                    items:
                        warehouses.map((warehouse) {
                          return DropdownMenuItem<String>(
                            value: warehouse.id,
                            child: Text(warehouse.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedWarehouseId = value;
                          _initializeStockOpnameItems();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: conductedByController,
                    decoration: const InputDecoration(
                      labelText: 'Conducted By',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('System Qty'), numeric: true),
                      DataColumn(label: Text('Actual Qty'), numeric: true),
                      DataColumn(label: Text('Discrepancy'), numeric: true),
                      DataColumn(label: Text('Notes')),
                    ],
                    rows:
                        stockOpnameItems.map((item) {
                          final product = products.firstWhere(
                            (p) => p.id == item.productId,
                            orElse:
                                () => Product(
                                  id: '',
                                  name: 'Unknown',
                                  sku: '',
                                  category: '',
                                  price: 0,
                                ),
                          );

                          return DataRow(
                            cells: [
                              DataCell(Text(product.name)),
                              DataCell(Text(product.sku)),
                              DataCell(Text(item.systemQuantity.toString())),
                              DataCell(
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  controller: TextEditingController(
                                    text: item.actualQuantity.toString(),
                                  ),
                                  onChanged: (value) {
                                    final actualQty = int.tryParse(value) ?? 0;
                                    setState(() {
                                      final index = stockOpnameItems.indexWhere(
                                        (i) => i.id == item.id,
                                      );
                                      if (index != -1) {
                                        stockOpnameItems[index] =
                                            StockOpnameItem(
                                              id: item.id,
                                              productId: item.productId,
                                              systemQuantity:
                                                  item.systemQuantity,
                                              actualQuantity: actualQty,
                                              notes: item.notes,
                                            );
                                      }
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                Text(
                                  item.discrepancy.toString(),
                                  style: TextStyle(
                                    color:
                                        item.discrepancy < 0
                                            ? Colors.red
                                            : (item.discrepancy > 0
                                                ? Colors.green
                                                : Colors.black),
                                    fontWeight:
                                        item.discrepancy != 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                              DataCell(
                                TextField(
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    hintText: 'Enter notes',
                                  ),
                                  controller: TextEditingController(
                                    text: item.notes,
                                  ),
                                  onChanged: (value) {
                                    final index = stockOpnameItems.indexWhere(
                                      (i) => i.id == item.id,
                                    );
                                    if (index != -1) {
                                      setState(() {
                                        stockOpnameItems[index] =
                                            stockOpnameItems[index].copyWith(
                                              notes: value,
                                            );
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveStockOpname() {
    if (conductedByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter who conducted the stock opname'),
        ),
      );
      return;
    }

    final stockOpname = StockOpname(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      warehouseId: selectedWarehouseId,
      date: DateTime.now(),
      conductedBy: conductedByController.text,
      status: StockOpnameStatus.draft,
      items: stockOpnameItems,
    );

    ref.read(stockOpnameProvider.notifier).addStockOpname(stockOpname);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock opname saved as draft')),
    );
  }

  void _completeStockOpname() {
    if (conductedByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter who conducted the stock opname'),
        ),
      );
      return;
    }

    // Create stock opname record
    final stockOpname = StockOpname(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      warehouseId: selectedWarehouseId,
      date: DateTime.now(),
      conductedBy: conductedByController.text,
      status: StockOpnameStatus.completed,
      items: stockOpnameItems,
    );

    ref.read(stockOpnameProvider.notifier).addStockOpname(stockOpname);

    // Update inventory quantities based on actual counts
    final inventoryItemsNotifier = ref.read(inventoryItemsNotifier.notifier);
    final inventoryItems = ref.read(inventoryItemsProvider);
    final inventoryMovementsNotifier = ref.read(
      inventoryMovementsNotifier.notifier,
    );

    for (final opnameItem in stockOpnameItems) {
      final inventoryItem = inventoryItems.firstWhere(
        (item) =>
            item.productId == opnameItem.productId &&
            item.warehouseId == selectedWarehouseId,
        orElse: () => null,
      );

      if (inventoryItem != null &&
          opnameItem.systemQuantity != opnameItem.actualQuantity) {
        // Update inventory quantity
        inventoryItemsNotifier.updateQuantity(
          inventoryItem.id,
          opnameItem.actualQuantity,
        );

        // Create movement record for adjustment
        final movement = InventoryMovement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: opnameItem.productId,
          sourceWarehouseId: selectedWarehouseId,
          quantity: opnameItem.discrepancy.abs(),
          type: MovementType.stockOpname,
          date: DateTime.now(),
          reference: 'SO-${stockOpname.id}',
          notes:
              'Stock opname adjustment: ${opnameItem.discrepancy > 0 ? 'Added' : 'Removed'} ${opnameItem.discrepancy.abs()} units',
        );

        inventoryMovementsNotifier.addMovement(movement);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stock opname completed and inventory updated'),
      ),
    );

    Navigator.of(context).pop();
  }
}

// inventory_movements_page.dart

class InventoryMovementsPage extends ConsumerWidget {
  const InventoryMovementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(inventoryMovementsProvider);
    final products = ref.watch(productsProvider);
    final warehouses = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Movements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Movements',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Source')),
                      DataColumn(label: Text('Destination')),
                      DataColumn(label: Text('Quantity'), numeric: true),
                      DataColumn(label: Text('Reference')),
                      DataColumn(label: Text('Notes')),
                    ],
                    rows:
                        movements.map((movement) {
                          final product = products.firstWhere(
                            (p) => p.id == movement.productId,
                            orElse:
                                () => Product(
                                  id: '',
                                  name: 'Unknown',
                                  sku: '',
                                  category: '',
                                  price: 0,
                                ),
                          );

                          final sourceWarehouse = warehouses.firstWhere(
                            (w) => w.id == movement.sourceWarehouseId,
                            orElse:
                                () => Warehouse(
                                  id: '',
                                  name: 'Unknown',
                                  location: '',
                                ),
                          );

                          final destinationWarehouse =
                              movement.destinationWarehouseId != null
                                  ? warehouses.firstWhere(
                                    (w) =>
                                        w.id == movement.destinationWarehouseId,
                                    orElse:
                                        () => Warehouse(
                                          id: '',
                                          name: 'N/A',
                                          location: '',
                                        ),
                                  )
                                  : null;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(movement.date),
                                ),
                              ),
                              DataCell(Text(product.name)),
                              DataCell(
                                Text(_getMovementTypeText(movement.type)),
                              ),
                              DataCell(Text(sourceWarehouse.name)),
                              DataCell(
                                Text(destinationWarehouse?.name ?? 'N/A'),
                              ),
                              DataCell(Text(movement.quantity.toString())),
                              DataCell(Text(movement.reference)),
                              DataCell(Text(movement.notes)),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMovementTypeText(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return 'Purchase';
      case MovementType.sale:
        return 'Sale';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.stockOpname:
        return 'Stock Opname';
      default:
        return 'Unknown';
    }
  }
}

// product_page.dart

class ProductPage extends ConsumerWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditProductDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Price'), numeric: true),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        products.map((product) {
                          return DataRow(
                            cells: [
                              DataCell(Text(product.name)),
                              DataCell(Text(product.sku)),
                              DataCell(Text(product.category)),
                              DataCell(
                                Text('\$${product.price.toStringAsFixed(2)}'),
                              ),
                              DataCell(Text(product.description)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _showAddEditProductDialog(
                                            context,
                                            ref,
                                            product,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => _showDeleteConfirmation(
                                            context,
                                            ref,
                                            product,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditProductDialog(
    BuildContext context,
    WidgetRef ref, [
    Product? product,
  ]) {
    final isEditing = product != null;

    final nameController = TextEditingController(text: product?.name ?? '');
    final skuController = TextEditingController(text: product?.sku ?? '');
    final categoryController = TextEditingController(
      text: product?.category ?? '',
    );
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final sku = skuController.text.trim();
                final category = categoryController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                final description = descriptionController.text.trim();

                if (name.isEmpty ||
                    sku.isEmpty ||
                    category.isEmpty ||
                    price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  final updatedProduct = product!.copyWith(
                    name: name,
                    sku: sku,
                    category: category,
                    price: price,
                    description: description,
                  );
                  ref
                      .read(productsProvider.notifier)
                      .updateProduct(updatedProduct);
                } else {
                  final newProduct = Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    sku: sku,
                    category: category,
                    price: price,
                    description: description,
                  );
                  ref.read(productsProvider.notifier).addProduct(newProduct);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete ${product.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(productsProvider.notifier).deleteProduct(product.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// warehouse_page.dart

class WarehousePage extends ConsumerWidget {
  const WarehousePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouses = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditWarehouseDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warehouses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows:
                        warehouses.map((warehouse) {
                          return DataRow(
                            cells: [
                              DataCell(Text(warehouse.name)),
                              DataCell(Text(warehouse.location)),
                              DataCell(Text(warehouse.description)),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () => _showAddEditWarehouseDialog(
                                            context,
                                            ref,
                                            warehouse,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed:
                                          () => _showDeleteConfirmation(
                                            context,
                                            ref,
                                            warehouse,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditWarehouseDialog(
    BuildContext context,
    WidgetRef ref, [
    Warehouse? warehouse,
  ]) {
    final isEditing = warehouse != null;

    final nameController = TextEditingController(text: warehouse?.name ?? '');
    final locationController = TextEditingController(
      text: warehouse?.location ?? '',
    );
    final descriptionController = TextEditingController(
      text: warehouse?.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Warehouse' : 'Add Warehouse'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final location = locationController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || location.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  final updatedWarehouse = Warehouse(
                    id: warehouse!.id,
                    name: name,
                    location: location,
                    description: description,
                  );
                  ref
                      .read(warehousesProvider.notifier)
                      .updateWarehouse(updatedWarehouse);
                } else {
                  final newWarehouse = Warehouse(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    location: location,
                    description: description,
                  );
                  ref
                      .read(warehousesProvider.notifier)
                      .addWarehouse(newWarehouse);
                }

                Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Warehouse warehouse,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Warehouse'),
          content: Text('Are you sure you want to delete ${warehouse.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(warehousesProvider.notifier)
                    .deleteWarehouse(warehouse.id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// low_stock_page.dart

class LowStockPage extends ConsumerWidget {
  const LowStockPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final products = ref.watch(productsProvider);
    final warehouses = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Low Stock Alerts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Low Stock Alerts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${lowStockItems.length} items below reorder point',
                  style: TextStyle(
                    color: lowStockItems.isEmpty ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  lowStockItems.isEmpty
                      ? const Center(
                        child: Text(
                          'No items below reorder point',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                      : Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Product')),
                              DataColumn(label: Text('SKU')),
                              DataColumn(label: Text('Warehouse')),
                              DataColumn(
                                label: Text('Current Qty'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Reorder Point'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Reorder Qty'),
                                numeric: true,
                              ),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows:
                                lowStockItems.map((item) {
                                  final product = products.firstWhere(
                                    (p) => p.id == item.productId,
                                    orElse:
                                        () => Product(
                                          id: '',
                                          name: 'Unknown',
                                          sku: '',
                                          category: '',
                                          price: 0,
                                        ),
                                  );

                                  final warehouse = warehouses.firstWhere(
                                    (w) => w.id == item.warehouseId,
                                    orElse:
                                        () => Warehouse(
                                          id: '',
                                          name: 'Unknown',
                                          location: '',
                                        ),
                                  );

                                  return DataRow(
                                    cells: [
                                      DataCell(Text(product.name)),
                                      DataCell(Text(product.sku)),
                                      DataCell(Text(warehouse.name)),
                                      DataCell(
                                        Text(
                                          item.currentQuantity.toString(),
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(item.reorderPoint.toString()),
                                      ),
                                      DataCell(
                                        Text(item.reorderQuantity.toString()),
                                      ),
                                      DataCell(
                                        ElevatedButton(
                                          onPressed:
                                              () => _createPurchaseOrder(
                                                context,
                                                ref,
                                                item,
                                                product,
                                                warehouse,
                                              ),
                                          child: const Text('Restock'),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _createPurchaseOrder(
    BuildContext context,
    WidgetRef ref,
    InventoryItem item,
    Product product,
    Warehouse warehouse,
  ) {
    final quantityController = TextEditingController(
      text: item.reorderQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Purchase Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${product.name}'),
              Text('Current Quantity: ${item.currentQuantity}'),
              Text('Warehouse: ${warehouse.name}'),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity to order',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final orderQuantity =
                    int.tryParse(quantityController.text) ?? 0;
                if (orderQuantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid quantity'),
                    ),
                  );
                  return;
                }

                // Add to inventory
                final newQuantity = item.currentQuantity + orderQuantity;
                ref
                    .read(inventoryItemsNotifier.notifier)
                    .updateQuantity(item.id, newQuantity);

                // Create movement record
                final movement = InventoryMovement(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productId: product.id,
                  sourceWarehouseId: warehouse.id,
                  quantity: orderQuantity,
                  type: MovementType.purchase,
                  date: DateTime.now(),
                  reference: 'PO-${DateTime.now().millisecondsSinceEpoch}',
                  notes: 'Restocked due to low inventory',
                );

                ref
                    .read(inventoryMovementsProvider.notifier)
                    .addMovement(movement);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} restocked successfully'),
                  ),
                );
              },
              child: const Text('Create PO'),
            ),
          ],
        );
      },
    );
  }
}

// Add a dashboard page to show key metrics
class DashboardPage extends ConsumerWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final warehouses = ref.watch(warehousesProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);

    // Calculate total inventory value
    double totalInventoryValue = 0;
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse:
            () => Product(id: '', name: '', sku: '', category: '', price: 0),
      );
      totalInventoryValue += product.price * item.currentQuantity;
    }

    // Get recent movements (last 5)
    final recentMovements = [...movements];
    recentMovements.sort((a, b) => b.date.compareTo(a.date));
    final last5Movements = recentMovements.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildInfoCard(
                  'Total Products',
                  products.length.toString(),
                  Icons.category,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Total Warehouses',
                  warehouses.length.toString(),
                  Icons.warehouse,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Low Stock Items',
                  lowStockItems.length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  'Inventory Value',
                  '\$${totalInventoryValue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Inventory Movements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Reference')),
                    ],
                    rows:
                        last5Movements.map((movement) {
                          final product = products.firstWhere(
                            (p) => p.id == movement.productId,
                            orElse:
                                () => Product(
                                  id: '',
                                  name: 'Unknown',
                                  sku: '',
                                  category: '',
                                  price: 0,
                                ),
                          );

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(movement.date),
                                ),
                              ),
                              DataCell(Text(product.name)),
                              DataCell(
                                Text(_getMovementTypeText(movement.type)),
                              ),
                              DataCell(Text(movement.quantity.toString())),
                              DataCell(Text(movement.reference)),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(icon, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMovementTypeText(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return 'Purchase';
      case MovementType.sale:
        return 'Sale';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.stockOpname:
        return 'Stock Opname';
      default:
        return 'Unknown';
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Inventory Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('Warehouses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WarehousePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Stock Opname'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StockOpnamePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryMovementsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Low Stock Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LowStockPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Extension for StockOpnameItem
extension StockOpnameItemExtension on StockOpnameItem {
  StockOpnameItem copyWith({
    String? id,
    String? productId,
    int? systemQuantity,
    int? actualQuantity,
    String? notes,
  }) {
    return StockOpnameItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      notes: notes ?? this.notes,
    );
  }
}

// Reports page to generate inventory reports
class ReportsPage extends ConsumerWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildReportCard(
                    context,
                    'Inventory Valuation',
                    'Get the current value of inventory by product and warehouse',
                    Icons.attach_money,
                    Colors.green,
                    () => _generateInventoryValuationReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Stock Movement History',
                    'Track inventory movements over time with detailed reports',
                    Icons.timeline,
                    Colors.blue,
                    () => _generateStockMovementReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Low Stock Report',
                    'View all products that are below reorder points',
                    Icons.warning,
                    Colors.orange,
                    () => _generateLowStockReport(context, ref),
                  ),
                  _buildReportCard(
                    context,
                    'Warehouse Capacity',
                    'Analyze warehouse usage and available space',
                    Icons.warehouse,
                    Colors.purple,
                    () => _generateWarehouseCapacityReport(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(description, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: const Text('Generate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateInventoryValuationReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final inventoryItems = ref.read(inventoryItemsProvider);
    final warehouses = ref.read(warehousesProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => InventoryValuationReportPage(
              products: products,
              inventoryItems: inventoryItems,
              warehouses: warehouses,
            ),
      ),
    );
  }

  void _generateStockMovementReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final movements = ref.read(inventoryMovementsProvider);
    final warehouses = ref.read(warehousesProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StockMovementReportPage(
              products: products,
              movements: movements,
              warehouses: warehouses,
            ),
      ),
    );
  }

  void _generateLowStockReport(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    final lowStockItems = ref.read(lowStockItemsProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LowStockReportPage(
              products: products,
              lowStockItems: lowStockItems,
            ),
      ),
    );
  }

  void _generateWarehouseCapacityReport(BuildContext context, WidgetRef ref) {
    final warehouses = ref.read(warehousesProvider);
    final inventoryItems = ref.read(inventoryItemsProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WarehouseCapacityReportPage(
              warehouses: warehouses,
              inventoryItems: inventoryItems,
            ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Inventory Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('Warehouses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WarehousePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryMovementsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Low Stock Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LowStockPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Inventory Valuation Report Page
class InventoryValuationReportPage extends StatelessWidget {
  final List<Product> products;
  final List<InventoryItem> inventoryItems;
  final List<Warehouse> warehouses;

  const InventoryValuationReportPage({
    Key? key,
    required this.products,
    required this.inventoryItems,
    required this.warehouses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate valuation data
    final valuationData = _calculateValuationData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Valuation Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToCsv(context),
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Valuation Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'As of ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('SKU')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Warehouse')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Unit Price')),
                        DataColumn(label: Text('Total Value')),
                      ],
                      rows:
                          valuationData.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['productName'] as String)),
                                DataCell(Text(item['sku'] as String)),
                                DataCell(Text(item['category'] as String)),
                                DataCell(Text(item['warehouseName'] as String)),
                                DataCell(Text(item['quantity'].toString())),
                                DataCell(
                                  Text(
                                    '\$${(item['unitPrice'] as double).toStringAsFixed(2)}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '\$${(item['totalValue'] as double).toStringAsFixed(2)}',
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Inventory Value: \$${_calculateTotalValue(valuationData).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Products: ${products.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total Warehouses: ${warehouses.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateValuationData() {
    final List<Map<String, dynamic>> result = [];

    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse:
            () => Product(
              id: '',
              name: 'Unknown',
              sku: '',
              category: '',
              price: 0,
            ),
      );

      final warehouse = warehouses.firstWhere(
        (w) => w.id == item.warehouseId,
        orElse:
            () => Warehouse(id: '', name: 'Unknown', location: '', capacity: 0),
      );

      final totalValue = product.price * item.currentQuantity;

      result.add({
        'productId': product.id,
        'productName': product.name,
        'sku': product.sku,
        'category': product.category,
        'warehouseId': warehouse.id,
        'warehouseName': warehouse.name,
        'quantity': item.currentQuantity,
        'unitPrice': product.price,
        'totalValue': totalValue,
      });
    }

    return result;
  }

  double _calculateTotalValue(List<Map<String, dynamic>> data) {
    double total = 0;
    for (final item in data) {
      total += item['totalValue'] as double;
    }
    return total;
  }

  void _exportToCsv(BuildContext context) {
    // This would be implemented with a CSV export package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export functionality would be implemented here'),
      ),
    );
  }
}

// Stock Movement Report Page
class StockMovementReportPage extends StatefulWidget {
  final List<Product> products;
  final List<InventoryMovement> movements;
  final List<Warehouse> warehouses;

  const StockMovementReportPage({
    Key? key,
    required this.products,
    required this.movements,
    required this.warehouses,
  }) : super(key: key);

  @override
  State<StockMovementReportPage> createState() =>
      _StockMovementReportPageState();
}

class _StockMovementReportPageState extends State<StockMovementReportPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedProductId;
  MovementType? _selectedMovementType;
  String? _selectedWarehouseId;

  @override
  Widget build(BuildContext context) {
    final filteredMovements = _getFilteredMovements();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToCsv(context),
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Movement Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFiltersSection(),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Warehouse')),
                        DataColumn(label: Text('Reference')),
                        DataColumn(label: Text('Value')),
                      ],
                      rows:
                          filteredMovements.map((movement) {
                            final product = widget.products.firstWhere(
                              (p) => p.id == movement.productId,
                              orElse:
                                  () => Product(
                                    id: '',
                                    name: 'Unknown',
                                    sku: '',
                                    category: '',
                                    price: 0,
                                  ),
                            );

                            final warehouse = widget.warehouses.firstWhere(
                              (w) => w.id == movement.warehouseId,
                              orElse:
                                  () => Warehouse(
                                    id: '',
                                    name: 'Unknown',
                                    location: '',
                                    capacity: 0,
                                  ),
                            );

                            final value = product.price * movement.quantity;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(movement.date),
                                  ),
                                ),
                                DataCell(Text(product.name)),
                                DataCell(
                                  Text(_getMovementTypeText(movement.type)),
                                ),
                                DataCell(Text(movement.quantity.toString())),
                                DataCell(Text(warehouse.name)),
                                DataCell(Text(movement.reference)),
                                DataCell(Text('\$${value.toStringAsFixed(2)}')),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Movements: ${filteredMovements.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total In: ${_calculateTotalIn(filteredMovements)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total Out: ${_calculateTotalOut(filteredMovements)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Net Change: ${_calculateNetChange(filteredMovements)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _calculateNetChange(filteredMovements) >= 0
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectEndDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedProductId,
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Products'),
                      ),
                      ...widget.products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.id,
                          child: Text(product.name),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<MovementType>(
                    decoration: const InputDecoration(
                      labelText: 'Movement Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedMovementType,
                    onChanged: (value) {
                      setState(() {
                        _selectedMovementType = value;
                      });
                    },
                    items: [
                      const DropdownMenuItem<MovementType>(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ...MovementType.values.map((type) {
                        return DropdownMenuItem<MovementType>(
                          value: type,
                          child: Text(_getMovementTypeText(type)),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Warehouse',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedWarehouseId,
                    onChanged: (value) {
                      setState(() {
                        _selectedWarehouseId = value;
                      });
                    },
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Warehouses'),
                      ),
                      ...widget.warehouses.map((warehouse) {
                        return DropdownMenuItem<String>(
                          value: warehouse.id,
                          child: Text(warehouse.name),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedProductId = null;
                      _selectedMovementType = null;
                      _selectedWarehouseId = null;
                      _startDate = DateTime.now().subtract(
                        const Duration(days: 30),
                      );
                      _endDate = DateTime.now();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<InventoryMovement> _getFilteredMovements() {
    return widget.movements.where((movement) {
      // Date filter
      final dateInRange =
          movement.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          movement.date.isBefore(_endDate.add(const Duration(days: 1)));

      // Product filter
      final productMatch =
          _selectedProductId == null ||
          movement.productId == _selectedProductId;

      // Movement type filter
      final typeMatch =
          _selectedMovementType == null ||
          movement.type == _selectedMovementType;

      // Warehouse filter
      final warehouseMatch =
          _selectedWarehouseId == null ||
          movement.warehouseId == _selectedWarehouseId;

      return dateInRange && productMatch && typeMatch && warehouseMatch;
    }).toList();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  int _calculateTotalIn(List<InventoryMovement> movements) {
    int total = 0;
    for (final movement in movements) {
      if (movement.type == MovementType.purchase ||
          movement.type == MovementType.adjustment && movement.quantity > 0) {
        total += movement.quantity;
      }
    }
    return total;
  }

  int _calculateTotalOut(List<InventoryMovement> movements) {
    int total = 0;
    for (final movement in movements) {
      if (movement.type == MovementType.sale ||
          (movement.type == MovementType.adjustment && movement.quantity < 0)) {
        total += movement.quantity.abs();
      }
    }
    return total;
  }

  int _calculateNetChange(List<InventoryMovement> movements) {
    int total = 0;
    for (final movement in movements) {
      if (movement.type == MovementType.purchase ||
          movement.type == MovementType.adjustment) {
        total += movement.quantity;
      } else if (movement.type == MovementType.sale) {
        total -= movement.quantity;
      }
    }
    return total;
  }

  String _getMovementTypeText(MovementType type) {
    switch (type) {
      case MovementType.purchase:
        return 'Purchase';
      case MovementType.sale:
        return 'Sale';
      case MovementType.transfer:
        return 'Transfer';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.stockOpname:
        return 'Stock Opname';
      default:
        return 'Unknown';
    }
  }

  void _exportToCsv(BuildContext context) {
    // This would be implemented with a CSV export package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export functionality would be implemented here'),
      ),
    );
  }
}

// Low Stock Report Page
class LowStockReportPage extends StatelessWidget {
  final List<Product> products;
  final List<InventoryItem> lowStockItems;

  const LowStockReportPage({
    Key? key,
    required this.products,
    required this.lowStockItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToCsv(context),
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Low Stock Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'As of ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('SKU')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Current Quantity')),
                      DataColumn(label: Text('Reorder Point')),
                      DataColumn(label: Text('Shortage')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows:
                        lowStockItems.map((item) {
                          final product = products.firstWhere(
                            (p) => p.id == item.productId,
                            orElse:
                                () => Product(
                                  id: '',
                                  name: 'Unknown',
                                  sku: '',
                                  category: '',
                                  price: 0,
                                ),
                          );

                          final shortage =
                              item.reorderPoint - item.currentQuantity;

                          return DataRow(
                            cells: [
                              DataCell(Text(product.name)),
                              DataCell(Text(product.sku)),
                              DataCell(Text(product.category)),
                              DataCell(Text(item.currentQuantity.toString())),
                              DataCell(Text(item.reorderPoint.toString())),
                              DataCell(Text(shortage.toString())),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        item.currentQuantity == 0
                                            ? Colors.red[100]
                                            : Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.currentQuantity == 0
                                        ? 'Out of Stock'
                                        : 'Low Stock',
                                    style: TextStyle(
                                      color:
                                          item.currentQuantity == 0
                                              ? Colors.red[900]
                                              : Colors.orange[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Low Stock Items: ${lowStockItems.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Out of Stock Items: ${lowStockItems.where((item) => item.currentQuantity == 0).length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Critical Items: ${lowStockItems.where((item) => item.currentQuantity < (item.reorderPoint * 0.5)).length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCsv(BuildContext context) {
    // This would be implemented with a CSV export package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export functionality would be implemented here'),
      ),
    );
  }
}

// Warehouse Capacity Report Page
class WarehouseCapacityReportPage extends StatelessWidget {
  final List<Warehouse> warehouses;
  final List<InventoryItem> inventoryItems;

  const WarehouseCapacityReportPage({
    Key? key,
    required this.warehouses,
    required this.inventoryItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final capacityData = _calculateCapacityData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Capacity Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportToCsv(context),
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warehouse Capacity Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'As of ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: capacityData.length,
                itemBuilder: (context, index) {
                  final warehouseData = capacityData[index];
                  final warehouse = warehouses.firstWhere(
                    (w) => w.id == warehouseData['warehouseId'],
                  );
                  final usedSpace = warehouseData['totalItems'] as int;
                  final capacityPercentage =
                      warehouse.capacity > 0
                          ? (usedSpace / warehouse.capacity * 100).clamp(0, 100)
                          : 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                warehouse.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCapacityStatusColor(
                                    capacityPercentage,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getCapacityStatusText(capacityPercentage),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${warehouse.location}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Capacity Usage:'),
                                  Text(
                                    '${capacityPercentage.toStringAsFixed(1)}%',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: capacityPercentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getCapacityStatusColor(capacityPercentage),
                                ),
                                minHeight: 10,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Used Space: $usedSpace items'),
                                  Text(
                                    'Available: ${warehouse.capacity - usedSpace} items',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Products: ${warehouseData['uniqueProducts']}',
                                  ),
                                  Text(
                                    'Total Capacity: ${warehouse.capacity} items',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Warehouses: ${warehouses.length}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total Capacity: ${_calculateTotalCapacity()} items',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Total Used Space: ${_calculateTotalUsedSpace(capacityData)} items',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Overall Capacity Usage: ${_calculateOverallCapacityPercentage(capacityData).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _calculateCapacityData() {
    final Map<String, Map<String, dynamic>> result = {};

    // Initialize with warehouse data
    for (final warehouse in warehouses) {
      result[warehouse.id] = {
        'warehouseId': warehouse.id,
        'totalItems': 0,
        'uniqueProducts': 0,
        'productIds': <String>{},
      };
    }

    // Aggregate inventory data
    for (final item in inventoryItems) {
      if (result.containsKey(item.warehouseId)) {
        result[item.warehouseId]!['totalItems'] =
            (result[item.warehouseId]!['totalItems'] as int) +
            item.currentQuantity;
        result[item.warehouseId]!['productIds'].add(item.productId);
      }
    }

    // Calculate unique products
    for (final warehouseId in result.keys) {
      result[warehouseId]!['uniqueProducts'] =
          (result[warehouseId]!['productIds'] as Set<String>).length;
    }

    return result.values.toList();
  }

  Color _getCapacityStatusColor(double percentage) {
    if (percentage >= 90) {
      return Colors.red;
    } else if (percentage >= 75) {
      return Colors.orange;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  String _getCapacityStatusText(double percentage) {
    if (percentage >= 90) {
      return 'Critical';
    } else if (percentage >= 75) {
      return 'High';
    } else if (percentage >= 50) {
      return 'Moderate';
    } else {
      return 'Low';
    }
  }

  int _calculateTotalCapacity() {
    int total = 0;
    for (final warehouse in warehouses) {
      total += warehouse.capacity;
    }
    return total;
  }

  int _calculateTotalUsedSpace(List<Map<String, dynamic>> capacityData) {
    int total = 0;
    for (final data in capacityData) {
      total += data['totalItems'] as int;
    }
    return total;
  }

  double _calculateOverallCapacityPercentage(
    List<Map<String, dynamic>> capacityData,
  ) {
    final totalCapacity = _calculateTotalCapacity();
    if (totalCapacity == 0) return 0;

    final totalUsed = _calculateTotalUsedSpace(capacityData);
    return (totalUsed / totalCapacity * 100).clamp(0, 100);
  }

  void _exportToCsv(BuildContext context) {
    // This would be implemented with a CSV export package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV export functionality would be implemented here'),
      ),
    );
  }
}

// Analytics Dashboard page with charts
class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final inventoryItems = ref.watch(inventoryItemsProvider);
    final movements = ref.watch(inventoryMovementsProvider);

    // Prepare data for charts
    final categoryData = _prepareCategoryData(products, inventoryItems);
    final movementData = _prepareMovementData(movements);
    final valueByWarehouseData = _prepareWarehouseValueData(
      products,
      inventoryItems,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Inventory by Category Chart
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildInventoryByCategoryChart(categoryData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Movement Trends
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Movement Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildMovementTrendsChart(movementData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Value by Warehouse
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Value by Warehouse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: _buildValueByWarehouseChart(valueByWarehouseData),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryByCategoryChart(Map<String, double> categoryData) {
    // Placeholder for chart implementation
    // In a real implementation, you would use a charting library like fl_chart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in categoryData.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    color: _getCategoryColor(entry.key),
                  ),
                  const SizedBox(width: 12),
                  Text(entry.key),
                  const Spacer(),
                  Text('\$${entry.value.toStringAsFixed(2)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovementTrendsChart(List<Map<String, dynamic>> movementData) {
    // Placeholder for chart implementation
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in movementData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(entry['date'] as String),
                  const Spacer(),
                  Text('In: ${entry['in']}'),
                  const SizedBox(width: 12),
                  Text('Out: ${entry['out']}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildValueByWarehouseChart(List<Map<String, dynamic>> warehouseData) {
    // Placeholder for chart implementation
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final entry in warehouseData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Text(entry['warehouse'] as String),
                  const Spacer(),
                  Text('\$${(entry['value'] as double).toStringAsFixed(2)}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _prepareCategoryData(
    List<Product> products,
    List<InventoryItem> inventoryItems,
  ) {
    final Map<String, double> result = {};

    // Calculate value by category
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse:
            () => Product(
              id: '',
              name: '',
              sku: '',
              category: 'Uncategorized',
              price: 0,
            ),
      );

      final category =
          product.category.isEmpty ? 'Uncategorized' : product.category;
      final value = product.price * item.currentQuantity;

      if (result.containsKey(category)) {
        result[category] = result[category]! + value;
      } else {
        result[category] = value;
      }
    }

    return result;
  }

  List<Map<String, dynamic>> _prepareMovementData(
    List<InventoryMovement> movements,
  ) {
    // Group movements by date and calculate in/out quantities
    final Map<String, Map<String, dynamic>> result = {};

    // Get the last 7 days
    final DateTime endDate = DateTime.now();
    final DateTime startDate = endDate.subtract(const Duration(days: 6));

    // Initialize result with dates
    for (int i = 0; i <= 6; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      result[dateStr] = {'date': dateStr, 'in': 0, 'out': 0};
    }

    // Calculate in/out for each date
    for (final movement in movements) {
      final dateStr = DateFormat('yyyy-MM-dd').format(movement.date);
      if (result.containsKey(dateStr)) {
        if (movement.type == MovementType.purchase ||
            (movement.type == MovementType.adjustment &&
                movement.quantity > 0)) {
          result[dateStr]!['in'] =
              (result[dateStr]!['in'] as int) + movement.quantity;
        } else if (movement.type == MovementType.sale ||
            (movement.type == MovementType.adjustment &&
                movement.quantity < 0)) {
          result[dateStr]!['out'] =
              (result[dateStr]!['out'] as int) + movement.quantity.abs();
        }
      }
    }

    return result.values.toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  List<Map<String, dynamic>> _prepareWarehouseValueData(
    List<Product> products,
    List<InventoryItem> inventoryItems,
  ) {
    // Calculate inventory value by warehouse
    final Map<String, Map<String, dynamic>> result = {};

    // Initialize with warehouse data
    final warehouseNames = <String, String>{};
    for (final item in inventoryItems) {
      if (!warehouseNames.containsKey(item.warehouseId)) {
        final warehouseIdParts = item.warehouseId.split('-');
        warehouseNames[item.warehouseId] =
            warehouseIdParts.isNotEmpty
                ? warehouseIdParts.first
                : item.warehouseId;
      }

      if (!result.containsKey(item.warehouseId)) {
        result[item.warehouseId] = {
          'warehouse': warehouseNames[item.warehouseId],
          'value': 0.0,
        };
      }
    }

    // Calculate value for each warehouse
    for (final item in inventoryItems) {
      final product = products.firstWhere(
        (p) => p.id == item.productId,
        orElse:
            () => Product(id: '', name: '', sku: '', category: '', price: 0),
      );

      final value = product.price * item.currentQuantity;
      result[item.warehouseId]!['value'] =
          (result[item.warehouseId]!['value'] as double) + value;
    }

    return result.values.toList()
      ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
  }

  Color _getCategoryColor(String category) {
    // Simple hash function to generate a color based on the category name
    final int hash = category.hashCode;
    final int r = ((hash & 0xFF0000) >> 16) % 200 + 55;
    final int g = ((hash & 0x00FF00) >> 8) % 200 + 55;
    final int b = (hash & 0x0000FF) % 200 + 55;
    return Color.fromRGBO(r, g, b, 1.0);
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Inventory Management',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const InventoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warehouse),
            title: const Text('Warehouses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WarehousePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Inventory Movements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryMovementsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Low Stock Alerts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LowStockPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Main app entry point
class InventoryManagementApp extends StatelessWidget {
  const InventoryManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Inventory Management',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const DashboardPage(),
        routes: {
          '/dashboard': (context) => const DashboardPage(),
          '/inventory': (context) => const InventoryPage(),
          '/products': (context) => const ProductPage(),
          '/warehouses': (context) => const WarehousePage(),
          '/reports': (context) => const ReportsPage(),
          '/analytics': (context) => const AnalyticsDashboardPage(),
          '/movements': (context) => const InventoryMovementsPage(),
          '/low-stock': (context) => const LowStockPage(),
          '/stock-opname': (context) => const StockOpnamePage(),
        },
      ),
    );
  }
}

// Utility functions for exporting data
class ExportUtils {
  static Future<void> exportToCsv({
    required List<List<dynamic>> rows,
    required String fileName,
  }) async {
    // This would be implemented with a CSV export package
    // Implementation depends on platform (web, mobile, desktop)
    // For example, using csv and path_provider packages
  }

  static Future<void> generatePdfReport({
    required List<List<dynamic>> data,
    required String title,
    required String fileName,
  }) async {
    // This would be implemented with a PDF generation package
    // Implementation depends on platform (web, mobile, desktop)
    // For example, using pdf package
  }
}
