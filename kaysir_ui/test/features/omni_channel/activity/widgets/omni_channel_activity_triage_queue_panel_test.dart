import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_triage.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_triage_queue_panel.dart';

void main() {
  testWidgets('omni-channel activity triage queue panel selects groups', (
    tester,
  ) async {
    OmniChannelActivityTriageGroup? selectedGroup;
    final queue = _feed().triageQueueFor(const OmniChannelActivityFilter());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityTriageQueuePanel(
              queue: queue,
              onGroupSelected: (group) => selectedGroup = group,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Triage queue'), findsOneWidget);
    expect(find.text('Focus on Point of sale'), findsWidgets);
    expect(find.text('2 attentions across source queue.'), findsOneWidget);
    expect(find.text('Open source queue'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Channel / 1 attention / 1 review'), findsOneWidget);
    expect(find.text('Pickup'), findsOneWidget);
    expect(find.text('Fulfillment / 1 review'), findsOneWidget);
    expect(find.text('Point of sale'), findsOneWidget);
    expect(find.text('2 attentions'), findsOneWidget);
    expect(find.text('2 reviews'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('omni-channel-activity-triage-open-focus')),
    );
    await tester.pump();

    expect(selectedGroup?.dimension, OmniChannelActivityTriageDimension.source);
    expect(selectedGroup?.id, 'point_of_sales');

    selectedGroup = null;

    await tester.tap(
      find.byKey(
        const ValueKey('omni-channel-activity-triage-channel-marketplace'),
      ),
    );
    await tester.pump();

    expect(
      selectedGroup?.dimension,
      OmniChannelActivityTriageDimension.channel,
    );
    expect(selectedGroup?.id, 'marketplace');
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity triage queue panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OmniChannelActivityTriageQueuePanel(
            queue: OmniChannelActivityTriageQueue.empty(),
          ),
        ),
      ),
    );

    expect(find.text('All queues clear'), findsOneWidget);
    expect(find.text('Triage queue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('omni-channel activity triage queue panel shows hidden queues', (
    tester,
  ) async {
    bool? expanded;
    final queue = _feed().triageQueueFor(
      const OmniChannelActivityFilter(),
      limit: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OmniChannelActivityTriageQueuePanel(
              queue: queue,
              onExpandedChanged: (value) => expanded = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('4 more queues available'), findsOneWidget);
    expect(find.text('Point of sale'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Ecommerce'), findsNothing);

    final toggle = find.byKey(
      const ValueKey('omni-channel-activity-triage-toggle-expanded'),
    );
    expect(find.text('Show all 6 queues'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pump();

    expect(expanded, isTrue);
    expect(tester.takeException(), isNull);
  });
}

OmniChannelActivityFeed _feed() {
  return OmniChannelActivityFeed(
    entries: [
      OmniChannelActivityEntry(
        id: 'pos-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 12),
        title: 'POS sync failed',
        detail: 'Marketplace order failed to sync.',
        severity: OmniChannelActivitySeverity.attention,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-1',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 11),
        title: 'Marketplace pickup review',
        detail: 'Pickup capacity needs review.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'marketplace',
        channelLabel: 'Marketplace',
        orderId: 'ECOM-1',
      ),
      OmniChannelActivityEntry(
        id: 'ecommerce-review-2',
        kind: OmniChannelActivityKind.fulfillment,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 9, 10),
        title: 'Web handoff review',
        detail: 'Courier handoff needs review.',
        severity: OmniChannelActivitySeverity.review,
        channelId: 'web_store',
        channelLabel: 'Web store',
        orderId: 'ECOM-2',
        fulfillmentModeKey: 'delivery',
        fulfillmentModeLabel: 'Delivery',
      ),
      OmniChannelActivityEntry(
        id: 'pos-switch',
        kind: OmniChannelActivityKind.switchAction,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9, 9),
        title: 'Runtime pack blocked',
        detail: 'Switch action needs attention.',
        severity: OmniChannelActivitySeverity.attention,
      ),
    ],
  );
}
