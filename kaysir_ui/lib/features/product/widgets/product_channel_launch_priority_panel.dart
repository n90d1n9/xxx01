import 'package:flutter/material.dart';

import '../../../widgets/ui/app_content_panel.dart';
import '../../../widgets/ui/app_status_pill.dart';
import '../models/product_channel_launch_priority.dart';
import '../models/sales_channel_readiness.dart';

class ProductChannelLaunchPriorityPanel extends StatelessWidget {
  const ProductChannelLaunchPriorityPanel({
    super.key,
    required this.priorities,
    required this.onSelected,
  });

  final List<ProductChannelLaunchPriority> priorities;
  final ValueChanged<ProductChannelLaunchPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppContentPanel(
      title: 'Launch priorities',
      subtitle:
          priorities.isEmpty
              ? 'No channels are enabled for this profile'
              : 'Ranked channel work from the active product profile',
      leadingIcon: Icons.rocket_launch_rounded,
      child:
          priorities.isEmpty
              ? const Text('Enable a channel profile to see launch priorities.')
              : LayoutBuilder(
                builder: (context, constraints) {
                  final columnCount =
                      constraints.maxWidth >= 980
                          ? 3
                          : constraints.maxWidth >= 620
                          ? 2
                          : 1;
                  const gap = 12.0;
                  final cardWidth =
                      (constraints.maxWidth - (gap * (columnCount - 1))) /
                      columnCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (var index = 0; index < priorities.length; index += 1)
                        SizedBox(
                          width: cardWidth,
                          child: _LaunchPriorityCard(
                            priority: priorities[index],
                            rank: index + 1,
                            onPressed: () => onSelected(priorities[index]),
                          ),
                        ),
                    ],
                  );
                },
              ),
    );
  }
}

class _LaunchPriorityCard extends StatelessWidget {
  const _LaunchPriorityCard({
    required this.priority,
    required this.rank,
    required this.onPressed,
  });

  final ProductChannelLaunchPriority priority;
  final int rank;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = _channelAccent(priority.readiness.channel);
    final statusColor = _levelColor(priority.level);

    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            priority.hasIssues
                ? accent.withValues(alpha: 0.05)
                : colorScheme.surface,
        border: Border.all(
          color:
              priority.hasIssues
                  ? accent.withValues(alpha: 0.26)
                  : colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          height: 174,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#$rank',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _channelIcon(priority.readiness.channel),
                              color: accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    AppStatusPill(
                      label: priority.statusLabel,
                      color: statusColor,
                      icon: _levelIcon(priority.level),
                      maxWidth: 96,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  priority.readiness.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  priority.actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priority.impactLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: priority.readiness.readyPercent / 100,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priority.blockedProductLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _channelIcon(ProductSalesChannel channel) {
  switch (channel) {
    case ProductSalesChannel.posCheckout:
      return Icons.point_of_sale_rounded;
    case ProductSalesChannel.onlineStore:
      return Icons.language_rounded;
    case ProductSalesChannel.marketplace:
      return Icons.storefront_rounded;
    case ProductSalesChannel.kiosk:
      return Icons.qr_code_scanner_rounded;
  }
}

IconData _levelIcon(ProductChannelLaunchPriorityLevel level) {
  switch (level) {
    case ProductChannelLaunchPriorityLevel.blocked:
      return Icons.priority_high_rounded;
    case ProductChannelLaunchPriorityLevel.improving:
      return Icons.trending_up_rounded;
    case ProductChannelLaunchPriorityLevel.ready:
      return Icons.check_rounded;
  }
}

Color _channelAccent(ProductSalesChannel channel) {
  switch (channel) {
    case ProductSalesChannel.posCheckout:
      return Colors.teal.shade700;
    case ProductSalesChannel.onlineStore:
      return Colors.blue.shade700;
    case ProductSalesChannel.marketplace:
      return Colors.deepPurple.shade600;
    case ProductSalesChannel.kiosk:
      return Colors.indigo.shade700;
  }
}

Color _levelColor(ProductChannelLaunchPriorityLevel level) {
  switch (level) {
    case ProductChannelLaunchPriorityLevel.blocked:
      return Colors.red.shade700;
    case ProductChannelLaunchPriorityLevel.improving:
      return Colors.orange.shade700;
    case ProductChannelLaunchPriorityLevel.ready:
      return Colors.green.shade700;
  }
}
