import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/admin/services/admin_route_icon_resolver.dart';

void main() {
  test('resolveAdminRouteIcon maps common admin domains', () {
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Dashboard')),
      Icons.dashboard_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Cashier')),
      Icons.point_of_sale_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: ' orders')),
      Icons.shopping_bag_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Inventory stock')),
      Icons.inventory_2_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Finance accounting')),
      Icons.account_balance_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Billing Management')),
      Icons.receipt_long_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Billing Diagnostics')),
      Icons.health_and_safety_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Human resources')),
      Icons.badge_outlined,
    );
  });

  test('resolveAdminRouteIcon distinguishes folders from leaf fallbacks', () {
    expect(
      resolveAdminRouteIcon(
        FeatureRoutes(
          title: 'Workspace',
          items: [FeatureRoutes(title: 'Child')],
        ),
      ),
      Icons.folder_outlined,
    );
    expect(
      resolveAdminRouteIcon(FeatureRoutes(title: 'Unknown')),
      Icons.circle_outlined,
    );
  });
}
