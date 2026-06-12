import 'sales_channel_definition.dart';
import 'sales_channel_types.dart';

/// Stable identifier for a reusable sales-channel profile.
class ProductSalesChannelProfileId {
  const ProductSalesChannelProfileId(this.value);

  static const omniRetail = ProductSalesChannelProfileId('omni_retail');
  static const counterService = ProductSalesChannelProfileId('counter_service');
  static const digitalCommerce = ProductSalesChannelProfileId(
    'digital_commerce',
  );
  static const values = [omniRetail, counterService, digitalCommerce];

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductSalesChannelProfileId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Reusable channel profile that groups readiness definitions and behavior.
class ProductSalesChannelProfile {
  const ProductSalesChannelProfile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.definitions,
    this.behavior = defaultProductSalesChannelProfileBehavior,
  });

  final ProductSalesChannelProfileId id;
  final String title;
  final String subtitle;
  final List<ProductSalesChannelDefinition> definitions;
  final ProductSalesChannelProfileBehavior behavior;
}

/// Business behavior metadata attached to a sales-channel profile.
class ProductSalesChannelProfileBehavior {
  const ProductSalesChannelProfileBehavior({
    required this.businessModelLabel,
    required this.operatorFocusLabel,
    this.capabilityLabels = const [],
  });

  final String businessModelLabel;
  final String operatorFocusLabel;
  final List<String> capabilityLabels;

  String get capabilitySummaryLabel {
    if (capabilityLabels.isEmpty) return 'Custom product behavior';
    if (capabilityLabels.length <= 2) return capabilityLabels.join(', ');

    return '${capabilityLabels.first}, ${capabilityLabels[1]} + '
        '${capabilityLabels.length - 2} more';
  }
}

/// Composable group of sales-channel profiles contributed by a pack.
class ProductSalesChannelProfilePack {
  const ProductSalesChannelProfilePack({
    required this.id,
    required this.title,
    required this.profiles,
    this.fallbackProfileId,
  });

  final String id;
  final String title;
  final List<ProductSalesChannelProfile> profiles;
  final ProductSalesChannelProfileId? fallbackProfileId;
}

/// Lookup container for active sales-channel profiles.
class ProductSalesChannelProfileRegistry {
  ProductSalesChannelProfileRegistry({
    required List<ProductSalesChannelProfile> profiles,
    this.fallbackProfileId = ProductSalesChannelProfileId.omniRetail,
  }) : profiles = List.unmodifiable(profiles);

  factory ProductSalesChannelProfileRegistry.fromPacks(
    List<ProductSalesChannelProfilePack> packs, {
    ProductSalesChannelProfileId? fallbackProfileId,
  }) {
    final mergedProfiles =
        <ProductSalesChannelProfileId, ProductSalesChannelProfile>{};
    ProductSalesChannelProfileId? packFallbackProfileId;

    for (final pack in packs) {
      for (final profile in pack.profiles) {
        mergedProfiles[profile.id] = profile;
      }
      packFallbackProfileId = pack.fallbackProfileId ?? packFallbackProfileId;
    }

    return ProductSalesChannelProfileRegistry(
      profiles: mergedProfiles.values.toList(growable: false),
      fallbackProfileId:
          fallbackProfileId ??
          packFallbackProfileId ??
          ProductSalesChannelProfileId.omniRetail,
    );
  }

  final List<ProductSalesChannelProfile> profiles;
  final ProductSalesChannelProfileId fallbackProfileId;

  bool get isEmpty => profiles.isEmpty;

  List<ProductSalesChannelProfileId> get profileIds {
    return List.unmodifiable(profiles.map((profile) => profile.id));
  }

  ProductSalesChannelProfile get fallbackProfile {
    return profileOrNull(fallbackProfileId) ??
        (profiles.isEmpty
            ? omniRetailProductSalesChannelProfile
            : profiles.first);
  }

  bool contains(ProductSalesChannelProfileId id) {
    return profileOrNull(id) != null;
  }

  ProductSalesChannelProfile resolve(ProductSalesChannelProfileId? id) {
    if (id == null) return fallbackProfile;

    return profileOrNull(id) ?? fallbackProfile;
  }

  ProductSalesChannelProfile? profileOrNull(ProductSalesChannelProfileId id) {
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }

    return null;
  }

  ProductSalesChannelProfileId resolveQueryValue(String? value) {
    final parsedId = _productSalesChannelProfileIdFromQueryValue(value);

    return contains(parsedId) ? parsedId : fallbackProfile.id;
  }
}

ProductSalesChannelProfile get defaultProductSalesChannelProfile {
  return defaultProductSalesChannelProfileRegistry.fallbackProfile;
}

List<ProductSalesChannelProfile> get defaultProductSalesChannelProfiles {
  return defaultProductSalesChannelProfileRegistry.profiles;
}

/// Resolves a default sales-channel profile by identifier.
ProductSalesChannelProfile productSalesChannelProfileFor(
  ProductSalesChannelProfileId id,
) {
  return defaultProductSalesChannelProfileRegistry.resolve(id);
}

String productSalesChannelProfileQueryValue(ProductSalesChannelProfileId id) {
  return id.value;
}

ProductSalesChannelProfileId productSalesChannelProfileIdFromQuery(
  String? value,
) {
  return _productSalesChannelProfileIdFromQueryValue(value);
}

ProductSalesChannelProfileId _productSalesChannelProfileIdFromQueryValue(
  String? value,
) {
  final normalized = value?.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );
  switch (normalized) {
    case 'counter':
    case 'counter_service':
    case 'counterservice':
      return ProductSalesChannelProfileId.counterService;
    case 'digital':
    case 'digital_commerce':
    case 'digitalcommerce':
    case 'online':
      return ProductSalesChannelProfileId.digitalCommerce;
    case 'omni':
    case 'omni_retail':
    case 'omniretail':
    case '':
    case null:
      return ProductSalesChannelProfileId.omniRetail;
  }

  return ProductSalesChannelProfileId(normalized);
}

const defaultProductSalesChannelProfileBehavior =
    ProductSalesChannelProfileBehavior(
      businessModelLabel: 'Product operations',
      operatorFocusLabel: 'Review catalog readiness and product setup queues',
    );

final omniRetailProductSalesChannelProfile = ProductSalesChannelProfile(
  id: ProductSalesChannelProfileId.omniRetail,
  title: 'Omni Retail',
  subtitle: 'POS, online, marketplace, and kiosk readiness',
  behavior: const ProductSalesChannelProfileBehavior(
    businessModelLabel: 'Omni-channel retail',
    operatorFocusLabel:
        'Coordinate store, online, marketplace, and self-service selling',
    capabilityLabels: [
      'Store checkout',
      'Online catalog',
      'Marketplace listing',
      'Kiosk scan flow',
    ],
  ),
  definitions: defaultProductSalesChannelDefinitions,
);

final counterServiceProductSalesChannelProfile = ProductSalesChannelProfile(
  id: ProductSalesChannelProfileId.counterService,
  title: 'Counter Service',
  subtitle: 'Fast checkout readiness for cashier-led selling',
  behavior: const ProductSalesChannelProfileBehavior(
    businessModelLabel: 'Cashier-led counter',
    operatorFocusLabel:
        'Keep price, stock, and scan readiness fast for service',
    capabilityLabels: ['Fast checkout', 'Kiosk queue', 'Stock sellability'],
  ),
  definitions: [
    productSalesChannelDefinitionFor(ProductSalesChannel.posCheckout),
    productSalesChannelDefinitionFor(ProductSalesChannel.kiosk),
  ],
);

final digitalCommerceProductSalesChannelProfile = ProductSalesChannelProfile(
  id: ProductSalesChannelProfileId.digitalCommerce,
  title: 'Digital Commerce',
  subtitle: 'Online storefront and marketplace listing readiness',
  behavior: const ProductSalesChannelProfileBehavior(
    businessModelLabel: 'Digital commerce',
    operatorFocusLabel:
        'Prepare products for online storefront and marketplace syndication',
    capabilityLabels: [
      'SKU discipline',
      'Product copy',
      'Marketplace taxonomy',
    ],
  ),
  definitions: [
    productSalesChannelDefinitionFor(ProductSalesChannel.onlineStore),
    productSalesChannelDefinitionFor(ProductSalesChannel.marketplace),
  ],
);

final _defaultProductSalesChannelProfiles = [
  omniRetailProductSalesChannelProfile,
  counterServiceProductSalesChannelProfile,
  digitalCommerceProductSalesChannelProfile,
];

final defaultProductSalesChannelProfilePack = ProductSalesChannelProfilePack(
  id: 'default_product_channels',
  title: 'Default Product Channels',
  profiles: _defaultProductSalesChannelProfiles,
  fallbackProfileId: ProductSalesChannelProfileId.omniRetail,
);

final defaultProductSalesChannelProfileRegistry =
    ProductSalesChannelProfileRegistry.fromPacks([
      defaultProductSalesChannelProfilePack,
    ]);
