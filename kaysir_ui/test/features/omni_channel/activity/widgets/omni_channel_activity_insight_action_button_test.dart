import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_center_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_insight_action_button.dart';

void main() {
  testWidgets('omni-channel activity insight action opens focused location', (
    tester,
  ) async {
    String? openedLocation;
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'sync-failed',
            kind: OmniChannelActivityKind.orderSync,
            sourceId: 'point_of_sales',
            sourceLabel: 'Point of sale',
            occurredAt: DateTime(2026, 6, 9, 11),
            title: 'Order sync failed',
            detail: 'Retry queued order.',
            severity: OmniChannelActivitySeverity.attention,
            channelId: 'web_store',
            orderId: 'POS-1',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OmniChannelActivityInsightActionButton(
            insight: insight,
            onOpenLocation: (location) => openedLocation = location,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Resolve activity'));
    await tester.pump();

    final location = Uri.parse(openedLocation!);
    expect(location.path, OmniChannelActivityRoutes.activityCenterPath);
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .statusQueryKey],
      'attention',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .sourceIdQueryKey],
      'point_of_sales',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .channelIdQueryKey],
      'web_store',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .orderIdQueryKey],
      'POS-1',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .selectedEntryIdQueryKey],
      'sync-failed',
    );
    expect(tester.takeException(), isNull);
  });
}
