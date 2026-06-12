import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_assortment_plan.dart';

class ProductAssortmentPlanPanel extends StatelessWidget {
  const ProductAssortmentPlanPanel({
    super.key,
    required this.plan,
    required this.onSegmentSelected,
  });

  final ProductAssortmentPlan plan;
  final ValueChanged<ProductAssortmentSegment> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    final summary = plan.summary;

    return AppContentPanel(
      title: 'Assortment planning',
      subtitle:
          '${plan.managementPack.title} | ${plan.channelProfile.title} | '
          '${summary.segmentCount} segments',
      leadingIcon: Icons.view_cozy_rounded,
      trailing: AppStatusPill(
        label: '${summary.launchReadyPercent}% ready',
        color: _readinessColor(summary.launchReadyPercent),
        icon: Icons.insights_rounded,
        maxWidth: 132,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for assortment planning.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AssortmentSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.launchReadyPercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _readinessColor(summary.launchReadyPercent),
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
                          for (final segment in plan.segments)
                            SizedBox(
                              width: width,
                              child: _AssortmentSegmentCard(
                                key: ValueKey(
                                  'product-assortment-segment-${segment.id}',
                                ),
                                segment: segment,
                                onSelected: () => onSegmentSelected(segment),
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

class _AssortmentSummaryStrip extends StatelessWidget {
  const _AssortmentSummaryStrip({required this.summary});

  final ProductAssortmentPlanSummary summary;

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
              child: _AssortmentMetric(
                label: 'Launch-ready',
                value: summary.launchReadyLabel,
                icon: Icons.rocket_launch_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AssortmentMetric(
                label: 'Planning status',
                value: summary.statusLabel,
                icon: Icons.checklist_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AssortmentMetric(
                label: 'Setup gaps',
                value: summary.qualityIssueCount.toString(),
                icon: Icons.assignment_late_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AssortmentMetric(
                label: 'Inventory value',
                value: _compactMoney(summary.totalInventoryValue),
                icon: Icons.payments_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AssortmentMetric extends StatelessWidget {
  const _AssortmentMetric({
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

class _AssortmentSegmentCard extends StatelessWidget {
  const _AssortmentSegmentCard({
    super.key,
    required this.segment,
    required this.onSelected,
  });

  final ProductAssortmentSegment segment;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _segmentStatusColor(segment.status);

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
                Expanded(
                  child: Text(
                    segment.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: '${segment.launchReadyPercent}%',
                  color: accent,
                  maxWidth: 64,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: segment.launchReadyPercent / 100,
                minHeight: 7,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: accent,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: segment.readinessLabel,
                  color: accent,
                  icon: Icons.inventory_2_rounded,
                  maxWidth: 132,
                ),
                AppStatusPill(
                  label: segment.issueSummaryLabel,
                  color: segment.hasAction ? Colors.orange.shade700 : accent,
                  icon:
                      segment.hasAction
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 170,
                ),
                if (segment.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${segment.untrackedProductCount} untracked',
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
                    '${segment.productCount} products | '
                    '${_compactMoney(segment.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: segment.actionLabel,
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

Color _segmentStatusColor(ProductAssortmentSegmentStatus status) {
  switch (status) {
    case ProductAssortmentSegmentStatus.healthy:
      return Colors.green.shade700;
    case ProductAssortmentSegmentStatus.watch:
      return Colors.orange.shade700;
    case ProductAssortmentSegmentStatus.action:
      return Colors.red.shade700;
  }
}

Color _readinessColor(int percent) {
  if (percent >= 80) return Colors.green.shade700;
  if (percent >= 50) return Colors.orange.shade700;

  return Colors.red.shade700;
}

String _compactMoney(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';

  return '\$${value.toStringAsFixed(0)}';
}
