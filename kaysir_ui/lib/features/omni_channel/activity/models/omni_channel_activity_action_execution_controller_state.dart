import 'omni_channel_activity.dart';
import 'omni_channel_activity_action.dart';
import 'omni_channel_activity_action_execution_key.dart';

/// Immutable execution state shared by omni-channel action surfaces.
class OmniChannelActivityActionExecutionControllerState {
  final Set<String> busyActionKeys;

  OmniChannelActivityActionExecutionControllerState({
    Set<String> busyActionKeys = const <String>{},
  }) : busyActionKeys = Set.unmodifiable(busyActionKeys);

  const OmniChannelActivityActionExecutionControllerState.empty()
    : busyActionKeys = const <String>{};

  bool get hasBusyActions => busyActionKeys.isNotEmpty;

  bool isBusyKey(String actionKey) {
    return busyActionKeys.contains(actionKey);
  }

  bool isActionBusy({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityAction action,
  }) {
    return isBusyKey(
      OmniChannelActivityActionExecutionKey.fromAction(
        entry: entry,
        action: action,
      ).value,
    );
  }

  OmniChannelActivityActionExecutionControllerState markBusy(String actionKey) {
    return OmniChannelActivityActionExecutionControllerState(
      busyActionKeys: {...busyActionKeys, actionKey},
    );
  }

  OmniChannelActivityActionExecutionControllerState clearBusy(
    String actionKey,
  ) {
    return OmniChannelActivityActionExecutionControllerState(
      busyActionKeys: {
        for (final key in busyActionKeys)
          if (key != actionKey) key,
      },
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OmniChannelActivityActionExecutionControllerState &&
        _setEquals(other.busyActionKeys, busyActionKeys);
  }

  @override
  int get hashCode {
    final sortedKeys = busyActionKeys.toList()..sort();

    return Object.hashAll(sortedKeys);
  }
}

bool _setEquals(Set<String> left, Set<String> right) {
  if (left.length != right.length) return false;

  return left.containsAll(right);
}
