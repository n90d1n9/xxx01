import 'package:flutter/material.dart';

import '../../cashier/experiences/pos_checkout_behavior.dart';
import '../../cashier/experiences/pos_order_fulfillment.dart';
import '../../cashier/utils/pos_formatters.dart';
import '../../cashier/widgets/pos_ui.dart';
import '../models/order.dart';
import '../utils/order_display.dart';

class OrderCheckoutPanel extends StatelessWidget {
  final Order order;
  final VoidCallback onShowPromotions;
  final VoidCallback onShowPayment;
  final Future<void> Function() onCompleteOrder;
  final POSCheckoutBehavior checkoutBehavior;
  final POSOrderFulfillmentReadiness? fulfillmentReadiness;
  final bool showPromotionAction;
  final bool showPaymentAction;

  const OrderCheckoutPanel({
    super.key,
    required this.order,
    required this.onShowPromotions,
    required this.onShowPayment,
    required this.onCompleteOrder,
    this.checkoutBehavior = POSCheckoutBehavior.standard,
    this.fulfillmentReadiness,
    this.showPromotionAction = true,
    this.showPaymentAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readiness = resolvePOSOrderReadiness(order);
    final fulfillmentReady = fulfillmentReadiness?.canComplete ?? true;
    final showPromoButton =
        showPromotionAction && order.appliedPromotions.isEmpty;
    final showPaymentButton = showPaymentAction;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CheckoutStatus(
            order: order,
            readiness: readiness,
            checkoutBehavior: checkoutBehavior,
            fulfillmentReadiness: fulfillmentReadiness,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          _AmountRow(label: 'Subtotal', value: order.subtotal),
          if (order.discountTotal > 0)
            _AmountRow(
              label: 'Discount',
              value: -order.discountTotal,
              color: theme.colorScheme.error,
            ),
          const SizedBox(height: POSUiTokens.gap),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: POSUiTokens.gap),
          _AmountRow(label: 'Total', value: order.total, emphasized: true),
          if (order.paidAmount > 0) ...[
            const SizedBox(height: POSUiTokens.gap),
            _AmountRow(
              label: 'Paid',
              value: order.paidAmount,
              color: theme.colorScheme.tertiary,
            ),
            _AmountRow(
              label: order.remainingAmount > 0 ? 'Balance' : 'Change',
              value: order.remainingAmount,
              color:
                  order.remainingAmount > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.tertiary,
            ),
          ],
          if (showPromoButton || showPaymentButton) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                if (showPromoButton) ...[
                  Expanded(
                    child: POSActionButton(
                      icon: const Icon(Icons.discount_outlined),
                      label: 'Promos',
                      onPressed: onShowPromotions,
                    ),
                  ),
                  if (showPaymentButton) const SizedBox(width: POSUiTokens.gap),
                ],
                if (showPaymentButton)
                  Expanded(
                    flex: 2,
                    child: POSActionButton(
                      icon: const Icon(Icons.payments_outlined),
                      label: checkoutBehavior.paymentButtonLabel,
                      variant: POSActionButtonVariant.tonal,
                      onPressed: order.items.isEmpty ? null : onShowPayment,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: POSUiTokens.gap),
          SizedBox(
            width: double.infinity,
            child: POSActionButton(
              icon: const Icon(Icons.check_circle_outline),
              label: checkoutBehavior.completeButtonLabel,
              variant: POSActionButtonVariant.filled,
              onPressed:
                  order.isPaid && fulfillmentReady
                      ? () => onCompleteOrder()
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutStatus extends StatelessWidget {
  final Order order;
  final POSOrderReadiness readiness;
  final POSCheckoutBehavior checkoutBehavior;
  final POSOrderFulfillmentReadiness? fulfillmentReadiness;

  const _CheckoutStatus({
    required this.order,
    required this.readiness,
    required this.checkoutBehavior,
    required this.fulfillmentReadiness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fulfillmentBlocked =
        order.isPaid && !(fulfillmentReadiness?.canComplete ?? true);
    final foreground = switch (readiness) {
      POSOrderReadiness.empty => theme.colorScheme.onSurfaceVariant,
      POSOrderReadiness.needsPayment => theme.colorScheme.error,
      POSOrderReadiness.readyToComplete =>
        fulfillmentBlocked
            ? theme.colorScheme.error
            : theme.colorScheme.tertiary,
    };
    final background = switch (readiness) {
      POSOrderReadiness.empty => theme.colorScheme.surfaceContainerHighest,
      POSOrderReadiness.needsPayment => theme.colorScheme.errorContainer
          .withValues(alpha: 0.24),
      POSOrderReadiness.readyToComplete => theme.colorScheme.tertiaryContainer
          .withValues(alpha: fulfillmentBlocked ? 0 : 0.30),
    };
    final effectiveBackground =
        fulfillmentBlocked
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.24)
            : background;
    final statusLabel =
        fulfillmentBlocked
            ? fulfillmentReadiness!.statusLabel
            : checkoutBehavior.readinessLabel(order);

    return POSSurface(
      color: effectiveBackground,
      border: Border.all(color: foreground.withValues(alpha: 0.18)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Icon(_statusIcon(readiness), size: 18, color: foreground),
          const SizedBox(width: POSUiTokens.gap),
          Expanded(
            child: Text(
              statusLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (readiness == POSOrderReadiness.needsPayment)
            Text(
              formatPOSCurrency(order.remainingAmount),
              style: theme.textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  IconData _statusIcon(POSOrderReadiness readiness) {
    switch (readiness) {
      case POSOrderReadiness.empty:
        return Icons.add_shopping_cart_outlined;
      case POSOrderReadiness.needsPayment:
        return Icons.timelapse_outlined;
      case POSOrderReadiness.readyToComplete:
        return Icons.verified_outlined;
    }
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool emphasized;
  final Color? color;

  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style =
        emphasized ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: style?.copyWith(
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
              color:
                  emphasized
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            formatPOSCurrency(value),
            style: style?.copyWith(
              color: color ?? (emphasized ? theme.colorScheme.primary : null),
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
