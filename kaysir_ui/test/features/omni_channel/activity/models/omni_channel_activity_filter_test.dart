import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';

void main() {
  test('omni-channel activity filter searches and scopes entries', () {
    final feed = _feed();

    final filter = const OmniChannelActivityFilter(
      query: 'pickup',
      sourceId: 'ecommerce',
      channelId: 'web_store',
      fulfillmentModeKey: 'pickup',
      status: OmniChannelActivityFilterStatus.orders,
    );

    final entries = feed.apply(filter);

    expect(filter.hasConstraints, isTrue);
    expect(entries.map((entry) => entry.id), ['order_1']);
  });

  test('omni-channel activity filter counts respect query and context', () {
    final feed = _feed();

    final counts = feed.countsFor(
      const OmniChannelActivityFilter(query: 'web', channelId: 'web_store'),
    );

    expect(counts.all, 2);
    expect(counts.orders, 1);
    expect(counts.orderSync, 1);
    expect(counts.attention, 1);
    expect(counts.countFor(OmniChannelActivityFilterStatus.orders), 1);
    expect(counts.countFor(OmniChannelActivityFilterStatus.orderSync), 1);
  });

  test('omni-channel activity filter copyWith can clear scoped ids', () {
    const filter = OmniChannelActivityFilter(
      query: 'web',
      status: OmniChannelActivityFilterStatus.attention,
      sourceId: 'ecommerce',
      channelId: 'web_store',
      orderId: 'ECOM-1',
      fulfillmentModeKey: 'pickup',
    );

    final next = filter.copyWith(
      query: '',
      status: OmniChannelActivityFilterStatus.all,
      clearSourceId: true,
      clearChannelId: true,
      clearOrderId: true,
      clearFulfillmentModeKey: true,
    );

    expect(next.hasConstraints, isFalse);
    expect(next.sourceId, isNull);
    expect(next.channelId, isNull);
    expect(next.orderId, isNull);
    expect(next.fulfillmentModeKey, isNull);
    expect(next, const OmniChannelActivityFilter());
  });
}

OmniChannelActivityFeed _feed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'order_1',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 1, 10),
        title: 'Pending order ECOM-1',
        detail: 'Web store / Pickup / Paid.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'web_store',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
      OmniChannelActivityEntry(
        id: 'sync_1',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 1, 11),
        title: 'Web order sync failed',
        detail: 'Network down.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'web_store',
        orderId: 'ECOM-1',
      ),
      OmniChannelActivityEntry(
        id: 'switch_1',
        kind: OmniChannelActivityKind.switchAction,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 1, 12),
        title: 'Blocked Runtime pack: No Payment Pack',
        detail: 'Finish current order first.',
        severity: OmniChannelActivitySeverity.attention,
      ),
    ],
  );
}
