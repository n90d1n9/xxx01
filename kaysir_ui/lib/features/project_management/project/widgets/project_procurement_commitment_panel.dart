import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_finance_workspace_service.dart';
import '../services/project_procurement_commitment_service.dart';

/// Reusable procurement panel for vendor, supplier, and commitment controls.
class ProjectProcurementCommitmentPanel extends StatelessWidget {
  const ProjectProcurementCommitmentPanel({
    required this.summary,
    this.maxItems = 8,
    super.key,
  });

  final ProjectProcurementCommitmentSummary summary;
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
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: summary.level.label,
            icon: summary.level.icon,
            color: levelColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        _ProcurementReadinessStrip(summary: summary, color: levelColor),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Commitments',
              value: summary.itemCount.toString(),
              icon: Icons.inventory_2_outlined,
              accentColor: colorScheme.primary,
              helper: 'Procurement items',
            ),
            AppMetricGridItem(
              title: 'Value',
              value: summary.commitmentAmountLabel,
              icon: Icons.request_quote_outlined,
              accentColor: levelColor,
              helper: 'Committed packages',
            ),
            AppMetricGridItem(
              title: 'Attention',
              value: summary.attentionAmountLabel,
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.attentionAmount <= 0
                      ? Colors.green.shade700
                      : levelColor,
              helper: 'Review or blocked',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot commit',
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProcurementCommitmentItemTile(item: visibleItems[index]),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
        if (summary.itemCount > maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing $maxItems of ${summary.itemCount} procurement commitments',
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

/// Compact readiness strip for procurement commitment status distribution.
class _ProcurementReadinessStrip extends StatelessWidget {
  const _ProcurementReadinessStrip({
    required this.summary,
    required this.color,
  });

  final ProjectProcurementCommitmentSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final readyPercent =
        summary.itemCount == 0 ? 0 : summary.readyCount / summary.itemCount;

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Procurement readiness',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  AppStatusPill(
                    label: '${summary.readyCount} Ready',
                    icon: Icons.verified_outlined,
                    color: Colors.green.shade700,
                    maxWidth: 104,
                  ),
                  AppStatusPill(
                    label: '${summary.reviewCount} Review',
                    icon: Icons.inventory_2_outlined,
                    color:
                        summary.reviewCount == 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                    maxWidth: 112,
                  ),
                  AppStatusPill(
                    label: '${summary.blockedCount} Blocked',
                    icon: Icons.block_outlined,
                    color:
                        summary.blockedCount == 0
                            ? Colors.green.shade700
                            : colorScheme.error,
                    maxWidth: 116,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: readyPercent.toDouble(),
              color: color,
              backgroundColor: color.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Procurement row with owner, evidence, source, amount, and action context.
class _ProcurementCommitmentItemTile extends StatelessWidget {
  const _ProcurementCommitmentItemTile({required this.item});

  final ProjectProcurementCommitmentItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return AppInfoRow(
      title: item.title,
      subtitle:
          '${item.detail} Owner: ${item.ownerLabel}. Evidence: ${item.evidenceLabel}.',
      icon: item.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 4,
      trailing: _ProcurementCommitmentTrailing(item: item),
    );
  }
}

/// Fixed-width procurement trailing content for stable row alignment.
class _ProcurementCommitmentTrailing extends StatelessWidget {
  const _ProcurementCommitmentTrailing({required this.item});

  final ProjectProcurementCommitmentItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);

    return SizedBox(
      width: 154,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.amountLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: item.kind.label,
              icon: item.icon,
              color: colorScheme.primary,
              tooltip: item.sourceLabel,
              maxWidth: 144,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: item.actionLabel,
              icon: item.level.icon,
              color: levelColor,
              tooltip: item.ownerLabel,
              maxWidth: 144,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project procurement commitment panel')
Widget projectProcurementCommitmentPanelPreview() {
  final project =
      const ProjectPortfolioRepository().findById('warehouse-automation')!;
  final workspace = buildProjectFinanceWorkspaceSummary(project);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectProcurementCommitmentPanel(
          summary: buildProjectProcurementCommitmentSummary(workspace),
        ),
      ),
    ),
  );
}
