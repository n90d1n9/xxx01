import '../../dashboard/routes.dart';
import 'order_workspace_launch_context.dart';
import 'order_workspace_profile.dart';
import 'order_workspace_route.dart';
import 'order_workspace_view.dart';

enum OrderWorkspaceRouteResolutionStatus {
  pathMatched,
  genericPathUpgraded,
  requestedProfileUnavailable,
  specializedPathAuthoritative,
}

extension OrderWorkspaceRouteResolutionStatusCopy
    on OrderWorkspaceRouteResolutionStatus {
  String get label {
    return switch (this) {
      OrderWorkspaceRouteResolutionStatus.pathMatched => 'Path matched',
      OrderWorkspaceRouteResolutionStatus.genericPathUpgraded =>
        'Generic path upgraded',
      OrderWorkspaceRouteResolutionStatus.requestedProfileUnavailable =>
        'Requested profile unavailable',
      OrderWorkspaceRouteResolutionStatus.specializedPathAuthoritative =>
        'Specialized path authoritative',
    };
  }
}

class OrderWorkspaceRouteResolution {
  final OrderWorkspaceRouteDefinition route;
  final OrderWorkspaceRouteDefinition pathRoute;
  final OrderWorkspaceLaunchContext? launchContext;
  final String requestedProfileId;
  final OrderWorkspaceRouteResolutionStatus status;

  const OrderWorkspaceRouteResolution({
    required this.route,
    required this.pathRoute,
    this.launchContext,
    required this.requestedProfileId,
    required this.status,
  });

  bool get upgradedGenericPath {
    return status == OrderWorkspaceRouteResolutionStatus.genericPathUpgraded;
  }

  bool get usedPathAuthority {
    return status ==
        OrderWorkspaceRouteResolutionStatus.specializedPathAuthoritative;
  }

  bool get requestedProfileMissing {
    return status ==
        OrderWorkspaceRouteResolutionStatus.requestedProfileUnavailable;
  }

  String get canonicalPath => route.path;

  OrderWorkspaceLaunchContext get canonicalLaunchContext {
    final original = launchContext;
    final workspaceView = _canonicalWorkspaceView;

    return OrderWorkspaceLaunchContext(
      sourceProfileId: original?.sourceProfileId ?? '',
      sourceProfileLabel: original?.sourceProfileLabel ?? '',
      orderWorkspaceProfileId: route.profile.id,
      workspaceViewId: workspaceView?.id ?? '',
      workspaceViewLabel: workspaceView?.label ?? '',
      reason: original?.reason ?? OrderWorkspaceLaunchReason.commerceWorkspace,
    );
  }

  String get canonicalLaunchLocation {
    return canonicalLaunchContext.locationForPath(canonicalPath);
  }

  String get message {
    return switch (status) {
      OrderWorkspaceRouteResolutionStatus.pathMatched =>
        'Opened ${route.title}.',
      OrderWorkspaceRouteResolutionStatus.genericPathUpgraded =>
        'Upgraded generic orders path to ${route.title}.',
      OrderWorkspaceRouteResolutionStatus.requestedProfileUnavailable =>
        'Requested order profile $requestedProfileId is unavailable. Opened ${route.title}.',
      OrderWorkspaceRouteResolutionStatus.specializedPathAuthoritative =>
        'Opened ${route.title} from the specialized route path.',
    };
  }

  OrderWorkspaceView? get _canonicalWorkspaceView {
    final original = launchContext;
    if (original != null) {
      final requestedView = ecommerceOrderWorkspaceViewById(
        views: route.profile.workspaceViews,
        viewId: original.workspaceViewId,
      );
      if (requestedView != null) return requestedView;
    }

    return ecommerceInitialOrderWorkspaceViewForProfile(route.profile);
  }
}

OrderWorkspaceRouteResolution ecommerceOrderWorkspaceRouteResolutionForLaunch({
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
  required String path,
  OrderWorkspaceLaunchContext? launchContext,
}) {
  final pathRoute = ecommerceOrderWorkspaceRouteForPath(
    routes: routes,
    path: path,
  );
  final requestedProfileId =
      launchContext?.orderWorkspaceProfileId.trim() ?? '';

  if (pathRoute.path != Routes.ordersPath) {
    final requestedDifferentProfile =
        requestedProfileId.isNotEmpty &&
        requestedProfileId != pathRoute.profile.id;
    return OrderWorkspaceRouteResolution(
      route: pathRoute,
      pathRoute: pathRoute,
      launchContext: launchContext,
      requestedProfileId: requestedProfileId,
      status:
          requestedDifferentProfile
              ? OrderWorkspaceRouteResolutionStatus.specializedPathAuthoritative
              : OrderWorkspaceRouteResolutionStatus.pathMatched,
    );
  }

  if (requestedProfileId.isEmpty) {
    return OrderWorkspaceRouteResolution(
      route: pathRoute,
      pathRoute: pathRoute,
      launchContext: launchContext,
      requestedProfileId: requestedProfileId,
      status: OrderWorkspaceRouteResolutionStatus.pathMatched,
    );
  }

  final profileRoute = ecommerceOrderWorkspaceRouteForProfileId(
    routes: routes,
    profileId: requestedProfileId,
  );
  if (profileRoute.profile.id != requestedProfileId) {
    return OrderWorkspaceRouteResolution(
      route: pathRoute,
      pathRoute: pathRoute,
      launchContext: launchContext,
      requestedProfileId: requestedProfileId,
      status: OrderWorkspaceRouteResolutionStatus.requestedProfileUnavailable,
    );
  }

  final status =
      profileRoute.path == pathRoute.path
          ? OrderWorkspaceRouteResolutionStatus.pathMatched
          : OrderWorkspaceRouteResolutionStatus.genericPathUpgraded;

  return OrderWorkspaceRouteResolution(
    route: profileRoute,
    pathRoute: pathRoute,
    launchContext: launchContext,
    requestedProfileId: requestedProfileId,
    status: status,
  );
}

OrderWorkspaceRouteDefinition ecommerceOrderWorkspaceRouteForLaunch({
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
  required String path,
  OrderWorkspaceLaunchContext? launchContext,
}) {
  return ecommerceOrderWorkspaceRouteResolutionForLaunch(
    routes: routes,
    path: path,
    launchContext: launchContext,
  ).route;
}
