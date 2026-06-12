import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_item.dart';
import '../models/warehouse.dart';

class WarehouseCapacityReportPage extends StatelessWidget {
  final List<Warehouse> warehouses;
  final List<InventoryItem> inventoryItems;

  const WarehouseCapacityReportPage({
    super.key,
    required this.warehouses,
    required this.inventoryItems,
  });

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
                      warehouse.capacity! > 0
                          ? (usedSpace / warehouse.capacity! * 100).clamp(
                            0,
                            100,
                          )
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
                                    capacityPercentage as double,
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
                                    'Available: ${warehouse.capacity! - usedSpace} items',
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
      total += warehouse.capacity! as int;
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
