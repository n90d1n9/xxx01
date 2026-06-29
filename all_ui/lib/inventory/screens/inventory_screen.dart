import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:queue_ui/inventory/states/inventory_item_provider.dart';

import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/warehouse.dart';
import '../states/inventory_movement_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';

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
                      () => Warehouse(
                        id: '',
                        name: 'Unknown',
                        location: '',
                        description: '',
                      ),
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
                    .read(inventoryItemsProvider.notifier)
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
                        .read(inventoryItemsProvider.notifier)
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
                          .read(inventoryItemsProvider.notifier)
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
                          .read(inventoryItemsProvider.notifier)
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
