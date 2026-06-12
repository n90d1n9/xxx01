import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_relation.dart';

void main() {
  test(
    'omni-channel related activity prioritizes order, channel, then source',
    () {
      final selectedEntry = _entry(
        id: 'selected',
        sourceId: 'ecommerce',
        sourceLabel: 'Ecommerce',
        channelId: 'marketplace',
        orderId: 'ECOM-1',
        occurredAt: DateTime(2026, 6, 9, 11),
      );
      final related = OmniChannelRelatedActivity.fromEntries(
        selectedEntry: selectedEntry,
        entries: [
          selectedEntry,
          _entry(
            id: 'same-source',
            sourceId: 'ecommerce',
            sourceLabel: 'Ecommerce',
            occurredAt: DateTime(2026, 6, 9, 11, 45),
          ),
          _entry(
            id: 'same-channel',
            sourceId: 'point_of_sales',
            sourceLabel: 'Point of sale',
            channelId: 'marketplace',
            occurredAt: DateTime(2026, 6, 9, 10),
          ),
          _entry(
            id: 'same-order',
            sourceId: 'point_of_sales',
            sourceLabel: 'Point of sale',
            channelId: 'web_store',
            orderId: 'ECOM-1',
            occurredAt: DateTime(2026, 6, 9, 9),
          ),
          _entry(
            id: 'unrelated',
            sourceId: 'inventory',
            sourceLabel: 'Inventory',
            channelId: 'warehouse',
            occurredAt: DateTime(2026, 6, 9, 12),
          ),
        ],
      );

      expect(
        related.entries.map(
          (entry) => '${entry.entry.id}:${entry.relation.label}',
        ),
        [
          'same-order:Same order',
          'same-channel:Same channel',
          'same-source:Same source',
        ],
      );
    },
  );

  test('omni-channel related activity respects limit', () {
    final selectedEntry = _entry(
      id: 'selected',
      sourceId: 'ecommerce',
      sourceLabel: 'Ecommerce',
      channelId: 'marketplace',
      orderId: 'ECOM-1',
      occurredAt: DateTime(2026, 6, 9, 11),
    );
    final related = OmniChannelRelatedActivity.fromEntries(
      selectedEntry: selectedEntry,
      limit: 1,
      entries: [
        selectedEntry,
        _entry(
          id: 'same-order',
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sale',
          orderId: 'ECOM-1',
          occurredAt: DateTime(2026, 6, 9, 10),
        ),
        _entry(
          id: 'same-channel',
          sourceId: 'point_of_sales',
          sourceLabel: 'Point of sale',
          channelId: 'marketplace',
          occurredAt: DateTime(2026, 6, 9, 9),
        ),
      ],
    );

    expect(related.entries.map((entry) => entry.entry.id), ['same-order']);
  });
}

OmniChannelActivityEntry _entry({
  required String id,
  required String sourceId,
  required String sourceLabel,
  required DateTime occurredAt,
  String? channelId,
  String? orderId,
}) {
  return OmniChannelActivityEntry(
    id: id,
    kind: OmniChannelActivityKind.order,
    sourceId: sourceId,
    sourceLabel: sourceLabel,
    occurredAt: occurredAt,
    title: id,
    detail: '$sourceLabel activity',
    channelId: channelId,
    orderId: orderId,
  );
}
