import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_value_breakdown_state.dart';

void main() {
  test('category value breakdown state formats rows and percentages', () {
    final state = inventoryAnalyticsCategoryValueBreakdownState(
      inventoryAnalyticsPreviewCategoryValues(),
    );

    expect(state.statusLabel, '3 categories');
    expect(state.hasRows, isTrue);
    expect(state.rows.first.label, 'Electronics');
    expect(state.rows.first.valueLabel, r'$12,500.00');
    expect(state.rows.first.helper, '32 units | 8 products');
    expect(state.rows.first.percent, closeTo(12500 / 21700, 0.0001));
    expect(state.rows.first.colorIndex, 0);
  });

  test('branch value breakdown state includes warehouse helper context', () {
    final state = inventoryAnalyticsBranchValueBreakdownState(
      inventoryAnalyticsPreviewBranchValues(),
    );

    expect(state.statusLabel, '2 branches');
    expect(state.rows.first.label, 'Jakarta Central');
    expect(state.rows.first.helper, '186 units | 2 warehouses | 24 products');
    expect(state.rows.first.percent, closeTo(14200 / 21700, 0.0001));
    expect(state.rows.first.colorIndex, 1);
  });

  test('warehouse value breakdown state offsets palette indexes', () {
    final state = inventoryAnalyticsWarehouseValueBreakdownState(
      inventoryAnalyticsPreviewWarehouseValues(),
    );

    expect(state.statusLabel, '2 locations');
    expect(state.rows.first.label, 'Main Warehouse');
    expect(state.rows.first.helper, '120 units | 20 products');
    expect(state.rows.first.percent, closeTo(11100 / 21700, 0.0001));
    expect(state.rows.first.colorIndex, 2);
  });

  test('value breakdown state handles zero totals safely', () {
    final state = inventoryAnalyticsCategoryValueBreakdownState(const [
      InventoryAnalyticsCategoryValue(
        category: 'Draft',
        value: 0,
        quantity: 0,
        productCount: 1,
      ),
    ]);

    expect(state.rows.single.percent, 0);
  });
}
