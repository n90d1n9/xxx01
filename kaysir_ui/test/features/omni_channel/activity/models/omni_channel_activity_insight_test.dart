import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_insight.dart';

void main() {
  test('omni-channel activity insight prioritizes attention entries', () {
    final feed = OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'review',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 1, 9),
          title: 'Pending order ECOM-1',
          detail: 'Web store / Pickup / Paid.',
          severity: OmniChannelActivitySeverity.review,
          channelId: 'web_store',
          orderId: 'ECOM-1',
        ),
        OmniChannelActivityEntry(
          id: 'attention',
          kind: OmniChannelActivityKind.switchAction,
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sale',
          occurredAt: DateTime(2026, 6, 1, 10),
          title: 'Blocked Runtime pack: No Payment Pack',
          detail: 'Runtime pack switch blocked.',
          severity: OmniChannelActivitySeverity.attention,
          supportSummary: 'Finish current order first.',
        ),
      ],
    );

    final insight = OmniChannelActivityInsight.fromFeed(feed);

    expect(insight.severity, OmniChannelActivitySeverity.attention);
    expect(insight.eventCount, 2);
    expect(insight.attentionCount, 1);
    expect(insight.reviewCount, 1);
    expect(insight.orderCount, 1);
    expect(insight.switchActionCount, 1);
    expect(
      insight.summaryLabel,
      '2 events, 1 order, 1 channel, 1 attention, 1 review',
    );
    expect(insight.headline, 'Omni-channel activity needs attention');
    expect(insight.detail, 'Finish current order first.');
    expect(
      insight.nextStep,
      'Resolve attention events before the next handoff.',
    );
    expect(insight.referenceEntry?.id, 'attention');
  });

  test('omni-channel activity insight surfaces review entries', () {
    final feed = OmniChannelActivityFeed(
      entries: [
        OmniChannelActivityEntry(
          id: 'pending',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 1, 9),
          title: 'Pending order ECOM-1',
          detail: 'Web store / Pickup / Paid.',
          severity: OmniChannelActivitySeverity.review,
          channelId: 'web_store',
          orderId: 'ECOM-1',
        ),
      ],
    );

    final insight = OmniChannelActivityInsight.fromFeed(feed);

    expect(insight.severity, OmniChannelActivitySeverity.review);
    expect(insight.summaryLabel, '1 event, 1 order, 1 channel, 1 review');
    expect(insight.headline, 'Omni-channel activity needs review');
    expect(insight.detail, 'Web store / Pickup / Paid.');
    expect(
      insight.nextStep,
      'Review pending order and switch activity before handoff.',
    );
  });

  test('omni-channel activity insight reports empty and healthy feeds', () {
    final empty = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(),
    );
    expect(empty.headline, 'No omni-channel activity yet');
    expect(empty.summaryLabel, 'No activity recorded');

    final healthy = OmniChannelActivityInsight.fromFeed(
      OmniChannelActivityFeed(
        entries: [
          OmniChannelActivityEntry(
            id: 'complete',
            kind: OmniChannelActivityKind.order,
            sourceId: 'ecommerce',
            sourceLabel: 'Ecommerce',
            occurredAt: DateTime(2026, 6, 1, 9),
            title: 'Completed order ECOM-1',
            detail: 'Web store / Pickup / Paid.',
            channelId: 'web_store',
            orderId: 'ECOM-1',
          ),
        ],
      ),
    );

    expect(healthy.severity, OmniChannelActivitySeverity.ready);
    expect(healthy.summaryLabel, '1 event, 1 order, 1 channel');
    expect(healthy.headline, 'Omni-channel activity is healthy');
  });
}
