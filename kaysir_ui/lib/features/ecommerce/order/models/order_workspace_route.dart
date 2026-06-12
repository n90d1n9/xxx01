import '../../dashboard/routes.dart';
import 'order_workspace_profile.dart';

enum OrderWorkspaceRouteIssueType {
  blankName,
  blankPath,
  duplicatePath,
  duplicateProfileId,
  unregisteredProfile,
}

class OrderWorkspaceRouteIssue {
  final OrderWorkspaceRouteIssueType type;
  final String message;
  final String? path;
  final String? profileId;

  const OrderWorkspaceRouteIssue({
    required this.type,
    required this.message,
    this.path,
    this.profileId,
  });

  @override
  String toString() => message;
}

class OrderWorkspaceRouteDefinition {
  final String name;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String path;
  final OrderWorkspaceProfile profile;

  const OrderWorkspaceRouteDefinition({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.path,
    required this.profile,
  });
}

const ecommerceAllCommerceOrderWorkspaceRoute = OrderWorkspaceRouteDefinition(
  name: 'Orders',
  title: 'Orders',
  subtitle: 'Omnichannel fulfillment',
  description:
      'Order operations for fulfillment, SLA, settlement, promise policy, delivery, pickup, and channel health.',
  icon: 'ecommerce-orders',
  path: Routes.ordersPath,
  profile: ecommerceAllCommerceOrderWorkspaceProfile,
);

const ecommerceMarketplaceOrderWorkspaceRoute = OrderWorkspaceRouteDefinition(
  name: 'Marketplace Orders',
  title: 'Marketplace Orders',
  subtitle: 'Marketplace fulfillment',
  description:
      'Marketplace order workspace for policy-bound fulfillment, marketplace handoff, settlement matching, and channel exception handling.',
  icon: 'marketplace-orders',
  path: Routes.marketplaceOrdersPath,
  profile: ecommerceMarketplaceOrderWorkspaceProfile,
);

const ecommerceDeliveryOrderWorkspaceRoute = OrderWorkspaceRouteDefinition(
  name: 'Delivery Orders',
  title: 'Delivery Orders',
  subtitle: 'Courier operations',
  description:
      'Delivery-app order workspace for prep-time promises, courier handoff, external settlement, and time-sensitive fulfillment.',
  icon: 'delivery-orders',
  path: Routes.deliveryOrdersPath,
  profile: ecommerceDeliveryOrderWorkspaceProfile,
);

const ecommerceWholesaleOrderWorkspaceRoute = OrderWorkspaceRouteDefinition(
  name: 'Wholesale Orders',
  title: 'Wholesale Orders',
  subtitle: 'B2B fulfillment',
  description:
      'Wholesale order workspace for account staging, B2B fulfillment, customer pickup, carrier handoff, and account blockers.',
  icon: 'wholesale-orders',
  path: Routes.wholesaleOrdersPath,
  profile: ecommerceWholesaleOrderWorkspaceProfile,
);

const ecommerceSpecializedOrderWorkspaceRouteDefinitions =
    <OrderWorkspaceRouteDefinition>[
      ecommerceMarketplaceOrderWorkspaceRoute,
      ecommerceDeliveryOrderWorkspaceRoute,
      ecommerceWholesaleOrderWorkspaceRoute,
    ];

const ecommerceDefaultOrderWorkspaceRouteDefinitions =
    <OrderWorkspaceRouteDefinition>[
      ecommerceAllCommerceOrderWorkspaceRoute,
      ...ecommerceSpecializedOrderWorkspaceRouteDefinitions,
    ];

OrderWorkspaceRouteDefinition ecommerceOrderWorkspaceRouteForProfileId({
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
  required String profileId,
}) {
  final normalizedProfileId = profileId.trim();
  for (final route in routes) {
    if (route.profile.id == normalizedProfileId) return route;
  }

  return ecommerceAllCommerceOrderWorkspaceRoute;
}

OrderWorkspaceRouteDefinition ecommerceOrderWorkspaceRouteForPath({
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
  required String path,
}) {
  final normalizedPath = path.trim();
  for (final route in routes) {
    if (route.path == normalizedPath) return route;
  }

  return ecommerceAllCommerceOrderWorkspaceRoute;
}

List<OrderWorkspaceRouteIssue> validateOrderWorkspaceRoutes({
  List<OrderWorkspaceRouteDefinition> routes =
      ecommerceDefaultOrderWorkspaceRouteDefinitions,
  List<OrderWorkspaceProfile> profiles = ecommerceDefaultOrderWorkspaceProfiles,
}) {
  final issues = <OrderWorkspaceRouteIssue>[];
  final registeredProfileIds = profiles.map((profile) => profile.id).toSet();
  final seenPaths = <String>{};
  final reportedPaths = <String>{};
  final seenProfileIds = <String>{};
  final reportedProfileIds = <String>{};

  for (final route in routes) {
    final routeName = route.name.trim();
    final routePath = route.path.trim();
    final profileId = route.profile.id.trim();

    if (routeName.isEmpty) {
      issues.add(
        OrderWorkspaceRouteIssue(
          type: OrderWorkspaceRouteIssueType.blankName,
          path: routePath,
          profileId: profileId,
          message:
              ' order workspace route for "$profileId" cannot have a blank name.',
        ),
      );
    }
    if (routePath.isEmpty) {
      issues.add(
        OrderWorkspaceRouteIssue(
          type: OrderWorkspaceRouteIssueType.blankPath,
          profileId: profileId,
          message:
              ' order workspace route "$routeName" cannot have a blank path.',
        ),
      );
    } else if (!seenPaths.add(routePath) && reportedPaths.add(routePath)) {
      issues.add(
        OrderWorkspaceRouteIssue(
          type: OrderWorkspaceRouteIssueType.duplicatePath,
          path: routePath,
          profileId: profileId,
          message:
              'Duplicate ecommerce order workspace route path "$routePath" found.',
        ),
      );
    }

    if (!seenProfileIds.add(profileId) && reportedProfileIds.add(profileId)) {
      issues.add(
        OrderWorkspaceRouteIssue(
          type: OrderWorkspaceRouteIssueType.duplicateProfileId,
          path: routePath,
          profileId: profileId,
          message:
              'Duplicate ecommerce order workspace route profile "$profileId" found.',
        ),
      );
    }
    if (!registeredProfileIds.contains(profileId)) {
      issues.add(
        OrderWorkspaceRouteIssue(
          type: OrderWorkspaceRouteIssueType.unregisteredProfile,
          path: routePath,
          profileId: profileId,
          message:
              ' order workspace route "$routeName" references unregistered profile "$profileId".',
        ),
      );
    }
  }

  return List.unmodifiable(issues);
}
