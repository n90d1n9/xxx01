import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_availability_management.dart';

class ProductAvailabilityManagementPanel extends StatelessWidget {
  const ProductAvailabilityManagementPanel({
    super.key,
    required this.overview,
    required this.onRuleSelected,
  });

  final ProductAvailabilityManagementOverview overview;
  final ValueChanged<ProductAvailabilityManagementEntry> onRuleSelected;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;

    return AppContentPanel(
      title: 'Availability rules',
      subtitle:
          '${summary.availabilityRuleTypeCount} rule types | '
          '${overview.channelProfile.title} sellable coverage',
      leadingIcon: Icons.event_available_rounded,
      trailing: AppStatusPill(
        label: '${summary.availabilityReadinessPercent}% ready',
        color: _coverageColor(summary.availabilityReadinessPercent),
        icon: Icons.rule_rounded,
        maxWidth: 150,
      ),
      child:
          summary.productCount == 0
              ? const Text('No products available for availability rules.')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AvailabilitySummaryStrip(summary: summary),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: summary.availabilityReadinessPercent / 100,
                      minHeight: 8,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      color: _coverageColor(
                        summary.availabilityReadinessPercent,
                      ),
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
                          for (final rule in overview.rules)
                            SizedBox(
                              width: width,
                              child: _AvailabilityRuleCard(
                                key: ValueKey(
                                  'product-availability-${rule.id}',
                                ),
                                rule: rule,
                                onSelected: () => onRuleSelected(rule),
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

class _AvailabilitySummaryStrip extends StatelessWidget {
  const _AvailabilitySummaryStrip({required this.summary});

  final ProductAvailabilityManagementSummary summary;

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
              child: _AvailabilityMetric(
                label: 'Availability coverage',
                value: summary.coverageLabel,
                icon: Icons.event_available_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AvailabilityMetric(
                label: 'Rule readiness',
                value: '${summary.availabilityReadinessPercent}% ready',
                icon: Icons.rule_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AvailabilityMetric(
                label: 'Availability risk',
                value: summary.availabilityRiskProductCount.toString(),
                icon: Icons.warning_amber_rounded,
              ),
            ),
            SizedBox(
              width: width,
              child: _AvailabilityMetric(
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

class _AvailabilityMetric extends StatelessWidget {
  const _AvailabilityMetric({
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

class _AvailabilityRuleCard extends StatelessWidget {
  const _AvailabilityRuleCard({
    super.key,
    required this.rule,
    required this.onSelected,
  });

  final ProductAvailabilityManagementEntry rule;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _statusColor(rule.status);

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
                Icon(_availabilityIcon(rule.type), color: accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rule.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppStatusPill(
                  label: rule.productCountLabel,
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
                  label: rule.issueSummaryLabel,
                  color: rule.hasRisk ? Colors.orange.shade700 : accent,
                  icon:
                      rule.hasRisk
                          ? Icons.warning_amber_rounded
                          : Icons.check_rounded,
                  maxWidth: 210,
                ),
                AppStatusPill(
                  label: rule.ruleCountLabel,
                  color:
                      rule.type == ProductAvailabilityRuleType.unconfigured
                          ? Colors.red.shade700
                          : accent,
                  icon: Icons.rule_rounded,
                  maxWidth: 126,
                ),
                if (rule.untrackedProductCount > 0)
                  AppStatusPill(
                    label: '${rule.untrackedProductCount} untracked',
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
                    '${rule.ruleCount} rules | '
                    '${_compactMoney(rule.totalInventoryValue)} value',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AppActionButton(
                  label: rule.actionLabel,
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

IconData _availabilityIcon(ProductAvailabilityRuleType type) {
  switch (type) {
    case ProductAvailabilityRuleType.unconfigured:
      return Icons.rule_rounded;
    case ProductAvailabilityRuleType.channelAccess:
      return Icons.storefront_rounded;
    case ProductAvailabilityRuleType.salesStatus:
      return Icons.visibility_rounded;
    case ProductAvailabilityRuleType.stockPolicy:
      return Icons.inventory_2_rounded;
    case ProductAvailabilityRuleType.scheduleWindow:
      return Icons.schedule_rounded;
    case ProductAvailabilityRuleType.fulfillmentMode:
      return Icons.local_shipping_rounded;
  }
}

Color _statusColor(ProductAvailabilityRiskStatus status) {
  switch (status) {
    case ProductAvailabilityRiskStatus.healthy:
      return Colors.green.shade700;
    case ProductAvailabilityRiskStatus.watch:
      return Colors.orange.shade700;
    case ProductAvailabilityRiskStatus.action:
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
