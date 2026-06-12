import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_category_management.dart';
import '../product_routes.dart';
import '../states/product_category_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_category_management_panel.dart';
import '../widgets/management_suite_screen.dart';

class ProductCategoryManagementScreen extends StatelessWidget {
  const ProductCategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Category Management',
      activeDestination: ProductManagementSuiteDestination.categoryManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final categoryOverview = ref.watch(
          productCategoryManagementOverviewProvider,
        );

        return [
          ProductCategoryManagementPanel(
            overview: categoryOverview,
            onCategorySelected:
                (category) => _openCategory(
                  context,
                  category: category,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openCategory(
  BuildContext context, {
  required ProductCategoryManagementEntry category,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(category.reviewTarget),
      mode: routeMode,
    ),
  );
}
