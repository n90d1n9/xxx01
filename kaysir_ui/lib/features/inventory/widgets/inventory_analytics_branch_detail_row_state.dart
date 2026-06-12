import 'package:flutter/material.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';
import 'movement_type_visuals.dart';

/// Presentation state for a warehouse row in the branch drill-down panel.
class InventoryAnalyticsBranchWarehouseRowState {
  const InventoryAnalyticsBranchWarehouseRowState({
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.healthLabel,
    required this.healthIcon,
    required this.isHealthy,
  });

  final String title;
  final String subtitle;
  final String valueLabel;
  final String healthLabel;
  final IconData healthIcon;
  final bool isHealthy;

  factory InventoryAnalyticsBranchWarehouseRowState.fromWarehouse(
    InventoryAnalyticsBranchWarehouse warehouse,
  ) {
    final isHealthy = warehouse.lowStockCount == 0;

    return InventoryAnalyticsBranchWarehouseRowState(
      title: warehouse.warehouseName,
      subtitle:
          '${warehouse.locationLabel} | '
          '${formatInventoryNumber(warehouse.quantity)} units | '
          '${formatInventoryNumber(warehouse.productCount)} products',
      valueLabel: formatInventoryCurrency(warehouse.value),
      healthLabel:
          isHealthy
              ? 'Healthy'
              : '${formatInventoryNumber(warehouse.lowStockCount)} low',
      healthIcon:
          isHealthy ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
      isHealthy: isHealthy,
    );
  }
}

/// Presentation state for a movement row in the branch drill-down panel.
class InventoryAnalyticsBranchMovementRowState {
  const InventoryAnalyticsBranchMovementRowState({
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.typeIcon,
    required this.quantityLabel,
  });

  final String title;
  final String subtitle;
  final String typeLabel;
  final IconData typeIcon;
  final String quantityLabel;

  factory InventoryAnalyticsBranchMovementRowState.fromMovement(
    InventoryAnalyticsBranchMovement movement,
  ) {
    return InventoryAnalyticsBranchMovementRowState(
      title: movement.productName,
      subtitle:
          '${formatInventoryTimestamp(movement.date)} | '
          '${movement.routeLabel} | '
          '${movement.referenceLabel}',
      typeLabel: inventoryMovementTypeLabel(movement.type),
      typeIcon: inventoryMovementTypeIcon(movement.type),
      quantityLabel: '${formatInventorySignedNumber(movement.quantity)} units',
    );
  }
}
