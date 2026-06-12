import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_sourcing_management.dart';
import '../product_routes.dart';
import '../states/product_sourcing_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/product_sourcing_management_panel.dart';

class ProductSourcingManagementScreen extends StatelessWidget {
  const ProductSourcingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Sourcing Management',
      activeDestination: ProductManagementSuiteDestination.sourcingManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final sourcingOverview = ref.watch(
          productSourcingManagementOverviewProvider,
        );

        return [
          ProductSourcingManagementPanel(
            overview: sourcingOverview,
            onSupplierSelected:
                (supplier) => _openSupplier(
                  context,
                  supplier: supplier,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openSupplier(
  BuildContext context, {
  required ProductSourcingManagementEntry supplier,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(supplier.reviewTarget),
      mode: routeMode,
    ),
  );
}
