import 'omni_channel_activity.dart';
import 'omni_channel_activity_action.dart';
import 'omni_channel_activity_action_execution_log.dart';

/// Stable UI identity for one omni-channel activity action execution.
class OmniChannelActivityActionExecutionKey {
  final String entryId;
  final String actionIdentity;

  const OmniChannelActivityActionExecutionKey({
    required this.entryId,
    required this.actionIdentity,
  });

  factory OmniChannelActivityActionExecutionKey.fromAction({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityAction action,
  }) {
    return OmniChannelActivityActionExecutionKey(
      entryId: entry.id,
      actionIdentity: action.identity,
    );
  }

  factory OmniChannelActivityActionExecutionKey.fromRecord(
    OmniChannelActivityActionExecutionRecord record,
  ) {
    return OmniChannelActivityActionExecutionKey(
      entryId: record.entryId,
      actionIdentity: record.actionIdentity,
    );
  }

  String get value {
    return '${entryId.trim()}::${actionIdentity.trim()}';
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    return other is OmniChannelActivityActionExecutionKey &&
        other.entryId == entryId &&
        other.actionIdentity == actionIdentity;
  }

  @override
  int get hashCode => Object.hash(entryId, actionIdentity);
}
