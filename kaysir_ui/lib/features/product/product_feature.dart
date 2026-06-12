import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';

import 'product_feature_route_registry.dart';
import 'product_routes.dart';

/// Product module entry point that exposes the active product route tree.
class ProductFeature implements FeaturesBase {
  static const workspacePath = ProductRoutes.workspacePath;
  static const strategyPath = ProductRoutes.strategyPath;
  static const assortmentPlanningPath = ProductRoutes.assortmentPlanningPath;
  static const categoryManagementPath = ProductRoutes.categoryManagementPath;
  static const pricingManagementPath = ProductRoutes.pricingManagementPath;
  static const sourcingManagementPath = ProductRoutes.sourcingManagementPath;
  static const lifecycleManagementPath = ProductRoutes.lifecycleManagementPath;
  static const variantManagementPath = ProductRoutes.variantManagementPath;
  static const relationshipManagementPath =
      ProductRoutes.relationshipManagementPath;
  static const availabilityManagementPath =
      ProductRoutes.availabilityManagementPath;
  static const channelReadinessPath = ProductRoutes.channelReadinessPath;
  static const setupTargetsPath = ProductRoutes.setupTargetsPath;
  static const packContractsPath = ProductRoutes.packContractsPath;
  static const catalogPath = ProductRoutes.catalogPath;
  static const freshnessReviewPath = ProductRoutes.freshnessReviewPath;
  static const addProductPath = ProductRoutes.addProductPath;
  static const editProductPath = ProductRoutes.editProductPath;
  static const stockMovementsPath = ProductRoutes.stockMovementsPath;
  static const addStockMovementPath = ProductRoutes.addStockMovementPath;
  static const stockOpnamePath = ProductRoutes.stockOpnamePath;
  static const scanProductPath = ProductRoutes.scanProductPath;
  static const discrepancyReportPath = ProductRoutes.discrepancyReportPath;

  @override
  List<FeatureRoutes> registerScreens() => [
    defaultProductFeatureRouteRegistry.workspaceRoute(),
  ];
}
