import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/adapters/ecommerce_order_omni_activity_adapter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';

void main() {
  test('ecommerce order maps into omni-channel order activity', () {
    final order = _order(status: 'pending');

    final entry = order.toEcommerceOrderActivity();

    expect(entry.id, 'ecommerce_order_ECOM-1');
    expect(entry.kind, OmniChannelActivityKind.order);
    expect(entry.sourceId, 'ecommerce');
    expect(entry.title, 'Pending order ECOM-1');
    expect(entry.channelId, 'web_store');
    expect(entry.channelLabel, 'Web store');
    expect(entry.fulfillmentModeKey, 'pickup');
    expect(entry.fulfillmentModeLabel, 'Pickup');
    expect(entry.severity, OmniChannelActivitySeverity.review);
    expect(entry.matchesQuery('pickup'), isTrue);
  });

  test('ecommerce order feed highlights cancelled orders as attention', () {
    final feed = ecommerceOrdersToOmniChannelActivityFeed([
      _order(id: 'ECOM-1', status: 'completed'),
      _order(id: 'ECOM-2', status: 'cancelled'),
    ]);

    expect(feed.orderCount, 2);
    expect(feed.attentionCount, 1);
    expect(feed.attentionEntries.single.orderId, 'ECOM-2');
    expect(
      feed.attentionEntries.single.supportSummary,
      'Cancelled order ECOM-2 needs operator review.',
    );
  });
}

Order _order({String id = 'ECOM-1', String status = 'pending'}) {
  return Order(
    id: id,
    items: const [],
    payments: const [],
    terminal: Terminal(
      id: 'web',
      name: 'Storefront',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 6, 1, 11),
    status: status,
    fulfillment: const OrderFulfillmentSnapshot(
      commerceChannelId: 'web_store',
      commerceChannelLabel: 'Web store',
      fulfillmentModeKey: 'pickup',
      fulfillmentModeLabel: 'Pickup',
      summaryLabel: 'Pickup at counter',
    ),
  );
}
