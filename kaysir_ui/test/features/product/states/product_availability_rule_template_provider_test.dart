import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/product_availability_rule_authoring.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/product_availability_rule_template_provider.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';

void main() {
  test('availability template provider exposes core templates by default', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final registry = container.read(
      productAvailabilityRuleTemplateRegistryProvider,
    );

    expect(registry.hasContributions, isFalse);
    expect(registry.templateIds, [
      ProductAvailabilityRuleTemplateId.counterService,
      ProductAvailabilityRuleTemplateId.onlineStore,
      ProductAvailabilityRuleTemplateId.marketplace,
      ProductAvailabilityRuleTemplateId.kiosk,
      ProductAvailabilityRuleTemplateId.wholesale,
      ProductAvailabilityRuleTemplateId.temporarilyPaused,
    ]);
  });

  test(
    'availability template provider activates product pack templates',
    () async {
      final container = ProviderContainer(
        overrides: [
          productManagementPacksProvider.overrideWithValue([
            coreProductManagementPack,
            groceryFreshGoodsProductManagementPack,
          ]),
          _memoryPreferencesRepositoryOverride(),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(ProductManagementPackId.groceryFreshGoods);

      final templates = container.read(
        productAvailabilityRuleTemplatesProvider,
      );
      final entries = container.read(
        productAvailabilityRuleTemplateEntriesProvider,
      );
      final sourceSummaries = container.read(
        productAvailabilityRuleTemplateSourceSummariesProvider,
      );

      expect(
        container
            .read(productAvailabilityRuleTemplateRegistryProvider)
            .contributionCount,
        1,
      );
      expect(
        templates.map((template) => template.id),
        containsAll([
          ProductAvailabilityRuleTemplateId.freshShelf,
          ProductAvailabilityRuleTemplateId.freshnessHold,
        ]),
      );
      expect(
        templates
            .singleWhere(
              (template) =>
                  template.id == ProductAvailabilityRuleTemplateId.freshShelf,
            )
            .attributes['freshness_status'],
        'Fresh',
      );
      expect(
        entries
            .singleWhere(
              (entry) =>
                  entry.template.id ==
                  ProductAvailabilityRuleTemplateId.freshShelf,
            )
            .sourceLabel,
        'Freshness availability templates',
      );
      expect(sourceSummaries.map((source) => source.title), [
        'Core templates',
        'Freshness availability templates',
      ]);
      expect(sourceSummaries.map((source) => source.templateCount), [6, 2]);
    },
  );
}

dynamic _memoryPreferencesRepositoryOverride() {
  return productManagementPackPreferencesRepositoryProvider.overrideWithValue(
    ProductManagementPackPreferencesRepository(
      store: MemoryProductManagementPackPreferencesStore(),
    ),
  );
}
