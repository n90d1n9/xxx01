import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_info_row.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_analytics_dashboard.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_priority_queue_state.dart';

/// Operator priority queue generated from inventory analytics signals.
class InventoryAnalyticsPriorityQueuePanel extends StatelessWidget {
  const InventoryAnalyticsPriorityQueuePanel({
    super.key,
    required this.dashboard,
    this.onPrioritySelected,
  });

  final InventoryAnalyticsDashboard dashboard;
  final ValueChanged<InventoryAnalyticsPriorityItemState>? onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    final state = InventoryAnalyticsPriorityQueueState.fromDashboard(dashboard);

    return AppContentPanel(
      title: 'Priority Queue',
      subtitle:
          'Suggested follow-up based on stock health and movement signals',
      leadingIcon: Icons.fact_check_rounded,
      trailing: AppStatusPill(
        label: state.statusLabel,
        icon: Icons.assignment_turned_in_rounded,
        color: state.statusColor,
        maxWidth: 150,
      ),
      child: Column(
        children: [
          for (var index = 0; index < state.items.length; index += 1) ...[
            _InventoryAnalyticsPriorityRow(
              item: state.items[index],
              onTap: _tapHandler(state.items[index]),
            ),
            if (index != state.items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  VoidCallback? _tapHandler(InventoryAnalyticsPriorityItemState item) {
    if (item.target == InventoryAnalyticsPriorityTarget.none) return null;
    final callback = onPrioritySelected;
    if (callback == null) return null;
    return () => callback(item);
  }
}

/// Row for one generated analytics priority.
class _InventoryAnalyticsPriorityRow extends StatelessWidget {
  const _InventoryAnalyticsPriorityRow({required this.item, this.onTap});

  final InventoryAnalyticsPriorityItemState item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      title: item.title,
      subtitle: item.message,
      subtitleMaxLines: 2,
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      iconBackgroundColor: item.color.withValues(alpha: 0.12),
      iconForegroundColor: item.color,
      contained: true,
      onTap: onTap,
      trailing: AppStatusPill(
        label: item.statusLabel,
        color: item.color,
        maxWidth: 110,
      ),
    );
  }
}

@Preview(name: 'Inventory analytics priority queue')
Widget inventoryAnalyticsPriorityQueuePanelPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsPriorityQueuePanel(
      dashboard: inventoryAnalyticsPreviewDashboard(),
    ),
  );
}
