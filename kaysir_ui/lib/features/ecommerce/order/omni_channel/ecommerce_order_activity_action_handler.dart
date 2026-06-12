import '../../../omni_channel/activity/models/omni_channel_activity_action_execution.dart';
import '../../../omni_channel/activity/services/omni_channel_activity_action_executor.dart';

/// Ecommerce handler for order, fulfillment, and commerce activity actions.
final ecommerceOrderActivityActionHandler = OmniChannelActivityActionHandler(
  id: 'ecommerce-order-activity-actions',
  canHandle: _canHandleEcommerceAction,
  handle: _handleEcommerceAction,
);

bool _canHandleEcommerceAction(OmniChannelActivityActionExecution execution) {
  final identity = execution.action.identity;

  return identity == 'commerce-workspace' ||
      identity.startsWith('order-workspace:');
}

OmniChannelActivityActionExecutionResult _handleEcommerceAction(
  OmniChannelActivityActionExecution execution,
) {
  final location = execution.action.location.trim();
  execution.openLocation(location);

  return OmniChannelActivityActionExecutionResult.completed(
    action: execution.action,
    message: _ecommerceActionMessage(execution),
    location: location,
  );
}

String _ecommerceActionMessage(OmniChannelActivityActionExecution execution) {
  if (execution.action.identity == 'commerce-workspace') {
    return 'Commerce workspace opened.';
  }

  final orderId = execution.entry.orderId?.trim() ?? '';
  if (orderId.isEmpty) return 'Order workspace opened.';

  return 'Order workspace opened for $orderId.';
}
