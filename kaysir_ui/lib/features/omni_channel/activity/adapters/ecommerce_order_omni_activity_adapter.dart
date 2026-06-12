import '../../../ecommerce/order/models/order_status.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../models/omni_channel_activity.dart';

extension EcommerceOrderOmniActivityAdapter on pos_order.Order {
  OmniChannelActivityEntry toEcommerceOrderActivity() {
    final status = ecommerceOrderStatusFor(this.status);
    final fulfillment = this.fulfillment;
    final channelLabel = fulfillment?.commerceChannelLabel.trim();
    final fulfillmentLabel = fulfillment?.fulfillmentModeLabel.trim();
    final channel =
        channelLabel == null || channelLabel.isEmpty ? 'Online' : channelLabel;
    final fulfillmentMode =
        fulfillmentLabel == null || fulfillmentLabel.isEmpty
            ? 'Standard fulfillment'
            : fulfillmentLabel;

    return OmniChannelActivityEntry(
      id: 'ecommerce_order_$id',
      kind: OmniChannelActivityKind.order,
      sourceId: 'ecommerce',
      sourceLabel: 'Ecommerce',
      occurredAt: createdAt,
      title: '${status.label} order $id',
      detail: '$channel / $fulfillmentMode / ${_paymentLabel(this)}.',
      severity: _severityFor(status.tone),
      channelId: fulfillment?.commerceChannelId,
      channelLabel: channel,
      orderId: id,
      fulfillmentModeKey: fulfillment?.fulfillmentModeKey,
      fulfillmentModeLabel: fulfillmentMode,
      supportSummary:
          status.tone == OrderStatusTone.danger
              ? '${status.label} order $id needs operator review.'
              : null,
      searchTerms: [
        'ecommerce',
        'online order',
        status.value,
        status.label,
        channel,
        fulfillmentMode,
        customer?.name ?? '',
        terminal.name,
      ],
      attributes: {
        'status': status.value,
        'payment': isPaid ? 'paid' : 'payment_due',
        'itemCount': items.length.toString(),
      },
    );
  }
}

OmniChannelActivityFeed ecommerceOrdersToOmniChannelActivityFeed(
  Iterable<pos_order.Order> orders, {
  Iterable<OmniChannelActivityEntry> additionalEntries = const [],
}) {
  return OmniChannelActivityFeed(
    entries: [
      for (final order in orders) order.toEcommerceOrderActivity(),
      ...additionalEntries,
    ],
  );
}

OmniChannelActivitySeverity _severityFor(OrderStatusTone tone) {
  switch (tone) {
    case OrderStatusTone.danger:
      return OmniChannelActivitySeverity.attention;
    case OrderStatusTone.warning:
    case OrderStatusTone.neutral:
      return OmniChannelActivitySeverity.review;
    case OrderStatusTone.progress:
    case OrderStatusTone.ready:
    case OrderStatusTone.success:
      return OmniChannelActivitySeverity.ready;
  }
}

String _paymentLabel(pos_order.Order order) {
  if (order.isPaid) return 'Paid';
  return 'Payment due ${order.remainingAmount.toStringAsFixed(2)}';
}
