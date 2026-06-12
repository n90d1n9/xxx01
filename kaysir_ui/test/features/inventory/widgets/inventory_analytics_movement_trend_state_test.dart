import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_analytics_dashboard.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_movement_trend_state.dart';
import 'package:kaysir/features/inventory/widgets/inventory_analytics_preview_data.dart';

void main() {
  test('movement trend panel state formats positive net summary', () {
    final state = inventoryAnalyticsMovementTrendPanelState(
      inventoryAnalyticsPreviewMovementTrends(),
    );

    expect(state.hasRows, isTrue);
    expect(state.rows, hasLength(3));
    expect(state.statusLabel, '+16 net');
    expect(state.statusIcon, Icons.trending_up_rounded);
    expect(state.statusColor, Colors.teal.shade700);
  });

  test('movement trend panel state formats negative net summary', () {
    final state = inventoryAnalyticsMovementTrendPanelState([
      InventoryAnalyticsMovementTrend(
        date: DateTime(2026, 6, 8),
        inboundQuantity: 2,
        outboundQuantity: 9,
      ),
    ]);

    expect(state.statusLabel, '-7 net');
    expect(state.statusIcon, Icons.trending_down_rounded);
    expect(state.statusColor, Colors.red.shade700);
  });

  test('movement trend row state formats date and metric chips', () {
    final state = inventoryAnalyticsMovementTrendRowState(
      InventoryAnalyticsMovementTrend(
        date: DateTime(2026, 6, 7),
        inboundQuantity: 16,
        outboundQuantity: 5,
      ),
    );

    expect(state.dateLabel, 'Jun 7');
    expect(state.metrics, hasLength(3));
    expect(state.metrics[0].label, 'In 16');
    expect(state.metrics[0].icon, Icons.south_west_rounded);
    expect(state.metrics[1].label, 'Out 5');
    expect(state.metrics[1].icon, Icons.north_east_rounded);
    expect(state.metrics[2].label, '+11 net');
    expect(state.metrics[2].icon, Icons.trending_up_rounded);
    expect(state.metrics[2].color, Colors.teal.shade700);
  });

  test('movement trend panel state handles empty windows', () {
    final state = inventoryAnalyticsMovementTrendPanelState(const []);

    expect(state.hasRows, isFalse);
    expect(state.statusLabel, '0 net');
    expect(state.rows, isEmpty);
  });
}
