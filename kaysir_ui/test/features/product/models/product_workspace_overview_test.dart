import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_item.dart';
import 'package:kaysir/features/inventory/models/inventory_stock_record.dart';
import 'package:kaysir/features/inventory/models/warehouse.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_action_registry.dart';
import 'package:kaysir/features/product/models/product_workspace_overview.dart';
import 'package:kaysir/features/product/models/product_workspace_recommendation.dart';

void main() {
  test('workspace overview composes reusable catalog command state', () {
    final registry = ProductSalesChannelProfileRegistry.fromPacks(
      coreProductManagementPack.profilePacks,
    );
    final selectedProfile = registry.fallbackProfile;
    final customContribution = ProductWorkspaceRecommendationContribution(
      id: 'traceability',
      isActive:
          (context) =>
              context.managementPack.id == ProductManagementPackId.coreCatalog,
      buildRecommendations:
          (context) => const [
            ProductWorkspaceRecommendation(
              id: 'traceability_review',
              title: 'Review traceability',
              subtitle: 'Custom pack recommendation',
              actionLabel: 'Open traceability',
              statusLabel: 'Custom',
              priority: ProductWorkspaceRecommendationPriority.medium,
              routePath: '/products/traceability',
            ),
          ],
    );

    final overview = buildProductWorkspaceOverview(
      products: _products,
      stockRecords: _stockRecords,
      actionRegistry: ProductWorkspaceActionRegistry(
        pack: coreProductManagementPack,
      ),
      managementPack: coreProductManagementPack,
      channelProfiles: registry.profiles,
      channelProfile: selectedProfile,
      channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
        packs: coreProductManagementPack.profilePacks,
        registry: registry,
        selectedProfile: selectedProfile,
      ),
      recommendationContributions: [customContribution],
    );

    expect(overview.summary.productCount, 2);
    expect(overview.summary.trackedProductCount, 2);
    expect(overview.summary.attentionProductCount, 1);
    expect(overview.qualitySummary.productCount, 2);
    expect(overview.qualitySummary.completeProductCount, 1);
    expect(overview.qualitySummary.totalIssueCount, greaterThan(0));
    expect(overview.actionGroups, isNotEmpty);
    expect(overview.actionSummary.hasActions, isTrue);
    expect(overview.channelProfile.title, 'Omni Retail');
    expect(overview.channelProfiles.length, greaterThanOrEqualTo(3));
    expect(overview.channelReadiness, isNotEmpty);
    expect(
      overview.profileReadinessOptions,
      hasLength(overview.channelProfiles.length),
    );
    expect(overview.launchPriorities, isNotEmpty);
    expect(overview.primaryLaunchPriority, overview.launchPriorities.first);
    expect(overview.strategyBrief.profile, overview.channelProfile);
    expect(overview.recommendations, isNotEmpty);
    expect(overview.recommendations.first.id, 'launch_queue');
    expect(
      overview.recommendations.map((recommendation) => recommendation.id),
      containsAll(['catalog_setup', 'stock_attention', 'traceability_review']),
    );
    expect(overview.attentionLabel, '1 product needs attention');
    expect(overview.catalogQualityLabel, contains('1/2 ready'));
    expect(overview.pulseSubtitle, contains('Omni Retail'));
  });

  test('workspace overview applies default freshness recommendations', () {
    final registry = ProductSalesChannelProfileRegistry.fromPacks(
      groceryFreshGoodsProductManagementPack.profilePacks,
    );
    final selectedProfile = registry.fallbackProfile;

    final overview = buildProductWorkspaceOverview(
      products: _products,
      stockRecords: _stockRecords,
      actionRegistry: ProductWorkspaceActionRegistry(
        pack: groceryFreshGoodsProductManagementPack,
      ),
      managementPack: groceryFreshGoodsProductManagementPack,
      channelProfiles: registry.profiles,
      channelProfile: selectedProfile,
      channelProfilePackOverview: buildProductSalesChannelProfilePackOverview(
        packs: groceryFreshGoodsProductManagementPack.profilePacks,
        registry: registry,
        selectedProfile: selectedProfile,
      ),
      recommendationContributions:
          defaultProductWorkspaceRecommendationContributions,
    );
    final freshnessRecommendation = overview.recommendations.singleWhere(
      (recommendation) => recommendation.id == 'freshness_data_setup',
    );

    expect(freshnessRecommendation.title, 'Prepare freshness data');
    expect(freshnessRecommendation.statusLabel, 'Freshness');
    expect(
      freshnessRecommendation.sourceLabel,
      groceryFreshGoodsProductManagementPack.title,
    );
    expect(freshnessRecommendation.routePath, contains('Freshness+setup'));
  });
}

final _products = [
  Product(
    id: 'p1',
    name: 'Laptop',
    sku: 'LT-001',
    category: 'Electronics',
    description: 'Workstation',
    price: 100,
    barcode: '8990001',
  ),
  Product(
    id: 'p2',
    name: 'Cable',
    sku: 'CB-001',
    category: 'Accessories',
    price: 25,
  ),
];

final _warehouse = Warehouse(
  id: 'w1',
  name: 'Main Warehouse',
  location: 'Jakarta',
);

final _stockRecords = [
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i1',
      productId: 'p1',
      warehouseId: 'w1',
      currentQuantity: 10,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[0],
    warehouse: _warehouse,
  ),
  InventoryStockRecord(
    item: InventoryItem(
      id: 'i2',
      productId: 'p2',
      warehouseId: 'w1',
      currentQuantity: 1,
      reorderPoint: 5,
      reorderQuantity: 10,
    ),
    product: _products[1],
    warehouse: _warehouse,
  ),
];
