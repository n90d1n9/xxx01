import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/warehouse.dart';

class InventoryWarehouseSummary extends StatelessWidget {
  const InventoryWarehouseSummary({super.key, required this.warehouses});

  final List<Warehouse> warehouses;

  @override
  Widget build(BuildContext context) {
    final branches =
        warehouses.map((warehouse) => warehouse.branchLabel).toSet().length;
    final locations =
        warehouses
            .map((warehouse) => warehouse.location.trim())
            .where((location) => location.isNotEmpty)
            .toSet()
            .length;
    final capacityTracked =
        warehouses.where((warehouse) => warehouse.capacity != null).length;
    final documented =
        warehouses
            .where(
              (warehouse) => (warehouse.description ?? '').trim().isNotEmpty,
            )
            .length;

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Warehouses',
          value: warehouses.length.toString(),
          helper: 'Storage locations',
          icon: Icons.warehouse_rounded,
          accentColor: Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Branches',
          value: branches.toString(),
          helper: '$locations operating locations',
          icon: Icons.account_tree_rounded,
          accentColor: Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Capacity',
          value: '$capacityTracked/${warehouses.length}',
          helper: 'Warehouses with tracked capacity',
          icon: Icons.inventory_rounded,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Documented',
          value: '$documented/${warehouses.length}',
          helper: 'Locations with operational notes',
          icon: Icons.description_rounded,
          accentColor: Colors.purple.shade700,
        ),
      ],
    );
  }
}
