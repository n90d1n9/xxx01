import 'omni_channel_activity.dart';
import 'omni_channel_activity_action.dart';

typedef OmniChannelActivityLocationOpener = void Function(String location);

enum OmniChannelActivityActionOutcome { completed, blocked, failed }

/// Runtime context passed to a module-owned omni-channel activity action handler.
class OmniChannelActivityActionExecution {
  final OmniChannelActivityEntry entry;
  final OmniChannelActivityAction action;
  final OmniChannelActivityLocationOpener openLocation;

  const OmniChannelActivityActionExecution({
    required this.entry,
    required this.action,
    required this.openLocation,
  });
}

/// User-facing result produced after an omni-channel activity action is handled.
class OmniChannelActivityActionExecutionResult {
  final OmniChannelActivityAction action;
  final OmniChannelActivityActionOutcome outcome;
  final String message;
  final String? location;

  const OmniChannelActivityActionExecutionResult.completed({
    required this.action,
    required this.message,
    this.location,
  }) : outcome = OmniChannelActivityActionOutcome.completed;

  const OmniChannelActivityActionExecutionResult.blocked({
    required this.action,
    required this.message,
    this.location,
  }) : outcome = OmniChannelActivityActionOutcome.blocked;

  const OmniChannelActivityActionExecutionResult.failed({
    required this.action,
    required this.message,
    this.location,
  }) : outcome = OmniChannelActivityActionOutcome.failed;

  bool get completed => outcome == OmniChannelActivityActionOutcome.completed;

  bool get blocked => outcome == OmniChannelActivityActionOutcome.blocked;

  bool get failed => outcome == OmniChannelActivityActionOutcome.failed;
}
