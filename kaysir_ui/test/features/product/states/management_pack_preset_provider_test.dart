import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_preset.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/repositories/management_pack_preferences_repository.dart';
import 'package:kaysir/features/product/states/management_pack_provider.dart';
import 'package:kaysir/features/product/states/management_pack_preset_provider.dart';
import 'package:kaysir/features/product/states/sales_channel_definition_provider.dart';

void main() {
  test(
    'product management pack preset provider exposes active core preset',
    () {
      final container = ProviderContainer(
        overrides: [_memoryPreferencesRepositoryOverride()],
      );
      addTearDown(container.dispose);

      expect(
        container.read(productManagementPackPresetsProvider),
        defaultProductManagementPackPresets,
      );
      expect(
        container.read(activeProductManagementPackPresetProvider)?.id,
        'core_omni_retail',
      );
    },
  );

  test(
    'product management pack preset provider follows pack and channel',
    () async {
      final container = ProviderContainer(
        overrides: [_memoryPreferencesRepositoryOverride()],
      );
      addTearDown(container.dispose);

      container.read(productSalesChannelProfileIdProvider.notifier).state =
          ProductSalesChannelProfileId.counterService;

      expect(
        container.read(activeProductManagementPackPresetProvider)?.id,
        'core_counter_service',
      );

      await container
          .read(productManagementPackIdProvider.notifier)
          .selectPack(ProductManagementPackId.groceryFreshGoods);
      container.read(productSalesChannelProfileIdProvider.notifier).state =
          groceryFreshGoodsProfileId;

      expect(
        container.read(activeProductManagementPackPresetProvider)?.id,
        'fresh_goods_grocery',
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
