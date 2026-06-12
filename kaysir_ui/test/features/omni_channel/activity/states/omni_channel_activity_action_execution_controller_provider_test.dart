import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import 'package:kaysir/features/omni_channel/activity/models/omni_channel_activity_action_execution_controller_state.dart';
import 'package:kaysir/features/omni_channel/activity/services/omni_channel_activity_action_executor.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_execution_controller_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_execution_log_provider.dart';
import 'package:kaysir/features/omni_channel/activity/states/omni_channel_activity_action_executor_provider.dart';

void main() {
  test(
    'omni-channel action execution controller records completed outcome',
    () async {
      final container = ProviderContainer(
        overrides: [
          omniChannelActivityActionExecutorProvider.overrideWithValue(
            OmniChannelActivityActionExecutor(
              handlers: [
                OmniChannelActivityActionHandler(
                  id: 'test-handler',
                  canHandle: (_) => true,
                  handle:
                      (execution) =>
                          OmniChannelActivityActionExecutionResult.completed(
                            action: execution.action,
                            message: 'Action handled by controller.',
                          ),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(omniChannelActivityActionExecutionControllerProvider.notifier)
          .execute(entry: _entry(), action: _action(), openLocation: (_) {});

      final log = container.read(omniChannelActivityActionExecutionLogProvider);

      expect(result?.message, 'Action handled by controller.');
      expect(log.latest?.result.message, 'Action handled by controller.');
      expect(
        container.read(omniChannelActivityActionExecutionControllerProvider),
        const OmniChannelActivityActionExecutionControllerState.empty(),
      );
    },
  );

  test(
    'omni-channel action execution controller prevents duplicates',
    () async {
      final completion = Completer<OmniChannelActivityActionExecutionResult>();
      late OmniChannelActivityActionExecution pendingExecution;
      var handledCount = 0;
      final container = ProviderContainer(
        overrides: [
          omniChannelActivityActionExecutorProvider.overrideWithValue(
            OmniChannelActivityActionExecutor(
              handlers: [
                OmniChannelActivityActionHandler(
                  id: 'slow-handler',
                  canHandle: (_) => true,
                  handle: (execution) {
                    handledCount++;
                    pendingExecution = execution;

                    return completion.future;
                  },
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        omniChannelActivityActionExecutionControllerProvider.notifier,
      );
      final entry = _entry();
      final action = _action();
      final firstRun = controller.execute(
        entry: entry,
        action: action,
        openLocation: (_) {},
      );

      expect(
        container
            .read(omniChannelActivityActionExecutionControllerProvider)
            .isActionBusy(entry: entry, action: action),
        isTrue,
      );

      final duplicate = await controller.execute(
        entry: entry,
        action: action,
        openLocation: (_) {},
      );

      expect(duplicate, isNull);
      expect(handledCount, 1);

      completion.complete(
        OmniChannelActivityActionExecutionResult.completed(
          action: pendingExecution.action,
          message: 'Slow action completed.',
        ),
      );

      final result = await firstRun;
      final state = container.read(
        omniChannelActivityActionExecutionControllerProvider,
      );

      expect(result?.message, 'Slow action completed.');
      expect(state.hasBusyActions, isFalse);
      expect(
        container
            .read(omniChannelActivityActionExecutionLogProvider)
            .latest
            ?.result
            .message,
        'Slow action completed.',
      );
    },
  );
}

OmniChannelActivityEntry _entry() {
  return OmniChannelActivityEntry(
    id: 'sync-failed',
    kind: OmniChannelActivityKind.orderSync,
    sourceId: 'point_of_sales',
    sourceLabel: 'Point of sale',
    occurredAt: DateTime(2026, 6, 9, 11),
    title: 'Order sync failed',
    detail: 'Retry the queued counter order.',
  );
}

OmniChannelActivityAction _action() {
  return const OmniChannelActivityAction(
    id: 'retry-sync',
    label: 'Retry sync',
    location: '/cashier',
    tooltip: 'Retry failed POS sync',
  );
}
