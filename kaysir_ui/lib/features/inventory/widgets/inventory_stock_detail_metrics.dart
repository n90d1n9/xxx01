import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_stock_record.dart';
import '../utils/inventory_formatters.dart';

class InventoryStockDetailMetrics extends StatelessWidget {
  const InventoryStockDetailMetrics({
    super.key,
    required this.record,
    this.currencyFormat,
  });

  final InventoryStockRecord record;
  final NumberFormat? currencyFormat;

  @override
  Widget build(BuildContext context) {
    return AppMetricGrid(
      minTileWidth: 150,
      metrics: [
        AppMetricGridItem(
          title: 'Current Qty',
          value: record.quantity.toString(),
          helper: 'Units on hand',
          icon: Icons.inventory_2_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Reorder Point',
          value: record.reorderPoint.toString(),
          helper: 'Attention threshold',
          icon: Icons.flag_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Reorder Qty',
          value: record.reorderQuantity.toString(),
          helper: 'Default replenish amount',
          icon: Icons.playlist_add_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Stock Value',
          value: formatInventoryCurrency(
            record.inventoryValue,
            formatter: currencyFormat,
          ),
          helper: 'Current quantity x price',
          icon: Icons.payments_rounded,
          accentColor: Colors.indigo.shade700,
        ),
      ],
    );
  }
}
