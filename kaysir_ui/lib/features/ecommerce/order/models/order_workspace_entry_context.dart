import '../../dashboard/routes.dart';
import 'order_workspace_breadcrumb.dart';
import 'order_workspace_launch_context.dart';
import 'order_workspace_launch_resolution.dart';
import 'order_workspace_profile.dart';
import 'order_workspace_query_state.dart';
import 'order_workspace_route.dart';
import 'order_workspace_route_resolution.dart';
import 'order_workspace_view.dart';

class OrderWorkspaceEntryContext {
  final OrderWorkspaceProfile profile;
  final OrderWorkspaceLaunchContext? launchContext;
  final OrderWorkspaceLaunchResolution? launchResolution;
  final OrderWorkspaceRouteResolution? routeResolution;

  const OrderWorkspaceEntryContext({
    required this.profile,
    this.launchContext,
    this.launchResolution,
    this.routeResolution,
  });

  factory OrderWorkspaceEntryContext.resolve({
    required OrderWorkspaceProfile profile,
    OrderWorkspaceLaunchContext? launchContext,
    OrderWorkspaceRouteResolution? routeResolution,
  }) {
    return OrderWorkspaceEntryContext(
      profile: profile,
      launchContext: launchContext,
      launchResolution:
          launchContext == null
              ? null
              : ecommerceOrderWorkspaceLaunchResolutionFor(
                profile: profile,
                launchContext: launchContext,
              ),
      routeResolution: routeResolution,
    );
  }

  OrderWorkspaceLaunchContext? get effectiveLaunchContext {
    return launchResolution?.launchContext ?? launchContext;
  }

  OrderWorkspaceView? get appliedWorkspaceView {
    return launchResolution?.appliedWorkspaceView ??
        ecommerceInitialOrderWorkspaceViewForProfile(profile);
  }

  bool get shouldShowBanner => effectiveLaunchContext != null;

  bool get usedLaunchFallback => launchResolution?.usedFallback ?? false;

  bool get usedRouteDecision {
    final resolution = routeResolution;
    if (resolution == null) return false;

    return resolution.status != OrderWorkspaceRouteResolutionStatus.pathMatched;
  }

  bool get shouldOfferCanonicalRoute {
    return usedRouteDecision && canonicalLaunchLocation.trim().isNotEmpty;
  }

  List<String> get breadcrumbLabels {
    return List.unmodifiable(breadcrumbs.map((breadcrumb) => breadcrumb.label));
  }

  List<OrderWorkspaceBreadcrumb> get breadcrumbs {
    final workspaceView = appliedWorkspaceView;
    final workspaceContext =
        workspaceView == null
            ? null
            : OrderWorkspaceContext.fromView(workspaceView);

    return breadcrumbsFor(activeWorkspace: workspaceContext);
  }

  List<OrderWorkspaceBreadcrumb> breadcrumbsFor({
    OrderWorkspaceContext? activeWorkspace,
  }) {
    final profileRoute = ecommerceOrderWorkspaceRouteForProfileId(
      profileId: profile.id,
    );
    final profileLabel = _profileBreadcrumbLabel(profile.title);
    final workspace = activeWorkspace;

    return List.unmodifiable(
      [
        const OrderWorkspaceBreadcrumb(
          id: 'commerce',
          label: 'Commerce',
          location: Routes.routePath,
        ),
        const OrderWorkspaceBreadcrumb(
          id: 'orders',
          label: 'Orders',
          location: Routes.ordersPath,
        ),
        OrderWorkspaceBreadcrumb(
          id: 'profile',
          label: profileLabel,
          location: profileRoute.path,
        ),
        if (workspace != null)
          OrderWorkspaceBreadcrumb(
            id: 'workspace',
            label: workspace.label,
            location: locationForWorkspaceContext(workspace),
            isCurrent: true,
          ),
      ].where((breadcrumb) => breadcrumb.label.trim().isNotEmpty),
    );
  }

  String locationForWorkspaceView(OrderWorkspaceView view) {
    return locationForWorkspaceContext(OrderWorkspaceContext.fromView(view));
  }

  String locationForWorkspaceContext(OrderWorkspaceContext workspace) {
    final profileRoute = ecommerceOrderWorkspaceRouteForProfileId(
      profileId: profile.id,
    );

    if (workspace.isPreset) {
      return _workspaceLocation(profileRoute.path, workspace);
    }

    return OrderWorkspaceQueryState(
      filter: workspace.filter,
      sortMode: workspace.sortMode,
    ).locationForPath(profileRoute.path);
  }

  String get detailLabel {
    final resolution = launchResolution;
    if (resolution != null) return resolution.detailLabel;

    final context = effectiveLaunchContext;
    if (context == null) return '';

    return [
      context.reason.label,
      context.orderProfileDisplayLabel,
      if (context.hasWorkspaceView) context.workspaceViewDisplayLabel,
    ].join(' - ');
  }

  String get launchFallbackMessage {
    return launchResolution?.fallbackMessage ?? '';
  }

  String get routeNote {
    final resolution = routeResolution;
    if (resolution == null) return '';
    if (resolution.status == OrderWorkspaceRouteResolutionStatus.pathMatched) {
      return '';
    }

    return resolution.message;
  }

  String get canonicalPath {
    return routeResolution?.canonicalPath ?? '';
  }

  String get canonicalLaunchLocation {
    return routeResolution?.canonicalLaunchLocation ?? '';
  }

  String _workspaceLocation(String path, OrderWorkspaceContext workspace) {
    final launch = effectiveLaunchContext;

    return OrderWorkspaceLaunchContext(
      sourceProfileId: launch?.sourceProfileId ?? '',
      sourceProfileLabel: launch?.sourceProfileLabel ?? '',
      orderWorkspaceProfileId: profile.id,
      workspaceViewId: workspace.id,
      workspaceViewLabel: workspace.label,
      reason: launch?.reason ?? OrderWorkspaceLaunchReason.commerceWorkspace,
    ).locationForPath(path);
  }

  String _profileBreadcrumbLabel(String title) {
    final normalizedTitle = title.trim();
    if (normalizedTitle == 'Orders') return 'All commerce';

    const suffix = ' Orders';
    if (normalizedTitle.endsWith(suffix) &&
        normalizedTitle.length > suffix.length) {
      return normalizedTitle.substring(
        0,
        normalizedTitle.length - suffix.length,
      );
    }

    return normalizedTitle;
  }
}
