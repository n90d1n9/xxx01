import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_components.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_separated_list.dart';
import 'package:kaysir/features/inventory/widgets/inventory_tile_surface.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('analytics summary renders reusable metrics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsSummaryGrid(
            summary: InventoryAnalyticsSummary(
              productCount: 3,
              warehouseCount: 2,
              lowStockCount: 1,
              totalInventoryValue: 815,
              inboundQuantity: 7,
              outboundQuantity: 3,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Inventory Value'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('7-Day Inbound'), findsOneWidget);
    expect(find.text('7-Day Net'), findsOneWidget);
    expect(find.text(r'$815.00'), findsOneWidget);
  });

  testWidgets('analytics category panel renders value bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsCategoryPanel(
            values: inventoryAnalyticsPreviewCategoryValues(),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(
        InventorySeparatedList<InventoryAnalyticsValueBreakdownRowState>,
      ),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Inventory by Category'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Accessories'), findsOneWidget);
    expect(find.text('Consumables'), findsOneWidget);
    expect(find.text(r'$12,500.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
  });

  testWidgets('analytics movement trend panel renders seven-day rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsMovementTrendPanel(
            trends: inventoryAnalyticsPreviewMovementTrends(),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(
        InventorySeparatedList<InventoryAnalyticsMovementTrendRowState>,
      ),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(3));
    expect(find.text('Movement Trend'), findsOneWidget);
    expect(find.text('Jun 5'), findsOneWidget);
    expect(find.text('Jun 6'), findsOneWidget);
    expect(find.text('In 12'), findsOneWidget);
    expect(find.text('Out 4'), findsOneWidget);
    expect(find.text('+8 net'), findsWidgets);
  });

  testWidgets('analytics warehouse panel renders value bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsWarehouseValuePanel(
            values: inventoryAnalyticsPreviewWarehouseValues(),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(
        InventorySeparatedList<InventoryAnalyticsValueBreakdownRowState>,
      ),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(2));
    expect(find.text('Value by Warehouse'), findsOneWidget);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text('Overflow Hub'), findsOneWidget);
    expect(find.text(r'$11,100.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('analytics branch panel renders value bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryAnalyticsBranchValuePanel(
            values: inventoryAnalyticsPreviewBranchValues(),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(
      find.byType(
        InventorySeparatedList<InventoryAnalyticsValueBreakdownRowState>,
      ),
      findsOneWidget,
    );
    expect(find.byType(InventoryTileSurface), findsNWidgets(2));
    expect(find.text('Value by Branch'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsOneWidget);
    expect(find.text('Surabaya North'), findsOneWidget);
    expect(find.text(r'$14,200.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });

  testWidgets('analytics branch detail panel renders drill-down context', (
    tester,
  ) async {
    String? selectedWarehouseId;
    String? selectedWarehouseBranchId;
    String? selectedMovementReference;
    String? selectedMovementBranchId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InventoryAnalyticsBranchDetailPanel(
              details: inventoryAnalyticsPreviewBranchDetails(),
              selectedBranchId: 'branch-jakarta',
              onBranchChanged: (_) {},
              onWarehouseSelected: (detail, warehouse) {
                selectedWarehouseBranchId = detail.branchId;
                selectedWarehouseId = warehouse.warehouseId;
              },
              onMovementSelected: (detail, movement) {
                selectedMovementBranchId = detail.branchId;
                selectedMovementReference = movement.referenceLabel;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.text('Branch Drill-down'), findsOneWidget);
    expect(find.text('Jakarta Central'), findsWidgets);
    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text(r'$14,200.00'), findsWidgets);
    expect(find.textContaining('TRF-001'), findsOneWidget);
    expect(
      find.textContaining('Main Warehouse -> Overflow Hub'),
      findsOneWidget,
    );
    expect(find.byType(AppMetricGrid), findsOneWidget);

    await tester.tap(find.text('Main Warehouse'));
    expect(selectedWarehouseBranchId, 'branch-jakarta');
    expect(selectedWarehouseId, 'main');

    await tester.ensureVisible(find.text('Cable'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cable'));
    expect(selectedMovementBranchId, 'branch-jakarta');
    expect(selectedMovementReference, 'TRF-001');
  });

  testWidgets('analytics panels show empty states', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                InventoryAnalyticsCategoryPanel(values: []),
                InventoryAnalyticsBranchValuePanel(values: []),
                InventoryAnalyticsBranchDetailPanel(
                  details: [],
                  selectedBranchId: null,
                  onBranchChanged: _noopBranchChange,
                ),
                InventoryAnalyticsWarehouseValuePanel(values: []),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsNWidgets(4));
    expect(find.text('No category value yet'), findsOneWidget);
    expect(find.text('No branch value yet'), findsOneWidget);
    expect(find.text('No branch detail yet'), findsOneWidget);
    expect(find.text('No warehouse value yet'), findsOneWidget);
  });
}

void _noopBranchChange(String _) {}
