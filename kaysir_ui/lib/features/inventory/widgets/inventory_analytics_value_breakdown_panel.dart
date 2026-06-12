import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_empty_state.dart';
import '../../../widgets/ui/app_status_pill.dart';
import 'inventory_analytics_preview_data.dart';
import 'inventory_analytics_value_bar_row.dart';
import 'inventory_analytics_value_breakdown_state.dart';
import 'inventory_separated_list.dart';

/// Reusable panel shell for analytics value breakdown lists.
class InventoryAnalyticsValueBreakdownPanel extends StatelessWidget {
  const InventoryAnalyticsValueBreakdownPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.statusIcon,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.state,
    this.statusColor,
    this.statusMaxWidth = 150,
  });

  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final IconData statusIcon;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final InventoryAnalyticsValueBreakdownPanelState state;
  final Color? statusColor;
  final double statusMaxWidth;

  @override
  Widget build(BuildContext context) {
    final resolvedStatusColor =
        statusColor ?? Theme.of(context).colorScheme.primary;

    return AppContentPanel(
      title: title,
      subtitle: subtitle,
      leadingIcon: leadingIcon,
      trailing:
          state.hasRows
              ? AppStatusPill(
                label: state.statusLabel,
                icon: statusIcon,
                color: resolvedStatusColor,
                maxWidth: statusMaxWidth,
              )
              : null,
      child:
          state.hasRows
              ? InventorySeparatedList<
                InventoryAnalyticsValueBreakdownRowState
              >(
                items: state.rows,
                itemBuilder: (context, row, index) {
                  return InventoryAnalyticsValueBarRow(
                    label: row.label,
                    valueLabel: row.valueLabel,
                    helper: row.helper,
                    percent: row.percent,
                    color: inventoryAnalyticsValuePaletteColor(
                      context,
                      row.colorIndex,
                    ),
                  );
                },
              )
              : AppEmptyState(
                title: emptyTitle,
                message: emptyMessage,
                icon: emptyIcon,
              ),
    );
  }
}

@Preview(name: 'Inventory analytics value breakdown panel')
Widget inventoryAnalyticsValueBreakdownPanelPreview() {
  return inventoryAnalyticsPreviewScaffold(
    InventoryAnalyticsValueBreakdownPanel(
      title: 'Inventory by Category',
      subtitle: 'Stock value concentration across product groups',
      leadingIcon: Icons.category_rounded,
      statusIcon: Icons.pie_chart_rounded,
      emptyTitle: 'No category value yet',
      emptyMessage: 'Add stocked products to populate category analytics.',
      emptyIcon: Icons.category_outlined,
      state: inventoryAnalyticsCategoryValueBreakdownState(
        inventoryAnalyticsPreviewCategoryValues(),
      ),
    ),
  );
}
