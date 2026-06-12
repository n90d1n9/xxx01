import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'sales_channel_profile.dart';

enum ProductRelationshipType {
  substitutes,
  complements,
  bundleComponents,
  upsells,
  crossSells,
}

enum ProductRelationshipRiskStatus { action, watch, healthy }

class ProductRelationshipTargetReference {
  const ProductRelationshipTargetReference({
    required this.type,
    required this.rawTarget,
  });

  final ProductRelationshipType type;
  final String rawTarget;
}

class ProductRelationshipManagementSummary {
  const ProductRelationshipManagementSummary({
    required this.productCount,
    required this.relationshipTypeCount,
    required this.relationshipProductCount,
    required this.relationshipReferenceCount,
    required this.resolvedReferenceCount,
    required this.unresolvedReferenceCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
  });

  final int productCount;
  final int relationshipTypeCount;
  final int relationshipProductCount;
  final int relationshipReferenceCount;
  final int resolvedReferenceCount;
  final int unresolvedReferenceCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;

  int get relationshipCoveragePercent {
    if (productCount == 0) return 0;

    return ((relationshipProductCount / productCount) * 100).round();
  }

  int get resolutionPercent {
    if (relationshipReferenceCount == 0) return 0;

    return ((resolvedReferenceCount / relationshipReferenceCount) * 100)
        .round();
  }

  int get relationshipRiskCount {
    return unresolvedReferenceCount +
        attentionProductCount +
        untrackedProductCount;
  }

  String get coverageLabel => '$relationshipProductCount/$productCount linked';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (unresolvedReferenceCount > 0) return 'Missing targets';
    if (attentionProductCount > 0) return 'Stock review';
    if (relationshipReferenceCount == 0) return 'No relationships';

    return 'Relationship ready';
  }
}

class ProductRelationshipManagementEntry {
  const ProductRelationshipManagementEntry({
    required this.type,
    required this.id,
    required this.title,
    required this.productCount,
    required this.referenceCount,
    required this.resolvedReferenceCount,
    required this.unresolvedReferenceCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
  });

  final ProductRelationshipType type;
  final String id;
  final String title;
  final int productCount;
  final int referenceCount;
  final int resolvedReferenceCount;
  final int unresolvedReferenceCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;

  int get resolutionPercent {
    if (referenceCount == 0) return 0;

    return ((resolvedReferenceCount / referenceCount) * 100).round();
  }

  int get riskCount {
    return unresolvedReferenceCount +
        attentionProductCount +
        untrackedProductCount;
  }

  bool get hasRisk => riskCount > 0;

  ProductRelationshipRiskStatus get status {
    if (unresolvedReferenceCount > 0) {
      return ProductRelationshipRiskStatus.action;
    }
    if (attentionProductCount > 0 || untrackedProductCount > 0) {
      return ProductRelationshipRiskStatus.watch;
    }

    return ProductRelationshipRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get resolutionLabel {
    if (referenceCount == 0) return 'No links';

    return '$resolvedReferenceCount/$referenceCount resolved';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Relationships ready';

    final parts = [
      if (unresolvedReferenceCount > 0)
        _countLabel(unresolvedReferenceCount, 'missing target'),
      if (attentionProductCount > 0)
        _countLabel(attentionProductCount, 'stock'),
      if (untrackedProductCount > 0)
        _countLabel(untrackedProductCount, 'untracked'),
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (unresolvedReferenceCount > 0) return 'Resolve targets';
    if (attentionProductCount > 0 || untrackedProductCount > 0) {
      return 'Review stock';
    }

    return 'Review links';
  }
}

class ProductRelationshipManagementOverview {
  ProductRelationshipManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductRelationshipManagementEntry> relationships,
  }) : relationships = List.unmodifiable(relationships);

  final ProductRelationshipManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductRelationshipManagementEntry> relationships;

  ProductRelationshipManagementEntry? get primaryRelationship {
    if (relationships.isEmpty) return null;

    return relationships.firstWhere(
      (relationship) => relationship.hasRisk,
      orElse: () => relationships.first,
    );
  }
}

ProductRelationshipManagementOverview
buildProductRelationshipManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final productLookup = _buildProductRelationshipLookup(records);
  final accumulators =
      <ProductRelationshipType, _ProductRelationshipAccumulator>{};
  final relationshipProductIds = <String>{};
  final attentionProductIds = <String>{};
  final untrackedProductIds = <String>{};

  for (final record in records) {
    final references = productRelationshipTargetReferencesFor(record.product);
    if (references.isEmpty) continue;

    relationshipProductIds.add(record.id);
    if (record.needsAttention) attentionProductIds.add(record.id);
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductIds.add(record.id);
    }

    for (final reference in references) {
      final target =
          productLookup[_normalizedRelationshipLookupKey(reference.rawTarget)];
      final isResolved = target != null && target.id != record.product.id;

      accumulators
          .putIfAbsent(
            reference.type,
            () => _ProductRelationshipAccumulator(type: reference.type),
          )
          .add(record: record, isResolved: isResolved);
    }
  }

  final relationships =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareRelationshipEntries);

  return ProductRelationshipManagementOverview(
    channelProfile: channelProfile,
    summary: ProductRelationshipManagementSummary(
      productCount: records.length,
      relationshipTypeCount: relationships.length,
      relationshipProductCount: relationshipProductIds.length,
      relationshipReferenceCount: relationships.fold(
        0,
        (total, relationship) => total + relationship.referenceCount,
      ),
      resolvedReferenceCount: relationships.fold(
        0,
        (total, relationship) => total + relationship.resolvedReferenceCount,
      ),
      unresolvedReferenceCount: relationships.fold(
        0,
        (total, relationship) => total + relationship.unresolvedReferenceCount,
      ),
      attentionProductCount: attentionProductIds.length,
      untrackedProductCount: untrackedProductIds.length,
      totalInventoryValue: records.fold(
        0,
        (total, record) => total + record.inventoryValue,
      ),
    ),
    relationships: relationships,
  );
}

List<ProductRelationshipTargetReference> productRelationshipTargetReferencesFor(
  Product product,
) {
  final references = <ProductRelationshipTargetReference>[];
  final seen = <String>{};

  for (final entry in product.customAttributes.entries) {
    final type = _relationshipTypeForAttribute(entry.key);
    if (type == null) continue;

    for (final target in _relationshipTargetsFromValue(entry.value)) {
      final seenKey =
          '${type.name}:${_normalizedRelationshipLookupKey(target)}';
      if (!seen.add(seenKey)) continue;

      references.add(
        ProductRelationshipTargetReference(type: type, rawTarget: target),
      );
    }
  }

  return List.unmodifiable(references);
}

String productRelationshipTypeTitle(ProductRelationshipType type) {
  switch (type) {
    case ProductRelationshipType.substitutes:
      return 'Substitutes';
    case ProductRelationshipType.complements:
      return 'Complements';
    case ProductRelationshipType.bundleComponents:
      return 'Bundle components';
    case ProductRelationshipType.upsells:
      return 'Upsells';
    case ProductRelationshipType.crossSells:
      return 'Cross-sells';
  }
}

class _ProductRelationshipAccumulator {
  _ProductRelationshipAccumulator({required this.type});

  final ProductRelationshipType type;
  final sourceProductIds = <String>{};
  final attentionProductIds = <String>{};
  final untrackedProductIds = <String>{};
  var referenceCount = 0;
  var resolvedReferenceCount = 0;
  var unresolvedReferenceCount = 0;
  var totalInventoryValue = 0.0;

  void add({
    required InventoryProductCatalogRecord record,
    required bool isResolved,
  }) {
    if (sourceProductIds.add(record.id)) {
      totalInventoryValue += record.inventoryValue;
    }
    if (record.needsAttention) attentionProductIds.add(record.id);
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductIds.add(record.id);
    }

    referenceCount += 1;
    if (isResolved) {
      resolvedReferenceCount += 1;
    } else {
      unresolvedReferenceCount += 1;
    }
  }

  ProductRelationshipManagementEntry toEntry() {
    final title = productRelationshipTypeTitle(type);
    final hasStockIssue =
        attentionProductIds.isNotEmpty || untrackedProductIds.isNotEmpty;

    return ProductRelationshipManagementEntry(
      type: type,
      id: type.name,
      title: title,
      productCount: sourceProductIds.length,
      referenceCount: referenceCount,
      resolvedReferenceCount: resolvedReferenceCount,
      unresolvedReferenceCount: unresolvedReferenceCount,
      attentionProductCount: attentionProductIds.length,
      untrackedProductCount: untrackedProductIds.length,
      totalInventoryValue: totalInventoryValue,
      reviewTarget: ProductCatalogReviewTarget(
        filter:
            unresolvedReferenceCount == 0 && hasStockIssue
                ? InventoryProductCatalogFilter.attention
                : InventoryProductCatalogFilter.all,
        title: 'Relationship management',
        reasonLabel: '${title.toLowerCase()} products',
      ),
    );
  }
}

Map<String, Product> _buildProductRelationshipLookup(
  List<InventoryProductCatalogRecord> records,
) {
  final lookup = <String, Product>{};

  void register(String? value, Product product) {
    final key = _normalizedRelationshipLookupKey(value);
    if (key.isEmpty) return;

    lookup.putIfAbsent(key, () => product);
  }

  for (final record in records) {
    register(record.product.id, record.product);
    register(record.product.sku, record.product);
    register(record.product.name, record.product);
  }

  return lookup;
}

ProductRelationshipType? _relationshipTypeForAttribute(String key) {
  final normalizedKey = _normalizedRelationshipAttributeKey(key);
  for (final entry in _relationshipAttributeKeys.entries) {
    if (entry.value.contains(normalizedKey)) return entry.key;
  }

  return null;
}

Iterable<String> _relationshipTargetsFromValue(String value) {
  return value
      .split(RegExp(r'(?:[,;|\n]|\s+[+/]\s+)'))
      .map((target) => target.trim())
      .where((target) => target.isNotEmpty);
}

int _compareRelationshipEntries(
  ProductRelationshipManagementEntry first,
  ProductRelationshipManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final referenceRank = second.referenceCount.compareTo(first.referenceCount);
  if (referenceRank != 0) return referenceRank;

  final typeRank = _relationshipTypeSortRank(
    first.type,
  ).compareTo(_relationshipTypeSortRank(second.type));
  if (typeRank != 0) return typeRank;

  return first.title.compareTo(second.title);
}

int _relationshipTypeSortRank(ProductRelationshipType type) {
  switch (type) {
    case ProductRelationshipType.substitutes:
      return 0;
    case ProductRelationshipType.complements:
      return 1;
    case ProductRelationshipType.bundleComponents:
      return 2;
    case ProductRelationshipType.upsells:
      return 3;
    case ProductRelationshipType.crossSells:
      return 4;
  }
}

String _normalizedRelationshipAttributeKey(String key) {
  return key.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
}

String _normalizedRelationshipLookupKey(String? value) {
  return value?.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '') ??
      '';
}

String _countLabel(int count, String label) {
  return count == 1 ? '1 $label' : '$count ${label}s';
}

const _relationshipAttributeKeys = {
  ProductRelationshipType.substitutes: {
    'substitute',
    'substitutes',
    'alternative',
    'alternatives',
    'replacement',
    'replacements',
  },
  ProductRelationshipType.complements: {
    'complement',
    'complements',
    'recommended_with',
    'pairs_with',
    'pair_with',
    'add_on',
    'add_ons',
    'addon',
    'addons',
  },
  ProductRelationshipType.bundleComponents: {
    'bundle_component',
    'bundle_components',
    'component',
    'components',
    'kit_component',
    'kit_components',
    'ingredient',
    'ingredients',
    'recipe_item',
    'recipe_items',
  },
  ProductRelationshipType.upsells: {
    'upsell',
    'upsells',
    'upgrade_to',
    'upgrade',
    'premium_option',
    'premium_options',
  },
  ProductRelationshipType.crossSells: {
    'cross_sell',
    'cross_sells',
    'crosssell',
    'crosssells',
    'related',
    'related_product',
    'related_products',
    'recommendation',
    'recommendations',
  },
};
