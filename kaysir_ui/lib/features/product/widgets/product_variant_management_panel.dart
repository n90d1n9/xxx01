import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_variant_management.dart';

class ProductVariantManagementPanel extends StatelessWidget {
  const ProductVariantManagementPanel({
    super.key,
    required this.overview,
    required this.onFamilySelected,
  });

  final ProductVariantManagementOverview overview;
  final ValueChanged<ProductVariantManagementEntry> onFamilySelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Variant management',
      subtitle:
          '${summary.variantFamilyCount} families | '
          '${overview.channelProfile.title} option structure',
      leadingIcon: Icons.layers_rounded,
      trailing: AppStatusPill(
        label: '${summary.optionCoveragePercent}% optioned',
        color: _coverageColor(summary.optionCoveragePercent),
        icon: Icons.tune_rounded,
        maxWidth: 150,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for variant management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VariantSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.optionCoveragePercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.optionCoveragePercent),
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
                          for (final family in overview.families)
                            SizedBox(
                              width: width,
                              child: _VariantFamilyCard(
                                key: ValueKey('product-variant-${family.id}'),
                                family: family,
                                onSelected: () => onFamilySelected(family),
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

class _VariantSummaryStrip extends StatelessWidget {
  const _VariantSummaryStrip({required this.summary});

  final ProductVariantManagementSummary summary;

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
              child: _VariantMetric(
                label: 'Variant coverage',
                value: summary.coverageLabel,
                icon: Icons.account_tree_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _VariantMetric(
                label: 'Option coverage',
                value: '${summary.optionCoveragePercent}% optioned',
                icon: Icons.tune_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _VariantMetric(
                label: 'Variant risk',
                value: summary.variantRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _VariantMetric(
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

class _VariantMetric extends StatelessWidget {
  const _VariantMetric({
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

class _VariantFamilyCard extends StatelessWidget {
  const _VariantFamilyCard({
    super.key,
    required this.family,
    required this.onSelected,
  });

  final ProductVariantManagementEntry family;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(family.status);

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
                  family.isStandalone
                      ? Icons.inventory_2_rounded
                      : Icons.layers_rounded,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    family.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: family.productCountLabel,
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
                  label: family.issueSummaryLabel,
                  color: family.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      family.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 210,
                ),
                AppStatusPill(
                  label: family.optionCoverageLabel,
                  color:
                      family.isStandalone
                          ? Colors.blueGrey.shade700
                          : _coverageColor(_familyOptionCoverage(family)),
                  icon: Icons.tune_rounded,
                  maxWidth: 132,
                ),
                if (family.isInferred)
                  AppStatusPill(
                    label: 'SKU inferred',
                    color: Colors.cyan.shade800,
                    icon: Icons.auto_fix_high_rounded,
                    maxWidth: 118,
                  ),
                if (family.duplicateOptionProductCount > 0)
                  AppStatusPill(
                    label: '${family.duplicateOptionProductCount} duplicate',
                    color: Colors.red.shade700,
                    icon: Icons.copy_all_rounded,
                    maxWidth: 132,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${family.optionValueCount} options | '
                    '${_compactMoney(family.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: family.actionLabel,
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

int _familyOptionCoverage(ProductVariantManagementEntry family) {
  if (family.productCount == 0 || family.isStandalone) return 0;

  return ((family.configuredVariantProductCount / family.productCount) * 100)
      .round();
}

Color _statusColor(ProductVariantRiskStatus status) {
  switch (status) {
    case ProductVariantRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductVariantRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductVariantRiskStatus.action:
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
