import 'package:flutter_riverpod/legacy.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution.dart';
import '../models/omni_channel_activity_action_execution_controller_state.dart';
import '../models/omni_channel_activity_action_execution_key.dart';
import '../services/omni_channel_activity_action_executor.dart';
import 'omni_channel_activity_action_execution_log_provider.dart';
import 'omni_channel_activity_action_executor_provider.dart';

/// Coordinates omni-channel action execution, busy state, and outcome logging.
class OmniChannelActivityActionExecutionController
    extends StateNotifier<OmniChannelActivityActionExecutionControllerState> {
  final OmniChannelActivityActionExecutor Function() _executor;
  final OmniChannelActivityActionExecutionLogNotifier Function() _logNotifier;

  OmniChannelActivityActionExecutionController({
    required OmniChannelActivityActionExecutor Function() executor,
    required OmniChannelActivityActionExecutionLogNotifier Function()
    logNotifier,
  }) : _executor = executor,
       _logNotifier = logNotifier,
       super(const OmniChannelActivityActionExecutionControllerState.empty());

  Future<OmniChannelActivityActionExecutionResult?> execute({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityAction action,
    required OmniChannelActivityLocationOpener openLocation,
  }) async {
    final actionKey =
        OmniChannelActivityActionExecutionKey.fromAction(
          entry: entry,
          action: action,
        ).value;
    if (state.isBusyKey(actionKey)) return null;

    state = state.markBusy(actionKey);
    try {
      final result = await _executor().execute(
        OmniChannelActivityActionExecution(
          entry: entry,
          action: action,
          openLocation: openLocation,
        ),
      );
      _logNotifier().record(entry: entry, result: result);

      return result;
    } finally {
      state = state.clearBusy(actionKey);
    }
  }
}

/// Provides the shared omni-channel action execution controller.
final omniChannelActivityActionExecutionControllerProvider =
    StateNotifierProvider<
      OmniChannelActivityActionExecutionController,
      OmniChannelActivityActionExecutionControllerState
    >((ref) {
      return OmniChannelActivityActionExecutionController(
        executor: () => ref.read(omniChannelActivityActionExecutorProvider),
        logNotifier:
            () => ref.read(
              omniChannelActivityActionExecutionLogProvider.notifier,
            ),
      );
    });
