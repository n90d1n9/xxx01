import 'management_pack.dart';
import 'sales_channel_profile.dart';

/// Reusable recipe that pairs a management pack with a channel profile.
class ProductManagementPackPreset {
  const ProductManagementPackPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scopeLabel,
    required this.packId,
    required this.channelProfileId,
    this.highlights = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String scopeLabel;
  final ProductManagementPackId packId;
  final ProductSalesChannelProfileId channelProfileId;
  final List<String> highlights;

  bool matches({
    required ProductManagementPack pack,
    required ProductSalesChannelProfile profile,
  }) {
    return pack.id == packId && profile.id == channelProfileId;
  }
}

/// Default presets for productized workspace modes.
const defaultProductManagementPackPresets = [
  ProductManagementPackPreset(
    id: 'core_omni_retail',
    title: 'Core Omni Retail',
    subtitle: 'General catalog operations across POS, online, and kiosk.',
    scopeLabel: 'Default tenant / all outlets',
    packId: ProductManagementPackId.coreCatalog,
    channelProfileId: ProductSalesChannelProfileId.omniRetail,
    highlights: ['Catalog basics', 'Scan readiness', 'Omni-channel launch'],
  ),
  ProductManagementPackPreset(
    id: 'core_counter_service',
    title: 'Counter Service Catalog',
    subtitle: 'Compact selling setup for cashier-led counter operations.',
    scopeLabel: 'Counter outlet',
    packId: ProductManagementPackId.coreCatalog,
    channelProfileId: ProductSalesChannelProfileId.counterService,
    highlights: ['POS checkout', 'Fast setup', 'Stock visibility'],
  ),
  ProductManagementPackPreset(
    id: 'core_digital_commerce',
    title: 'Digital Commerce Catalog',
    subtitle: 'Online and marketplace product readiness for digital selling.',
    scopeLabel: 'Online business line',
    packId: ProductManagementPackId.coreCatalog,
    channelProfileId: ProductSalesChannelProfileId.digitalCommerce,
    highlights: ['Online store', 'Marketplace', 'Price readiness'],
  ),
  ProductManagementPackPreset(
    id: 'fresh_goods_grocery',
    title: 'Fresh Goods Grocery',
    subtitle: 'Fresh inventory, expiry, batch, and weighted-item operations.',
    scopeLabel: 'Fresh grocery outlet',
    packId: ProductManagementPackId.groceryFreshGoods,
    channelProfileId: groceryFreshGoodsProfileId,
    highlights: ['Expiry control', 'Batch traceability', 'Freshness queue'],
  ),
];

/// Finds the preset matching the active pack and sales-channel profile.
ProductManagementPackPreset? activeProductManagementPackPresetFor({
  required List<ProductManagementPackPreset> presets,
  required ProductManagementPack pack,
  required ProductSalesChannelProfile profile,
}) {
  for (final preset in presets) {
    if (preset.matches(pack: pack, profile: profile)) return preset;
  }

  return null;
}
