import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_item.dart';
import '../models/product.dart';

class LowStockReportPage extends StatelessWidget {
  final List<Product> products;
  final List<InventoryItem> lowStockItems;

  const LowStockReportPage({
    super.key,
    required this.products,
    required this.lowStockItems,
  });

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
