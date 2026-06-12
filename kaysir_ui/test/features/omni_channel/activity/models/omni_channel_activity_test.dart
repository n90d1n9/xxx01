import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';

void main() {
  test('omni-channel activity feed sorts and summarizes entries', () {
    final feed = OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'older',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 1, 9),
          title: 'Pending order',
          detail: 'Online order.',
          severity: OmniChannelActivitySeverity.review,
          channelId: 'web_store',
          orderId: 'order_1',
        ),
        OmniChannelActivityEntry(
          id: 'newer',
          kind: OmniChannelActivityKind.orderSync,
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sales',
          occurredAt: DateTime(2026, 6, 1, 10),
          title: 'Sync failed',
          detail: 'Network down.',
          severity: OmniChannelActivitySeverity.attention,
          channelId: 'web_store',
          orderId: 'order_1',
        ),
      ],
    );

    expect(feed.entries.map((entry) => entry.id), ['newer', 'older']);
    expect(feed.orderCount, 1);
    expect(feed.orderSyncCount, 1);
    expect(feed.reviewCount, 1);
    expect(feed.attentionCount, 1);
    expect(feed.forOrder('order_1'), hasLength(2));
    expect(feed.forChannel('web_store'), hasLength(2));
    expect(feed.search('network'), hasLength(1));
  });
}
