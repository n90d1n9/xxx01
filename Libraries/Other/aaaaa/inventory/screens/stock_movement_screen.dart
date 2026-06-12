import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_movement.dart';
import '../models/product.dart';
import '../models/warehouse.dart';

class StockMovementReportPage extends StatefulWidget {
  final List<Product> products;
  final List<InventoryMovement> movements;
  final List<Warehouse> warehouses;

  const StockMovementReportPage({
    super.key,
    required this.products,
    required this.movements,
    required this.warehouses,
  });

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
                      style: TextStyle(
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
                      }),
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
                      }),
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
                      }),
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
