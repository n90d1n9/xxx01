import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/warehouse.dart';
import '../states/inventory_movement_provider.dart';
import '../states/product_provider.dart';
import '../states/warehouse_provider.dart';

class InventoryMovementsPage extends ConsumerWidget {
  const InventoryMovementsPage({super.key});

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
