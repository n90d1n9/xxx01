import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_center_query_state.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';
import 'package:kaysir/features/omni_channel/activity/omni_channel_activity_routes.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_provider.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_insight_status_banner.dart';

void main() {
  testWidgets('omni-channel activity status banner shows actionable insight', (
    tester,
  ) async {
    String? openedLocation;
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'review',
            kind: OmniChannelActivityKind.order,
            sourceId: 'ecommerce',
            sourceLabel: 'Ecommerce',
            occurredAt: DateTime(2026, 6, 1, 10),
            title: 'Marketplace order needs review',
            detail: 'Pickup capacity requires confirmation.',
            severity: OmniChannelActivitySeverity.review,
            channelId: 'marketplace',
            orderId: 'ECOM-1',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      _buildStatusBanner(
        insight: insight,
        onOpenActivityCenter: (location) => openedLocation = location,
      ),
    );

    expect(find.text('Omni-channel activity needs review'), findsOneWidget);
    expect(find.text('1 event, 1 order, 1 channel, 1 review'), findsOneWidget);
    expect(find.byIcon(Icons.pending_actions_outlined), findsOneWidget);
    expect(find.text('Review activity'), findsOneWidget);

    await tester.tap(find.text('Review activity'));
    await tester.pump();

    final location = Uri.parse(openedLocation!);
    expect(location.path, OmniChannelActivityRoutes.activityCenterPath);
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .statusQueryKey],
      'review',
    );
    expect(
      location.queryParameters[OmniChannelActivityCenterQueryState
          .selectedEntryIdQueryKey],
      'review',
    );
  });

  testWidgets(
    'omni-channel activity status banner hides ready state by default',
    (tester) async {
      final insight = OmniChannelActivityInsight.fromFeed(
        OmniChannelActivityFeed(),
      );

      await tester.pumpWidget(_buildStatusBanner(insight: insight));

      expect(find.text('No omni-channel activity yet'), findsNothing);
      expect(
        find.byType(OmniChannelActivityInsightStatusBanner),
        findsOneWidget,
      );
    },
  );

  testWidgets('omni-channel activity status banner can show ready state', (
    tester,
  ) async {
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(),
    );

    await tester.pumpWidget(
      _buildStatusBanner(insight: insight, showReadyState: true),
    );

    expect(find.text('No omni-channel activity yet'), findsOneWidget);
    expect(find.text('No activity recorded'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}

Widget _buildStatusBanner({
  required OmniChannelActivityInsight insight,
  bool showReadyState = false,
  ValueChanged<String>? onOpenActivityCenter,
}) {
  return ProviderScope(
    overrides: [omniChannelActivityInsightProvider.overrideWithValue(insight)],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 520,
          child: OmniChannelActivityInsightStatusBanner(
            showReadyState: showReadyState,
            onOpenActivityCenter: onOpenActivityCenter,
          ),
        ),
      ),
    ),
  );
}
