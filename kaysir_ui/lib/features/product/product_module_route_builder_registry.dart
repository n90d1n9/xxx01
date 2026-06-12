import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';

import '../inventory/models/inventory_product_catalog_presentation_state.dart';
import 'models/product_catalog_table_column_ids.dart';
import 'models/experience_profile.dart';
import 'models/management_pack.dart';
import 'models/management_suite_destination.dart';
import 'models/product_module_destination.dart';
import 'models/product_route_state.dart';
import 'product_routes.dart';
import 'screens/add_movement_screen.dart';
import 'screens/discrepancey_report_screen.dart';
import 'screens/product_assortment_planning_screen.dart';
import 'screens/product_availability_management_screen.dart';
import 'screens/product_category_management_screen.dart';
import 'screens/product_channel_readiness_screen.dart';
import 'screens/product_editor_route_screen.dart';
import 'screens/product_lifecycle_management_screen.dart';
import 'screens/product_pack_contracts_screen.dart';
import 'screens/product_pricing_management_screen.dart';
import 'screens/product_relationship_management_screen.dart';
import 'screens/product_screen.dart';
import 'screens/product_setup_targets_screen.dart';
import 'screens/product_sourcing_management_screen.dart';
import 'screens/product_strategy_screen.dart';
import 'screens/product_variant_management_screen.dart';
import 'screens/scan_product_screen.dart';
import 'screens/stock_movement_screen.dart';
import 'screens/stock_opname_list_screen.dart';
import 'utils/product_catalog_review_target.dart';
import 'widgets/experience_profile_scope.dart';
import 'widgets/management_route_mode_hydrator.dart';

typedef ProductModulePageBuilder =
    Page<dynamic> Function(BuildContext context, GoRouterState state);

/// Creates route metadata and page builders for product module destinations.
class ProductModuleRouteBuilderRegistry {
  const ProductModuleRouteBuilderRegistry();

  FeatureRoutes routeForDestination(
    ProductModuleDestination destination, {
    ProductExperienceProfile? experienceProfile,
    List<FeatureRoutes> childRoutes = const [],
  }) {
    return FeatureRoutes(
      name: destination.routeName,
      title: destination.title,
      subtitle: destination.subtitle,
      description: destination.description,
      icon: 'inventory',
      path: destination.path,
      pageBuilder: pageBuilderForDestinationId(
        destination.id,
        experienceProfile: experienceProfile,
      ),
      items: childRoutes,
    );
  }

  /// Hidden workflow routes that should live under a visible destination.
  List<FeatureRoutes> childRoutesForDestination(
    ProductModuleDestination destination,
  ) {
    return childRoutesForDestinationId(destination.id);
  }

  /// Hidden workflow routes that should live under a visible destination id.
  List<FeatureRoutes> childRoutesForDestinationId(
    ProductModuleDestinationId id,
  ) {
    return switch (id) {
      ProductModuleDestinationId.catalog => [editProductRoute()],
      _ => const [],
    };
  }

  /// Hidden workflow routes that remain reachable when their parent is absent.
  List<FeatureRoutes> fallbackRoutesForDestinations(
    Iterable<ProductModuleDestination> destinations,
  ) {
    final destinationIds = {
      for (final destination in destinations) destination.id,
    };
    if (destinationIds.contains(ProductModuleDestinationId.catalog)) {
      return const [];
    }

    return [editProductRoute()];
  }

  ProductModulePageBuilder pageBuilderForDestinationId(
    ProductModuleDestinationId id, {
    ProductExperienceProfile? experienceProfile,
  }) {
    return switch (id) {
      ProductModuleDestinationId.strategy => _managementModePageBuilder(
        const ProductStrategyScreen(),
        experienceProfile: experienceProfile,
      ),
      ProductModuleDestinationId.assortmentPlanning =>
        _managementModePageBuilder(
          const ProductAssortmentPlanningScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.categoryManagement =>
        _managementModePageBuilder(
          const ProductCategoryManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.pricingManagement =>
        _managementModePageBuilder(
          const ProductPricingManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.sourcingManagement =>
        _managementModePageBuilder(
          const ProductSourcingManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.lifecycleManagement =>
        _managementModePageBuilder(
          const ProductLifecycleManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.variantManagement =>
        _managementModePageBuilder(
          const ProductVariantManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.relationshipManagement =>
        _managementModePageBuilder(
          const ProductRelationshipManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.availabilityManagement =>
        _managementModePageBuilder(
          const ProductAvailabilityManagementScreen(),
          experienceProfile: experienceProfile,
        ),
      ProductModuleDestinationId.channelReadiness => _managementModePageBuilder(
        const ProductChannelReadinessScreen(),
        experienceProfile: experienceProfile,
      ),
      ProductModuleDestinationId.setupTargets => _managementModePageBuilder(
        const ProductSetupTargetsScreen(),
        experienceProfile: experienceProfile,
      ),
      ProductModuleDestinationId.packContracts => _managementModePageBuilder(
        const ProductPackContractsScreen(),
        experienceProfile: experienceProfile,
      ),
      ProductModuleDestinationId.catalog => _catalogPageBuilderForProfile(
        experienceProfile,
      ),
      ProductModuleDestinationId.freshnessReview => _freshnessReviewPageBuilder,
      ProductModuleDestinationId.addProduct => _addProductPageBuilder,
      ProductModuleDestinationId.stockMovements => _stockMovementsPageBuilder,
      ProductModuleDestinationId.addStockMovement =>
        _addStockMovementPageBuilder,
      ProductModuleDestinationId.stockOpname => _stockOpnamePageBuilder,
      ProductModuleDestinationId.scanProduct => _scanProductPageBuilder,
      ProductModuleDestinationId.discrepancyReport =>
        _discrepancyReportPageBuilder,
    };
  }

  FeatureRoutes editProductRoute() {
    return FeatureRoutes(
      title: 'Edit Product',
      name: ProductRoutes.editProductRouteName,
      subtitle: 'Update pack-aware product data',
      description:
          'Standalone product form for editing products with active product management pack fields.',
      icon: 'inventory',
      path: ProductRoutes.editProductPath,
      position: const [],
      pageBuilder: _editProductPageBuilder,
    );
  }
}

const defaultProductModuleRouteBuilderRegistry =
    ProductModuleRouteBuilderRegistry();

ProductModulePageBuilder _managementModePageBuilder(
  Widget child, {
  ProductExperienceProfile? experienceProfile,
}) {
  return (BuildContext context, GoRouterState state) {
    final routeState = ProductManagementRouteState.fromQueryParameters(
      state.uri.queryParameters,
      fallbackPackId: experienceProfile?.defaultPackId,
      fallbackChannelProfileId: experienceProfile?.defaultChannelProfileId,
    );
    return MaterialPage(
      child: ProductManagementRouteModeHydrator(
        initialPackId: routeState.packId,
        initialChannelProfileId: routeState.channelProfileId,
        experienceProfile: experienceProfile,
        child: child,
      ),
    );
  };
}

ProductModulePageBuilder _catalogPageBuilderForProfile(
  ProductExperienceProfile? experienceProfile,
) {
  return (BuildContext context, GoRouterState state) {
    final routeState = ProductCatalogRouteState.fromQueryParameters(
      state.uri.queryParameters,
      fallbackPackId: experienceProfile?.defaultPackId,
      fallbackChannelProfileId: experienceProfile?.defaultChannelProfileId,
    );
    return MaterialPage(
      child: _ProductExperienceProfileScopeMaybe(
        experienceProfile: experienceProfile,
        child: ProductsScreen(
          initialReviewTarget: routeState.reviewTarget,
          initialPackId: routeState.packId,
          initialChannelProfileId: routeState.channelProfileId,
        ),
      ),
    );
  };
}

Page<dynamic> _freshnessReviewPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return MaterialPage(
    child: ProductExperienceProfileScope(
      profile: productFreshGoodsExperienceProfile,
      child: ProductsScreen(
        initialReviewTarget: _freshnessReviewTarget,
        initialPackId: ProductManagementPackId.groceryFreshGoods,
        initialChannelProfileId: groceryFreshGoodsProfileId,
        initialPresentationState: _freshnessReviewPresentationState,
        activeSuiteDestination:
            ProductManagementSuiteDestination.freshnessReview,
      ),
    ),
  );
}

Page<dynamic> _addProductPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  final routeState = ProductEditorRouteState.fromRoute(
    pathParameters: state.pathParameters,
    queryParameters: state.uri.queryParameters,
  );
  return MaterialPage(
    child: ProductManagementRouteModeHydrator(
      initialPackId: routeState.packId,
      initialChannelProfileId: routeState.channelProfileId,
      child: ProductEditorRouteScreen(
        initialFocusFieldId: routeState.focusFieldId,
      ),
    ),
  );
}

Page<dynamic> _stockMovementsPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: StockMovementsScreen());
}

Page<dynamic> _addStockMovementPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: AddStockMovementScreen());
}

Page<dynamic> _stockOpnamePageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: StockOpnameListScreen());
}

Page<dynamic> _scanProductPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  final routeState = ProductScanRouteState.fromQueryParameters(
    state.uri.queryParameters,
  );
  return MaterialPage(
    child: ScanProductScreen(
      initialQuery: routeState.initialQuery,
      returnTarget: routeState.returnTarget,
    ),
  );
}

Page<dynamic> _discrepancyReportPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: DiscrepancyReportScreen());
}

Page<dynamic> _editProductPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  final routeState = ProductEditorRouteState.fromRoute(
    pathParameters: state.pathParameters,
    queryParameters: state.uri.queryParameters,
  );
  return MaterialPage(
    child: ProductManagementRouteModeHydrator(
      initialPackId: routeState.packId,
      initialChannelProfileId: routeState.channelProfileId,
      child: ProductEditorRouteScreen(
        productId: routeState.productId,
        initialFocusFieldId: routeState.focusFieldId,
      ),
    ),
  );
}

const _freshnessReviewTarget = ProductCatalogReviewTarget(
  title: 'Freshness Review',
  reasonLabel: 'expiry and batch readiness',
);

final _freshnessReviewPresentationState =
    InventoryProductCatalogPresentationPreset.stockControl.presentationState
        .showContributionColumn(
          productFreshGoodsFreshnessColumnId,
          defaultVisible: false,
        );

class _ProductExperienceProfileScopeMaybe extends StatelessWidget {
  const _ProductExperienceProfileScopeMaybe({
    required this.experienceProfile,
    required this.child,
  });

  final ProductExperienceProfile? experienceProfile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final experienceProfile = this.experienceProfile;
    if (experienceProfile == null) return child;

    return ProductExperienceProfileScope(
      profile: experienceProfile,
      child: child,
    );
  }
}
