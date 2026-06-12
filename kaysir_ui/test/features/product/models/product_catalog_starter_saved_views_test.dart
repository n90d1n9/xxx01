import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/product/models/product_catalog_default_saved_view_contributions.dart';
import 'package:kaysir/features/product/models/product_catalog_saved_view_contribution.dart';
import 'package:kaysir/features/product/models/product_catalog_starter_saved_views.dart';
import 'package:kaysir/features/product/models/product_catalog_table_column_ids.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test('builds starter catalog views from product mode characteristics', () {
    final omniViews = buildProductCatalogStarterSavedViewSet(
      pack: coreProductManagementPack,
      channelProfile: omniRetailProductSalesChannelProfile,
    );

    expect(omniViews.seedKey, 'core_catalog.omni_retail');
    expect(omniViews.views.map((view) => view.label), [
      'Omni Retail overview',
      'Omni readiness',
      'Stock control',
      'Price guardrails',
    ]);
    expect(
      omniViews.sectionLabelFor(
        omniViews.views.firstWhere(
          (view) => view.label == 'Omni Retail overview',
        ),
      ),
      'Mode views',
    );
    expect(
      omniViews.sectionLabelFor(
        omniViews.views.firstWhere((view) => view.label == 'Omni readiness'),
      ),
      'Channel views',
    );
    expect(
      omniViews.sectionLabelFor(
        omniViews.views.firstWhere((view) => view.label == 'Price guardrails'),
      ),
      'Pack views',
    );
    final priceGuardrails = omniViews.views.firstWhere(
      (view) => view.label == 'Price guardrails',
    );
    expect(
      priceGuardrails.presentationState.tableViewState.preferences
          .isContributionVisible('product-channel-fit'),
      isFalse,
    );
    expect(omniViews.viewIds.length, omniViews.views.length);
    expect(
      omniViews.views
          .firstWhere((view) => view.label == 'Omni readiness')
          .presentationState
          .matches(
            InventoryProductCatalogPresentationPreset
                .channelSignals
                .presentationState,
          ),
      isTrue,
    );

    final counterViews = buildProductCatalogStarterSavedViewSet(
      pack: coreProductManagementPack,
      channelProfile: counterServiceProductSalesChannelProfile,
    );

    expect(
      counterViews.views.map((view) => view.label),
      containsAll(['Counter checkout', 'Stock sellability']),
    );

    final groceryViews = buildProductCatalogStarterSavedViewSet(
      pack: groceryFreshGoodsProductManagementPack,
      channelProfile: groceryFreshGoodsProductSalesChannelProfile,
    );

    expect(groceryViews.seedKey, 'grocery_fresh_goods.grocery_fresh_goods');
    expect(
      groceryViews.views.map((view) => view.label),
      containsAll([
        'Grocery Fresh Goods overview',
        'Freshness queue',
        'Fresh channel signals',
        'Markdown check',
      ]),
    );
    expect(
      groceryViews.sectionLabelFor(
        groceryViews.views.firstWhere(
          (view) => view.label == 'Freshness queue',
        ),
      ),
      'Pack views',
    );
    expect(
      groceryViews.views
          .firstWhere((view) => view.label == 'Freshness queue')
          .presentationState
          .tableViewState
          .preferences
          .isContributionVisible(
            productFreshGoodsFreshnessColumnId,
            defaultVisible: false,
          ),
      isTrue,
    );
  });

  test('exposes default starter views through contribution registry', () {
    expect(defaultProductCatalogSavedViewContributionRegistry.contributionIds, [
      'mode-overview',
      'counter-service-channel',
      'digital-commerce-channel',
      'omni-retail-channel',
      'grocery-fresh-goods-pack',
      'core-price-guardrails',
    ]);
  });

  test('builds starter catalog views from custom contribution registry', () {
    const registry = ProductCatalogSavedViewContributionRegistry(
      contributions: [
        ProductCatalogSavedViewContribution(
          id: 'test-launch-queue',
          sectionLabel: 'Launch views',
          buildViews: _testLaunchQueueViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'test-counter-only',
          sectionLabel: 'Counter views',
          appliesTo: _testIsCounterService,
          buildViews: _testCounterOnlyViews,
        ),
      ],
    );

    final omniViews = buildProductCatalogStarterSavedViewSet(
      pack: coreProductManagementPack,
      channelProfile: omniRetailProductSalesChannelProfile,
      registry: registry,
    );
    final counterViews = buildProductCatalogStarterSavedViewSet(
      pack: coreProductManagementPack,
      channelProfile: counterServiceProductSalesChannelProfile,
      registry: registry,
    );

    expect(omniViews.views.map((view) => view.label), ['Launch queue']);
    expect(
      omniViews.views.single.id,
      'starter-core_catalog.omni_retail.launch',
    );
    expect(omniViews.sectionLabelFor(omniViews.views.single), 'Launch views');
    expect(counterViews.views.map((view) => view.label), [
      'Launch queue',
      'Counter pressure',
    ]);
    expect(
      counterViews.sectionLabelFor(
        counterViews.views.firstWhere(
          (view) => view.label == 'Counter pressure',
        ),
      ),
      'Counter views',
    );
  });
}

Iterable<InventoryProductCatalogSavedView> _testLaunchQueueViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'launch',
      label: 'Launch queue',
      description: 'Custom launch readiness',
      preset: InventoryProductCatalogPresentationPreset.operationsTable,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _testCounterOnlyViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'counter-pressure',
      label: 'Counter pressure',
      description: 'Counter-only checkout pressure review',
      preset: InventoryProductCatalogPresentationPreset.pricing,
    ),
  ];
}

bool _testIsCounterService(ProductCatalogSavedViewContributionContext context) {
  return context.channelProfile.id ==
      ProductSalesChannelProfileId.counterService;
}
