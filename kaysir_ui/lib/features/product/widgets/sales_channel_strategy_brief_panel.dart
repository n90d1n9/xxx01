import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_channel_launch_priority.dart';
import '../models/sales_channel_profile_readiness.dart';
import '../models/sales_channel_readiness.dart';
import '../models/sales_channel_strategy_brief.dart';

/// Strategy summary panel for the active product sales-channel profile.
class ProductSalesChannelStrategyBriefPanel extends StatelessWidget {
  const ProductSalesChannelStrategyBriefPanel({
    super.key,
    required this.brief,
    this.onPrioritySelected,
  });

  final ProductSalesChannelStrategyBrief brief;
  final ValueChanged<ProductChannelLaunchPriority>? onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _levelColor(brief.summary.level);

    return AppContentPanel(
      title: 'Active strategy',
      subtitle: brief.profile.subtitle,
      leadingIcon: Icons.account_tree_rounded,
      trailing: AppStatusPill(
        label: brief.summary.statusLabel,
        color: statusColor,
        icon: _levelIcon(brief.summary.level),
        maxWidth: 124,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.route_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brief.titleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      brief.profileFocusLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (brief.capabilityLabels.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusPill(
                  label: brief.businessModelLabel,
                  color: colorScheme.primary,
                  icon: Icons.business_center_rounded,
                  maxWidth: 184,
                ),
                for (final capability in brief.capabilityLabels)
                  AppStatusPill(
                    label: capability,
                    color: colorScheme.secondary,
                    showDot: true,
                    maxWidth: 160,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(
            brief.operatorCueLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columnCount =
                  constraints.maxWidth >= 920
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              const gap = 10.0;
              final tileWidth =
                  (constraints.maxWidth - (gap * (columnCount - 1))) /
                  columnCount;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _StrategyBriefMetric(
                      icon: Icons.hub_rounded,
                      label: 'Channels',
                      value: brief.channelCountLabel,
                      detail: brief.channelMixLabel,
                      accent: colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _StrategyBriefMetric(
                      icon: Icons.task_alt_rounded,
                      label: 'Readiness',
                      value: brief.readinessLabel,
                      detail: brief.coverageLabel,
                      accent: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _StrategyBriefMetric(
                      icon: Icons.warning_amber_rounded,
                      label: 'Gaps',
                      value: brief.gapLabel,
                      detail: brief.nextActionLabel,
                      accent: statusColor,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _StrategyBriefMetric(
                      icon: Icons.low_priority_rounded,
                      label: 'Next queue',
                      value: brief.nextQueueLabel,
                      detail: brief.nextActionLabel,
                      accent: Colors.blueGrey.shade700,
                    ),
                  ),
                ],
              );
            },
          ),
          if (brief.primaryPriority != null && onPrioritySelected != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onPrioritySelected!(brief.primaryPriority!),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(brief.actionButtonLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(name: 'Sales channel strategy brief')
Widget productSalesChannelStrategyBriefPanelPreview() {
  final readiness = buildProductSalesChannelReadiness(const []);

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProductSalesChannelStrategyBriefPanel(
          brief: buildProductSalesChannelStrategyBrief(
            profile: defaultProductSalesChannelProfile,
            readiness: readiness,
          ),
          onPrioritySelected: (_) {},
        ),
      ),
    ),
  );
}

/// Compact metric tile used by the channel strategy brief.
class _StrategyBriefMetric extends StatelessWidget {
  const _StrategyBriefMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.05),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _levelIcon(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Icons.priority_high_rounded;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Icons.trending_up_rounded;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Icons.check_rounded;
  }
}

Color _levelColor(ProductSalesChannelProfileReadinessLevel level) {
  switch (level) {
    case ProductSalesChannelProfileReadinessLevel.blocked:
      return Colors.red.shade700;
    case ProductSalesChannelProfileReadinessLevel.improving:
      return Colors.orange.shade700;
    case ProductSalesChannelProfileReadinessLevel.ready:
      return Colors.green.shade700;
  }
}
