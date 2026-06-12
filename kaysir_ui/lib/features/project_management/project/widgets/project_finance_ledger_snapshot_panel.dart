import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_finance_ledger.dart';
import '../services/project_finance_ledger_summary_service.dart';

/// Compact project finance ledger snapshot for budget, expense, and proof records.
class ProjectFinanceLedgerSnapshotPanel extends StatelessWidget {
  const ProjectFinanceLedgerSnapshotPanel({
    required this.summary,
    this.maxBudgetLines = 3,
    super.key,
  });

  final ProjectFinanceLedgerSummary summary;
  final int maxBudgetLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleLines = [...summary.budgetLines]
      ..sort((left, right) => right.utilization.compareTo(left.utilization));
    final displayedLines = visibleLines.take(maxBudgetLines).toList();

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
              title: 'Planned',
              value: _money(summary.plannedAmount),
              icon: Icons.account_balance_wallet_outlined,
              accentColor: colorScheme.primary,
              helper: 'Budget baseline',
            ),
            AppMetricGridItem(
              title: 'Committed',
              value: _money(summary.committedAmount),
              icon: Icons.assignment_turned_in_outlined,
              accentColor: colorScheme.primary,
              helper: 'Reserved spend',
            ),
            AppMetricGridItem(
              title: 'Spent',
              value: _money(summary.spentAmount),
              icon: Icons.receipt_long_outlined,
              accentColor:
                  summary.utilization >= 0.9 ? levelColor : colorScheme.primary,
              helper: '${(summary.utilization * 100).round()}% utilized',
            ),
            AppMetricGridItem(
              title: 'Open Items',
              value: summary.openItemCount.toString(),
              icon: Icons.fact_check_outlined,
              accentColor:
                  summary.openItemCount == 0
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Requests and proof',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < displayedLines.length; index++) ...[
          _BudgetLineTile(line: displayedLines[index]),
          if (index != displayedLines.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _money(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

/// Budget line tile showing utilization and owner context.
class _BudgetLineTile extends StatelessWidget {
  const _BudgetLineTile({required this.line});

  final ProjectBudgetLine line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final utilizationPercent = (line.utilization * 100).round();
    final lineColor =
        line.utilization >= 0.9 ? colorScheme.error : colorScheme.primary;

    return AppInfoRow(
      title: '${line.title} ($utilizationPercent%)',
      subtitle:
          '${line.category.label} - ${_money(line.spentAmount)} spent of ${_money(line.plannedAmount)} planned - owner: ${line.owner}.',
      icon: line.category.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: lineColor.withValues(alpha: 0.12),
      iconForegroundColor: lineColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: utilizationPercent >= 90 ? 'Watch' : 'Tracked',
        icon:
            utilizationPercent >= 90
                ? Icons.priority_high_rounded
                : Icons.verified_outlined,
        color: lineColor,
        maxWidth: 120,
      ),
    );
  }

  String _money(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

@Preview(name: 'Project finance ledger snapshot panel')
Widget projectFinanceLedgerSnapshotPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 620,
          child: ProjectFinanceLedgerSnapshotPanel(
            summary: buildProjectFinanceLedgerSummary(
              projectId: 'retail-modernization',
            ),
          ),
        ),
      ),
    ),
  );
}
