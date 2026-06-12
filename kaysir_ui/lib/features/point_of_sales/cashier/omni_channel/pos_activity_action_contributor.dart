import '../../../omni_channel/activity/models/omni_channel_activity.dart';
import '../../../omni_channel/activity/models/omni_channel_activity_action.dart';

/// POS action contributor for cashier and order-sync activity.
Iterable<OmniChannelActivityAction> posActivityActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  if (!_isPointOfSalesSource(entry)) return;

  if (entry.kind == OmniChannelActivityKind.orderSync &&
      entry.requiresAttention) {
    yield _cashierAction(
      label: 'Open sync queue',
      id: 'pos-sync-queue',
      intent: OmniChannelActivityActionIntent.retry,
    );
  }

  yield _cashierAction(priority: 20);
}

OmniChannelActivityAction _cashierAction({
  String label = 'Open cashier',
  String id = 'cashier-workspace',
  OmniChannelActivityActionIntent intent =
      OmniChannelActivityActionIntent.inspect,
  int priority = 0,
}) {
  return OmniChannelActivityAction(
    id: id,
    label: label,
    location: '/cashier',
    tooltip: 'Open the cashier workspace',
    intent: intent,
    priority: priority,
  );
}

bool _isPointOfSalesSource(OmniChannelActivityEntry entry) {
  final sourceId = entry.sourceId.toLowerCase();
  final sourceLabel = entry.sourceLabel.toLowerCase();

  return sourceId.contains('point_of_sales') ||
      sourceId == 'pos' ||
      sourceLabel.contains('point of sale') ||
      sourceLabel.contains('cashier');
}
