import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_item.dart';
import '../models/product.dart';
import '../models/warehouse.dart';

class InventoryValuationReportPage extends StatelessWidget {
  final List<Product> products;
  final List<InventoryItem> inventoryItems;
  final List<Warehouse> warehouses;

  const InventoryValuationReportPage({
    super.key,
    required this.products,
    required this.inventoryItems,
    required this.warehouses,
  });

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
