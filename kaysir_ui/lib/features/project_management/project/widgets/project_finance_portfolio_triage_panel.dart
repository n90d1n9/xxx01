import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_portfolio_triage_service.dart';

/// Portfolio finance triage panel for switching between project finance work.
class ProjectFinancePortfolioTriagePanel extends StatelessWidget {
  const ProjectFinancePortfolioTriagePanel({
    required this.summary,
    required this.selectedProjectId,
    required this.onProjectSelected,
    this.maxEntries = 6,
    super.key,
  });

  final ProjectFinancePortfolioTriageSummary summary;
  final String selectedProjectId;
  final ValueChanged<String> onProjectSelected;
  final int maxEntries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleEntries = summary.entries.take(maxEntries).toList();

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
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Projects',
              value: summary.projectCount.toString(),
              icon: Icons.work_outline_rounded,
              accentColor: colorScheme.primary,
              helper: 'In triage',
            ),
            AppMetricGridItem(
              title: 'Actions',
              value: summary.actionCount.toString(),
              icon: Icons.pending_actions_outlined,
              accentColor:
                  summary.actionCount == 0 ? Colors.green.shade700 : levelColor,
              helper: 'Finance next steps',
            ),
            AppMetricGridItem(
              title: 'Critical',
              value: summary.criticalActionCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.criticalActionCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Blocked actions',
            ),
            AppMetricGridItem(
              title: 'Open Ledger',
              value: summary.openLedgerCount.toString(),
              icon: Icons.receipt_long_outlined,
              accentColor:
                  summary.openLedgerCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Open records',
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = _tileWidth(constraints.maxWidth);
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final entry in visibleEntries)
                  SizedBox(
                    width: tileWidth,
                    child: _ProjectFinanceTriageTile(
                      entry: entry,
                      isSelected: entry.projectId == selectedProjectId,
                      onTap: () => onProjectSelected(entry.projectId),
                    ),
                  ),
              ],
            );
          },
        ),
        if (summary.entries.length > maxEntries) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxEntries of ${summary.entries.length} finance triage projects',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  double _tileWidth(double maxWidth) {
    if (maxWidth >= 960) return (maxWidth - 24) / 3;
    if (maxWidth >= 640) return (maxWidth - 12) / 2;
    return maxWidth;
  }
}

/// Tappable project finance triage tile with action and ledger indicators.
class _ProjectFinanceTriageTile extends StatelessWidget {
  const _ProjectFinanceTriageTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  final ProjectFinancePortfolioTriageEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = entry.level.color(colorScheme);
    final borderColor =
        isSelected ? colorScheme.primary : colorScheme.outlineVariant;

    return Material(
      color:
          isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.22)
              : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: isSelected ? 1.4 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppStatusPill(
                    label: entry.level.label,
                    icon: entry.level.icon,
                    color: levelColor,
                    maxWidth: 96,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.client} - ${entry.businessDomain}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                entry.primaryActionTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _TriageMetricRow(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact metric row for one portfolio finance triage tile.
class _TriageMetricRow extends StatelessWidget {
  const _TriageMetricRow({required this.entry});

  final ProjectFinancePortfolioTriageEntry entry;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MiniMetric(label: 'Actions', value: entry.actionCount.toString()),
        _MiniMetric(label: 'Open', value: entry.openLedgerCount.toString()),
        _MiniMetric(label: 'Budget', value: '${entry.budgetUsedPercent}%'),
        _MiniMetric(label: 'Gap', value: entry.budgetVarianceLabel),
      ],
    );
  }
}

/// Small metric chip used inside project finance triage tiles.
class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 66),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project finance portfolio triage panel')
Widget projectFinancePortfolioTriagePanelPreview() {
  final projects = const ProjectPortfolioRepository().fetchProjects();

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectFinancePortfolioTriagePanel(
          summary: buildProjectFinancePortfolioTriageSummary(projects),
          selectedProjectId: projects.first.id,
          onProjectSelected: (_) {},
        ),
      ),
    ),
  );
}
