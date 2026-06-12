import 'package:flutter/material.dart';

import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../../order/models/order.dart';

class PaymentSummaryPanel extends StatelessWidget {
  final Order order;

  const PaymentSummaryPanel({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return POSSurface(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      border: Border.all(color: theme.dividerColor),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(child: _PaymentMetric(label: 'Total', value: order.total)),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: _PaymentMetric(label: 'Paid', value: order.paidAmount),
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: _PaymentMetric(
              label: 'Remaining',
              value: order.remainingAmount,
              emphasized: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMetric extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;

  const _PaymentMetric({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatPOSCurrency(value),
            style: theme.textTheme.titleMedium?.copyWith(
              color: emphasized ? theme.colorScheme.primary : null,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
