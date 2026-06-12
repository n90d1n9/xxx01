import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:queue_ui/inventory/states/inventory_movement_provider.dart';

import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/stockopname.dart';
import '../states/inventory_item_provider.dart';
import '../states/product_provider.dart';
import '../states/stockopname_provider.dart';
import '../states/warehouse_provider.dart';

class StockOpnamePage extends ConsumerStatefulWidget {
  const StockOpnamePage({super.key});

  @override
  ConsumerState<StockOpnamePage> createState() => _StockOpnamePageState();
}

class _StockOpnamePageState extends ConsumerState<StockOpnamePage> {
  late String selectedWarehouseId;
  late List<StockOpnameItem> stockOpnameItems;
  final TextEditingController conductedByController = TextEditingController();
  StockOpnameStatus currentStatus = StockOpnameStatus.draft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final warehouses = ref.read(warehousesProvider);
      if (warehouses.isNotEmpty) {
        selectedWarehouseId = warehouses[0].id;
        _initializeStockOpnameItems();
      }
    });
  }

  void _initializeStockOpnameItems() {
    final inventoryItems = ref.read(inventoryItemsProvider);
    final warehouseItems = inventoryItems
        .where((item) => item.warehouseId == selectedWarehouseId)
        .toList();

    setState(() {
      stockOpnameItems = warehouseItems.map((item) {
        return StockOpnameItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + item.id,
          productId: item.productId,
          systemQuantity: item.currentQuantity,
          actualQuantity: item.currentQuantity, // Default to system quantity
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
                    items: warehouses.map((warehouse) {
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
                    rows: stockOpnameItems.map((item) {
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
                                    stockOpnameItems[index] = StockOpnameItem(
                                      id: item.id,
                                      productId: item.productId,
                                      systemQuantity: item.systemQuantity,
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
                                color: item.discrepancy < 0
                                    ? Colors.red
                                    : (item.discrepancy > 0
                                          ? Colors.green
                                          : Colors.black),
                                fontWeight: item.discrepancy != 0
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
    final inventoryItemsNotifier = ref.read(inventoryItemsProvider.notifier);
    final inventoryItems = ref.read(inventoryItemsProvider);
    final inventoryMovementsNotifier = ref.read(
      inventoryMovementsProvider.notifier,
    );

    for (final opnameItem in stockOpnameItems) {
      final inventoryItem = inventoryItems.firstWhere(
        (item) =>
            item.productId == opnameItem.productId &&
            item.warehouseId == selectedWarehouseId,
        //orElse: () => null,
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
