import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_dashboard_branch_detail_rows.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';

void main() {
  testWidgets('branch detail rows render warehouse and movement state', (
    tester,
  ) async {
    final detail = inventoryAnalyticsPreviewBranchDetails().first;
    var warehouseTapped = false;
    var movementTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              InventoryAnalyticsBranchWarehouseRow(
                warehouse: detail.warehouses.first,
                onTap: () => warehouseTapped = true,
              ),
              InventoryAnalyticsBranchMovementRow(
                movement: detail.recentMovements.first,
                onTap: () => movementTapped = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Main Warehouse'), findsOneWidget);
    expect(find.text(r'$11,100.00'), findsOneWidget);
    expect(find.text('1 low'), findsOneWidget);
    expect(find.text('Cable'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
    expect(find.text('+6 units'), findsOneWidget);

    await tester.tap(find.text('Main Warehouse'));
    await tester.tap(find.text('Cable'));

    expect(warehouseTapped, isTrue);
    expect(movementTapped, isTrue);
  });
}
