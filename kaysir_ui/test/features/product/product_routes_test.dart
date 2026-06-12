import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product_catalog_view_preset.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/models/product_workspace_setup_target.dart';
import 'package:kaysir/features/product/product_routes.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';

void main() {
  test('product workspace URI preserves profile parameters', () {
    expect(ProductRoutes.workspaceUri(), ProductRoutes.workspacePath);
    expect(
      ProductRoutes.workspaceUri(experience: ' fresh-goods '),
      '/product-workspace?experience=fresh_goods',
    );
    expect(
      ProductRoutes.workspaceUri(
        experience: 'fresh-goods',
        profile: ProductSalesChannelProfileId.digitalCommerce,
      ),
      '/product-workspace?experience=fresh_goods&profile=digital_commerce',
    );
    expect(
      ProductRoutes.workspaceUri(
        profile: const ProductSalesChannelProfileId('grocery_market'),
      ),
      '/product-workspace?profile=grocery_market',
    );
    expect(
      ProductRoutes.productExperienceProfileValueFromQuery(' fresh-goods '),
      'fresh_goods',
    );
    expect(
      productExperienceProfileQueryValue(' Stock Control '),
      'stock_control',
    );
  });

  test('product workspace URI preserves setup targets', () {
    expect(
      ProductRoutes.workspaceSetupUri(ProductWorkspaceSetupTarget.freshness),
      '/product-workspace?setup=freshness',
    );
    expect(
      ProductRoutes.workspaceUri(
        profile: ProductSalesChannelProfileId.digitalCommerce,
        setupTarget: ProductWorkspaceSetupTarget.freshness,
      ),
      '/product-workspace?profile=digital_commerce&setup=freshness',
    );
    expect(
      ProductRoutes.workspaceSetupTargetFromQuery('freshness'),
      ProductWorkspaceSetupTarget.freshness,
    );
    expect(
      ProductRoutes.workspaceSetupTargetIdFromQuery(' freshness '),
      'freshness',
    );
    expect(ProductRoutes.workspaceSetupTargetIdFromQuery(' '), isNull);

    final customTarget = ProductRoutes.workspaceSetupTargetFromQuery(
      'restaurant_menu',
    );

    expect(customTarget?.id, 'restaurant_menu');
    expect(customTarget?.title, 'Restaurant Menu setup');
    expect(customTarget?.isCustom, isTrue);
  });

  test('product workspace URI preserves product mode parameters', () {
    expect(
      ProductRoutes.workspaceUri(
        pack: ProductManagementPackId.groceryFreshGoods,
      ),
      '/product-workspace?pack=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.workspaceUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
        setupTarget: ProductWorkspaceSetupTarget.freshness,
      ),
      '/product-workspace?pack=grocery_fresh_goods&profile=grocery_fresh_goods&setup=freshness',
    );
    expect(
      ProductRoutes.productManagementPackIdFromQuery(' fresh-goods '),
      ProductManagementPackId.groceryFreshGoods,
    );
    expect(
      ProductRoutes.productManagementPackIdFromQuery('restaurant-menu')?.value,
      'restaurant_menu',
    );
    expect(ProductRoutes.productManagementPackIdFromQuery(' '), isNull);
    expect(
      ProductRoutes.productSalesChannelProfileIdOrNullFromQuery(
        'digital-commerce',
      ),
      ProductSalesChannelProfileId.digitalCommerce,
    );
    expect(
      ProductRoutes.productSalesChannelProfileIdOrNullFromQuery(
        'grocery-fresh-goods',
      ),
      groceryFreshGoodsProfileId,
    );
    expect(
      ProductRoutes.productSalesChannelProfileIdOrNullFromQuery(null),
      isNull,
    );
  });

  test('product management suite URIs preserve product mode parameters', () {
    expect(ProductRoutes.strategyUri(), ProductRoutes.strategyPath);
    expect(
      ProductRoutes.strategyUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/strategy?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.assortmentPlanningUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/assortment-planning?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.categoryManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/categories?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.pricingManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/pricing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.sourcingManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/sourcing?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.lifecycleManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/lifecycle?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.variantManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/variants?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.relationshipManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/relationships?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.availabilityManagementUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/availability?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.channelReadinessUri(
        profile: ProductSalesChannelProfileId.digitalCommerce,
      ),
      '/products/channel-readiness?profile=digital_commerce',
    );
    expect(
      ProductRoutes.setupTargetsUri(
        pack: ProductManagementPackId.groceryFreshGoods,
      ),
      '/products/setup-targets?pack=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.packContractsUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/pack-contracts?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
  });

  test('product catalog URI preserves filter and query parameters', () {
    expect(ProductRoutes.catalogUri(), ProductRoutes.catalogPath);
    expect(
      ProductRoutes.catalogUri(filter: InventoryProductCatalogFilter.attention),
      '/products?filter=attention',
    );
    expect(
      ProductRoutes.catalogUri(
        filter: InventoryProductCatalogFilter.inStock,
        query: ' cable ',
      ),
      '/products?filter=in_stock&q=cable',
    );
    expect(
      ProductRoutes.catalogUriForReviewTarget(
        const ProductCatalogReviewTarget(
          filter: InventoryProductCatalogFilter.untracked,
          query: 'No SKU',
        ),
      ),
      '/products?filter=untracked&q=No+SKU',
    );
    expect(
      ProductRoutes.catalogUriForReviewTarget(
        const ProductCatalogReviewTarget(
          filter: InventoryProductCatalogFilter.attention,
          query: 'No SKU',
          title: 'Online Store',
          reasonLabel: 'missing SKU',
        ),
      ),
      '/products?filter=attention&q=No+SKU&review=Online+Store&reason=missing+SKU',
    );

    final target = ProductRoutes.catalogReviewTargetFromQueryParameters({
      ProductRoutes.catalogFilterQueryKey: 'attention',
      ProductRoutes.catalogSearchQueryKey: 'No description',
      ProductRoutes.catalogReviewTitleQueryKey: 'Catalog quality',
      ProductRoutes.catalogReviewReasonQueryKey: 'missing description',
    });

    expect(target.filter, InventoryProductCatalogFilter.attention);
    expect(target.query, 'No description');
    expect(target.summaryLabel, 'Catalog quality: missing description');
  });

  test('product catalog URI preserves product mode parameters', () {
    expect(
      ProductRoutes.catalogUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.catalogUri(
        filter: InventoryProductCatalogFilter.attention,
        query: ' expiry ',
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products?pack=grocery_fresh_goods&profile=grocery_fresh_goods&filter=attention&q=expiry',
    );
    expect(
      ProductRoutes.catalogUriForReviewTarget(
        const ProductCatalogReviewTarget(
          filter: InventoryProductCatalogFilter.attention,
          title: 'Freshness Review',
          reasonLabel: 'expiry gaps',
        ),
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products?pack=grocery_fresh_goods&profile=grocery_fresh_goods&filter=attention&review=Freshness+Review&reason=expiry+gaps',
    );

    final parameters =
        Uri.parse(
          '/products?pack=grocery&profile=grocery-fresh-goods',
        ).queryParameters;

    expect(
      ProductRoutes.catalogPackIdFromQueryParameters(parameters),
      ProductManagementPackId.groceryFreshGoods,
    );
    expect(
      ProductRoutes.catalogProfileIdFromQueryParameters(parameters),
      groceryFreshGoodsProfileId,
    );
  });

  test('product stock movement URIs expose standalone screens', () {
    expect(
      ProductRoutes.freshnessReviewUri(),
      ProductRoutes.freshnessReviewPath,
    );
    expect(ProductRoutes.stockMovementsUri(), ProductRoutes.stockMovementsPath);
    expect(
      ProductRoutes.addStockMovementUri(),
      ProductRoutes.addStockMovementPath,
    );
    expect(ProductRoutes.stockOpnameUri(), ProductRoutes.stockOpnamePath);
    expect(ProductRoutes.scanProductUri(), ProductRoutes.scanProductPath);
    expect(
      ProductRoutes.scanProductUri(query: ' CF-1 '),
      '/products/stock-opname/scan?q=CF-1',
    );
    expect(
      ProductRoutes.scanProductUri(
        query: 'TE-1',
        returnTarget: ProductScanReturnTarget.discrepancyReport,
      ),
      '/products/stock-opname/scan?q=TE-1&returnTo=discrepancy_report',
    );
    expect(
      ProductRoutes.discrepancyReportUri(),
      ProductRoutes.discrepancyReportPath,
    );
  });

  test('product editor URIs expose add edit and focus fields', () {
    expect(ProductRoutes.addProductUri(), ProductRoutes.addProductPath);
    expect(
      ProductRoutes.addProductUri(focusField: ProductManagementFieldId.barcode),
      '/products/new?field=barcode',
    );
    expect(
      ProductRoutes.addProductUri(
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
        focusField: ProductManagementFieldId.expiryDate,
      ),
      '/products/new?pack=grocery_fresh_goods&profile=grocery_fresh_goods&field=expiry_date',
    );
    expect(
      ProductRoutes.editProductUri(productId: ' p1 '),
      '/products/p1/edit',
    );
    expect(
      ProductRoutes.editProductUri(
        productId: 'p1',
        focusField: ProductManagementFieldId.expiryDate,
      ),
      '/products/p1/edit?field=expiry_date',
    );
    expect(
      ProductRoutes.editProductUri(
        productId: 'p1',
        pack: ProductManagementPackId.groceryFreshGoods,
        profile: groceryFreshGoodsProfileId,
      ),
      '/products/p1/edit?pack=grocery_fresh_goods&profile=grocery_fresh_goods',
    );
    expect(
      ProductRoutes.productEditorFocusFieldFromQuery('expiry_date'),
      ProductManagementFieldId.expiryDate,
    );
    expect(ProductRoutes.productEditorFocusFieldFromQuery('unknown'), isNull);
  });

  test('product scan return targets round trip safely', () {
    expect(
      productScanReturnTargetQueryValue(ProductScanReturnTarget.stockOpname),
      'stock_opname',
    );
    expect(
      productScanReturnTargetQueryValue(
        ProductScanReturnTarget.discrepancyReport,
      ),
      'discrepancy_report',
    );
    expect(
      productScanReturnTargetFromQuery('discrepancy_report'),
      ProductScanReturnTarget.discrepancyReport,
    );
    expect(
      productScanReturnTargetFromQuery('unknown'),
      ProductScanReturnTarget.stockOpname,
    );
    expect(
      ProductRoutes.scanReturnUri(ProductScanReturnTarget.discrepancyReport),
      ProductRoutes.discrepancyReportPath,
    );
  });

  test('product catalog preset URI uses preset filter', () {
    const preset = ProductCatalogViewPreset(
      id: ProductCatalogViewPresetId.untrackedSetup,
      title: 'Untracked Setup',
      subtitle: 'Products missing stock records',
      filter: InventoryProductCatalogFilter.untracked,
      count: 2,
      countLabel: '2 setup',
      intentLabel: 'Setup',
    );

    expect(
      ProductRoutes.catalogUriForPreset(preset),
      '/products?filter=untracked&review=Untracked+Setup',
    );
  });

  test('product channel readiness URI uses readiness review filter', () {
    const readiness = ProductSalesChannelReadiness(
      channel: ProductSalesChannel.kiosk,
      title: 'Self-Service Kiosk',
      subtitle: 'Fast-scan products',
      readyCount: 1,
      totalCount: 4,
      reviewFilter: InventoryProductCatalogFilter.inStock,
      issues: [
        ProductSalesChannelReadinessIssue(
          blocker: ProductSalesChannelBlocker.missingCopy,
          label: 'missing copy',
          count: 2,
          reviewFilter: InventoryProductCatalogFilter.all,
          reviewQuery: 'No description',
        ),
      ],
    );

    expect(
      ProductRoutes.catalogUriForChannelReadiness(readiness),
      '/products?q=No+description&review=Self-Service+Kiosk&reason=missing+copy',
    );
    expect(
      ProductRoutes.catalogUriForChannelReadinessIssue(readiness.issues.single),
      '/products?q=No+description&review=Channel+readiness&reason=missing+copy',
    );
    expect(
      ProductRoutes.catalogUriForChannelReadinessIssue(
        readiness.issues.single,
        title: readiness.title,
      ),
      '/products?q=No+description&review=Self-Service+Kiosk&reason=missing+copy',
    );
  });
}
