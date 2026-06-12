import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_filter.dart';
import 'package:kaysir/features/omni_channel/activity/widgets/omni_channel_activity_presentation.dart';

void main() {
  test('omni-channel activity entry presentation exposes UI-safe copy', () {
    final presentation = OmniChannelActivityEntryPresentation(
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
        channelLabel: 'Web store',
        orderId: 'ECOM-1',
      ),
    );

    expect(presentation.title, 'Pending order ECOM-1');
    expect(presentation.detail, 'Web store / Pickup / Paid.');
    expect(presentation.supportText, 'Web store / Pickup / Paid.');
    expect(presentation.contextLabel, 'Ecommerce / Web store / ECOM-1');
    expect(presentation.kindVisuals.icon, Icons.receipt_long_outlined);
    expect(presentation.kindVisuals.tone, OmniChannelActivityTone.info);
    expect(presentation.severityVisuals.icon, Icons.pending_actions_outlined);
    expect(presentation.severityVisuals.tone, OmniChannelActivityTone.warning);
  });

  test('omni-channel activity entry presentation prefers support summary', () {
    final presentation = OmniChannelActivityEntryPresentation(
      OmniChannelActivityEntry(
        id: 'switch_1',
        kind: OmniChannelActivityKind.switchAction,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 1, 10),
        title: 'Blocked Runtime pack: No Payment Pack',
        detail: '',
        severity: OmniChannelActivitySeverity.attention,
        supportSummary: 'Finish current order first.',
      ),
    );

    expect(presentation.detail, 'Switch action');
    expect(presentation.supportText, 'Finish current order first.');
    expect(presentation.contextLabel, 'Point of sale');
    expect(presentation.severityVisuals.tone, OmniChannelActivityTone.danger);
  });

  test('omni-channel activity filter option presentation maps counts', () {
    final counts = OmniChannelActivityFilterCounts.fromEntries([
      OmniChannelActivityEntry(
        id: 'order_1',
        kind: OmniChannelActivityKind.order,
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        occurredAt: DateTime(2026, 6, 1, 10),
        title: 'Pending order ECOM-1',
        detail: 'Web store / Pickup / Paid.',
        severity: OmniChannelActivitySeverity.review,
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
      ),
    ]);

    final options = omniChannelActivityFilterOptionPresentations(
      counts: counts,
      statuses: const [
        OmniChannelActivityFilterStatus.all,
        OmniChannelActivityFilterStatus.attention,
        OmniChannelActivityFilterStatus.orders,
        OmniChannelActivityFilterStatus.orderSync,
      ],
    );

    expect(options.map((option) => option.label), [
      'All',
      'Attention',
      'Order',
      'Order sync',
    ]);
    expect(options.map((option) => option.count), [2, 1, 1, 1]);
    expect(options[1].tone, OmniChannelActivityTone.danger);
    expect(options[2].icon, Icons.receipt_long_outlined);
    expect(options.every((option) => option.hasActivity), isTrue);
  });

  test('omni-channel activity action presentation maps intents', () {
    final presentations = [
      OmniChannelActivityActionPresentation(
        const OmniChannelActivityAction(
          label: 'Open sync queue',
          location: '/cashier',
          tooltip: 'Retry failed sync',
          intent: OmniChannelActivityActionIntent.retry,
        ),
      ),
      OmniChannelActivityActionPresentation(
        const OmniChannelActivityAction(
          label: 'Open orders',
          location: '/commerce/orders',
          tooltip: 'Review order',
          intent: OmniChannelActivityActionIntent.review,
        ),
      ),
      OmniChannelActivityActionPresentation(
        const OmniChannelActivityAction(
          label: 'Open commerce',
          location: '/commerce',
          tooltip: 'Inspect workspace',
          intent: OmniChannelActivityActionIntent.inspect,
        ),
      ),
    ];

    expect(presentations.map((presentation) => presentation.icon), [
      Icons.replay_circle_filled_outlined,
      Icons.rate_review_outlined,
      Icons.manage_search_outlined,
    ]);
    expect(presentations.map((presentation) => presentation.tone), [
      OmniChannelActivityTone.danger,
      OmniChannelActivityTone.warning,
      OmniChannelActivityTone.info,
    ]);
  });

  test(
    'omni-channel activity action presentation explains disabled actions',
    () {
      final presentation = OmniChannelActivityActionPresentation(
        const OmniChannelActivityAction(
          label: 'Open sync queue',
          location: '/cashier',
          tooltip: 'Retry failed sync',
          intent: OmniChannelActivityActionIntent.retry,
          enabled: false,
          disabledReason: 'Sync is already running.',
        ),
      );

      expect(presentation.isEnabled, isFalse);
      expect(presentation.tooltip, 'Sync is already running.');
    },
  );
}
