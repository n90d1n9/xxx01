import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_dashboard_insight_state.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_tile_surface.dart';

/// Executive insight panel for the analytics dashboard workspace.
class InventoryAnalyticsDashboardInsightPanel extends StatelessWidget {
  const InventoryAnalyticsDashboardInsightPanel({
    super.key,
    required this.dashboard,
  });

  final InventoryAnalyticsDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final state = InventoryAnalyticsDashboardInsightState.fromDashboard(
      dashboard,
    );

    return AppContentPanel(
      title: state.title,
      subtitle: state.message,
      leadingIcon: state.icon,
      trailing: AppStatusPill(
        label: state.statusLabel,
        icon: state.icon,
        color: state.color,
        maxWidth: 170,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final facts = [
            for (final fact in state.facts)
              _InventoryAnalyticsInsightFactTile(fact: fact),
          ];

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < facts.length; index += 1) ...[
                  facts[index],
                  if (index != facts.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < facts.length; index += 1) ...[
                Expanded(child: facts[index]),
                if (index != facts.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Compact fact tile shown inside the analytics insight panel.
class _InventoryAnalyticsInsightFactTile extends StatelessWidget {
  const _InventoryAnalyticsInsightFactTile({required this.fact});

  final InventoryAnalyticsDashboardInsightFactState fact;

  @override
  Widget build(BuildContext context) {
    return InventoryTileSurface(
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: fact.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(fact.icon, color: fact.color, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fact.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fact.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  fact.helper,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Inventory analytics dashboard insight')
Widget inventoryAnalyticsDashboardInsightPanelPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsDashboardInsightPanel(
      dashboard: inventoryAnalyticsPreviewDashboard(),
    ),
  );
}
