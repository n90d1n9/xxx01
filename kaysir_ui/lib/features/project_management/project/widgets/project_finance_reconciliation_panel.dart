import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_finance_reconciliation_service.dart';

/// Finance reconciliation panel for receipts, approvals, proof, and closeout.
class ProjectFinanceReconciliationPanel extends StatelessWidget {
  const ProjectFinanceReconciliationPanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectFinanceReconciliationSummary summary;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleItems = summary.items.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.detail,
          icon: summary.level.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: levelColor.withValues(alpha: 0.12),
          iconForegroundColor: levelColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 120,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Items',
              value: summary.itemCount.toString(),
              icon: Icons.inventory_2_outlined,
              accentColor: colorScheme.primary,
              helper: 'Evidence checks',
            ),
            AppMetricGridItem(
              title: 'Clean',
              value: summary.cleanCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Ready to close',
            ),
            AppMetricGridItem(
              title: 'Evidence',
              value: (summary.actionCount - summary.blockedCount).toString(),
              icon: Icons.fact_check_outlined,
              accentColor:
                  summary.actionCount == summary.blockedCount
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs proof',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot close',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _FinanceReconciliationItemTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Reconciliation item tile with evidence and owner expectations.
class _FinanceReconciliationItemTile extends StatelessWidget {
  const _FinanceReconciliationItemTile({required this.item});

  final ProjectFinanceReconciliationItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle:
          '${item.detail} Evidence: ${item.evidenceLabel}. Owner: ${item.ownerLabel}.',
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: itemColor.withValues(alpha: 0.12),
      iconForegroundColor: itemColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: item.level.label,
        icon: item.level.icon,
        color: itemColor,
        maxWidth: 120,
      ),
    );
  }
}

@Preview(name: 'Project finance reconciliation panel')
Widget projectFinanceReconciliationPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectFinanceReconciliationPanel(
            summary: buildProjectFinanceReconciliationSummary(
              _previewProject(),
              today: DateTime(2026, 6, 9),
            ),
          ),
        ),
      ),
    ),
  );
}

ProjectPortfolioItem _previewProject() {
  return ProjectPortfolioItem(
    id: 'venue-fit-out',
    name: 'Venue Fit Out',
    owner: 'Site Lead',
    client: 'Venue Client',
    businessDomain: 'Event Production',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: 0.58,
    budgetUsed: 0.74,
    health: ProjectHealth.atRisk,
    milestones: [
      ProjectMilestone(
        label: 'Pilot',
        dueDate: DateTime(2026, 6, 21),
        isComplete: false,
      ),
    ],
  );
}
