import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_warehouse_capacity_report.dart';
import 'inventory_filtered_empty_state.dart';
import 'inventory_separated_list.dart';
import 'warehouse_capacity_tile.dart';

/// Panel that renders filtered warehouse capacity report lines.
class InventoryWarehouseCapacityPanel extends StatelessWidget {
  const InventoryWarehouseCapacityPanel({
    super.key,
    required this.lines,
    this.totalCount,
    this.onResetFilters,
  });

  final List<InventoryWarehouseCapacityLine> lines;
  final int? totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    final totalCount = this.totalCount ?? lines.length;

    return AppContentPanel(
      title: 'Capacity Ledger',
      subtitle:
          '${lines.length} of $totalCount warehouse utilization, availability, and product rows',
      leadingIcon: Icons.warehouse_rounded,
      trailing: AppStatusPill(
        label: '${lines.length} locations',
        icon: Icons.location_city_rounded,
        color: Colors.purple.shade700,
        maxWidth: 140,
      ),
      child:
          lines.isEmpty
              ? InventoryWarehouseCapacityEmptyState(
                totalCount: totalCount,
                onResetFilters: onResetFilters,
              )
              : InventoryWarehouseCapacityList(lines: lines),
    );
  }
}

/// List wrapper for warehouse capacity report tiles.
class InventoryWarehouseCapacityList extends StatelessWidget {
  const InventoryWarehouseCapacityList({super.key, required this.lines});

  final List<InventoryWarehouseCapacityLine> lines;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<InventoryWarehouseCapacityLine>(
      items: lines,
      itemBuilder: (context, line, index) {
        return InventoryWarehouseCapacityTile(line: line);
      },
    );
  }
}

/// Empty or filtered state for the warehouse capacity panel.
class InventoryWarehouseCapacityEmptyState extends StatelessWidget {
  const InventoryWarehouseCapacityEmptyState({
    super.key,
    required this.totalCount,
    this.onResetFilters,
  });

  final int totalCount;
  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return InventoryFilteredEmptyState(
      totalCount: totalCount,
      emptyTitle: 'No warehouses to analyze',
      emptyMessage: 'Add warehouses before generating capacity reports.',
      filteredTitle: 'No capacity rows in this branch',
      filteredMessage: 'Try another branch or reset filters.',
      icon: Icons.warehouse_outlined,
      onResetFilters: onResetFilters,
    );
  }
}
