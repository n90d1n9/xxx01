import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_relationship_management.dart';

class ProductRelationshipManagementPanel extends StatelessWidget {
  const ProductRelationshipManagementPanel({
    super.key,
    required this.overview,
    required this.onRelationshipSelected,
  });

  final ProductRelationshipManagementOverview overview;
  final ValueChanged<ProductRelationshipManagementEntry> onRelationshipSelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Relationship management',
      subtitle:
          '${summary.relationshipTypeCount} relationship types | '
          '${overview.channelProfile.title} relationship map',
      leadingIcon: Icons.link_rounded,
      trailing: AppStatusPill(
        label: '${summary.resolutionPercent}% resolved',
        color: _coverageColor(summary.resolutionPercent),
        icon: Icons.account_tree_rounded,
        maxWidth: 150,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for relationship management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RelationshipSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.resolutionPercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.resolutionPercent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (overview.relationships.isEmpty)
                    const Text(
                      'No product relationships configured yet. Add relationship attributes such as add-ons, substitutes, bundle components, upsells, or cross-sells to activate this map.',
                    )
                  else
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
                            for (final relationship in overview.relationships)
                              SizedBox(
                                width: width,
                                child: _RelationshipCard(
                                  key: ValueKey(
                                    'product-relationship-${relationship.id}',
                                  ),
                                  relationship: relationship,
                                  onSelected:
                                      () =>
                                          onRelationshipSelected(relationship),
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

class _RelationshipSummaryStrip extends StatelessWidget {
  const _RelationshipSummaryStrip({required this.summary});

  final ProductRelationshipManagementSummary summary;

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
              child: _RelationshipMetric(
                label: 'Relationship coverage',
                value: summary.coverageLabel,
                icon: Icons.link_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _RelationshipMetric(
                label: 'Target resolution',
                value: '${summary.resolutionPercent}% resolved',
                icon: Icons.account_tree_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _RelationshipMetric(
                label: 'Relationship risk',
                value: summary.relationshipRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _RelationshipMetric(
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

class _RelationshipMetric extends StatelessWidget {
  const _RelationshipMetric({
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

class _RelationshipCard extends StatelessWidget {
  const _RelationshipCard({
    super.key,
    required this.relationship,
    required this.onSelected,
  });

  final ProductRelationshipManagementEntry relationship;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(relationship.status);

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
                Icon(
                  _relationshipIcon(relationship.type),
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    relationship.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: relationship.productCountLabel,
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
                  label: relationship.issueSummaryLabel,
                  color: relationship.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      relationship.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 210,
                ),
                AppStatusPill(
                  label: relationship.resolutionLabel,
                  color: _coverageColor(relationship.resolutionPercent),
                  icon: Icons.account_tree_rounded,
                  maxWidth: 148,
                ),
                if (relationship.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${relationship.untrackedProductCount} untracked',
                    color: Colors.blueGrey.shade700,
                    icon: Icons.visibility_off_rounded,
                    maxWidth: 128,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${relationship.referenceCount} links | '
                    '${_compactMoney(relationship.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: relationship.actionLabel,
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

IconData _relationshipIcon(ProductRelationshipType type) {
  switch (type) {
    case ProductRelationshipType.substitutes:
      return Icons.swap_horiz_rounded;
    case ProductRelationshipType.complements:
      return Icons.add_link_rounded;
    case ProductRelationshipType.bundleComponents:
      return Icons.inventory_2_rounded;
    case ProductRelationshipType.upsells:
      return Icons.trending_up_rounded;
    case ProductRelationshipType.crossSells:
      return Icons.hub_rounded;
  }
}

Color _statusColor(ProductRelationshipRiskStatus status) {
  switch (status) {
    case ProductRelationshipRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductRelationshipRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductRelationshipRiskStatus.action:
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
