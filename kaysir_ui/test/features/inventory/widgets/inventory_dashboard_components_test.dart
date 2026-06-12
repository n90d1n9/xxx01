import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/movement_type.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dashboard_components.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('inventory dashboard summary uses shared metric grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: InventoryDashboardSummary(
              totalProducts: 3,
              totalWarehouses: 2,
              totalBranches: 2,
              lowStockItems: 1,
              inventoryValue: 1700,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('2 branches covered'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);
    expect(find.text('Inventory Value'), findsOneWidget);
    expect(find.text(r'$1,700.00'), findsOneWidget);
  });

  testWidgets('recent inventory movements panel renders movement rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: RecentInventoryMovementsPanel(
              movements: [
                InventoryMovementListEntry(
                  productName: 'Laptop',
                  type: MovementType.purchase,
                  quantity: 10,
                  reference: 'PO-001',
                  date: DateTime(2026, 5, 31, 9, 30),
                ),
                InventoryMovementListEntry(
                  productName: 'Desk Chair',
                  type: MovementType.sale,
                  quantity: 2,
                  reference: 'SO-001',
                  date: DateTime(2026, 5, 30, 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.byType(AppInfoRow), findsNWidgets(2));
    expect(find.byType(AppStatusPill), findsNWidgets(3));
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Desk Chair'), findsOneWidget);
    expect(find.text('Inbound'), findsOneWidget);
    expect(find.text('Outbound'), findsOneWidget);
    expect(find.text('10 units'), findsOneWidget);
    expect(find.text('2 units'), findsOneWidget);
  });

  testWidgets('recent inventory movements panel shows empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            child: RecentInventoryMovementsPanel(movements: []),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No recent movements'), findsOneWidget);
    expect(find.text('No activity'), findsOneWidget);
  });
}
