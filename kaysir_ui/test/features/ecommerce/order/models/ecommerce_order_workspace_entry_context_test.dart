import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_entry_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route_resolution.dart';

void main() {
  test('entry context combines route and launch resolution', () {
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'marketplace_operations',
      sourceProfileLabel: 'Marketplace operations',
      orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
      workspaceViewId: 'marketplace_priority',
      workspaceViewLabel: 'Policy priority',
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );
    final routeResolution = ecommerceOrderWorkspaceRouteResolutionForLaunch(
      path: Routes.ordersPath,
      launchContext: launchContext,
    );

    final entryContext = OrderWorkspaceEntryContext.resolve(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      launchContext: launchContext,
      routeResolution: routeResolution,
    );

    expect(entryContext.appliedWorkspaceView?.id, 'marketplace_priority');
    expect(entryContext.shouldShowBanner, isTrue);
    expect(entryContext.usedLaunchFallback, isFalse);
    expect(entryContext.usedRouteDecision, isTrue);
    expect(entryContext.shouldOfferCanonicalRoute, isTrue);
    expect(
      entryContext.detailLabel,
      'Commerce workspace - marketplace_ops - Policy priority',
    );
    expect(entryContext.breadcrumbLabels, [
      'Commerce',
      'Orders',
      'Marketplace',
      'Policy priority',
    ]);
    final breadcrumbs = entryContext.breadcrumbs;
    expect(breadcrumbs.map((breadcrumb) => breadcrumb.location).take(3), [
      Routes.routePath,
      Routes.ordersPath,
      Routes.marketplaceOrdersPath,
    ]);
    expect(breadcrumbs.last.location, isNotEmpty);
    expect(
      breadcrumbs.take(3).every((breadcrumb) => breadcrumb.canOpen),
      isTrue,
    );
    expect(breadcrumbs.last.isCurrent, isTrue);
    expect(breadcrumbs.last.canOpen, isFalse);
    final workspaceLocation = Uri.parse(breadcrumbs.last.location);
    expect(workspaceLocation.path, Routes.marketplaceOrdersPath);
    expect(
      workspaceLocation.queryParameters[OrderWorkspaceLaunchContext
          .workspaceViewIdQueryKey],
      'marketplace_priority',
    );
    final marketplaceAllLocation = Uri.parse(
      entryContext.locationForWorkspaceView(
        ecommerceMarketplaceOrderWorkspaceProfile.workspaceViews.firstWhere(
          (view) => view.id == 'marketplace_all',
        ),
      ),
    );
    expect(marketplaceAllLocation.path, Routes.marketplaceOrdersPath);
    expect(
      marketplaceAllLocation.queryParameters[OrderWorkspaceLaunchContext
          .orderWorkspaceProfileIdQueryKey],
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
    expect(
      marketplaceAllLocation.queryParameters[OrderWorkspaceLaunchContext
          .workspaceViewIdQueryKey],
      'marketplace_all',
    );
    expect(
      entryContext.routeNote,
      'Upgraded generic orders path to Marketplace Orders.',
    );
    expect(
      entryContext.canonicalLaunchLocation,
      routeResolution.canonicalLaunchLocation,
    );
  });

  test('entry context reports launch fallback and default workspace', () {
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'marketplace_operations',
      sourceProfileLabel: 'Marketplace operations',
      orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
      workspaceViewId: 'legacy_priority',
      workspaceViewLabel: 'Legacy priority',
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );

    final entryContext = OrderWorkspaceEntryContext.resolve(
      profile: ecommerceMarketplaceOrderWorkspaceProfile,
      launchContext: launchContext,
    );

    expect(entryContext.appliedWorkspaceView?.id, 'marketplace_all');
    expect(entryContext.breadcrumbLabels, [
      'Commerce',
      'Orders',
      'Marketplace',
      'Marketplace all',
    ]);
    expect(entryContext.usedLaunchFallback, isTrue);
    expect(entryContext.usedRouteDecision, isFalse);
    expect(entryContext.shouldOfferCanonicalRoute, isFalse);
    expect(
      entryContext.launchFallbackMessage,
      'Requested Legacy priority is unavailable. Opened Marketplace all.',
    );
  });

  test('entry context stays quiet without a launch source', () {
    final entryContext = OrderWorkspaceEntryContext.resolve(
      profile: ecommerceDeliveryOrderWorkspaceProfile,
    );

    expect(entryContext.effectiveLaunchContext, isNull);
    expect(entryContext.shouldShowBanner, isFalse);
    expect(entryContext.appliedWorkspaceView?.id, 'delivery_all');
    expect(entryContext.breadcrumbLabels, [
      'Commerce',
      'Orders',
      'Delivery',
      'Delivery all',
    ]);
    expect(entryContext.shouldOfferCanonicalRoute, isFalse);
    expect(entryContext.detailLabel, isEmpty);
    expect(entryContext.routeNote, isEmpty);
  });

  test('entry context names the all-commerce profile breadcrumb', () {
    final entryContext = OrderWorkspaceEntryContext.resolve(
      profile: ecommerceAllCommerceOrderWorkspaceProfile,
    );

    expect(entryContext.breadcrumbLabels, [
      'Commerce',
      'Orders',
      'All commerce',
      'All orders',
    ]);
  });
}
