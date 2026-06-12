import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('core product management pack exposes reusable catalog contract', () {
    expect(coreProductManagementPack.id, ProductManagementPackId.coreCatalog);
    expect(coreProductManagementPack.title, 'Core Catalog');
    expect(coreProductManagementPack.profilePacks, [
      defaultProductSalesChannelProfilePack,
    ]);
    expect(
      coreProductManagementPack.defaultChannelProfileId,
      ProductSalesChannelProfileId.omniRetail,
    );
    expect(coreProductManagementPack.capabilityLabels, [
      'Catalog basics',
      'Scan readiness',
      'Stock tracking',
      'Omni-channel readiness',
    ]);
    expect(coreProductManagementPack.requiredFields.map((field) => field.id), [
      ProductManagementFieldId.sku,
      ProductManagementFieldId.category,
    ]);
    expect(
      coreProductManagementPack.fieldOrNull(ProductManagementFieldId.barcode),
      isNotNull,
    );
  });

  test(
    'grocery fresh goods pack extends product data and channel strategy',
    () {
      expect(
        groceryFreshGoodsProductManagementPack.id,
        ProductManagementPackId.groceryFreshGoods,
      );
      expect(
        groceryFreshGoodsProductManagementPack.defaultChannelProfileId,
        groceryFreshGoodsProfileId,
      );
      expect(
        groceryFreshGoodsProductManagementPack.hasCapability(
          ProductManagementCapability.expiryTracking,
        ),
        isTrue,
      );
      expect(
        groceryFreshGoodsProductManagementPack.fieldIds,
        containsAll([
          ProductManagementFieldId.sku,
          ProductManagementFieldId.expiryDate,
          ProductManagementFieldId.batchNumber,
          ProductManagementFieldId.weightedUnit,
        ]),
      );
      expect(
        groceryFreshGoodsProductManagementPack.requiredFields.map(
          (field) => field.id,
        ),
        containsAll([
          ProductManagementFieldId.sku,
          ProductManagementFieldId.category,
          ProductManagementFieldId.expiryDate,
          ProductManagementFieldId.batchNumber,
        ]),
      );
      expect(
        groceryFreshGoodsProductSalesChannelProfile.behavior.capabilityLabels,
        [
          'Expiry-aware selling',
          'Batch traceability',
          'Weighted products',
          'Freshness queue',
        ],
      );
      expect(
        groceryFreshGoodsProductSalesChannelProfile.definitions.map(
          (definition) => definition.channel,
        ),
        [
          ProductSalesChannel.posCheckout,
          ProductSalesChannel.onlineStore,
          ProductSalesChannel.kiosk,
        ],
      );
    },
  );

  test('product management pack registry composes active variant packs', () {
    final registry = ProductManagementPackRegistry.fromPacks([
      coreProductManagementPack,
      groceryFreshGoodsProductManagementPack,
    ]);

    expect(registry.packIds, [
      ProductManagementPackId.coreCatalog,
      ProductManagementPackId.groceryFreshGoods,
    ]);
    expect(registry.fallbackPack, groceryFreshGoodsProductManagementPack);
    expect(registry.profilePacks, [
      defaultProductSalesChannelProfilePack,
      groceryFreshGoodsProductSalesChannelProfilePack,
    ]);
    expect(
      registry.resolve(const ProductManagementPackId('unknown')),
      groceryFreshGoodsProductManagementPack,
    );
  });
}
