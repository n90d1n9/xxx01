import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_summary_metric_state.dart';

void main() {
  test('analytics summary metric state formats top-level metrics', () {
    final metrics = inventoryAnalyticsSummaryMetricStates(
      const InventoryAnalyticsSummary(
        productCount: 3,
        warehouseCount: 2,
        lowStockCount: 1,
        totalInventoryValue: 815,
        inboundQuantity: 7,
        outboundQuantity: 3,
      ),
    );

    expect(metrics, hasLength(4));
    expect(metrics[0].title, 'Inventory Value');
    expect(metrics[0].value, r'$815.00');
    expect(metrics[0].helper, '3 products tracked');
    expect(metrics[1].helper, 'Lines below reorder point');
    expect(metrics[1].accentColor, Colors.orange.shade700);
    expect(metrics[3].value, '+4');
    expect(metrics[3].icon, Icons.trending_up_rounded);
  });

  test('analytics summary metric state marks negative net movement', () {
    final metrics = inventoryAnalyticsSummaryMetricStates(
      const InventoryAnalyticsSummary(
        productCount: 3,
        warehouseCount: 2,
        lowStockCount: 0,
        totalInventoryValue: 815,
        inboundQuantity: 2,
        outboundQuantity: 8,
      ),
    );

    expect(metrics[1].helper, 'No active alerts');
    expect(metrics[1].accentColor, Colors.green.shade700);
    expect(metrics[3].value, '-6');
    expect(metrics[3].icon, Icons.trending_down_rounded);
    expect(metrics[3].accentColor, Colors.red.shade700);
  });

  test('branch detail metric state formats selected branch context', () {
    final detail = inventoryAnalyticsPreviewBranchDetails().first;
    final metrics = inventoryAnalyticsBranchDetailMetricStates(detail);

    expect(metrics, hasLength(4));
    expect(metrics[0].title, 'Value');
    expect(metrics[0].value, r'$14,200.00');
    expect(metrics[0].helper, '186 units');
    expect(metrics[1].helper, 'Needs attention');
    expect(metrics[2].value, '2');
    expect(metrics[2].helper, '24 products');
    expect(metrics[3].value, '18');
    expect(metrics[3].helper, '2 shown');
  });

  test('metric tile state converts to app metric grid items', () {
    final item =
        const InventoryAnalyticsMetricTileState(
          title: 'Movement',
          value: '18',
          helper: '2 shown',
          icon: Icons.timeline_rounded,
          accentColor: Colors.pink,
        ).toMetricGridItem();

    expect(item.title, 'Movement');
    expect(item.value, '18');
    expect(item.helper, '2 shown');
    expect(item.icon, Icons.timeline_rounded);
    expect(item.accentColor, Colors.pink);
  });
}
