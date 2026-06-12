import 'package:flutter/material.dart';

import '../../order/models/order.dart';
import '../../order/utils/order_display.dart';
import 'pos_ui.dart';

typedef POSSwitchOrderContextLabelsBuilder =
    Iterable<String> Function(Order order);

class POSSwitchOrderContextBanner extends StatelessWidget {
  final Order? order;
  final String title;
  final IconData icon;
  final POSSwitchOrderContextLabelsBuilder? labelsBuilder;

  const POSSwitchOrderContextBanner({
    super.key,
    required this.order,
    this.title = 'Active order',
    this.icon = Icons.receipt_long_outlined,
    this.labelsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final order = this.order;
    if (order == null || order.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final labels = _labelsFor(order);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(color: colorScheme.tertiary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (labels.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final label in labels)
                        _OrderContextPill(label: label),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _labelsFor(Order order) {
    final labels =
        labelsBuilder?.call(order) ??
        [posOrderSwitchSummary(order), posOrderReadinessLabel(order)];

    return [
      for (final label in labels)
        if (label.trim().isNotEmpty) label,
    ];
  }
}

class _OrderContextPill extends StatelessWidget {
  final String label;

  const _OrderContextPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
