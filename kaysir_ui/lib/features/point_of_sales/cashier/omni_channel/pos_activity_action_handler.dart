import '../../../omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import '../../../omni_channel/activity/services/omni_channel_activity_action_executor.dart';

/// POS handler for cashier workspace and sync queue activity actions.
final posActivityActionHandler = OmniChannelActivityActionHandler(
  id: 'point-of-sales-activity-actions',
  canHandle: _canHandlePosAction,
  handle: _handlePosAction,
);

bool _canHandlePosAction(OmniChannelActivityActionExecution execution) {
  final identity = execution.action.identity;

  return identity == 'pos-sync-queue' || identity == 'cashier-workspace';
}

OmniChannelActivityActionExecutionResult _handlePosAction(
  OmniChannelActivityActionExecution execution,
) {
  final location = execution.action.location.trim();
  execution.openLocation(location);

  return OmniChannelActivityActionExecutionResult.completed(
    action: execution.action,
    message:
        execution.action.identity == 'pos-sync-queue'
            ? 'POS sync queue opened.'
            : 'Cashier workspace opened.',
    location: location,
  );
}
