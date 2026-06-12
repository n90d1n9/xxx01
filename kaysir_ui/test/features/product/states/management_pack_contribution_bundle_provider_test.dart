import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_contribution_bundle_provider.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';

void main() {
  test('pack contribution bundle provider exposes current core pack', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final bundle = container.read(
      productManagementPackContributionBundleProvider,
    );

    expect(bundle.managementPack, coreProductManagementPack);
    expect(bundle.fieldCountLabel, '4 fields');
    expect(bundle.moduleContributionStatusLabel, '0/5 active hooks');
    expect(bundle.moduleActivationSummaries.single.statusLabel, 'Inactive');
    expect(bundle.setupReadinessContributions.single.isActive, isFalse);
  });

  test(
    'pack contribution bundle provider follows active pack registry',
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

      final bundle = container.read(
        productManagementPackContributionBundleProvider,
      );

      expect(bundle.managementPack, groceryFreshGoodsProductManagementPack);
      expect(bundle.fieldCountLabel, '9 fields');
      expect(bundle.activeModuleContributionCount, 5);
      expect(bundle.moduleActivationSummaries.single.statusLabel, 'Active');
      expect(bundle.actionContributions.single.title, 'Freshness control');
      expect(
        bundle.actionContributions.single.sourceLabel,
        'Freshness operations',
      );
      expect(
        bundle.setupReadinessContributions.single.title,
        'Freshness Readiness',
      );
      expect(
        bundle.recommendationContributions.single.sourceLabel,
        'Freshness operations',
      );
      expect(
        bundle.moduleBriefContributions.single.sourceLabel,
        'Freshness operations',
      );
      expect(
        bundle.moduleBriefContributions.single.title,
        'Freshness selling gates',
      );
      expect(
        bundle.availabilityTemplateContributions.single.sourceLabel,
        'Freshness operations',
      );
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
