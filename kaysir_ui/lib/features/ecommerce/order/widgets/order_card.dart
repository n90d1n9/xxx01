import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../point_of_sales/cashier/utils/pos_formatters.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/order_attention.dart';
import '../models/order_insights.dart';
import '../models/order_lifecycle.dart';
import 'order_attention_panel.dart';
import 'order_financial_summary_panel.dart';
import 'order_fulfillment_detail_grid.dart';
import 'order_lifecycle_timeline.dart';
import 'order_status_controls.dart';

class OrderCard extends StatelessWidget {
  final pos_order.Order order;
  final ValueChanged<String> onStatusChanged;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusChanged,
  });

  String _getPaymentMethodString(pos_order.Order order) {
    if (order.payments.isEmpty) return 'Unpaid';
    return order.payments.last.method;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final theme = Theme.of(context);
    final fulfillment = order.fulfillment;
    final paymentMethod = _getPaymentMethodString(order);
    final lifecyclePolicy = ecommerceOrderLifecyclePolicyFor(order);
    final lifecycleSteps = lifecyclePolicy.timelineFor(order.status);
    final statusActions = ecommerceOrderAvailableStatusActions(order);
    final attentionSignals = ecommerceOrderAttentionSignals(order);

    return Padding(
      padding: const EdgeInsets.only(bottom: POSUiTokens.gapLarge),
      child: POSSurface(
        border: Border.all(color: theme.dividerColor),
        elevated: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(POSUiTokens.radius),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            title: Text(
              order.id,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: POSUiTokens.gap,
                runSpacing: 6,
                children: [
                  _MetaPill(
                    icon: Icons.schedule_outlined,
                    label: dateFormat.format(order.createdAt),
                  ),
                  _MetaPill(
                    icon:
                        orderUsesExternalSettlement(order)
                            ? Icons.hub_outlined
                            : Icons.payments_outlined,
                    label: paymentMethod,
                  ),
                  if (fulfillment != null)
                    _MetaPill(
                      icon: _channelIcon(fulfillment.commerceChannelId),
                      label: fulfillment.commerceChannelLabel,
                    ),
                ],
              ),
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 138),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OrderStatusBadge(status: order.status),
                  const SizedBox(height: 4),
                  Text(
                    formatPOSCurrency(order.total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fulfillment != null) ...[
                    _FulfillmentSummary(order: order),
                    const SizedBox(height: POSUiTokens.gapLarge),
                  ],
                  const Text(
                    'Order Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Text('${item.quantity}x'),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item.product.name)),
                          Text(formatPOSCurrency(item.total)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  OrderFinancialSummaryPanel(order: order),
                  const SizedBox(height: 16),
                  OrderLifecycleTimeline(
                    label: lifecyclePolicy.label,
                    steps: lifecycleSteps,
                  ),
                  if (attentionSignals.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    OrderAttentionPanel(signals: attentionSignals),
                  ],
                  if (statusActions.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Next Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OrderStatusActionStrip(
                      actions: statusActions,
                      onChanged: onStatusChanged,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _channelIcon(String channelId) {
    return switch (channelId) {
      'marketplace' => Icons.store_mall_directory_outlined,
      'delivery_app' => Icons.delivery_dining_outlined,
      'social_order' => Icons.chat_bubble_outline,
      'phone_order' => Icons.call_outlined,
      'wholesale' => Icons.warehouse_outlined,
      'web_store' => Icons.language_outlined,
      _ => Icons.hub_outlined,
    };
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentSummary extends StatelessWidget {
  final pos_order.Order order;

  const _FulfillmentSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fulfillment = order.fulfillment;
    if (fulfillment == null) return const SizedBox.shrink();

    return POSSurface(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.38),
      child: Row(
        children: [
          POSIconBadge(
            icon: Icons.local_shipping_outlined,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: POSUiTokens.gapLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fulfillment.commerceChannelLabel} • ${fulfillment.fulfillmentModeLabel}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fulfillment.summaryLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: POSUiTokens.gap),
                OrderFulfillmentDetailGrid(fulfillment: fulfillment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
