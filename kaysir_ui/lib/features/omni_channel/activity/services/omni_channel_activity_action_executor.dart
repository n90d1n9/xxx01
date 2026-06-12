import 'dart:async';

import '../models/omni_channel_activity_action_execution.dart';

typedef OmniChannelActivityActionCanHandle =
    bool Function(OmniChannelActivityActionExecution execution);

typedef OmniChannelActivityActionHandle =
    FutureOr<OmniChannelActivityActionExecutionResult> Function(
      OmniChannelActivityActionExecution execution,
    );

/// Module-owned handler that decides whether and how an activity action runs.
class OmniChannelActivityActionHandler {
  final String id;
  final OmniChannelActivityActionCanHandle canHandle;
  final OmniChannelActivityActionHandle handle;

  const OmniChannelActivityActionHandler({
    required this.id,
    required this.canHandle,
    required this.handle,
  });

  Future<OmniChannelActivityActionExecutionResult> execute(
    OmniChannelActivityActionExecution execution,
  ) async {
    return handle(execution);
  }
}

/// Executes omni-channel activity actions through registered module handlers.
class OmniChannelActivityActionExecutor {
  final List<OmniChannelActivityActionHandler> handlers;

  OmniChannelActivityActionExecutor({
    required Iterable<OmniChannelActivityActionHandler> handlers,
  }) : handlers = List.unmodifiable(handlers);

  Future<OmniChannelActivityActionExecutionResult> execute(
    OmniChannelActivityActionExecution execution,
  ) async {
    final action = execution.action;
    if (!action.isEnabled) {
      return OmniChannelActivityActionExecutionResult.blocked(
        action: action,
        message: action.effectiveTooltip,
        location: action.location,
      );
    }

    for (final handler in handlers) {
      if (!handler.canHandle(execution)) continue;

      try {
        return await handler.execute(execution);
      } catch (_) {
        return OmniChannelActivityActionExecutionResult.failed(
          action: action,
          message: 'Could not complete ${action.label}.',
          location: action.location,
        );
      }
    }

    return OmniChannelActivityActionExecutionResult.failed(
      action: action,
      message: 'No handler is available for ${action.label}.',
      location: action.location,
    );
  }

  OmniChannelActivityActionExecutor extendWith(
    Iterable<OmniChannelActivityActionHandler> nextHandlers,
  ) {
    return OmniChannelActivityActionExecutor(
      handlers: [...handlers, ...nextHandlers],
    );
  }
}

/// Fallback handler that preserves existing action behavior by opening a route.
final omniChannelActivityNavigationActionHandler =
    OmniChannelActivityActionHandler(
      id: 'omni-channel-navigation',
      canHandle: _canOpenNavigationAction,
      handle: _openNavigationAction,
    );

bool _canOpenNavigationAction(OmniChannelActivityActionExecution execution) {
  return execution.action.location.trim().isNotEmpty;
}

OmniChannelActivityActionExecutionResult _openNavigationAction(
  OmniChannelActivityActionExecution execution,
) {
  final location = execution.action.location.trim();
  execution.openLocation(location);

  return OmniChannelActivityActionExecutionResult.completed(
    action: execution.action,
    message: 'Action completed: ${execution.action.label}.',
    location: location,
  );
}
