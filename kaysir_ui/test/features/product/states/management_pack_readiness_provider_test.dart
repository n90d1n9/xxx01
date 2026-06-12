import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_readiness.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/management_pack_readiness_provider.dart';

void main() {
  test('pack readiness provider exposes active pack readiness sections', () {
    final container = ProviderContainer(
      overrides: [_memoryPreferencesRepositoryOverride()],
    );
    addTearDown(container.dispose);

    final readiness = container.read(productManagementPackReadinessProvider);

    expect(readiness.bundle.managementPack, coreProductManagementPack);
    expect(readiness.sections.map((section) => section.id), [
      productManagementPackReadinessDataSectionId,
      productManagementPackReadinessChannelSectionId,
      productManagementPackReadinessWorkflowSectionId,
      productManagementPackReadinessExtensionSectionId,
    ]);
  });

  test(
    'pack readiness provider follows active product management pack',
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

      final readiness = container.read(productManagementPackReadinessProvider);

      expect(
        readiness.bundle.managementPack,
        groceryFreshGoodsProductManagementPack,
      );
      expect(readiness.titleLabel, 'Grocery Fresh Goods readiness');
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
