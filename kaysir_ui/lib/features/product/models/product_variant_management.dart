import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'sales_channel_profile.dart';

const productStandaloneVariantGroupLabel = 'Standalone products';

enum ProductVariantRiskStatus { action, watch, healthy }

class ProductVariantManagementSummary {
  const ProductVariantManagementSummary({
    required this.productCount,
    required this.variantFamilyCount,
    required this.variantProductCount,
    required this.standaloneProductCount,
    required this.configuredVariantProductCount,
    required this.incompleteVariantProductCount,
    required this.duplicateOptionProductCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
  });

  final int productCount;
  final int variantFamilyCount;
  final int variantProductCount;
  final int standaloneProductCount;
  final int configuredVariantProductCount;
  final int incompleteVariantProductCount;
  final int duplicateOptionProductCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;

  int get variantCoveragePercent {
    if (productCount == 0) return 0;

    return ((variantProductCount / productCount) * 100).round();
  }

  int get optionCoveragePercent {
    if (variantProductCount == 0) return 0;

    return ((configuredVariantProductCount / variantProductCount) * 100)
        .round();
  }

  int get variantRiskCount {
    return incompleteVariantProductCount +
        duplicateOptionProductCount +
        attentionProductCount +
        untrackedProductCount;
  }

  String get coverageLabel => '$variantProductCount/$productCount grouped';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (incompleteVariantProductCount > 0) return 'Variant setup';
    if (duplicateOptionProductCount > 0) return 'Duplicate options';
    if (attentionProductCount > 0) return 'Stock review';

    return 'Variant ready';
  }
}

class ProductVariantManagementEntry {
  const ProductVariantManagementEntry({
    required this.id,
    required this.title,
    required this.productCount,
    required this.configuredVariantProductCount,
    required this.incompleteVariantProductCount,
    required this.duplicateOptionProductCount,
    required this.optionValueCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
    this.isStandalone = false,
    this.isInferred = false,
  });

  final String id;
  final String title;
  final int productCount;
  final int configuredVariantProductCount;
  final int incompleteVariantProductCount;
  final int duplicateOptionProductCount;
  final int optionValueCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;
  final bool isStandalone;
  final bool isInferred;

  int get riskCount {
    return incompleteVariantProductCount +
        duplicateOptionProductCount +
        attentionProductCount +
        untrackedProductCount;
  }

  bool get hasRisk => riskCount > 0;

  ProductVariantRiskStatus get status {
    if (incompleteVariantProductCount > 0 || duplicateOptionProductCount > 0) {
      return ProductVariantRiskStatus.action;
    }
    if (attentionProductCount > 0 || untrackedProductCount > 0) {
      return ProductVariantRiskStatus.watch;
    }

    return ProductVariantRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get optionCoverageLabel {
    if (isStandalone) return 'Standalone';
    if (productCount == 0) return 'No options';

    return '$configuredVariantProductCount/$productCount optioned';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return isStandalone ? 'Standalone ready' : 'Variant ready';

    final parts = [
      if (incompleteVariantProductCount > 0)
        '$incompleteVariantProductCount missing option',
      if (duplicateOptionProductCount > 0)
        '$duplicateOptionProductCount duplicate',
      if (attentionProductCount > 0) '$attentionProductCount stock',
      if (untrackedProductCount > 0) '$untrackedProductCount untracked',
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (incompleteVariantProductCount > 0) return 'Complete options';
    if (duplicateOptionProductCount > 0) return 'Review duplicates';
    if (attentionProductCount > 0) return 'Review stock';
    if (isStandalone) return 'Open catalog';

    return 'Review variants';
  }
}

class ProductVariantManagementOverview {
  ProductVariantManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductVariantManagementEntry> families,
  }) : families = List.unmodifiable(families);

  final ProductVariantManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductVariantManagementEntry> families;

  ProductVariantManagementEntry? get primaryFamily {
    if (families.isEmpty) return null;

    return families.firstWhere(
      (family) => family.hasRisk,
      orElse: () => families.first,
    );
  }
}

ProductVariantManagementOverview buildProductVariantManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final skuCandidateCounts = <String, int>{};
  for (final record in records) {
    if (productExplicitVariantFamilyFor(record.product) != null) continue;

    final skuCandidate = _skuFamilyCandidate(record.product.sku);
    if (skuCandidate == null) continue;

    skuCandidateCounts[skuCandidate] =
        (skuCandidateCounts[skuCandidate] ?? 0) + 1;
  }

  final accumulators = <String, _ProductVariantAccumulator>{};

  for (final record in records) {
    final grouping = _variantGroupingFor(
      record.product,
      skuCandidateCounts: skuCandidateCounts,
    );
    accumulators
        .putIfAbsent(
          grouping.id,
          () => _ProductVariantAccumulator(
            id: grouping.id,
            title: grouping.title,
            isStandalone: grouping.isStandalone,
            isInferred: grouping.isInferred,
            skuFamilyCandidate: grouping.skuFamilyCandidate,
          ),
        )
        .add(record);
  }

  final families =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareVariantEntries);

  return ProductVariantManagementOverview(
    channelProfile: channelProfile,
    summary: ProductVariantManagementSummary(
      productCount: families.fold(
        0,
        (total, family) => total + family.productCount,
      ),
      variantFamilyCount:
          families.where((family) => !family.isStandalone).length,
      variantProductCount: families.fold(
        0,
        (total, family) =>
            total + (family.isStandalone ? 0 : family.productCount),
      ),
      standaloneProductCount: families.fold(
        0,
        (total, family) =>
            total + (family.isStandalone ? family.productCount : 0),
      ),
      configuredVariantProductCount: families.fold(
        0,
        (total, family) =>
            total +
            (family.isStandalone ? 0 : family.configuredVariantProductCount),
      ),
      incompleteVariantProductCount: families.fold(
        0,
        (total, family) => total + family.incompleteVariantProductCount,
      ),
      duplicateOptionProductCount: families.fold(
        0,
        (total, family) => total + family.duplicateOptionProductCount,
      ),
      attentionProductCount: families.fold(
        0,
        (total, family) => total + family.attentionProductCount,
      ),
      untrackedProductCount: families.fold(
        0,
        (total, family) => total + family.untrackedProductCount,
      ),
      totalInventoryValue: families.fold(
        0,
        (total, family) => total + family.totalInventoryValue,
      ),
    ),
    families: families,
  );
}

String? productExplicitVariantFamilyFor(Product product) {
  for (final key in _variantFamilyAttributeKeys) {
    final value = _customAttributeValue(product, key);
    if (value != null) return value;
  }

  return null;
}

Map<String, String> productVariantOptionsFor(Product product) {
  final options = <String, String>{};

  for (final entry in product.customAttributes.entries) {
    final normalizedKey = _normalizedAttributeKey(entry.key);
    final label = _variantOptionLabelFor(normalizedKey);
    final normalizedValue = entry.value.trim();

    if (label != null && normalizedValue.isNotEmpty) {
      options[label] = normalizedValue;
    }
  }

  return Map.unmodifiable(options);
}

class _ProductVariantAccumulator {
  _ProductVariantAccumulator({
    required this.id,
    required this.title,
    required this.isStandalone,
    required this.isInferred,
    this.skuFamilyCandidate,
  });

  final String id;
  final String title;
  final bool isStandalone;
  final bool isInferred;
  final String? skuFamilyCandidate;
  final optionSignatureCounts = <String, int>{};
  var productCount = 0;
  var configuredVariantProductCount = 0;
  var incompleteVariantProductCount = 0;
  var attentionProductCount = 0;
  var untrackedProductCount = 0;
  var totalInventoryValue = 0.0;

  void add(InventoryProductCatalogRecord record) {
    productCount += 1;
    totalInventoryValue += record.inventoryValue;

    if (record.needsAttention) attentionProductCount += 1;
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductCount += 1;
    }

    if (isStandalone) return;

    final optionSignature = _productVariantOptionSignature(
      record.product,
      skuFamilyCandidate: skuFamilyCandidate,
    );
    if (optionSignature == null) {
      incompleteVariantProductCount += 1;
    } else {
      configuredVariantProductCount += 1;
      optionSignatureCounts[optionSignature] =
          (optionSignatureCounts[optionSignature] ?? 0) + 1;
    }
  }

  ProductVariantManagementEntry toEntry() {
    final duplicateOptionProductCount = optionSignatureCounts.values.fold(
      0,
      (total, count) => total + (count > 1 ? count - 1 : 0),
    );

    return ProductVariantManagementEntry(
      id: id,
      title: title,
      productCount: productCount,
      configuredVariantProductCount: configuredVariantProductCount,
      incompleteVariantProductCount: incompleteVariantProductCount,
      duplicateOptionProductCount: duplicateOptionProductCount,
      optionValueCount: optionSignatureCounts.length,
      attentionProductCount: attentionProductCount,
      untrackedProductCount: untrackedProductCount,
      totalInventoryValue: totalInventoryValue,
      isStandalone: isStandalone,
      isInferred: isInferred,
      reviewTarget: ProductCatalogReviewTarget(
        query: isStandalone ? '' : title,
        title: 'Variant management',
        reasonLabel:
            isStandalone
                ? 'standalone products'
                : '${title.toLowerCase()} variants',
      ),
    );
  }
}

class _ProductVariantGrouping {
  const _ProductVariantGrouping({
    required this.id,
    required this.title,
    required this.isStandalone,
    required this.isInferred,
    this.skuFamilyCandidate,
  });

  final String id;
  final String title;
  final bool isStandalone;
  final bool isInferred;
  final String? skuFamilyCandidate;
}

_ProductVariantGrouping _variantGroupingFor(
  Product product, {
  required Map<String, int> skuCandidateCounts,
}) {
  final explicitFamily = productExplicitVariantFamilyFor(product);
  if (explicitFamily != null) {
    return _ProductVariantGrouping(
      id: _variantGroupIdFor(explicitFamily),
      title: explicitFamily,
      isStandalone: false,
      isInferred: false,
    );
  }

  final skuCandidate = _skuFamilyCandidate(product.sku);
  if (skuCandidate != null && (skuCandidateCounts[skuCandidate] ?? 0) > 1) {
    return _ProductVariantGrouping(
      id: _variantGroupIdFor(skuCandidate),
      title: skuCandidate,
      isStandalone: false,
      isInferred: true,
      skuFamilyCandidate: skuCandidate,
    );
  }

  return const _ProductVariantGrouping(
    id: 'standalone_products',
    title: productStandaloneVariantGroupLabel,
    isStandalone: true,
    isInferred: false,
  );
}

String? _productVariantOptionSignature(
  Product product, {
  required String? skuFamilyCandidate,
}) {
  final options = productVariantOptionsFor(product);
  if (options.isNotEmpty) {
    final parts = [
      for (final entry
          in options.entries.toList()
            ..sort((first, second) => first.key.compareTo(second.key)))
        '${entry.key}:${entry.value.trim().toLowerCase()}',
    ];

    return parts.join('|');
  }

  final skuSuffix = _skuVariantSuffix(
    product.sku,
    familyCandidate: skuFamilyCandidate,
  );
  if (skuSuffix != null) return 'SKU:$skuSuffix';

  return null;
}

String? _skuFamilyCandidate(String? sku) {
  final normalizedSku = sku?.trim().toUpperCase();
  if (normalizedSku == null || normalizedSku.isEmpty) return null;

  final match = RegExp(
    r'^([A-Z0-9]{2,})[-_./ ]+(.+)$',
  ).firstMatch(normalizedSku);
  if (match == null) return null;

  return match.group(1);
}

String? _skuVariantSuffix(String? sku, {required String? familyCandidate}) {
  final normalizedSku = sku?.trim().toUpperCase();
  final normalizedFamily = familyCandidate?.trim().toUpperCase();
  if (normalizedSku == null ||
      normalizedSku.isEmpty ||
      normalizedFamily == null ||
      normalizedFamily.isEmpty ||
      !normalizedSku.startsWith(normalizedFamily)) {
    return null;
  }

  final suffix = normalizedSku
      .substring(normalizedFamily.length)
      .replaceFirst(RegExp(r'^[-_./ ]+'), '');

  return suffix.isEmpty ? null : suffix;
}

int _compareVariantEntries(
  ProductVariantManagementEntry first,
  ProductVariantManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  if (first.isStandalone != second.isStandalone) {
    return first.isStandalone ? 1 : -1;
  }

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final productRank = second.productCount.compareTo(first.productCount);
  if (productRank != 0) return productRank;

  final valueRank = second.totalInventoryValue.compareTo(
    first.totalInventoryValue,
  );
  if (valueRank != 0) return valueRank;

  return first.title.compareTo(second.title);
}

String _variantGroupIdFor(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');

  return trimmed.isEmpty ? 'variant_family' : trimmed;
}

String? _customAttributeValue(Product product, String key) {
  for (final entry in product.customAttributes.entries) {
    final normalizedKey = _normalizedAttributeKey(entry.key);
    final normalizedValue = entry.value.trim();
    if (normalizedKey == key && normalizedValue.isNotEmpty) {
      return normalizedValue;
    }
  }

  return null;
}

String _normalizedAttributeKey(String key) {
  return key.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

String? _variantOptionLabelFor(String normalizedKey) {
  return switch (normalizedKey) {
    'variant' || 'variant_name' || 'option' || 'option_name' => 'Option',
    'size' || 'unit_size' => 'Size',
    'color' || 'colour' => 'Color',
    'flavor' || 'flavour' => 'Flavor',
    'roast' || 'roast_level' => 'Roast',
    'pack_size' || 'package_size' => 'Pack',
    'volume' => 'Volume',
    'weight' => 'Weight',
    'material' => 'Material',
    'style' => 'Style',
    'temperature' => 'Temperature',
    'modifier' || 'modifier_group' => 'Modifier',
    'bundle' || 'bundle_type' => 'Bundle',
    _ => null,
  };
}

const _variantFamilyAttributeKeys = [
  'variant_group',
  'variant_family',
  'variant_set',
  'parent_product',
  'parent_product_id',
  'parent_sku',
  'product_family',
  'style_family',
  'model',
  'collection',
];
