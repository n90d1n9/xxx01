import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_detail.dart';

void main() {
  test(
    'omni-channel activity detail summarizes support and context fields',
    () {
      final detail = OmniChannelActivityDetail.fromEntry(
        OmniChannelActivityEntry(
          id: 'marketplace-review',
          kind: OmniChannelActivityKind.order,
          sourceId: 'ecommerce',
          sourceLabel: 'Ecommerce',
          occurredAt: DateTime(2026, 6, 9),
          title: 'Marketplace pickup needs review',
          detail: 'Confirm pickup capacity.',
          channelId: 'marketplace',
          channelLabel: 'Marketplace',
          orderId: 'ECOM-9',
          fulfillmentModeLabel: 'Pickup',
          supportSummary: 'Review pickup capacity with store ops.',
          attributes: {
            'slaWindow': '30 min',
            'reserved_stock': 'Low',
            'empty': '',
          },
        ),
      );

      expect(detail.title, 'Marketplace pickup needs review');
      expect(detail.summary, 'Review pickup capacity with store ops.');
      expect(detail.contextLabel, 'Ecommerce / Marketplace / ECOM-9');
      expect(
        detail.primaryFields.map((field) => '${field.label}: ${field.value}'),
        containsAll([
          'Source: Ecommerce',
          'Channel: Marketplace',
          'Order: ECOM-9',
          'Fulfillment: Pickup',
          'Event ID: marketplace-review',
        ]),
      );
      expect(detail.attributeFields.map((field) => field.label), [
        'Reserved Stock',
        'Sla Window',
      ]);
    },
  );
}
