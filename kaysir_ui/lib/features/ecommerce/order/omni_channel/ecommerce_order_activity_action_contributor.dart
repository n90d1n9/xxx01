import '../../dashboard/routes.dart' as ecommerce_routes;
import '../../../omni_channel/activity/models/omni_channel_activity.dart';
import '../../../omni_channel/activity/models/omni_channel_activity_action.dart';
import '../models/order_workspace_query_state.dart';

/// Ecommerce action contributor for order, fulfillment, and commerce activity.
Iterable<OmniChannelActivityAction> ecommerceOrderActivityActionContributor(
  OmniChannelActivityEntry entry,
) sync* {
  switch (entry.kind) {
    case OmniChannelActivityKind.order:
    case OmniChannelActivityKind.fulfillment:
    case OmniChannelActivityKind.payment:
      yield _orderWorkspaceAction(entry);
    case OmniChannelActivityKind.orderSync:
      if (_hasValue(entry.orderId) && !entry.requiresAttention) {
        yield _orderWorkspaceAction(entry);
      } else if (!_isPointOfSalesSource(entry)) {
        yield _commerceWorkspaceAction();
      }
    case OmniChannelActivityKind.channelSwitch:
    case OmniChannelActivityKind.switchAction:
    case OmniChannelActivityKind.system:
      if (!_isPointOfSalesSource(entry)) {
        yield _commerceWorkspaceAction();
      }
  }

  if (!_isPointOfSalesSource(entry)) {
    yield _commerceWorkspaceAction(priority: 20);
  }

  if (_hasValue(entry.orderId)) {
    yield _orderWorkspaceAction(
      entry,
      label: 'Open related order',
      tooltip: 'Open the order connected to this activity',
      priority: 30,
    );
  }
}

OmniChannelActivityAction _orderWorkspaceAction(
  OmniChannelActivityEntry entry, {
  String label = 'Open orders',
  String tooltip = 'Open the matching ecommerce order workspace',
  int priority = 0,
}) {
  return OmniChannelActivityAction(
    id: _orderWorkspaceActionId(entry),
    label: label,
    location: _orderWorkspaceLocation(entry),
    tooltip: tooltip,
    intent: OmniChannelActivityActionIntent.review,
    priority: priority,
  );
}

OmniChannelActivityAction _commerceWorkspaceAction({int priority = 0}) {
  return OmniChannelActivityAction(
    id: 'commerce-workspace',
    label: 'Open commerce',
    location: ecommerce_routes.Routes.routePath,
    tooltip: 'Open the commerce command workspace',
    intent: OmniChannelActivityActionIntent.inspect,
    priority: priority,
  );
}

String _orderWorkspaceLocation(OmniChannelActivityEntry entry) {
  final queryParameters = <String, String>{
    if (_hasValue(entry.orderId))
      OrderWorkspaceQueryState.searchQueryKey: entry.orderId!.trim(),
    if (_hasValue(entry.channelId))
      OrderWorkspaceQueryState.channelIdQueryKey: entry.channelId!.trim(),
    if (_hasValue(entry.fulfillmentModeKey))
      OrderWorkspaceQueryState.fulfillmentModeQueryKey:
          entry.fulfillmentModeKey!.trim(),
  };

  return Uri(
    path: _orderWorkspacePath(entry),
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
  ).toString();
}

String _orderWorkspaceActionId(OmniChannelActivityEntry entry) {
  return 'order-workspace:${_orderWorkspacePath(entry)}:'
      '${entry.channelId ?? ''}:${entry.fulfillmentModeKey ?? ''}:'
      '${entry.orderId ?? ''}';
}

String _orderWorkspacePath(OmniChannelActivityEntry entry) {
  final channel = (entry.channelId ?? entry.channelLabel ?? '').toLowerCase();
  if (channel.contains('marketplace')) {
    return ecommerce_routes.Routes.marketplaceOrdersPath;
  }
  if (channel.contains('delivery') || channel.contains('courier')) {
    return ecommerce_routes.Routes.deliveryOrdersPath;
  }
  if (channel.contains('wholesale')) {
    return ecommerce_routes.Routes.wholesaleOrdersPath;
  }

  return ecommerce_routes.Routes.ordersPath;
}

bool _isPointOfSalesSource(OmniChannelActivityEntry entry) {
  final sourceId = entry.sourceId.toLowerCase();
  final sourceLabel = entry.sourceLabel.toLowerCase();

  return sourceId.contains('point_of_sales') ||
      sourceId == 'pos' ||
      sourceLabel.contains('point of sale') ||
      sourceLabel.contains('cashier');
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
