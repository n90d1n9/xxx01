import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/services/omni_channel_activity_action_executor.dart';

void main() {
  test(
    'omni-channel activity action executor opens navigation fallback',
    () async {
      String? openedLocation;
      final executor = OmniChannelActivityActionExecutor(
        handlers: [omniChannelActivityNavigationActionHandler],
      );

      final result = await executor.execute(
        OmniChannelActivityActionExecution(
          entry: _entry(),
          action: const OmniChannelActivityAction(
            label: 'Open workspace',
            location: '/module',
            tooltip: 'Open module workspace',
          ),
          openLocation: (location) => openedLocation = location,
        ),
      );

      expect(openedLocation, '/module');
      expect(result.completed, isTrue);
      expect(result.message, 'Action completed: Open workspace.');
    },
  );

  test(
    'omni-channel activity action executor blocks disabled action',
    () async {
      String? openedLocation;
      final executor = OmniChannelActivityActionExecutor(
        handlers: [omniChannelActivityNavigationActionHandler],
      );

      final result = await executor.execute(
        OmniChannelActivityActionExecution(
          entry: _entry(),
          action: const OmniChannelActivityAction(
            label: 'Retry sync',
            location: '/cashier',
            tooltip: 'Retry failed sync',
            enabled: false,
            disabledReason: 'Sync is already running.',
          ),
          openLocation: (location) => openedLocation = location,
        ),
      );

      expect(openedLocation, isNull);
      expect(result.blocked, isTrue);
      expect(result.message, 'Sync is already running.');
    },
  );

  test(
    'omni-channel activity action executor lets module handler take over',
    () async {
      final handled = <String>[];
      String? openedLocation;
      final executor = OmniChannelActivityActionExecutor(
        handlers: [
          OmniChannelActivityActionHandler(
            id: 'test-module',
            canHandle: (execution) => execution.action.identity == 'module',
            handle: (execution) {
              handled.add('${execution.entry.id}:${execution.action.identity}');

              return OmniChannelActivityActionExecutionResult.completed(
                action: execution.action,
                message: 'Module handler completed.',
              );
            },
          ),
          omniChannelActivityNavigationActionHandler,
        ],
      );

      final result = await executor.execute(
        OmniChannelActivityActionExecution(
          entry: _entry(),
          action: const OmniChannelActivityAction(
            id: 'module',
            label: 'Resolve locally',
            location: '/module',
            tooltip: 'Resolve inside module',
          ),
          openLocation: (location) => openedLocation = location,
        ),
      );

      expect(handled, ['activity:module']);
      expect(openedLocation, isNull);
      expect(result.completed, isTrue);
      expect(result.message, 'Module handler completed.');
    },
  );
}

OmniChannelActivityEntry _entry() {
  return OmniChannelActivityEntry(
    id: 'activity',
    kind: OmniChannelActivityKind.system,
    sourceId: 'module',
    sourceLabel: 'Module',
    occurredAt: DateTime(2026, 6, 9),
    title: 'Module activity',
    detail: 'Review module activity.',
  );
}
