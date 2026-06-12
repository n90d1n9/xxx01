import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_cost_structure_service.dart';

/// Cost structure panel showing domain-adaptive budget baseline categories.
class ProjectCostStructurePanel extends StatelessWidget {
  const ProjectCostStructurePanel({
    required this.summary,
    this.maxLines = 5,
    super.key,
  });

  final ProjectCostStructureSummary summary;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleLines = summary.lines.take(maxLines).toList();

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
            maxWidth: 112,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Categories',
              value: summary.categoryCount.toString(),
              icon: Icons.pie_chart_outline_rounded,
              accentColor: colorScheme.primary,
              helper: summary.profileLabel,
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Ledger-ready',
            ),
            AppMetricGridItem(
              title: 'Watch',
              value: (summary.watchCount + summary.criticalCount).toString(),
              icon: Icons.visibility_outlined,
              accentColor:
                  summary.watchCount + summary.criticalCount == 0
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Needs control',
            ),
            AppMetricGridItem(
              title: 'Reserve',
              value: '${summary.contingencySharePercent}%',
              icon: Icons.savings_outlined,
              accentColor: colorScheme.primary,
              helper: 'Contingency share',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleLines.length; index++) ...[
          _CostStructureLineTile(line: visibleLines[index]),
          if (index != visibleLines.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Cost structure row with planned share and control readiness.
class _CostStructureLineTile extends StatelessWidget {
  const _CostStructureLineTile({required this.line});

  final ProjectCostStructureLine line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineColor = line.level.color(colorScheme);

    return AppInfoRow(
      title: '${line.title} (${line.plannedSharePercent}%)',
      subtitle: line.detail,
      icon: line.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: lineColor.withValues(alpha: 0.12),
      iconForegroundColor: lineColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: line.level.label,
        icon: line.level.icon,
        color: lineColor,
        maxWidth: 112,
      ),
    );
  }
}

@Preview(name: 'Project cost structure panel')
Widget projectCostStructurePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectCostStructurePanel(
            summary: const ProjectCostStructureSummary(
              projectId: 'venue-fit-out',
              projectName: 'Venue Fit Out',
              profileLabel: 'Event production',
              budgetPaceLabel: 'Spend ahead of progress',
              lines: [
                ProjectCostStructureLine(
                  id: 'venue-fit-out-vendor',
                  title: 'Venue and vendors',
                  detail:
                      'Needs Procurement before this baseline category becomes ledger-ready.',
                  category: ProjectCostStructureCategory.vendor,
                  plannedShare: 0.34,
                  level: ProjectCostStructureLevel.watch,
                  icon: Icons.inventory_2_outlined,
                ),
                ProjectCostStructureLine(
                  id: 'venue-fit-out-logistics',
                  title: 'Logistics and field ops',
                  detail:
                      'Needs Project Float before this baseline category becomes ledger-ready.',
                  category: ProjectCostStructureCategory.logistics,
                  plannedShare: 0.17,
                  level: ProjectCostStructureLevel.watch,
                  icon: Icons.local_shipping_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
