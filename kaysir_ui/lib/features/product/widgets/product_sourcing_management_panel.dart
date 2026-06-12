import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_sourcing_management.dart';

class ProductSourcingManagementPanel extends StatelessWidget {
  const ProductSourcingManagementPanel({
    super.key,
    required this.overview,
    required this.onSupplierSelected,
  });

  final ProductSourcingManagementOverview overview;
  final ValueChanged<ProductSourcingManagementEntry> onSupplierSelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Sourcing management',
      subtitle:
          '${summary.supplierCount} suppliers | '
          '${overview.channelProfile.title} supply readiness',
      leadingIcon: Icons.local_shipping_rounded,
      trailing: AppStatusPill(
        label: '${summary.sourcingCoveragePercent}% assigned',
        color: _coverageColor(summary.sourcingCoveragePercent),
        icon: Icons.assignment_turned_in_rounded,
        maxWidth: 150,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for sourcing management.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SourcingSummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.sourcingCoveragePercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(summary.sourcingCoveragePercent),
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
                          for (final supplier in overview.suppliers)
                            SizedBox(
                              width: width,
                              child: _SupplierCard(
                                key: ValueKey(
                                  'product-sourcing-${supplier.id}',
                                ),
                                supplier: supplier,
                                onSelected: () => onSupplierSelected(supplier),
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

class _SourcingSummaryStrip extends StatelessWidget {
  const _SourcingSummaryStrip({required this.summary});

  final ProductSourcingManagementSummary summary;

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
              child: _SourcingMetric(
                label: 'Supplier coverage',
                value: summary.coverageLabel,
                icon: Icons.assignment_turned_in_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _SourcingMetric(
                label: 'Cost visibility',
                value: '${summary.costCoveragePercent}% costed',
                icon: Icons.request_quote_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _SourcingMetric(
                label: 'Sourcing risk',
                value: summary.sourcingRiskCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _SourcingMetric(
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

class _SourcingMetric extends StatelessWidget {
  const _SourcingMetric({
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

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({
    super.key,
    required this.supplier,
    required this.onSelected,
  });

  final ProductSourcingManagementEntry supplier;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(supplier.status);

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
                Icon(Icons.local_shipping_rounded, color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    supplier.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: supplier.productCountLabel,
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
                  label: supplier.issueSummaryLabel,
                  color: supplier.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      supplier.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 198,
                ),
                AppStatusPill(
                  label: '${supplier.costCoveragePercent}% costed',
                  color: _coverageColor(supplier.costCoveragePercent),
                  icon: Icons.request_quote_rounded,
                  maxWidth: 126,
                ),
                if (supplier.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${supplier.untrackedProductCount} untracked',
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
                    '${_compactMoney(supplier.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: supplier.actionLabel,
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

Color _statusColor(ProductSourcingRiskStatus status) {
  switch (status) {
    case ProductSourcingRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductSourcingRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductSourcingRiskStatus.action:
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
