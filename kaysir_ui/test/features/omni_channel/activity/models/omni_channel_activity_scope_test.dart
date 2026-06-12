import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_scope.dart';

void main() {
  test(
    'omni-channel activity scope options summarize source and channel facets',
    () {
      final options = _feed().scopeOptionsFor(
        const OmniChannelActivityFilter(query: 'web'),
      );

      expect(
        options.sources.map((option) => '${option.label}:${option.count}'),
        ['Ecommerce:1', 'Point of sale:1'],
      );
      expect(
        options.channels.map((option) => '${option.label}:${option.count}'),
        ['Web store:2'],
      );
      expect(
        options.fulfillmentModes.map(
          (option) => '${option.label}:${option.count}',
        ),
        ['Pickup:1'],
      );
    },
  );

  test(
    'omni-channel activity scope options keep other selected dimensions',
    () {
      final options = _feed().scopeOptionsFor(
        const OmniChannelActivityFilter(
          status: OmniChannelActivityFilterStatus.orders,
          sourceId: 'ecommerce',
        ),
      );

      expect(options.sources.map((option) => option.id), ['ecommerce']);
      expect(options.channels.map((option) => '${option.id}:${option.count}'), [
        'marketplace:1',
        'web_store:1',
      ]);
      expect(
        options.fulfillmentModes.map(
          (option) => '${option.id}:${option.count}',
        ),
        ['delivery:1', 'pickup:1'],
      );
    },
  );
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
        title: 'Pending web order',
        detail: 'Web store / Pickup / Paid.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
      OmniChannelActivityEntry(
        id: 'order_2',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 1, 9),
        title: 'Marketplace pickup',
        detail: 'Marketplace pickup needs review.',
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-2',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
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
        channelLabel: 'Web store',
        orderId: 'ECOM-1',
      ),
    ],
  );
}
