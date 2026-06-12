import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_record.dart';
import '../utils/inventory_formatters.dart';

class InventoryStockSummary extends StatelessWidget {
  const InventoryStockSummary({
    super.key,
    required this.records,
    this.currencyFormat,
  });

  final List<InventoryStockRecord> records;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    final lowStockCount =
        records.where((record) => record.needsAttention).length;
    final totalUnits = records.fold<int>(
      0,
      (sum, record) => sum + record.quantity,
    );
    final inventoryValue = records.fold<double>(
      0,
      (sum, record) => sum + record.inventoryValue,
    );

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Stock Lines',
          value: records.length.toString(),
          helper: 'Tracked product-location pairs',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Units On Hand',
          value: formatInventoryNumber(totalUnits),
          helper: 'Available across warehouses',
          icon: Icons.category_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Needs Attention',
          value: lowStockCount.toString(),
          helper: 'Low or empty stock lines',
          icon: Icons.notification_important_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Stock Value',
          value: formatInventoryCurrency(
            inventoryValue,
            formatter: currencyFormat,
          ),
          helper: 'Based on current product pricing',
          icon: Icons.payments_rounded,
          accentColor: Colors.indigo.shade700,
        ),
      ],
    );
  }
}
