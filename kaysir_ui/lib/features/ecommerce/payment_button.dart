import 'package:flutter/material.dart';

import 'order/order.dart';

class PaymentButtons extends StatelessWidget {
  final Function(PaymentMethod) onPaymentSelected;
  final VoidCallback? onExternalSettlementSelected;
  final bool enabled;
  final String? disabledMessage;
  final String? externalSettlementLabel;

  const PaymentButtons({
    super.key,
    required this.onPaymentSelected,
    this.onExternalSettlementSelected,
    this.enabled = true,
    this.disabledMessage,
    this.externalSettlementLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!enabled && disabledMessage != null) ...[
            Text(
              disabledMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (externalSettlementLabel != null)
            ElevatedButton.icon(
              icon: const Icon(Icons.verified_outlined),
              label: Text(externalSettlementLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: enabled ? onExternalSettlementSelected : null,
            )
          else ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              label: const Text('Pay with Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed:
                  enabled ? () => onPaymentSelected(PaymentMethod.card) : null,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_money),
              label: const Text('Pay with Cash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
              onPressed:
                  enabled ? () => onPaymentSelected(PaymentMethod.cash) : null,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.smartphone),
              label: const Text('Mobile Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: theme.colorScheme.onTertiary,
              ),
              onPressed:
                  enabled
                      ? () => onPaymentSelected(PaymentMethod.mobilePay)
                      : null,
            ),
          ],
        ],
      ),
    );
  }
}
