import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product_relationship_management.dart';
import '../product_routes.dart';
import '../states/product_relationship_management_provider.dart';
import '../utils/management_route_mode.dart';
import '../widgets/management_suite_screen.dart';
import '../widgets/product_relationship_management_panel.dart';

class ProductRelationshipManagementScreen extends StatelessWidget {
  const ProductRelationshipManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProductManagementSuiteScreen(
      title: 'Relationship Management',
      activeDestination:
          ProductManagementSuiteDestination.relationshipManagement,
      modeControlConfig: ProductManagementSuiteModeControlConfig.focused,
      builder: (context, ref, suiteContext) {
        final relationshipOverview = ref.watch(
          productRelationshipManagementOverviewProvider,
        );

        return [
          ProductRelationshipManagementPanel(
            overview: relationshipOverview,
            onRelationshipSelected:
                (relationship) => _openRelationship(
                  context,
                  relationship: relationship,
                  routeMode: suiteContext.routeMode,
                ),
          ),
        ];
      },
    );
  }
}

void _openRelationship(
  BuildContext context, {
  required ProductRelationshipManagementEntry relationship,
  required ProductManagementRouteMode routeMode,
}) {
  context.go(
    productRouteWithManagementMode(
      ProductRoutes.catalogUriForReviewTarget(relationship.reviewTarget),
      mode: routeMode,
    ),
  );
}
