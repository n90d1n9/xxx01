import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_pricing_management.dart';
import '../product_routes.dart';
import '../states/product_pricing_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/product_pricing_management_panel.dart';

class ProductPricingManagementScreen extends StatelessWidget {
  const ProductPricingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Pricing Management',
      activeDestination: ProductManagementSuiteDestination.pricingManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final pricingOverview = ref.watch(
          productPricingManagementOverviewProvider,
        );

        return [
          ProductPricingManagementPanel(
            overview: pricingOverview,
            onPricingGroupSelected:
                (entry) => _openPricingGroup(
                  context,
                  entry: entry,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openPricingGroup(
  BuildContext context, {
  required ProductPricingManagementEntry entry,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(entry.reviewTarget),
      mode: routeMode,
    ),
  );
}
