import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_evidence_vault_service.dart';
import '../services/project_finance_workspace_service.dart';

/// Reusable evidence vault panel for proof, approvals, receipts, and handoff.
class ProjectEvidenceVaultPanel extends StatelessWidget {
  const ProjectEvidenceVaultPanel({
    required this.summary,
    this.maxRecords = 8,
    super.key,
  });

  final ProjectEvidenceVaultSummary summary;
  final int maxRecords;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = summary.level.color(colorScheme);
    final visibleRecords = summary.records.take(maxRecords).toList();

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
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        _EvidenceReadinessBar(summary: summary, color: levelColor),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Records',
              value: summary.recordCount.toString(),
              icon: Icons.inventory_2_outlined,
              accentColor: colorScheme.primary,
              helper: 'Evidence items',
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: Icons.verified_outlined,
              accentColor: Colors.green.shade700,
              helper: 'Can hand off',
            ),
            AppMetricGridItem(
              title: 'Review',
              value: summary.reviewCount.toString(),
              icon: Icons.rate_review_outlined,
              accentColor:
                  summary.reviewCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs cleanup',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot close',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleRecords.length; index++) ...[
          _EvidenceVaultRecordTile(record: visibleRecords[index]),
          if (index != visibleRecords.length - 1) const SizedBox(height: 10),
        ],
        if (summary.recordCount > maxRecords) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxRecords of ${summary.recordCount} evidence records',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

/// Linear readiness bar for evidence vault completion.
class _EvidenceReadinessBar extends StatelessWidget {
  const _EvidenceReadinessBar({required this.summary, required this.color});

  final ProjectEvidenceVaultSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evidence readiness',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${summary.readinessPercent}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: summary.readinessPercent / 100,
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Evidence vault record row with owner, source, proof, and readiness state.
class _EvidenceVaultRecordTile extends StatelessWidget {
  const _EvidenceVaultRecordTile({required this.record});

  final ProjectEvidenceVaultRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = record.level.color(colorScheme);

    return AppInfoRow(
      title: record.title,
      subtitle:
          '${record.detail} Owner: ${record.ownerLabel}. Evidence: ${record.evidenceLabel}.',
      icon: record.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppStatusPill(
              label: record.kind.label,
              icon: record.icon,
              color: colorScheme.primary,
              maxWidth: 128,
            ),
            const SizedBox(height: 6),
            AppStatusPill(
              label: record.level.label,
              icon: record.level.icon,
              color: levelColor,
              tooltip: record.sourceLabel,
              maxWidth: 128,
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Project evidence vault panel')
Widget projectEvidenceVaultPanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectEvidenceVaultPanel(
          summary: buildProjectEvidenceVaultSummary(workspace),
        ),
      ),
    ),
  );
}
