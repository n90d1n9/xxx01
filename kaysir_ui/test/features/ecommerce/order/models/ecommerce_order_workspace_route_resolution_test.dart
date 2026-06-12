import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route_resolution.dart';

void main() {
  test(
    'route resolution upgrades generic order paths by requested profile',
    () {
      const launchContext = OrderWorkspaceLaunchContext(
        sourceProfileId: 'marketplace_operations',
        sourceProfileLabel: 'Marketplace operations',
        orderWorkspaceProfileId: ecommerceMarketplaceOrderWorkspaceProfileId,
        workspaceViewId: 'marketplace_priority',
        workspaceViewLabel: 'Policy priority',
        reason: OrderWorkspaceLaunchReason.commerceWorkspace,
      );

      final resolution = ecommerceOrderWorkspaceRouteResolutionForLaunch(
        path: Routes.ordersPath,
        launchContext: launchContext,
      );

      expect(
        resolution.route.profile,
        ecommerceMarketplaceOrderWorkspaceProfile,
      );
      expect(
        resolution.pathRoute.profile,
        ecommerceAllCommerceOrderWorkspaceProfile,
      );
      expect(
        resolution.status,
        OrderWorkspaceRouteResolutionStatus.genericPathUpgraded,
      );
      expect(resolution.upgradedGenericPath, isTrue);
      expect(resolution.canonicalPath, Routes.marketplaceOrdersPath);
      expect(
        resolution.message,
        'Upgraded generic orders path to Marketplace Orders.',
      );

      final canonicalUri = Uri.parse(resolution.canonicalLaunchLocation);
      expect(canonicalUri.path, Routes.marketplaceOrdersPath);
      expect(
        canonicalUri.queryParameters['source_profile_id'],
        'marketplace_operations',
      );
      expect(
        canonicalUri.queryParameters['order_workspace_profile_id'],
        ecommerceMarketplaceOrderWorkspaceProfileId,
      );
      expect(
        canonicalUri.queryParameters['workspace_view_id'],
        'marketplace_priority',
      );
    },
  );

  test('route resolution falls back when requested profile is unavailable', () {
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'legacy',
      sourceProfileLabel: 'Legacy profile',
      orderWorkspaceProfileId: 'retired_profile',
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );

    final resolution = ecommerceOrderWorkspaceRouteResolutionForLaunch(
      path: Routes.ordersPath,
      launchContext: launchContext,
    );

    expect(resolution.route.profile, ecommerceAllCommerceOrderWorkspaceProfile);
    expect(
      resolution.status,
      OrderWorkspaceRouteResolutionStatus.requestedProfileUnavailable,
    );
    expect(resolution.requestedProfileMissing, isTrue);
    expect(
      resolution.message,
      'Requested order profile retired_profile is unavailable. Opened Orders.',
    );
    final canonicalUri = Uri.parse(resolution.canonicalLaunchLocation);
    expect(canonicalUri.path, Routes.ordersPath);
    expect(
      canonicalUri.queryParameters['order_workspace_profile_id'],
      ecommerceAllCommerceOrderWorkspaceProfileId,
    );
    expect(canonicalUri.queryParameters['workspace_view_id'], 'all_orders');
  });

  test('route resolution keeps specialized paths authoritative', () {
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'wholesale',
      sourceProfileLabel: 'Wholesale profile',
      orderWorkspaceProfileId: ecommerceWholesaleOrderWorkspaceProfileId,
      workspaceViewId: 'wholesale_priority',
      workspaceViewLabel: 'Account blockers',
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );

    final resolution = ecommerceOrderWorkspaceRouteResolutionForLaunch(
      path: Routes.deliveryOrdersPath,
      launchContext: launchContext,
    );

    expect(resolution.route.profile, ecommerceDeliveryOrderWorkspaceProfile);
    expect(
      resolution.status,
      OrderWorkspaceRouteResolutionStatus.specializedPathAuthoritative,
    );
    expect(resolution.usedPathAuthority, isTrue);
    expect(
      resolution.message,
      'Opened Delivery Orders from the specialized route path.',
    );
    final canonicalUri = Uri.parse(resolution.canonicalLaunchLocation);
    expect(canonicalUri.path, Routes.deliveryOrdersPath);
    expect(
      canonicalUri.queryParameters['order_workspace_profile_id'],
      ecommerceDeliveryOrderWorkspaceProfileId,
    );
    expect(canonicalUri.queryParameters['workspace_view_id'], 'delivery_all');
  });

  test('route convenience lookup returns the resolved route', () {
    const launchContext = OrderWorkspaceLaunchContext(
      sourceProfileId: 'delivery_ops',
      sourceProfileLabel: 'Delivery profile',
      orderWorkspaceProfileId: ecommerceDeliveryOrderWorkspaceProfileId,
      reason: OrderWorkspaceLaunchReason.commerceWorkspace,
    );

    expect(
      ecommerceOrderWorkspaceRouteForLaunch(
        path: Routes.ordersPath,
        launchContext: launchContext,
      ).profile,
      ecommerceDeliveryOrderWorkspaceProfile,
    );
  });
}
