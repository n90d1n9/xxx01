import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/management_pack_preset.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';

void main() {
  test(
    'default product management pack presets cover reusable product lines',
    () {
      expect(defaultProductManagementPackPresets.map((preset) => preset.id), [
        'core_omni_retail',
        'core_counter_service',
        'core_digital_commerce',
        'fresh_goods_grocery',
      ]);
      expect(
        defaultProductManagementPackPresets.last.packId,
        ProductManagementPackId.groceryFreshGoods,
      );
      expect(defaultProductManagementPackPresets.last.highlights, [
        'Expiry control',
        'Batch traceability',
        'Freshness queue',
      ]);
    },
  );

  test('active product management pack preset matches pack and profile', () {
    final activePreset = activeProductManagementPackPresetFor(
      presets: defaultProductManagementPackPresets,
      pack: coreProductManagementPack,
      profile: counterServiceProductSalesChannelProfile,
    );

    expect(activePreset?.id, 'core_counter_service');

    final missingPreset = activeProductManagementPackPresetFor(
      presets: defaultProductManagementPackPresets,
      pack: groceryFreshGoodsProductManagementPack,
      profile: omniRetailProductSalesChannelProfile,
    );

    expect(missingPreset, isNull);
  });
}
