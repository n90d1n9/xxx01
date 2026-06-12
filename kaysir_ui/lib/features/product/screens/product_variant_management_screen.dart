import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_variant_management.dart';
import '../product_routes.dart';
import '../states/product_variant_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/product_variant_management_panel.dart';

class ProductVariantManagementScreen extends StatelessWidget {
  const ProductVariantManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Variant Management',
      activeDestination: ProductManagementSuiteDestination.variantManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final variantOverview = ref.watch(
          productVariantManagementOverviewProvider,
        );

        return [
          ProductVariantManagementPanel(
            overview: variantOverview,
            onFamilySelected:
                (family) => _openFamily(
                  context,
                  family: family,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openFamily(
  BuildContext context, {
  required ProductVariantManagementEntry family,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(family.reviewTarget),
      mode: routeMode,
    ),
  );
}
