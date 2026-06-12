import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_pricing_management.dart';

class ProductPricingManagementPanel extends StatelessWidget {
  const ProductPricingManagementPanel({
    super.key,
    required this.overview,
    required this.onPricingGroupSelected,
  });

  final ProductPricingManagementOverview overview;
  final ValueChanged<ProductPricingManagementEntry> onPricingGroupSelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Pricing management',
      subtitle:
          '${overview.channelProfile.title} pricing readiness | '
          '${summary.statusLabel}',
      leadingIcon: Icons.sell_rounded,
      trailing: AppStatusPill(
        label: '${summary.pricingCoveragePercent}% priced',
        color: _coverageColor(summary.pricingCoveragePercent),
        icon: Icons.price_check_rounded,
        maxWidth: 140,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for pricing management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PricingSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.pricingCoveragePercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.pricingCoveragePercent),
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
                          for (final entry in overview.entries)
                            SizedBox(
                              width: width,
                              child: _PricingGroupCard(
                                key: ValueKey('product-pricing-${entry.id}'),
                                entry: entry,
                                onSelected: () => onPricingGroupSelected(entry),
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

class _PricingSummaryStrip extends StatelessWidget {
  const _PricingSummaryStrip({required this.summary});

  final ProductPricingManagementSummary summary;

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
              child: _PricingMetric(
                label: 'Price coverage',
                value: summary.coverageLabel,
                icon: Icons.price_check_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _PricingMetric(
                label: 'Margin data',
                value: '${summary.marginCoveragePercent}% costed',
                icon: Icons.request_quote_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _PricingMetric(
                label: 'Pricing risk',
                value: summary.pricingRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _PricingMetric(
                label: 'Average price',
                value: _compactMoney(summary.averageUnitPrice),
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PricingMetric extends StatelessWidget {
  const _PricingMetric({
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

class _PricingGroupCard extends StatelessWidget {
  const _PricingGroupCard({
    super.key,
    required this.entry,
    required this.onSelected,
  });

  final ProductPricingManagementEntry entry;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(entry.status);

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
                Icon(Icons.sell_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: entry.productCountLabel,
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
                  label: entry.issueSummaryLabel,
                  color: entry.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      entry.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 180,
                ),
                AppStatusPill(
                  label: '${entry.pricingCoveragePercent}% priced',
                  color: _coverageColor(entry.pricingCoveragePercent),
                  icon: Icons.price_check_rounded,
                  maxWidth: 132,
                ),
                if (entry.costedProductCount > 0)
                  AppStatusPill(
                    label: '${entry.costedProductCount} costed',
                    color: Colors.blueGrey.shade700,
                    icon: Icons.request_quote_rounded,
                    maxWidth: 124,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${entry.priceRangeLabel} | '
                    '${_compactMoney(entry.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: entry.actionLabel,
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

Color _statusColor(ProductPricingRiskStatus status) {
  switch (status) {
    case ProductPricingRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductPricingRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductPricingRiskStatus.action:
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
