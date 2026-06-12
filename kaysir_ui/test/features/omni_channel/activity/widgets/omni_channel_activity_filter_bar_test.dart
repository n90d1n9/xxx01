import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_scope.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_filter_bar.dart';

void main() {
  testWidgets(
    'omni-channel activity filter bar changes source, channel, and fulfillment scopes',
    (tester) async {
      var filter = const OmniChannelActivityFilter();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder:
                  (context, setState) => SingleChildScrollView(
                    child: OmniChannelActivityFilterBar(
                      filter: filter,
                      counts: _counts(),
                      scopeOptions: _scopeOptions(),
                      onFilterChanged:
                          (value) => setState(() => filter = value),
                    ),
                  ),
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(
          const ValueKey('omni-channel-activity-source-scope-point_of_sales'),
        ),
      );
      await tester.pump();

      expect(filter.sourceId, 'point_of_sales');
      expect(filter.channelId, isNull);

      await tester.tap(
        find.byKey(
          const ValueKey('omni-channel-activity-channel-scope-marketplace'),
        ),
      );
      await tester.pump();

      expect(filter.sourceId, 'point_of_sales');
      expect(filter.channelId, 'marketplace');

      await tester.tap(
        find.byKey(
          const ValueKey('omni-channel-activity-fulfillment-scope-pickup'),
        ),
      );
      await tester.pump();

      expect(filter.sourceId, 'point_of_sales');
      expect(filter.channelId, 'marketplace');
      expect(filter.fulfillmentModeKey, 'pickup');

      await tester.tap(
        find.byKey(const ValueKey('omni-channel-activity-source-scope-all')),
      );
      await tester.pump();

      expect(filter.sourceId, isNull);
      expect(filter.channelId, 'marketplace');
      expect(filter.fulfillmentModeKey, 'pickup');
      expect(tester.takeException(), isNull);
    },
  );
}

OmniChannelActivityFilterCounts _counts() {
  return const OmniChannelActivityFilterCounts(
    all: 4,
    attention: 1,
    review: 1,
    orders: 2,
    orderSync: 1,
    channelSwitches: 0,
    switchActions: 0,
    fulfillment: 0,
    payments: 1,
    system: 0,
  );
}

OmniChannelActivityScopeOptions _scopeOptions() {
  return const OmniChannelActivityScopeOptions(
    sources: [
      OmniChannelActivityScopeOption(
        id: 'ecommerce',
        label: 'Ecommerce',
        count: 3,
      ),
      OmniChannelActivityScopeOption(
        id: 'point_of_sales',
        label: 'Point of sale',
        count: 1,
      ),
    ],
    channels: [
      OmniChannelActivityScopeOption(
        id: 'marketplace',
        label: 'Marketplace',
        count: 2,
      ),
      OmniChannelActivityScopeOption(
        id: 'web_store',
        label: 'Web store',
        count: 1,
      ),
    ],
    fulfillmentModes: [
      OmniChannelActivityScopeOption(id: 'pickup', label: 'Pickup', count: 2),
      OmniChannelActivityScopeOption(
        id: 'delivery',
        label: 'Delivery',
        count: 1,
      ),
    ],
  );
}
