import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/action.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/destination.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/order_workspace_bridge.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_profile.dart';

void main() {
  test('bridge resolves product profile preferred order workspace route', () {
    final bridge = orderWorkspaceBridgeForProfile(
      productProfile: ProductProfile.marketplaceOperations,
    );

    expect(bridge.route.path, Routes.marketplaceOrdersPath);
    expect(
      bridge.displayProfileId,
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
    expect(
      bridge.resolvedProfileId,
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
    expect(bridge.resolvedByFallback, isFalse);
    expect(bridge.isSpecializedOrderRoute, isTrue);
    expect(bridge.channelSummary, 'Marketplace');
    expect(bridge.workspaceViewCountLabel, '4 workspace views');
    expect(bridge.routeShortTitle, 'Marketplace');
    expect(bridge.compactLabel, 'Orders: Marketplace');

    final launchUri = Uri.parse(
      bridge.launchLocation(reason: OrderWorkspaceLaunchReason.profileDetails),
    );
    expect(launchUri.path, Routes.marketplaceOrdersPath);
    expect(
      launchUri.queryParameters['source_profile_id'],
      'marketplace_operations',
    );
    expect(
      launchUri.queryParameters['order_workspace_profile_id'],
      ecommerceMarketplaceOrderWorkspaceProfileId,
    );
    expect(launchUri.queryParameters['workspace_view_id'], 'marketplace_all');
    expect(
      launchUri.queryParameters['workspace_view_label'],
      'Marketplace all',
    );
    expect(launchUri.queryParameters['launch_reason'], 'profile_details');
  });

  test(
    'bridge exposes fallback when product profile references unknown order profile',
    () {
      final bridge = orderWorkspaceBridgeForProfile(
        productProfile: ProductProfile.standard.copyWith(
          preferredOrderWorkspaceProfileId: 'missing_profile',
        ),
      );

      expect(bridge.route.path, Routes.ordersPath);
      expect(bridge.displayProfileId, 'missing_profile');
      expect(
        bridge.resolvedProfileId,
        ecommerceAllCommerceOrderWorkspaceProfileId,
      );
      expect(bridge.resolvedByFallback, isTrue);
      expect(bridge.isSpecializedOrderRoute, isFalse);
    },
  );

  test(
    'primary route selection prefers explicit specialized order profile',
    () {
      final routePath = primaryOrderRoutePathFor(
        productProfile: ProductProfile.standard.copyWith(
          preferredOrderWorkspaceProfileId:
              ecommerceWholesaleOrderWorkspaceProfileId,
        ),
        destinations: const [
          Destination(
            id: 'marketplace_queue',
            title: 'Marketplace queue',
            subtitle: 'Open marketplace orders.',
            routePath: Routes.marketplaceOrdersPath,
            metricLabel: 'Orders',
            metricValue: '0',
            actionLabel: 'Open',
            icon: Icons.storefront_outlined,
            tone: DestinationTone.secondary,
          ),
        ],
      );

      expect(routePath, Routes.wholesaleOrdersPath);
    },
  );

  test(
    'primary route selection can fall back through destinations, actions, and capabilities',
    () {
      final destinationRoutePath = primaryOrderRoutePathFor(
        productProfile: ProductProfile.standard,
        destinations: const [
          Destination(
            id: 'delivery_queue',
            title: 'Delivery queue',
            subtitle: 'Open delivery orders.',
            routePath: Routes.deliveryOrdersPath,
            metricLabel: 'Orders',
            metricValue: '0',
            actionLabel: 'Open',
            icon: Icons.delivery_dining_outlined,
            tone: DestinationTone.secondary,
          ),
        ],
      );
      final actionRoutePath = primaryOrderRoutePathFor(
        productProfile: ProductProfile.standard,
        actions: const [
          Action(
            id: 'open_marketplace_orders',
            title: 'Open marketplace orders',
            description: 'Review marketplace orders.',
            actionLabel: 'Open',
            routePath: Routes.marketplaceOrdersPath,
            icon: Icons.storefront_outlined,
            tone: ActionTone.secondary,
            priority: 1,
          ),
        ],
      );
      final capabilityRoutePath = primaryOrderRoutePathFor(
        productProfile: ProductProfile.standard.copyWith(
          id: 'delivery_only',
          label: 'Delivery only',
          capabilities: const [ProductCapability.pickupDelivery],
        ),
      );

      expect(destinationRoutePath, Routes.deliveryOrdersPath);
      expect(actionRoutePath, Routes.marketplaceOrdersPath);
      expect(capabilityRoutePath, Routes.deliveryOrdersPath);
    },
  );

  test('primary order launch location carries product profile context', () {
    final location = primaryOrderLaunchLocationFor(
      productProfile: ProductProfile.marketplaceOperations,
    );
    final uri = Uri.parse(location);

    expect(uri.path, Routes.marketplaceOrdersPath);
    expect(uri.queryParameters['source_profile_id'], 'marketplace_operations');
    expect(uri.queryParameters['workspace_view_id'], 'marketplace_all');
    expect(uri.queryParameters['workspace_view_label'], 'Marketplace all');
    expect(
      uri.queryParameters['source_profile_label'],
      'Marketplace operations',
    );
    expect(uri.queryParameters['launch_reason'], 'commerce_workspace');
  });

  test('workspace view count label handles singular and plural copy', () {
    expect(orderWorkspaceViewCountLabel(1), '1 workspace view');
    expect(orderWorkspaceViewCountLabel(2), '2 workspace views');
  });

  test('compact order labels avoid duplicate base order copy', () {
    final bridge = orderWorkspaceBridgeForProfile(
      productProfile: ProductProfile.standard,
    );

    expect(bridge.routeShortTitle, 'Orders');
    expect(bridge.compactLabel, 'Orders');
  });

  test('order workspace short title removes only order suffix copy', () {
    expect(orderWorkspaceShortTitle('Marketplace Orders'), 'Marketplace');
    expect(orderWorkspaceShortTitle('Wholesale'), 'Wholesale');
  });
}
