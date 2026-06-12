import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_lifecycle_management.dart';
import '../product_routes.dart';
import '../states/product_lifecycle_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/product_lifecycle_management_panel.dart';
import '../widgets/management_suite_screen.dart';

class ProductLifecycleManagementScreen extends StatelessWidget {
  const ProductLifecycleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Lifecycle Management',
      activeDestination: ProductManagementSuiteDestination.lifecycleManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final lifecycleOverview = ref.watch(
          productLifecycleManagementOverviewProvider,
        );

        return [
          ProductLifecycleManagementPanel(
            overview: lifecycleOverview,
            onStageSelected:
                (stage) => _openStage(
                  context,
                  stage: stage,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openStage(
  BuildContext context, {
  required ProductLifecycleManagementEntry stage,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(stage.reviewTarget),
      mode: routeMode,
    ),
  );
}
