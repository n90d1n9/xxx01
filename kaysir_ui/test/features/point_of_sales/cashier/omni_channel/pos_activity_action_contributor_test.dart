import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/point_of_sales/cashier/omni_channel/pos_activity_action_contributor.dart';

void main() {
  test('pos activity contributor prioritizes failed sync recovery', () {
    final registry = const OmniChannelActivityActionRegistry(
      contributors: [posActivityActionContributor],
    );

    final actions = registry.actionsFor(
      OmniChannelActivityEntry(
        id: 'failed-sync',
        kind: OmniChannelActivityKind.orderSync,
        sourceId: 'point_of_sales',
        sourceLabel: 'Point of sale',
        occurredAt: DateTime(2026, 6, 9),
        title: 'Order sync failed',
        detail: 'Retry the queued order.',
        severity: OmniChannelActivitySeverity.attention,
        orderId: 'POS-1',
      ),
    );

    expect(actions.map((action) => action.label), [
      'Open sync queue',
      'Open cashier',
    ]);
    expect(actions.first.intent, OmniChannelActivityActionIntent.retry);
    expect(actions.first.location, '/cashier');
  });
}
