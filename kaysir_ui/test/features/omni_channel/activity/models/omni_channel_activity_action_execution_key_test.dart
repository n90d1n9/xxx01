import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_key.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_log.dart';

void main() {
  test('omni-channel action execution key matches action and log records', () {
    final entry = OmniChannelActivityEntry(
      id: 'sync-failed',
      kind: OmniChannelActivityKind.orderSync,
      sourceId: 'point_of_sales',
      sourceLabel: 'Point of sale',
      occurredAt: DateTime(2026, 6, 9, 11),
      title: 'Order sync failed',
      detail: 'Retry the queued counter order.',
    );
    const action = OmniChannelActivityAction(
      id: 'retry-sync',
      label: 'Retry sync',
      location: '/cashier',
      tooltip: 'Retry failed POS sync',
    );
    final record = OmniChannelActivityActionExecutionRecord(
      id: 'record-1',
      result: const OmniChannelActivityActionExecutionResult.failed(
        action: action,
        message: 'Sync failed.',
        location: '/cashier',
      ),
      entryId: entry.id,
      entryTitle: entry.title,
      sourceLabel: entry.sourceLabel,
      occurredAt: DateTime(2026, 6, 9, 11, 1),
      sequence: 1,
    );

    final actionKey = OmniChannelActivityActionExecutionKey.fromAction(
      entry: entry,
      action: action,
    );
    final recordKey = OmniChannelActivityActionExecutionKey.fromRecord(record);

    expect(actionKey, recordKey);
    expect(actionKey.value, 'sync-failed::retry-sync');
  });
}
