import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_log.dart';

void main() {
  test('omni-channel action execution log records newest entries first', () {
    final first = _entry(id: 'first');
    final second = _entry(id: 'second');
    final third = _entry(id: 'third');
    final log = const OmniChannelActivityActionExecutionLog.empty(limit: 2)
        .record(
          entry: first,
          result: _completedResult('First handled.'),
          occurredAt: DateTime(2026, 6, 9, 10),
          sequence: 1,
        )
        .record(
          entry: second,
          result: _blockedResult('Second blocked.'),
          occurredAt: DateTime(2026, 6, 9, 10, 1),
          sequence: 2,
        )
        .record(
          entry: third,
          result: _completedResult('Third handled.'),
          occurredAt: DateTime(2026, 6, 9, 10, 2),
          sequence: 3,
        );

    expect(log.entries.map((entry) => entry.entryId), ['third', 'second']);
    expect(log.latest?.entryId, 'third');
    expect(log.completedCount, 1);
    expect(log.attentionCount, 1);
    expect(log.isNotEmpty, isTrue);
  });

  test('omni-channel action execution log can clear records', () {
    final log = const OmniChannelActivityActionExecutionLog.empty().record(
      entry: _entry(id: 'activity'),
      result: _completedResult('Handled.'),
      occurredAt: DateTime(2026, 6, 9, 10),
      sequence: 1,
    );

    expect(log.clear().isEmpty, isTrue);
  });

  test('omni-channel action execution log can clear completed records', () {
    final log = const OmniChannelActivityActionExecutionLog.empty()
        .record(
          entry: _entry(id: 'completed'),
          result: _completedResult('Handled.'),
          occurredAt: DateTime(2026, 6, 9, 10),
          sequence: 1,
        )
        .record(
          entry: _entry(id: 'blocked'),
          result: _blockedResult('Blocked.'),
          occurredAt: DateTime(2026, 6, 9, 10, 1),
          sequence: 2,
        )
        .record(
          entry: _entry(id: 'failed'),
          result: _failedResult('Failed.'),
          occurredAt: DateTime(2026, 6, 9, 10, 2),
          sequence: 3,
        );

    final cleared = log.clearCompleted();

    expect(cleared.entries.map((entry) => entry.entryId), [
      'failed',
      'blocked',
    ]);
    expect(cleared.completedCount, 0);
    expect(cleared.attentionEntries.map((entry) => entry.entryId), [
      'failed',
      'blocked',
    ]);
  });

  test('omni-channel action execution record exposes reopen location', () {
    final action = const OmniChannelActivityAction(
      id: 'module-action',
      label: 'Handle module',
      location: '/fallback',
      tooltip: 'Handle module activity',
    );
    final explicitResult = OmniChannelActivityActionExecutionResult.completed(
      action: action,
      message: 'Handled.',
      location: '/explicit',
    );
    final fallbackResult = OmniChannelActivityActionExecutionResult.completed(
      action: action,
      message: 'Handled.',
    );

    expect(_record(result: explicitResult).openLocation, '/explicit');
    expect(_record(result: fallbackResult).openLocation, '/fallback');
    expect(_record(result: fallbackResult).canOpenLocation, isTrue);
  });

  test('omni-channel action execution log filters outcomes', () {
    final log = const OmniChannelActivityActionExecutionLog.empty()
        .record(
          entry: _entry(id: 'completed'),
          result: _completedResult('Handled.'),
          occurredAt: DateTime(2026, 6, 9, 10),
          sequence: 1,
        )
        .record(
          entry: _entry(id: 'blocked'),
          result: _blockedResult('Blocked.'),
          occurredAt: DateTime(2026, 6, 9, 10, 1),
          sequence: 2,
        )
        .record(
          entry: _entry(id: 'failed'),
          result: _failedResult('Failed.'),
          occurredAt: DateTime(2026, 6, 9, 10, 2),
          sequence: 3,
        );

    expect(
      log
          .entriesFor(OmniChannelActivityActionExecutionLogFilter.attention)
          .map((entry) => entry.entryId),
      ['failed', 'blocked'],
    );
    expect(log.countFor(OmniChannelActivityActionExecutionLogFilter.all), 3);
    expect(
      log.countFor(OmniChannelActivityActionExecutionLogFilter.completed),
      1,
    );
    expect(
      log.countFor(OmniChannelActivityActionExecutionLogFilter.blocked),
      1,
    );
    expect(log.countFor(OmniChannelActivityActionExecutionLogFilter.failed), 1);
  });
}

OmniChannelActivityActionExecutionRecord _record({
  required OmniChannelActivityActionExecutionResult result,
}) {
  return OmniChannelActivityActionExecutionRecord(
    id: 'record',
    result: result,
    entryId: 'activity',
    entryTitle: 'Module activity',
    sourceLabel: 'Module',
    occurredAt: DateTime(2026, 6, 9),
    sequence: 1,
  );
}

OmniChannelActivityEntry _entry({required String id}) {
  return OmniChannelActivityEntry(
    id: id,
    kind: OmniChannelActivityKind.system,
    sourceId: 'module',
    sourceLabel: 'Module',
    occurredAt: DateTime(2026, 6, 9),
    title: 'Module activity $id',
    detail: 'Review module activity.',
  );
}

OmniChannelActivityActionExecutionResult _completedResult(String message) {
  return OmniChannelActivityActionExecutionResult.completed(
    action: _action(),
    message: message,
    location: '/module',
  );
}

OmniChannelActivityActionExecutionResult _blockedResult(String message) {
  return OmniChannelActivityActionExecutionResult.blocked(
    action: _action(),
    message: message,
    location: '/module',
  );
}

OmniChannelActivityActionExecutionResult _failedResult(String message) {
  return OmniChannelActivityActionExecutionResult.failed(
    action: _action(),
    message: message,
    location: '/module',
  );
}

OmniChannelActivityAction _action() {
  return const OmniChannelActivityAction(
    id: 'module-action',
    label: 'Handle module',
    location: '/module',
    tooltip: 'Handle module activity',
  );
}
