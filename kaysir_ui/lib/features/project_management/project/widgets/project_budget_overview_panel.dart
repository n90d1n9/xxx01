import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_budget_overview_service.dart';
import '../services/project_budget_pulse_service.dart';

/// Compact project finance panel showing budget use against delivery progress.
class ProjectBudgetOverviewPanel extends StatelessWidget {
  const ProjectBudgetOverviewPanel({required this.overview, super.key});

  final ProjectBudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = overview.state.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: overview.paceLabel,
          subtitle: overview.detail,
          icon: overview.state.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: stateColor.withValues(alpha: 0.12),
          iconForegroundColor: stateColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: overview.state.label,
            icon: overview.state.icon,
            color: stateColor,
            maxWidth: 118,
          ),
        ),
        const SizedBox(height: 12),
        _BudgetPaceBar(overview: overview),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Budget Used',
              value: '${overview.budgetUsedPercent}%',
              icon: Icons.account_balance_wallet_outlined,
              accentColor: stateColor,
              helper: 'Total consumed',
            ),
            AppMetricGridItem(
              title: 'Progress',
              value: '${overview.progressPercent}%',
              icon: Icons.trending_up_rounded,
              accentColor: colorScheme.primary,
              helper: 'Delivery completion',
            ),
            AppMetricGridItem(
              title: 'Gap',
              value: overview.varianceLabel,
              icon: Icons.speed_outlined,
              accentColor: stateColor,
              helper: 'Budget minus progress',
            ),
            AppMetricGridItem(
              title: 'Remaining',
              value: '${overview.remainingBudgetPercent}%',
              icon: Icons.savings_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Unspent budget',
            ),
          ],
        ),
      ],
    );
  }
}

/// Horizontal comparison bar for project progress and consumed budget.
class _BudgetPaceBar extends StatelessWidget {
  const _BudgetPaceBar({required this.overview});

  final ProjectBudgetOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = overview.state.color(colorScheme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BudgetPaceLegend(
            progressPercent: overview.progressPercent,
            budgetUsedPercent: overview.budgetUsedPercent,
          ),
          const SizedBox(height: 10),
          _BudgetPaceTrack(
            label: 'Budget',
            percent: overview.budgetUsed,
            color: stateColor,
          ),
          const SizedBox(height: 8),
          _BudgetPaceTrack(
            label: 'Progress',
            percent: overview.progress,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Text legend for the budget pace comparison chart.
class _BudgetPaceLegend extends StatelessWidget {
  const _BudgetPaceLegend({
    required this.progressPercent,
    required this.budgetUsedPercent,
  });

  final int progressPercent;
  final int budgetUsedPercent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Budget vs progress',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$budgetUsedPercent% / $progressPercent%',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Fixed-height track for a single budget pace value.
class _BudgetPaceTrack extends StatelessWidget {
  const _BudgetPaceTrack({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clampedPercent = percent.clamp(0, 1).toDouble();

    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: clampedPercent,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Project budget overview panel')
Widget projectBudgetOverviewPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 520,
          child: ProjectBudgetOverviewPanel(
            overview: const ProjectBudgetOverview(
              projectId: 'venue-fit-out',
              projectName: 'Venue Fit Out',
              progress: 0.58,
              budgetUsed: 0.74,
              state: ProjectBudgetPulseState.pressure,
            ),
          ),
        ),
      ),
    ),
  );
}
