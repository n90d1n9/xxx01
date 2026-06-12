import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_presentation_state.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog_saved_view.dart';
import 'package:kaysir/features/product/models/product_catalog_saved_view_contribution.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/states/product_catalog_saved_view_contribution_provider.dart';

void main() {
  test('exposes default catalog saved view contributions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registry = container.read(
      productCatalogSavedViewContributionRegistryProvider,
    );

    expect(registry.contributionIds, contains('mode-overview'));
    expect(registry.contributionIds, contains('omni-retail-channel'));
    expect(registry.contributionIds, contains('core-price-guardrails'));
  });

  test('builds registry from overridden contribution list', () {
    final container = ProviderContainer(
      overrides: [
        productCatalogSavedViewContributionsProvider.overrideWithValue([
          const ProductCatalogSavedViewContribution(
            id: 'test-launch-view',
            sectionLabel: 'Launch views',
            buildViews: _testLaunchViews,
          ),
        ]),
      ],
    );
    addTearDown(container.dispose);

    final registry = container.read(
      productCatalogSavedViewContributionRegistryProvider,
    );
    final views = registry.starterViewsFor(
      ProductCatalogSavedViewContributionContext(
        seedKey: 'core_catalog.omni_retail',
        pack: coreProductManagementPack,
        channelProfile: omniRetailProductSalesChannelProfile,
      ),
    );

    expect(registry.contributionIds, ['test-launch-view']);
    expect(views.single.label, 'Launch review');
  });
}

Iterable<InventoryProductCatalogSavedView> _testLaunchViews(
  ProductCatalogSavedViewContributionContext context,
) {
  return [
    context.starterView(
      suffix: 'launch-review',
      label: 'Launch review',
      description: 'Custom launch workflow',
      preset: InventoryProductCatalogPresentationPreset.operationsTable,
    ),
  ];
}
