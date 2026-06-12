import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product_route_state.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';

void main() {
  test('product management route state parses pack and channel profile', () {
    final state = ProductManagementRouteState.fromQueryParameters({
      ProductRoutes.productModePackQueryKey: ' fresh-goods ',
      ProductRoutes.productModeProfileQueryKey: 'digital-commerce',
    });

    expect(state.packId, ProductManagementPackId.groceryFreshGoods);
    expect(
      state.channelProfileId,
      ProductSalesChannelProfileId.digitalCommerce,
    );
    expect(state.hasSelection, isTrue);
  });

  test('product management route state applies fallbacks', () {
    final fallbackState = ProductManagementRouteState.fromQueryParameters(
      const {},
      fallbackPackId: ProductManagementPackId.groceryFreshGoods,
      fallbackChannelProfileId: groceryFreshGoodsProfileId,
    );
    final explicitState = ProductManagementRouteState.fromQueryParameters(
      {
        ProductRoutes.productModePackQueryKey: 'core',
        ProductRoutes.productModeProfileQueryKey: 'digital-commerce',
      },
      fallbackPackId: ProductManagementPackId.groceryFreshGoods,
      fallbackChannelProfileId: groceryFreshGoodsProfileId,
    );

    expect(fallbackState.packId, ProductManagementPackId.groceryFreshGoods);
    expect(fallbackState.channelProfileId, groceryFreshGoodsProfileId);
    expect(explicitState.packId, ProductManagementPackId.coreCatalog);
    expect(
      explicitState.channelProfileId,
      ProductSalesChannelProfileId.digitalCommerce,
    );
  });

  test('product workspace route state parses setup context', () {
    final state = ProductWorkspaceRouteState.fromQueryParameters({
      ProductRoutes.workspaceExperienceQueryKey: ' fresh-goods ',
      ProductRoutes.workspacePackQueryKey: 'grocery',
      ProductRoutes.workspaceProfileQueryKey: 'grocery-fresh-goods',
      ProductRoutes.workspaceSetupQueryKey: ' freshness ',
    });

    expect(state.experienceProfileValue, 'fresh_goods');
    expect(state.hasExperienceProfile, isTrue);
    expect(state.packId, ProductManagementPackId.groceryFreshGoods);
    expect(state.channelProfileId, groceryFreshGoodsProfileId);
    expect(state.setupTargetId, 'freshness');
  });

  test('product workspace route state applies profile defaults', () {
    final state = ProductWorkspaceRouteState.fromQueryParameters(
      {ProductRoutes.workspaceSetupQueryKey: 'freshness'},
      fallbackPackId: ProductManagementPackId.groceryFreshGoods,
      fallbackChannelProfileId: groceryFreshGoodsProfileId,
    );

    expect(state.packId, ProductManagementPackId.groceryFreshGoods);
    expect(state.channelProfileId, groceryFreshGoodsProfileId);
    expect(state.setupTargetId, 'freshness');
  });

  test('product catalog route state parses review target and product mode', () {
    final state = ProductCatalogRouteState.fromQueryParameters({
      ProductRoutes.catalogPackQueryKey: 'core',
      ProductRoutes.catalogProfileQueryKey: 'omni-retail',
      ProductRoutes.catalogFilterQueryKey: 'attention',
      ProductRoutes.catalogSearchQueryKey: 'No SKU',
      ProductRoutes.catalogReviewTitleQueryKey: 'Catalog quality',
      ProductRoutes.catalogReviewReasonQueryKey: 'missing SKU',
    });

    expect(state.packId, ProductManagementPackId.coreCatalog);
    expect(state.channelProfileId, ProductSalesChannelProfileId.omniRetail);
    expect(
      state.reviewTarget,
      const ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.attention,
        query: 'No SKU',
        title: 'Catalog quality',
        reasonLabel: 'missing SKU',
      ),
    );
  });

  test('product catalog route state applies profile defaults', () {
    final state = ProductCatalogRouteState.fromQueryParameters(
      {
        ProductRoutes.catalogFilterQueryKey: 'attention',
        ProductRoutes.catalogReviewTitleQueryKey: 'Freshness Review',
      },
      fallbackPackId: ProductManagementPackId.groceryFreshGoods,
      fallbackChannelProfileId: groceryFreshGoodsProfileId,
    );

    expect(state.packId, ProductManagementPackId.groceryFreshGoods);
    expect(state.channelProfileId, groceryFreshGoodsProfileId);
    expect(state.reviewTarget.filter, InventoryProductCatalogFilter.attention);
    expect(state.reviewTarget.normalizedTitle, 'Freshness Review');
  });

  test('product editor route state parses product and focused field', () {
    final state = ProductEditorRouteState.fromRoute(
      pathParameters: {ProductRoutes.productIdPathParameter: 'p1'},
      queryParameters: {
        ProductRoutes.productModePackQueryKey: 'grocery_fresh_goods',
        ProductRoutes.productModeProfileQueryKey: 'grocery_fresh_goods',
        ProductRoutes.productEditorFocusQueryKey: 'expiry_date',
      },
    );

    expect(state.packId, ProductManagementPackId.groceryFreshGoods);
    expect(state.channelProfileId, groceryFreshGoodsProfileId);
    expect(state.productId, 'p1');
    expect(state.focusFieldId, ProductManagementFieldId.expiryDate);
  });

  test('product scan route state parses initial query and return target', () {
    final state = ProductScanRouteState.fromQueryParameters({
      ProductRoutes.scanProductQueryKey: 'TE-1',
      ProductRoutes.scanProductReturnTargetQueryKey: 'discrepancy_report',
    });

    expect(state.initialQuery, 'TE-1');
    expect(state.returnTarget, ProductScanReturnTarget.discrepancyReport);
  });
}
