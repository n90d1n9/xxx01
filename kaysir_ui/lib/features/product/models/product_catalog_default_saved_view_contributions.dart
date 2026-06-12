import '../../inventory/models/inventory_product_catalog_presentation_state.dart';
import '../../inventory/models/inventory_product_catalog_saved_view.dart';
import 'product_catalog_saved_view_contribution.dart';
import 'product_catalog_table_column_ids.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

const defaultProductCatalogSavedViewContributionRegistry =
    ProductCatalogSavedViewContributionRegistry(
      contributions: [
        ProductCatalogSavedViewContribution(
          id: 'mode-overview',
          sectionLabel: 'Mode views',
          buildViews: _modeOverviewStarterViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'counter-service-channel',
          sectionLabel: 'Channel views',
          appliesTo: _isCounterServiceProfile,
          buildViews: _counterServiceStarterViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'digital-commerce-channel',
          sectionLabel: 'Channel views',
          appliesTo: _isDigitalCommerceProfile,
          buildViews: _digitalCommerceStarterViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'omni-retail-channel',
          sectionLabel: 'Channel views',
          appliesTo: _isOmniLikeProfile,
          buildViews: _omniRetailStarterViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'grocery-fresh-goods-pack',
          sectionLabel: 'Pack views',
          appliesTo: _isGroceryFreshGoodsPack,
          buildViews: _groceryFreshGoodsStarterViews,
        ),
        ProductCatalogSavedViewContribution(
          id: 'core-price-guardrails',
          sectionLabel: 'Pack views',
          appliesTo: _usesCorePriceGuardrails,
          buildViews: _corePriceGuardrailStarterViews,
        ),
      ],
    );

Iterable<InventoryProductCatalogSavedView> _modeOverviewStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'overview',
      label: '${context.modeShortLabel} overview',
      description: 'Default cards for daily catalog work',
      preset: InventoryProductCatalogPresentationPreset.cards,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _counterServiceStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'counter-checkout',
      label: 'Counter checkout',
      description: 'Price and scan readiness for cashier-led service',
      preset: InventoryProductCatalogPresentationPreset.pricing,
    ),
    context.starterView(
      suffix: 'stock-sellability',
      label: 'Stock sellability',
      description: 'Inventory availability and shortage review',
      preset: InventoryProductCatalogPresentationPreset.stockControl,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _digitalCommerceStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'digital-listings',
      label: 'Digital listings',
      description: 'Online and marketplace readiness signals',
      preset: InventoryProductCatalogPresentationPreset.channelSignals,
    ),
    context.starterView(
      suffix: 'price-sync',
      label: 'Price sync',
      description: 'Digital price and catalog value checks',
      preset: InventoryProductCatalogPresentationPreset.pricing,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _omniRetailStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'omni-readiness',
      label: 'Omni readiness',
      description: 'POS, online, marketplace, and kiosk launch signals',
      preset: InventoryProductCatalogPresentationPreset.channelSignals,
    ),
    context.starterView(
      suffix: 'stock-control',
      label: 'Stock control',
      description: 'Availability and replenishment risk review',
      preset: InventoryProductCatalogPresentationPreset.stockControl,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _groceryFreshGoodsStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'freshness-queue',
      label: 'Freshness queue',
      description: 'Fresh stock, shortage, and selling-risk review',
      preset: InventoryProductCatalogPresentationPreset.stockControl,
      presentationState: InventoryProductCatalogPresentationPreset
          .stockControl
          .presentationState
          .showContributionColumn(
            productFreshGoodsFreshnessColumnId,
            defaultVisible: false,
          ),
    ),
    context.starterView(
      suffix: 'fresh-channel-signals',
      label: 'Fresh channel signals',
      description: 'Fresh goods readiness across active channels',
      preset: InventoryProductCatalogPresentationPreset.channelSignals,
    ),
    context.starterView(
      suffix: 'markdown-check',
      label: 'Markdown check',
      description: 'Pricing review for fresh goods and aging stock',
      preset: InventoryProductCatalogPresentationPreset.pricing,
    ),
  ];
}

Iterable<InventoryProductCatalogSavedView> _corePriceGuardrailStarterViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'price-guardrails',
      label: 'Price guardrails',
      description: 'Price, value, and margin review',
      preset: InventoryProductCatalogPresentationPreset.pricing,
      presentationState: InventoryProductCatalogPresentationPreset
          .pricing
          .presentationState
          .hideContributionColumn('product-channel-fit'),
    ),
  ];
}

bool _isCounterServiceProfile(
  ProductCatalogSavedViewContributionContext context,
) {
  return context.channelProfile.id ==
      ProductSalesChannelProfileId.counterService;
}

bool _isDigitalCommerceProfile(
  ProductCatalogSavedViewContributionContext context,
) {
  return context.channelProfile.id ==
      ProductSalesChannelProfileId.digitalCommerce;
}

bool _isOmniLikeProfile(ProductCatalogSavedViewContributionContext context) {
  return context.channelProfile.id !=
          ProductSalesChannelProfileId.counterService &&
      context.channelProfile.id != ProductSalesChannelProfileId.digitalCommerce;
}

bool _isGroceryFreshGoodsPack(
  ProductCatalogSavedViewContributionContext context,
) {
  return context.pack.id == ProductManagementPackId.groceryFreshGoods;
}

bool _usesCorePriceGuardrails(
  ProductCatalogSavedViewContributionContext context,
) {
  return context.pack.id != ProductManagementPackId.groceryFreshGoods;
}
