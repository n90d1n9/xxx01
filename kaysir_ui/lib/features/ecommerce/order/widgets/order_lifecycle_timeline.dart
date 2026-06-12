import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/order_lifecycle.dart';
import 'order_status_controls.dart';

class OrderLifecycleTimeline extends StatelessWidget {
  final String label;
  final List<OrderLifecycleStep> steps;

  const OrderLifecycleTimeline({
    super.key,
    required this.label,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 17,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Text(
                  'Fulfillment progress',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          Wrap(
            spacing: POSUiTokens.gap,
            runSpacing: POSUiTokens.gap,
            children:
                steps.map((step) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 132,
                      maxWidth: 190,
                    ),
                    child: _LifecycleStepTile(step: step),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LifecycleStepTile extends StatelessWidget {
  final OrderLifecycleStep step;

  const _LifecycleStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _stepColor(context);
    final isMuted = step.state == OrderLifecycleStepState.upcoming;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isMuted ? 0.05 : 0.1),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
        border: Border.all(
          color: color.withValues(alpha: isMuted ? 0.14 : 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_stepIcon(), size: 18, color: color),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isMuted ? theme.colorScheme.onSurfaceVariant : color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    step.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _stepColor(BuildContext context) {
    return switch (step.state) {
      OrderLifecycleStepState.completed => Colors.green,
      OrderLifecycleStepState.current => ecommerceOrderStatusToneColor(
        context,
        step.tone,
      ),
      OrderLifecycleStepState.upcoming => Theme.of(context).colorScheme.outline,
    };
  }

  IconData _stepIcon() {
    return switch (step.state) {
      OrderLifecycleStepState.completed => Icons.check_circle_outline,
      OrderLifecycleStepState.current => Icons.radio_button_checked_outlined,
      OrderLifecycleStepState.upcoming => Icons.circle_outlined,
    };
  }
}
