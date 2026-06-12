import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/inventory/states/inventory_item_provider.dart';

import '../models/inventory_item.dart';
import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/warehouse.dart';
import '../states/inventory_movement_provider.dart';
import '../states/low_stock_items_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';

class LowStockPage extends ConsumerWidget {
  const LowStockPage({super.key});

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
              child: lowStockItems.isEmpty
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
                          rows: lowStockItems.map((item) {
                            final product = products.firstWhere(
                              (p) => p.id == item.productId,
                              orElse: () => Product(
                                id: '',
                                name: 'Unknown',
                                sku: '',
                                category: '',
                                price: 0,
                              ),
                            );

                            final warehouse = warehouses.firstWhere(
                              (w) => w.id == item.warehouseId,
                              orElse: () => Warehouse(
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
                                DataCell(Text(item.reorderPoint.toString())),
                                DataCell(Text(item.reorderQuantity.toString())),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () => _createPurchaseOrder(
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
                    .read(inventoryItemsProvider.notifier)
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
