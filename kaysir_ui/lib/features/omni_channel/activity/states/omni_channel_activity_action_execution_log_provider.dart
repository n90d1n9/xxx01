import 'package:flutter_riverpod/legacy.dart';

import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action_execution.dart';
import '../models/omni_channel_activity_action_execution_log.dart';

/// Stores recent omni-channel activity action outcomes for operator review.
class OmniChannelActivityActionExecutionLogNotifier
    extends StateNotifier<OmniChannelActivityActionExecutionLog> {
  final DateTime Function() _clock;
  int _sequence = 0;

  OmniChannelActivityActionExecutionLogNotifier({
    DateTime Function()? clock,
    int limit = defaultOmniChannelActivityActionExecutionLogLimit,
  }) : _clock = clock ?? DateTime.now,
       super(OmniChannelActivityActionExecutionLog.empty(limit: limit));

  OmniChannelActivityActionExecutionRecord record({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityActionExecutionResult result,
  }) {
    _sequence += 1;
    state = state.record(
      entry: entry,
      result: result,
      occurredAt: _clock(),
      sequence: _sequence,
    );

    return state.entries.first;
  }

  void clear() {
    state = state.clear();
  }

  void clearCompleted() {
    state = state.clearCompleted();
  }
}

/// Provides recent action outcomes shown by the Activity Center.
final omniChannelActivityActionExecutionLogProvider = StateNotifierProvider<
  OmniChannelActivityActionExecutionLogNotifier,
  OmniChannelActivityActionExecutionLog
>((ref) => OmniChannelActivityActionExecutionLogNotifier());

/// Selected outcome filter for the Activity Center action execution log panel.
final omniChannelActivityActionExecutionLogFilterProvider =
    StateProvider<OmniChannelActivityActionExecutionLogFilter>(
      (ref) => OmniChannelActivityActionExecutionLogFilter.all,
    );
