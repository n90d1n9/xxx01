import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/models/inventory_movement_record.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_screen_state.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_priority_queue_state.dart';

void main() {
  test('analytics dashboard header state formats as-of copy', () {
    final state = InventoryAnalyticsDashboardHeaderState.fromDashboard(
      dashboard: InventoryAnalyticsDashboard(
        summary: inventoryAnalyticsPreviewSummary(),
        categoryValues: const [],
        warehouseValues: const [],
        movementTrends: const [],
        branchValues: const [],
        branchDetails: const [],
      ),
      asOfDate: DateTime(2026, 6, 11),
    );

    expect(state.eyebrow, 'Inventory Intelligence');
    expect(state.title, 'Analytics Dashboard');
    expect(
      state.subtitle,
      'As of 2026-06-11 | 48 products and 5 warehouses in view',
    );
  });

  test('analytics dashboard resolves selected branch id', () {
    final details = inventoryAnalyticsPreviewBranchDetails();

    expect(
      inventoryAnalyticsResolvedBranchId(
        selectedBranchId: 'branch-surabaya',
        details: details,
      ),
      'branch-surabaya',
    );
    expect(
      inventoryAnalyticsResolvedBranchId(
        selectedBranchId: 'missing',
        details: details,
      ),
      'branch-jakarta',
    );
    expect(
      inventoryAnalyticsResolvedBranchId(
        selectedBranchId: null,
        details: const [],
      ),
      isNull,
    );
  });

  test('analytics dashboard maps movement types to filters', () {
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.purchase),
      InventoryMovementFilter.inbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.receipt),
      InventoryMovementFilter.inbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.inbound),
      InventoryMovementFilter.inbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.sale),
      InventoryMovementFilter.outbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.issue),
      InventoryMovementFilter.outbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.outbound),
      InventoryMovementFilter.outbound,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.transfer),
      InventoryMovementFilter.transfer,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.adjustment),
      InventoryMovementFilter.adjustment,
    );
    expect(
      inventoryAnalyticsMovementFilterForType(MovementType.stockOpname),
      InventoryMovementFilter.stockOpname,
    );
  });

  test('analytics dashboard route helpers build drill-down links', () {
    final detail = inventoryAnalyticsPreviewBranchDetails().first;
    final warehouse = detail.warehouses.first;
    final movement = detail.recentMovements.first;

    expect(
      inventoryAnalyticsWarehouseStockRoute(
        detail: detail,
        warehouse: warehouse,
      ),
      '/inventory/stock?branch=branch-jakarta&warehouse=main',
    );
    expect(
      inventoryAnalyticsBranchMovementRoute(detail: detail, movement: movement),
      '/inventory/movements?branch=branch-jakarta&q=TRF-001&filter=transfer',
    );
  });

  test('analytics dashboard priority route helpers build action links', () {
    expect(
      inventoryAnalyticsPriorityRoute(
        const InventoryAnalyticsPriorityItemState(
          title: 'Low stock',
          message: 'Review replenishment',
          statusLabel: 'Restock',
          icon: Icons.warning_amber_rounded,
          level: InventoryAnalyticsPriorityLevel.high,
          target: InventoryAnalyticsPriorityTarget.lowStock,
        ),
      ),
      '/inventory/low-stock',
    );
    expect(
      inventoryAnalyticsPriorityRoute(
        const InventoryAnalyticsPriorityItemState(
          title: 'Branch',
          message: 'Review branch',
          statusLabel: 'Monitor',
          icon: Icons.account_tree_rounded,
          level: InventoryAnalyticsPriorityLevel.medium,
          target: InventoryAnalyticsPriorityTarget.branchDetail,
          targetBranchId: 'branch-jakarta',
        ),
      ),
      '/inventory/warehouses/branch?branch=branch-jakarta',
    );
    expect(
      inventoryAnalyticsPriorityRoute(
        const InventoryAnalyticsPriorityItemState(
          title: 'Stable',
          message: 'Keep monitoring',
          statusLabel: 'Stable',
          icon: Icons.verified_rounded,
          level: InventoryAnalyticsPriorityLevel.informational,
          target: InventoryAnalyticsPriorityTarget.none,
        ),
      ),
      '/inventory/analytics',
    );
  });
}
