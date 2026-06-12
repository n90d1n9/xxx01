import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_route.dart';

void main() {
  test('default ecommerce order workspace routes map paths to profiles', () {
    expect(validateOrderWorkspaceRoutes(), isEmpty);
    expect(
      ecommerceDefaultOrderWorkspaceRouteDefinitions.map((route) => route.path),
      [
        Routes.ordersPath,
        Routes.marketplaceOrdersPath,
        Routes.deliveryOrdersPath,
        Routes.wholesaleOrdersPath,
      ],
    );
    expect(
      ecommerceDefaultOrderWorkspaceRouteDefinitions.map(
        (route) => route.profile.id,
      ),
      ecommerceDefaultOrderWorkspaceProfiles.map((profile) => profile.id),
    );
    expect(ecommerceAllCommerceOrderWorkspaceRoute.name, 'Orders');
    expect(ecommerceAllCommerceOrderWorkspaceRoute.title, 'Orders');
  });

  test('route lookup falls back to the all-commerce route', () {
    expect(
      ecommerceOrderWorkspaceRouteForProfileId(
        profileId: ecommerceMarketplaceOrderWorkspaceProfile.id,
      ).path,
      Routes.marketplaceOrdersPath,
    );
    expect(
      ecommerceOrderWorkspaceRouteForPath(
        path: Routes.deliveryOrdersPath,
      ).profile,
      ecommerceDeliveryOrderWorkspaceProfile,
    );
    expect(
      ecommerceOrderWorkspaceRouteForProfileId(profileId: 'unknown').profile,
      ecommerceAllCommerceOrderWorkspaceProfile,
    );
    expect(
      ecommerceOrderWorkspaceRouteForPath(path: '/missing').path,
      Routes.ordersPath,
    );
  });

  test('route validation catches unsafe route registration shapes', () {
    final issues = validateOrderWorkspaceRoutes(
      routes: [
        ecommerceMarketplaceOrderWorkspaceRoute,
        const OrderWorkspaceRouteDefinition(
          name: '',
          title: 'Duplicate route',
          subtitle: 'Duplicate',
          description: 'Duplicate',
          icon: 'marketplace-orders',
          path: Routes.marketplaceOrdersPath,
          profile: ecommerceMarketplaceOrderWorkspaceProfile,
        ),
        const OrderWorkspaceRouteDefinition(
          name: 'Unknown profile route',
          title: 'Unknown profile route',
          subtitle: 'Unknown',
          description: 'Unknown',
          icon: 'ecommerce-orders',
          path: '/commerce/orders/unknown',
          profile: OrderWorkspaceProfile(
            id: 'unknown_profile',
            title: 'Unknown',
            description: 'Unknown',
            salesChannels: [],
          ),
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll([
        OrderWorkspaceRouteIssueType.blankName,
        OrderWorkspaceRouteIssueType.duplicatePath,
        OrderWorkspaceRouteIssueType.duplicateProfileId,
        OrderWorkspaceRouteIssueType.unregisteredProfile,
      ]),
    );
  });
}
