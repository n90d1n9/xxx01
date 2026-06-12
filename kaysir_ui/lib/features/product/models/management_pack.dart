import 'sales_channel_definition.dart';
import 'sales_channel_profile.dart';
import 'sales_channel_types.dart';

/// Stable identifier for a reusable product management pack.
class ProductManagementPackId {
  const ProductManagementPackId(this.value);

  static const coreCatalogValue = 'core_catalog';
  static const groceryFreshGoodsValue = 'grocery_fresh_goods';
  static const coreCatalog = ProductManagementPackId(coreCatalogValue);
  static const groceryFreshGoods = ProductManagementPackId(
    groceryFreshGoodsValue,
  );
  static const values = [coreCatalog, groceryFreshGoods];

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductManagementPackId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Stable identifier for a field contributed by a product management pack.
class ProductManagementFieldId {
  const ProductManagementFieldId(this.value);

  static const sku = ProductManagementFieldId('sku');
  static const category = ProductManagementFieldId('category');
  static const barcode = ProductManagementFieldId('barcode');
  static const unit = ProductManagementFieldId('unit');
  static const expiryDate = ProductManagementFieldId('expiry_date');
  static const batchNumber = ProductManagementFieldId('batch_number');
  static const weightedUnit = ProductManagementFieldId('weighted_unit');
  static const shelfLifeDays = ProductManagementFieldId('shelf_life_days');
  static const freshnessStatus = ProductManagementFieldId('freshness_status');
  static const values = [
    sku,
    category,
    barcode,
    unit,
    expiryDate,
    batchNumber,
    weightedUnit,
    shelfLifeDays,
    freshnessStatus,
  ];

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductManagementFieldId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Operational capabilities that a management pack can add to products.
enum ProductManagementCapability {
  catalogBasics,
  scanReadiness,
  stockTracking,
  omniChannelReadiness,
  expiryTracking,
  batchTracking,
  weightedInventory,
  freshnessQueue,
}

/// Input type used to render a management pack field.
enum ProductManagementFieldType { text, number, date, toggle, select }

/// Human-facing labels for product management capabilities.
extension ProductManagementCapabilityLabels on ProductManagementCapability {
  String get label {
    switch (this) {
      case ProductManagementCapability.catalogBasics:
        return 'Catalog basics';
      case ProductManagementCapability.scanReadiness:
        return 'Scan readiness';
      case ProductManagementCapability.stockTracking:
        return 'Stock tracking';
      case ProductManagementCapability.omniChannelReadiness:
        return 'Omni-channel readiness';
      case ProductManagementCapability.expiryTracking:
        return 'Expiry tracking';
      case ProductManagementCapability.batchTracking:
        return 'Batch tracking';
      case ProductManagementCapability.weightedInventory:
        return 'Weighted inventory';
      case ProductManagementCapability.freshnessQueue:
        return 'Freshness queue';
    }
  }
}

/// Field contract contributed by a product management pack.
class ProductManagementPackField {
  const ProductManagementPackField({
    required this.id,
    required this.label,
    required this.type,
    required this.description,
    required this.capability,
    this.required = false,
    this.unitLabel,
    this.options = const [],
    this.displayPriority = 0,
  });

  final ProductManagementFieldId id;
  final String label;
  final ProductManagementFieldType type;
  final String description;
  final ProductManagementCapability capability;
  final bool required;
  final String? unitLabel;
  final List<String> options;
  final int displayPriority;

  String get requirementLabel => required ? 'Required' : 'Optional';
}

/// Reusable product management configuration for a business model.
class ProductManagementPack {
  ProductManagementPack({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.businessModelLabel,
    required this.operatorFocusLabel,
    required List<ProductSalesChannelProfilePack> profilePacks,
    required this.defaultChannelProfileId,
    List<ProductManagementCapability> capabilities = const [],
    List<ProductManagementPackField> fields = const [],
  }) : profilePacks = List.unmodifiable(profilePacks),
       capabilities = List.unmodifiable(capabilities),
       fields = List.unmodifiable(
         fields.toList()..sort(
           (left, right) =>
               left.displayPriority.compareTo(right.displayPriority),
         ),
       );

  final ProductManagementPackId id;
  final String title;
  final String subtitle;
  final String businessModelLabel;
  final String operatorFocusLabel;
  final List<ProductSalesChannelProfilePack> profilePacks;
  final ProductSalesChannelProfileId defaultChannelProfileId;
  final List<ProductManagementCapability> capabilities;
  final List<ProductManagementPackField> fields;

  List<String> get capabilityLabels {
    return List.unmodifiable(
      capabilities.map((capability) => capability.label),
    );
  }

  List<ProductManagementPackField> get requiredFields {
    return List.unmodifiable(fields.where((field) => field.required));
  }

  List<ProductManagementFieldId> get fieldIds {
    return List.unmodifiable(fields.map((field) => field.id));
  }

  bool hasCapability(ProductManagementCapability capability) {
    return capabilities.contains(capability);
  }

  ProductManagementPackField? fieldOrNull(ProductManagementFieldId id) {
    for (final field in fields) {
      if (field.id == id) return field;
    }

    return null;
  }
}

/// Lookup container for available product management packs.
class ProductManagementPackRegistry {
  ProductManagementPackRegistry({
    required List<ProductManagementPack> packs,
    this.fallbackPackId = ProductManagementPackId.coreCatalog,
  }) : packs = List.unmodifiable(packs);

  factory ProductManagementPackRegistry.fromPacks(
    List<ProductManagementPack> packs, {
    ProductManagementPackId? fallbackPackId,
  }) {
    ProductManagementPackId? packFallbackId;

    for (final pack in packs) {
      packFallbackId = pack.id;
    }

    return ProductManagementPackRegistry(
      packs: packs,
      fallbackPackId:
          fallbackPackId ??
          packFallbackId ??
          ProductManagementPackId.coreCatalog,
    );
  }

  final List<ProductManagementPack> packs;
  final ProductManagementPackId fallbackPackId;

  ProductManagementPack get fallbackPack {
    return packOrNull(fallbackPackId) ??
        (packs.isEmpty ? coreProductManagementPack : packs.first);
  }

  List<ProductManagementPackId> get packIds {
    return List.unmodifiable(packs.map((pack) => pack.id));
  }

  List<ProductSalesChannelProfilePack> get profilePacks {
    return List.unmodifiable([for (final pack in packs) ...pack.profilePacks]);
  }

  ProductManagementPack resolve(ProductManagementPackId? id) {
    if (id == null) return fallbackPack;

    return packOrNull(id) ?? fallbackPack;
  }

  ProductManagementPack? packOrNull(ProductManagementPackId id) {
    for (final pack in packs) {
      if (pack.id == id) return pack;
    }

    return null;
  }
}

const coreProductManagementFields = [
  ProductManagementPackField(
    id: ProductManagementFieldId.sku,
    label: 'SKU',
    type: ProductManagementFieldType.text,
    description: 'Internal catalog identifier used for lookup and reporting.',
    capability: ProductManagementCapability.catalogBasics,
    required: true,
    displayPriority: 10,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.category,
    label: 'Category',
    type: ProductManagementFieldType.text,
    description: 'Product grouping used for browsing, reporting, and filters.',
    capability: ProductManagementCapability.catalogBasics,
    required: true,
    displayPriority: 20,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.barcode,
    label: 'Barcode',
    type: ProductManagementFieldType.text,
    description: 'Scan code used by POS, stock count, and kiosk workflows.',
    capability: ProductManagementCapability.scanReadiness,
    displayPriority: 30,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.unit,
    label: 'Unit',
    type: ProductManagementFieldType.text,
    description: 'Selling or stock unit shown in product operations.',
    capability: ProductManagementCapability.stockTracking,
    displayPriority: 40,
  ),
];

const groceryFreshGoodsFields = [
  ProductManagementPackField(
    id: ProductManagementFieldId.expiryDate,
    label: 'Expiry date',
    type: ProductManagementFieldType.date,
    description: 'Date used to protect fresh goods from expired selling.',
    capability: ProductManagementCapability.expiryTracking,
    required: true,
    displayPriority: 50,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.batchNumber,
    label: 'Batch number',
    type: ProductManagementFieldType.text,
    description: 'Lot or batch identifier for receiving and recall workflows.',
    capability: ProductManagementCapability.batchTracking,
    required: true,
    displayPriority: 60,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.weightedUnit,
    label: 'Weighted unit',
    type: ProductManagementFieldType.toggle,
    description: 'Marks products sold by measured weight instead of pieces.',
    capability: ProductManagementCapability.weightedInventory,
    displayPriority: 70,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.shelfLifeDays,
    label: 'Shelf life',
    type: ProductManagementFieldType.number,
    description: 'Expected fresh-stock lifetime after receiving.',
    capability: ProductManagementCapability.freshnessQueue,
    unitLabel: 'days',
    displayPriority: 80,
  ),
  ProductManagementPackField(
    id: ProductManagementFieldId.freshnessStatus,
    label: 'Freshness status',
    type: ProductManagementFieldType.select,
    description: 'Operational freshness state for review queues.',
    capability: ProductManagementCapability.freshnessQueue,
    options: ['Fresh', 'Monitor', 'Discount', 'Pull'],
    displayPriority: 90,
  ),
];

final coreProductManagementPack = ProductManagementPack(
  id: ProductManagementPackId.coreCatalog,
  title: 'Core Catalog',
  subtitle: 'Reusable product catalog operations for general selling',
  businessModelLabel: 'General product operations',
  operatorFocusLabel: 'Keep products searchable, sellable, and channel-ready',
  profilePacks: [defaultProductSalesChannelProfilePack],
  defaultChannelProfileId: ProductSalesChannelProfileId.omniRetail,
  capabilities: const [
    ProductManagementCapability.catalogBasics,
    ProductManagementCapability.scanReadiness,
    ProductManagementCapability.stockTracking,
    ProductManagementCapability.omniChannelReadiness,
  ],
  fields: coreProductManagementFields,
);

const groceryFreshGoodsProfileId = ProductSalesChannelProfileId(
  'grocery_fresh_goods',
);

final groceryFreshGoodsProductSalesChannelProfile = ProductSalesChannelProfile(
  id: groceryFreshGoodsProfileId,
  title: 'Fresh Goods Grocery',
  subtitle: 'Expiry, batch, scan, and freshness readiness',
  behavior: const ProductSalesChannelProfileBehavior(
    businessModelLabel: 'Fresh goods retail',
    operatorFocusLabel:
        'Protect grocery availability with expiry and batch discipline',
    capabilityLabels: [
      'Expiry-aware selling',
      'Batch traceability',
      'Weighted products',
      'Freshness queue',
    ],
  ),
  definitions: [
    productSalesChannelDefinitionFor(ProductSalesChannel.posCheckout),
    productSalesChannelDefinitionFor(ProductSalesChannel.onlineStore),
    productSalesChannelDefinitionFor(ProductSalesChannel.kiosk),
  ],
);

final groceryFreshGoodsProductSalesChannelProfilePack =
    ProductSalesChannelProfilePack(
      id: 'grocery_fresh_goods_channels',
      title: 'Grocery Fresh Goods Channels',
      profiles: [groceryFreshGoodsProductSalesChannelProfile],
      fallbackProfileId: groceryFreshGoodsProfileId,
    );

final groceryFreshGoodsProductManagementPack = ProductManagementPack(
  id: ProductManagementPackId.groceryFreshGoods,
  title: 'Grocery Fresh Goods',
  subtitle: 'Fresh inventory, expiry, batch, and weighted-item operations',
  businessModelLabel: 'Grocery and fresh goods',
  operatorFocusLabel:
      'Track freshness-critical product data before selling across channels',
  profilePacks: [groceryFreshGoodsProductSalesChannelProfilePack],
  defaultChannelProfileId: groceryFreshGoodsProfileId,
  capabilities: const [
    ProductManagementCapability.catalogBasics,
    ProductManagementCapability.scanReadiness,
    ProductManagementCapability.stockTracking,
    ProductManagementCapability.expiryTracking,
    ProductManagementCapability.batchTracking,
    ProductManagementCapability.weightedInventory,
    ProductManagementCapability.freshnessQueue,
    ProductManagementCapability.omniChannelReadiness,
  ],
  fields: const [...coreProductManagementFields, ...groceryFreshGoodsFields],
);

final defaultProductManagementPacks = [
  coreProductManagementPack,
  groceryFreshGoodsProductManagementPack,
];

final defaultProductManagementPackRegistry =
    ProductManagementPackRegistry.fromPacks(defaultProductManagementPacks);
