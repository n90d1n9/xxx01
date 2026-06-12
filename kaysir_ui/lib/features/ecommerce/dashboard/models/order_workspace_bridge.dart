import '../../order/models/order_workspace_launch_context.dart';
import '../../order/models/order_workspace_profile.dart';
import '../../order/models/order_workspace_route.dart';
import '../../order/models/order_workspace_view.dart';
import '../routes.dart';
import 'action.dart';
import 'destination.dart';
import 'product_profile.dart';

class OrderWorkspaceBridge {
  final ProductProfile productProfile;
  final OrderWorkspaceRouteDefinition route;
  final String requestedProfileId;

  const OrderWorkspaceBridge({
    required this.productProfile,
    required this.route,
    required this.requestedProfileId,
  });

  String get resolvedProfileId => route.profile.id;

  String get displayProfileId {
    if (requestedProfileId.isEmpty) return resolvedProfileId;
    return requestedProfileId;
  }

  bool get resolvedByFallback {
    if (requestedProfileId.isEmpty) return true;
    return requestedProfileId != resolvedProfileId;
  }

  String get channelSummary {
    return route.profile.salesChannels
        .map((channel) => channel.label)
        .join(', ');
  }

  String get workspaceViewCountLabel {
    return orderWorkspaceViewCountLabel(route.profile.workspaceViews.length);
  }

  String get routeShortTitle {
    return orderWorkspaceShortTitle(route.title);
  }

  String get compactLabel {
    final shortTitle = routeShortTitle;
    if (shortTitle.isEmpty || shortTitle == 'Orders') return 'Orders';

    return 'Orders: $shortTitle';
  }

  bool get isSpecializedOrderRoute {
    return ecommerceSpecializedOrderWorkspaceRouteDefinitions.any(
      (definition) => definition.path == route.path,
    );
  }

  OrderWorkspaceView? get initialWorkspaceView {
    return ecommerceInitialOrderWorkspaceViewForProfile(route.profile);
  }

  OrderWorkspaceLaunchContext launchContext({
    OrderWorkspaceLaunchReason reason =
        OrderWorkspaceLaunchReason.commerceWorkspace,
  }) {
    final workspaceView = initialWorkspaceView;

    return OrderWorkspaceLaunchContext(
      sourceProfileId: productProfile.id,
      sourceProfileLabel: productProfile.label,
      orderWorkspaceProfileId: route.profile.id,
      workspaceViewId: workspaceView?.id ?? '',
      workspaceViewLabel: workspaceView?.label ?? '',
      reason: reason,
    );
  }

  String launchLocation({
    OrderWorkspaceLaunchReason reason =
        OrderWorkspaceLaunchReason.commerceWorkspace,
  }) {
    return launchContext(reason: reason).locationForPath(route.path);
  }
}

OrderWorkspaceBridge orderWorkspaceBridgeForProfile({
  required ProductProfile productProfile,
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
}) {
  final requestedProfileId =
      productProfile.preferredOrderWorkspaceProfileId.trim();
  final route = ecommerceOrderWorkspaceRouteForProfileId(
    routes: routes,
    profileId: requestedProfileId,
  );

  return OrderWorkspaceBridge(
    productProfile: productProfile,
    route: route,
    requestedProfileId: requestedProfileId,
  );
}

String primaryOrderRoutePathFor({
  required ProductProfile productProfile,
  List<Destination> destinations = const [],
  List<Action> actions = const [],
}) {
  final bridge = orderWorkspaceBridgeForProfile(productProfile: productProfile);
  if (bridge.isSpecializedOrderRoute) return bridge.route.path;

  for (final destination in destinations) {
    if (isSpecializedOrderRoute(destination.routePath)) {
      return destination.routePath;
    }
  }

  for (final action in actions) {
    if (isSpecializedOrderRoute(action.routePath)) {
      return action.routePath;
    }
  }

  return ecommerceOperationalOrderRouteForCapabilities(
    productProfile.capabilities,
  );
}

String primaryOrderLaunchLocationFor({
  required ProductProfile productProfile,
  List<Destination> destinations = const [],
  List<Action> actions = const [],
  OrderWorkspaceLaunchReason reason =
      OrderWorkspaceLaunchReason.commerceWorkspace,
}) {
  final routePath = primaryOrderRoutePathFor(
    productProfile: productProfile,
    destinations: destinations,
    actions: actions,
  );
  final route = ecommerceOrderWorkspaceRouteForPath(path: routePath);
  final workspaceView = ecommerceInitialOrderWorkspaceViewForProfile(
    route.profile,
  );

  return OrderWorkspaceLaunchContext(
    sourceProfileId: productProfile.id,
    sourceProfileLabel: productProfile.label,
    orderWorkspaceProfileId: route.profile.id,
    workspaceViewId: workspaceView?.id ?? '',
    workspaceViewLabel: workspaceView?.label ?? '',
    reason: reason,
  ).locationForPath(routePath);
}

bool isSpecializedOrderRoute(String routePath) {
  return switch (routePath.trim()) {
    Routes.marketplaceOrdersPath ||
    Routes.deliveryOrdersPath ||
    Routes.wholesaleOrdersPath => true,
    _ => false,
  };
}

String orderWorkspaceViewCountLabel(int count) {
  if (count == 1) return '1 workspace view';
  return '$count workspace views';
}

String orderWorkspaceShortTitle(String title) {
  final normalizedTitle = title.trim();
  const suffix = ' Orders';
  if (normalizedTitle.endsWith(suffix) &&
      normalizedTitle.length > suffix.length) {
    return normalizedTitle.substring(0, normalizedTitle.length - suffix.length);
  }

  return normalizedTitle;
}
