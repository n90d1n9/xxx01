import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_insight_banner.dart';

void main() {
  testWidgets('omni-channel activity insight banner renders next step', (
    tester,
  ) async {
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'attention',
            kind: OmniChannelActivityKind.orderSync,
            sourceId: 'point_of_sales',
            sourceLabel: 'Point of sale',
            occurredAt: DateTime(2026, 6, 1, 10),
            title: 'Web order sync failed',
            detail: 'Network down.',
            severity: OmniChannelActivitySeverity.attention,
            channelId: 'web_store',
            orderId: 'ECOM-1',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: OmniChannelActivityInsightBanner(insight: insight),
          ),
        ),
      ),
    );

    expect(find.text('Omni-channel activity needs attention'), findsOneWidget);
    expect(find.text('1 event, 1 channel, 1 attention'), findsOneWidget);
    expect(find.text('Network down.'), findsOneWidget);
    expect(
      find.text('Next: Resolve attention events before the next handoff.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.priority_high_outlined), findsOneWidget);
    expect(find.byIcon(Icons.route_outlined), findsOneWidget);
  });

  testWidgets('omni-channel activity insight banner can hide next step', (
    tester,
  ) async {
    final insight = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: OmniChannelActivityInsightBanner(
              insight: insight,
              showNextStep: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('No omni-channel activity yet'), findsOneWidget);
    expect(find.text('No activity recorded'), findsOneWidget);
    expect(find.textContaining('Next:'), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
