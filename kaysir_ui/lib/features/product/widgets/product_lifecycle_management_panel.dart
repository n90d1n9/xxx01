import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_lifecycle_management.dart';

class ProductLifecycleManagementPanel extends StatelessWidget {
  const ProductLifecycleManagementPanel({
    super.key,
    required this.overview,
    required this.onStageSelected,
  });

  final ProductLifecycleManagementOverview overview;
  final ValueChanged<ProductLifecycleManagementEntry> onStageSelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Lifecycle management',
      subtitle:
          '${summary.productCount} products | '
          '${overview.channelProfile.title} governance',
      leadingIcon: Icons.flag_circle_rounded,
      trailing: AppStatusPill(
        label: '${summary.activeCoveragePercent}% active',
        color: _coverageColor(summary.activeCoveragePercent),
        icon: Icons.published_with_changes_rounded,
        maxWidth: 140,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for lifecycle management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LifecycleSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.activeCoveragePercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.activeCoveragePercent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columnCount =
                          constraints.maxWidth >= 1040
                              ? 3
                              : constraints.maxWidth >= 680
                              ? 2
                              : 1;
                      const gap = 12.0;
                      final width =
                          (constraints.maxWidth - (gap * (columnCount - 1))) /
                          columnCount;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final stage in overview.stages)
                            SizedBox(
                              width: width,
                              child: _LifecycleStageCard(
                                key: ValueKey('product-lifecycle-${stage.id}'),
                                stage: stage,
                                onSelected: () => onStageSelected(stage),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
    );
  }
}

class _LifecycleSummaryStrip extends StatelessWidget {
  const _LifecycleSummaryStrip({required this.summary});

  final ProductLifecycleManagementSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount =
            constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 1;
        const gap = 10.0;
        final width =
            (constraints.maxWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: width,
              child: _LifecycleMetric(
                label: 'Active coverage',
                value: summary.coverageLabel,
                icon: Icons.published_with_changes_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _LifecycleMetric(
                label: 'Lifecycle risk',
                value: summary.lifecycleRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _LifecycleMetric(
                label: 'Channel risk',
                value: summary.channelRiskProductCount.toString(),
                icon: Icons.hub_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _LifecycleMetric(
                label: 'Inventory value',
                value: _compactMoney(summary.totalInventoryValue),
                icon: Icons.inventory_2_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LifecycleMetric extends StatelessWidget {
  const _LifecycleMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifecycleStageCard extends StatelessWidget {
  const _LifecycleStageCard({
    super.key,
    required this.stage,
    required this.onSelected,
  });

  final ProductLifecycleManagementEntry stage;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(stage.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_stageIcon(stage.stage), color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stage.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: stage.productCountLabel,
                  color: accent,
                  maxWidth: 112,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: stage.issueSummaryLabel,
                  color: stage.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      stage.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 210,
                ),
                if (stage.channelRiskProductCount > 0)
                  AppStatusPill(
                    label: '${stage.channelRiskProductCount} channel',
                    color: Colors.teal.shade700,
                    icon: Icons.hub_rounded,
                    maxWidth: 124,
                  ),
                if (stage.qualityIssueProductCount > 0)
                  AppStatusPill(
                    label: '${stage.qualityIssueProductCount} setup',
                    color: Colors.red.shade700,
                    icon: Icons.rule_rounded,
                    maxWidth: 112,
                  ),
                if (stage.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${stage.untrackedProductCount} untracked',
                    color: Colors.blueGrey.shade700,
                    icon: Icons.visibility_off_rounded,
                    maxWidth: 132,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_compactMoney(stage.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: stage.actionLabel,
                  icon: Icons.manage_search_rounded,
                  compact: true,
                  variant: AppActionButtonVariant.secondary,
                  onPressed: onSelected,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

IconData _stageIcon(ProductLifecycleStage stage) {
  return switch (stage) {
    ProductLifecycleStage.draft => Icons.edit_note_rounded,
    ProductLifecycleStage.active => Icons.verified_rounded,
    ProductLifecycleStage.blocked => Icons.block_rounded,
    ProductLifecycleStage.retiring => Icons.event_busy_rounded,
    ProductLifecycleStage.archived => Icons.inventory_rounded,
  };
}

Color _statusColor(ProductLifecycleRiskStatus status) {
  switch (status) {
    case ProductLifecycleRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductLifecycleRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductLifecycleRiskStatus.action:
      return Colors.red.shade700;
  }
}

Color _coverageColor(int percent) {
  if (percent >= 90) return Colors.green.shade700;
  if (percent >= 70) return Colors.orange.shade700;

  return Colors.red.shade700;
}

String _compactMoney(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';

  return '\$${value.toStringAsFixed(value >= 100 ? 0 : 2)}';
}
