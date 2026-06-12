import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import '../utils/inventory_formatters.dart';
import 'inventory_metric_chip.dart';

class InventoryProductCatalogTileMetrics extends StatelessWidget {
  const InventoryProductCatalogTileMetrics({super.key, required this.record});

  final InventoryProductCatalogRecord record;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ProductMetric(
          label: 'Stock',
          value: formatInventoryNumber(record.totalQuantity),
          icon: Icons.inventory_rounded,
          emphasize: record.status == InventoryProductCatalogStatus.outOfStock,
        ),
        _ProductMetric(
          label: 'Warehouses',
          value: formatInventoryNumber(record.warehouseCount),
          icon: Icons.warehouse_rounded,
          emphasize: record.status == InventoryProductCatalogStatus.untracked,
        ),
        _ProductMetric(
          label: 'Value',
          value: formatInventoryCurrency(record.inventoryValue),
          icon: Icons.payments_rounded,
        ),
        _ProductMetric(
          label: 'Shortage',
          value: formatInventoryNumber(record.totalShortage),
          icon: Icons.flag_rounded,
          emphasize: record.totalShortage > 0,
        ),
      ],
    );
  }
}

class _ProductMetric extends StatelessWidget {
  const _ProductMetric({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return InventoryMetricChip(
      label: label,
      value: value,
      icon: icon,
      emphasize: emphasize,
      emphasizeColor: Colors.red.shade700,
      maxValueWidth: 130,
    );
  }
}
