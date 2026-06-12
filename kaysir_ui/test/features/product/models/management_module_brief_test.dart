import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_module_brief.dart';
import 'package:kaysir/features/product/models/management_suite_destination.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';
import 'package:kaysir/features/product/product_routes.dart';

void main() {
  test('resolver exposes stable contribution metadata with fallbacks', () {
    final customResolver = ProductManagementModuleBriefResolver(
      id: 'coffee_price_brief',
      title: 'Coffee price ladder',
      description: 'Routes coffee pricing work to menu review.',
      destination: ProductManagementSuiteDestination.pricingManagement,
      buildAction:
          (_) => const ProductManagementModuleBriefAction(
            id: 'coffee_price_ladder',
            label: 'Review coffee prices',
            detail: 'Espresso ladder',
            destination: ProductManagementSuiteDestination.pricingManagement,
          ),
    );
    final fallbackResolver = ProductManagementModuleBriefResolver(
      destination: ProductManagementSuiteDestination.availabilityManagement,
      buildAction:
          (_) => const ProductManagementModuleBriefAction(
            id: 'availability_review',
            label: 'Review availability',
            detail: 'Availability queue',
            destination:
                ProductManagementSuiteDestination.availabilityManagement,
          ),
    );

    expect(customResolver.contributionId, 'coffee_price_brief');
    expect(customResolver.hasTitle, isTrue);
    expect(customResolver.hasDescription, isTrue);
    expect(
      fallbackResolver.contributionId,
      'module_brief_availabilityManagement',
    );
    expect(fallbackResolver.hasTitle, isFalse);
    expect(fallbackResolver.hasDescription, isFalse);
  });

  test('default registry routes missing pricing to catalog review', () {
    final overview = _overview(
      products: [
        Product(
          id: 'missing-price',
          name: 'Cold Brew Bottle',
          sku: 'DRK-014',
          category: 'Beverage',
          description: 'Ready-to-drink bottle',
          barcode: '899000000014',
          price: 0,
        ),
      ],
      quantity: 12,
      reorderPoint: 4,
    );

    final action = defaultProductManagementModuleBriefRegistry.resolve(
      activeDestination: ProductManagementSuiteDestination.pricingManagement,
      overview: overview,
    );

    expect(action.id, 'pricing_missing_price');
    expect(action.label, 'Review missing prices');
    expect(action.detail, '1 missing price');
    expect(action.destination, ProductManagementSuiteDestination.catalog);
    expect(action.tone, ProductManagementModuleBriefActionTone.warning);
    expect(action.contextLabel, 'Catalog quality');
    expect(
      action.routePath,
      ProductRoutes.catalogUriForReviewTarget(
        overview.qualitySummary.activeIssues.first.reviewTarget,
      ),
    );
  });

  test(
    'registry falls back to top recommendation for modules without resolver',
    () {
      final overview = _overview(
        products: [
          Product(
            id: 'low-stock',
            name: 'Filter Paper',
            sku: 'SUP-090',
            category: 'Supplies',
            description: 'Reusable brew bar supply',
            barcode: '899000000090',
            price: 3,
          ),
        ],
        quantity: 1,
        reorderPoint: 8,
      );

      final action = defaultProductManagementModuleBriefRegistry.resolve(
        activeDestination: ProductManagementSuiteDestination.variantManagement,
        overview: overview,
      );
      final recommendation = overview.recommendations.firstWhere(
        (recommendation) => recommendation.canNavigate,
      );

      expect(action.id, 'recommendation_${recommendation.id}');
      expect(action.label, recommendation.actionLabel);
      expect(action.detail, recommendation.subtitle);
      expect(action.destination, ProductManagementSuiteDestination.catalog);
      expect(action.tone, _expectedTone(recommendation.priority));
      expect(
        action.contextLabel,
        '${recommendation.statusLabel} / ${recommendation.sourceLabel}',
      );
      expect(action.routePath, recommendation.routePath);
    },
  );

  test('registry allows product modules to provide custom brief actions', () {
    const customAction = ProductManagementModuleBriefAction(
      id: 'variant_matrix_review',
      label: 'Review variant matrix',
      detail: '3 families need option cleanup',
      destination: ProductManagementSuiteDestination.variantManagement,
    );
    final registry = ProductManagementModuleBriefRegistry(
      resolvers: [
        ProductManagementModuleBriefResolver(
          destination: ProductManagementSuiteDestination.variantManagement,
          buildAction: (_) => customAction,
        ),
      ],
    );

    final action = registry.resolve(
      activeDestination: ProductManagementSuiteDestination.variantManagement,
      overview: _overview(),
    );

    expect(action, same(customAction));
  });

  test('registry can merge product-specific resolvers with defaults', () {
    const customAction = ProductManagementModuleBriefAction(
      id: 'coffee_pricing_review',
      label: 'Audit espresso pricing',
      detail: 'Coffee shop price ladder',
      destination: ProductManagementSuiteDestination.pricingManagement,
      contextLabel: 'Coffee shop pack',
    );
    final registry = defaultProductManagementModuleBriefRegistry.mergedWith([
      ProductManagementModuleBriefResolver(
        destination: ProductManagementSuiteDestination.pricingManagement,
        buildAction: (_) => customAction,
      ),
    ]);
    final overview = _overview(
      products: [
        Product(
          id: 'missing-price',
          name: 'Cold Brew Bottle',
          sku: 'DRK-014',
          category: 'Beverage',
          description: 'Ready-to-drink bottle',
          barcode: '899000000014',
          price: 0,
        ),
      ],
    );

    final pricingAction = registry.resolve(
      activeDestination: ProductManagementSuiteDestination.pricingManagement,
      overview: overview,
    );
    final catalogAction = registry.resolve(
      activeDestination: ProductManagementSuiteDestination.catalog,
      overview: overview,
    );

    expect(pricingAction, same(customAction));
    expect(catalogAction.id, startsWith('catalog_'));
  });
}

ProductManagementModuleBriefActionTone _expectedTone(
  ProductWorkspaceRecommendationPriority priority,
) {
  return switch (priority) {
    ProductWorkspaceRecommendationPriority.critical =>
      ProductManagementModuleBriefActionTone.danger,
    ProductWorkspaceRecommendationPriority.high =>
      ProductManagementModuleBriefActionTone.warning,
    ProductWorkspaceRecommendationPriority.medium =>
      ProductManagementModuleBriefActionTone.warning,
    ProductWorkspaceRecommendationPriority.ready =>
      ProductManagementModuleBriefActionTone.success,
  };
}

ProductWorkspaceOverview _overview({
  List<Product>? products,
  int quantity = 12,
  int reorderPoint = 4,
}) {
  final resolvedProducts =
      products ??
      [
        Product(
          id: 'coffee-beans',
          name: 'House Blend Beans',
          sku: 'COF-001',
          category: 'Coffee',
          description: 'Whole bean retail pack',
          barcode: '899000000001',
          price: 12,
          customAttributes: const {'available_channels': 'POS, Online'},
        ),
      ];
  final warehouse = Warehouse(
    id: 'main-store',
    name: 'Main Store',
    location: 'Jakarta',
  );
  final stockRecords = buildInventoryStockRecords(
    inventoryItems: [
      for (final product in resolvedProducts)
        InventoryItem(
          id: 'stock-${product.id}',
          productId: product.id,
          warehouseId: warehouse.id,
          currentQuantity: quantity,
          reorderPoint: reorderPoint,
          reorderQuantity: 12,
        ),
    ],
    products: resolvedProducts,
    warehouses: [warehouse],
  );
  final registry = defaultProductSalesChannelProfileRegistry;
  final channelProfile = omniRetailProductSalesChannelProfile;

  return buildProductWorkspaceOverview(
    products: resolvedProducts,
    stockRecords: stockRecords,
    actionRegistry: ProductWorkspaceActionRegistry(
      pack: coreProductManagementPack,
    ),
    managementPack: coreProductManagementPack,
    channelProfiles: registry.profiles,
    channelProfile: channelProfile,
    channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack],
      registry: registry,
      selectedProfile: channelProfile,
    ),
  );
}
