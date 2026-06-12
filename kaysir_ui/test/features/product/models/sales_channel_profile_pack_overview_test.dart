import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/sales_channel_profile_pack_overview.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';

void main() {
  test('profile pack overview describes default pack provenance', () {
    final overview = buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack],
      registry: defaultProductSalesChannelProfileRegistry,
      selectedProfile: omniRetailProductSalesChannelProfile,
    );

    expect(overview.statusLabel, 'Single pack');
    expect(overview.packCountLabel, '1 pack');
    expect(overview.profileCountLabel, '3 profiles');
    expect(overview.selectedSourceLabel, 'Default Product Channels');
    expect(overview.fallbackLabel, 'Fallback: Omni Retail');
    expect(overview.packs.single.statusLabel, 'Current fallback');
    expect(
      overview.packs.single.profilePreviewLabel,
      'Omni Retail, Counter Service + 1 more',
    );
  });

  test('profile pack overview tracks composed custom pack source', () {
    const groceryProfileId = ProductSalesChannelProfileId('grocery_market');
    final groceryProfile = ProductSalesChannelProfile(
      id: groceryProfileId,
      title: 'Grocery Market',
      subtitle: 'Fresh goods and shelf scanning readiness',
      definitions: const [],
    );
    final groceryPack = ProductSalesChannelProfilePack(
      id: 'grocery_pack',
      title: 'Grocery Pack',
      profiles: [groceryProfile],
      fallbackProfileId: groceryProfileId,
    );
    final registry = ProductSalesChannelProfileRegistry.fromPacks([
      defaultProductSalesChannelProfilePack,
      groceryPack,
    ]);
    final overview = buildProductSalesChannelProfilePackOverview(
      packs: [defaultProductSalesChannelProfilePack, groceryPack],
      registry: registry,
      selectedProfile: groceryProfile,
    );

    expect(overview.statusLabel, 'Composable');
    expect(overview.packCountLabel, '2 packs');
    expect(overview.profileCountLabel, '4 profiles');
    expect(overview.selectedSourceLabel, 'Grocery Pack');
    expect(overview.fallbackProfile, groceryProfile);
    expect(overview.packs.first.statusLabel, 'Available');
    expect(overview.packs.last.statusLabel, 'Current fallback');
    expect(overview.packs.last.profilePreviewLabel, 'Grocery Market');
  });
}
