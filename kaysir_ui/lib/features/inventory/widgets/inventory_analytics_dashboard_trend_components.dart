import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_movement_trend_state.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_separated_list.dart';
import 'inventory_tile_surface.dart';

/// Panel showing the seven-day stock movement trend for analytics.
class InventoryAnalyticsMovementTrendPanel extends StatelessWidget {
  const InventoryAnalyticsMovementTrendPanel({super.key, required this.trends});

  final List<InventoryAnalyticsMovementTrend> trends;

  @override
  Widget build(BuildContext context) {
    final state = inventoryAnalyticsMovementTrendPanelState(trends);

    return AppContentPanel(
      title: 'Movement Trend',
      subtitle: 'Seven-day inbound, outbound, and net stock flow',
      leadingIcon: Icons.timeline_rounded,
      trailing: AppStatusPill(
        label: state.statusLabel,
        icon: state.statusIcon,
        color: state.statusColor,
        maxWidth: 130,
      ),
      child:
          state.hasRows
              ? InventorySeparatedList<InventoryAnalyticsMovementTrendRowState>(
                items: state.rows,
                itemBuilder: (context, row, index) {
                  return _MovementTrendRow(state: row);
                },
              )
              : const AppEmptyState(
                title: 'No movement window',
                message:
                    'Movement trends appear once stock activity is tracked.',
                icon: Icons.timeline_outlined,
              ),
    );
  }
}

@Preview(name: 'Inventory analytics movement trend panel')
Widget inventoryAnalyticsMovementTrendPanelPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsMovementTrendPanel(
      trends: inventoryAnalyticsPreviewMovementTrends(),
    ),
  );
}

/// Layout row for one movement trend date and its metric chips.
class _MovementTrendRow extends StatelessWidget {
  const _MovementTrendRow({required this.state});

  final InventoryAnalyticsMovementTrendRowState state;

  @override
  Widget build(BuildContext context) {
    return InventoryTileSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final metrics = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final metric in state.metrics) _TrendMetric(state: metric),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TrendDateLabel(label: state.dateLabel),
                const SizedBox(height: 10),
                metrics,
              ],
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 92,
                child: _TrendDateLabel(label: state.dateLabel),
              ),
              const SizedBox(width: 12),
              Expanded(child: metrics),
            ],
          );
        },
      ),
    );
  }
}

/// Text label for a movement trend row date.
class _TrendDateLabel extends StatelessWidget {
  const _TrendDateLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

/// Compact status chip for one movement trend metric.
class _TrendMetric extends StatelessWidget {
  const _TrendMetric({required this.state});

  final InventoryAnalyticsMovementTrendMetricState state;

  @override
  Widget build(BuildContext context) {
    return AppStatusPill(
      label: state.label,
      icon: state.icon,
      color: state.color,
      maxWidth: 120,
    );
  }
}
