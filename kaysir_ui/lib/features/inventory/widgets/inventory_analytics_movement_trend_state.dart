import 'package:flutter/material.dart';

import '../models/inventory_analytics_dashboard.dart';
import '../utils/inventory_formatters.dart';

/// Presentation state for a compact movement trend metric chip.
class InventoryAnalyticsMovementTrendMetricState {
  const InventoryAnalyticsMovementTrendMetricState({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Presentation state for one movement trend row.
class InventoryAnalyticsMovementTrendRowState {
  const InventoryAnalyticsMovementTrendRowState({
    required this.dateLabel,
    required this.metrics,
  });

  final String dateLabel;
  final List<InventoryAnalyticsMovementTrendMetricState> metrics;
}

/// Presentation state for the movement trend panel summary and rows.
class InventoryAnalyticsMovementTrendPanelState {
  const InventoryAnalyticsMovementTrendPanelState({
    required this.statusLabel,
    required this.statusIcon,
    required this.statusColor,
    required this.rows,
  });

  final String statusLabel;
  final IconData statusIcon;
  final Color statusColor;
  final List<InventoryAnalyticsMovementTrendRowState> rows;

  bool get hasRows => rows.isNotEmpty;
}

/// Builds movement trend panel state from seven-day trend values.
InventoryAnalyticsMovementTrendPanelState
inventoryAnalyticsMovementTrendPanelState(
  List<InventoryAnalyticsMovementTrend> trends,
) {
  final inbound = trends.fold<int>(
    0,
    (sum, trend) => sum + trend.inboundQuantity,
  );
  final outbound = trends.fold<int>(
    0,
    (sum, trend) => sum + trend.outboundQuantity,
  );
  final net = inbound - outbound;

  return InventoryAnalyticsMovementTrendPanelState(
    statusLabel: '${formatInventorySignedNumber(net)} net',
    statusIcon:
        net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
    statusColor: _movementTrendNetColor(net),
    rows: [
      for (final trend in trends)
        inventoryAnalyticsMovementTrendRowState(trend),
    ],
  );
}

/// Builds the display state for one movement trend row.
InventoryAnalyticsMovementTrendRowState inventoryAnalyticsMovementTrendRowState(
  InventoryAnalyticsMovementTrend trend,
) {
  final net = trend.netQuantityChange;

  return InventoryAnalyticsMovementTrendRowState(
    dateLabel: formatInventoryShortDate(trend.date),
    metrics: [
      InventoryAnalyticsMovementTrendMetricState(
        label: 'In ${formatInventoryNumber(trend.inboundQuantity)}',
        icon: Icons.south_west_rounded,
        color: Colors.green.shade700,
      ),
      InventoryAnalyticsMovementTrendMetricState(
        label: 'Out ${formatInventoryNumber(trend.outboundQuantity)}',
        icon: Icons.north_east_rounded,
        color: Colors.red.shade700,
      ),
      InventoryAnalyticsMovementTrendMetricState(
        label: '${formatInventorySignedNumber(net)} net',
        icon:
            net >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        color: _movementTrendNetColor(net),
      ),
    ],
  );
}

Color _movementTrendNetColor(int netQuantity) {
  return netQuantity >= 0 ? Colors.teal.shade700 : Colors.red.shade700;
}
