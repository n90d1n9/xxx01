import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_assortment_plan.dart';
import '../product_routes.dart';
import '../states/product_assortment_plan_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_assortment_plan_panel.dart';
import '../widgets/management_suite_screen.dart';

class ProductAssortmentPlanningScreen extends StatelessWidget {
  const ProductAssortmentPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Assortment Planning',
      activeDestination: ProductManagementSuiteDestination.assortmentPlanning,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final plan = ref.watch(productAssortmentPlanProvider);

        return [
          ProductAssortmentPlanPanel(
            plan: plan,
            onSegmentSelected:
                (segment) => _openAssortmentSegment(
                  context,
                  segment: segment,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openAssortmentSegment(
  BuildContext context, {
  required ProductAssortmentSegment segment,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(segment.reviewTarget),
      mode: routeMode,
    ),
  );
}
