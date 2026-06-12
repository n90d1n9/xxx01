import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_category_management.dart';

class ProductCategoryManagementPanel extends StatelessWidget {
  const ProductCategoryManagementPanel({
    super.key,
    required this.overview,
    required this.onCategorySelected,
  });

  final ProductCategoryManagementOverview overview;
  final ValueChanged<ProductCategoryManagementEntry> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Category management',
      subtitle:
          '${summary.categoryCount} categories | '
          '${overview.channelProfile.title} readiness',
      leadingIcon: Icons.category_rounded,
      trailing: AppStatusPill(
        label: '${summary.taxonomyCoveragePercent}% covered',
        color: _coverageColor(summary.taxonomyCoveragePercent),
        icon: Icons.account_tree_rounded,
        maxWidth: 150,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for category management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CategorySummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.taxonomyCoveragePercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.taxonomyCoveragePercent),
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
                          for (final category in overview.categories)
                            SizedBox(
                              width: width,
                              child: _CategoryCard(
                                key: ValueKey(
                                  'product-category-${category.id}',
                                ),
                                category: category,
                                onSelected: () => onCategorySelected(category),
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

class _CategorySummaryStrip extends StatelessWidget {
  const _CategorySummaryStrip({required this.summary});

  final ProductCategoryManagementSummary summary;

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
              child: _CategoryMetric(
                label: 'Taxonomy coverage',
                value: summary.coverageLabel,
                icon: Icons.account_tree_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _CategoryMetric(
                label: 'Status',
                value: summary.statusLabel,
                icon: Icons.rule_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _CategoryMetric(
                label: 'Uncategorized',
                value: summary.uncategorizedProductCount.toString(),
                icon: Icons.category_outlined,
              ),
            ),
            SizedBox(
              width: width,
              child: _CategoryMetric(
                label: 'Category risk',
                value: summary.categoryRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryMetric extends StatelessWidget {
  const _CategoryMetric({
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.category,
    required this.onSelected,
  });

  final ProductCategoryManagementEntry category;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(category.status);

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
                Icon(Icons.category_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: category.productCountLabel,
                  color: accent,
                  maxWidth: 114,
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
                  label: category.issueSummaryLabel,
                  color: category.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      category.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 190,
                ),
                if (category.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${category.untrackedProductCount} untracked',
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
                    _compactMoney(category.totalInventoryValue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: category.actionLabel,
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

Color _statusColor(ProductCategoryRiskStatus status) {
  switch (status) {
    case ProductCategoryRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductCategoryRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductCategoryRiskStatus.action:
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

  return '\$${value.toStringAsFixed(0)}';
}
