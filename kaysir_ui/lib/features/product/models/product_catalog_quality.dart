import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/utils/inventory_label_utils.dart';
import '../utils/product_catalog_review_target.dart';
import 'management_pack.dart';

enum ProductCatalogQualityIssueType {
  missingSku,
  missingCategory,
  missingDescription,
  missingPrice,
  missingScanCode,
  missingRequiredPackField,
}

class ProductCatalogQualityIssue {
  const ProductCatalogQualityIssue({
    required this.id,
    required this.type,
    required this.label,
    required this.count,
    required this.reviewTarget,
    this.packField,
  });

  final String id;
  final ProductCatalogQualityIssueType type;
  final String label;
  final int count;
  final ProductCatalogReviewTarget reviewTarget;
  final ProductManagementPackField? packField;

  String get countLabel => '$count $label';

  bool get isActive => count > 0;
}

class ProductCatalogQualitySummary {
  const ProductCatalogQualitySummary({
    required this.productCount,
    required this.completeProductCount,
    required this.issueProductCount,
    required this.totalIssueCount,
    required this.issues,
  });

  final int productCount;
  final int completeProductCount;
  final int issueProductCount;
  final int totalIssueCount;
  final List<ProductCatalogQualityIssue> issues;

  int get completePercent {
    if (productCount == 0) return 0;

    return ((completeProductCount / productCount) * 100).round();
  }

  String get completeCountLabel => '$completeProductCount/$productCount ready';

  List<ProductCatalogQualityIssue> get activeIssues {
    final active =
        issues.where((issue) => issue.isActive).toList()..sort((left, right) {
          final countComparison = right.count.compareTo(left.count);
          if (countComparison != 0) return countComparison;

          return left.label.compareTo(right.label);
        });

    return List.unmodifiable(active);
  }
}

ProductCatalogQualitySummary summarizeProductCatalogQuality(
  List<InventoryProductCatalogRecord> records, {
  ProductManagementPack? pack,
}) {
  final definitions = _productCatalogQualityIssueDefinitions(pack: pack);
  final issueCounts = {for (final definition in definitions) definition.id: 0};
  var issueProductCount = 0;
  var totalIssueCount = 0;

  for (final record in records) {
    final issues = _productCatalogQualityIssueDefinitionsForRecord(
      record,
      definitions: definitions,
    );
    if (issues.isNotEmpty) {
      issueProductCount += 1;
    }
    totalIssueCount += issues.length;

    for (final issue in issues) {
      issueCounts[issue.id] = issueCounts[issue.id]! + 1;
    }
  }

  return ProductCatalogQualitySummary(
    productCount: records.length,
    completeProductCount: records.length - issueProductCount,
    issueProductCount: issueProductCount,
    totalIssueCount: totalIssueCount,
    issues: [
      for (final definition in definitions)
        ProductCatalogQualityIssue(
          id: definition.id,
          type: definition.type,
          label: definition.label,
          count: issueCounts[definition.id] ?? 0,
          reviewTarget: definition.reviewTarget,
          packField: definition.packField,
        ),
    ],
  );
}

List<ProductCatalogQualityIssueType> productCatalogQualityIssueTypes(
  InventoryProductCatalogRecord record, {
  ProductManagementPack? pack,
}) {
  return [
    for (final definition in _productCatalogQualityIssueDefinitions(pack: pack))
      if (definition.matches(record)) definition.type,
  ];
}

List<ProductCatalogQualityIssue> productCatalogQualityIssuesForRecord(
  InventoryProductCatalogRecord record, {
  ProductManagementPack? pack,
}) {
  return [
    for (final definition in _productCatalogQualityIssueDefinitions(pack: pack))
      if (definition.matches(record))
        ProductCatalogQualityIssue(
          id: definition.id,
          type: definition.type,
          label: definition.label,
          count: 1,
          reviewTarget: definition.reviewTarget,
          packField: definition.packField,
        ),
  ];
}

class _ProductCatalogQualityIssueDefinition {
  const _ProductCatalogQualityIssueDefinition({
    required this.id,
    required this.type,
    required this.label,
    required this.query,
    required this.matches,
    this.packField,
  });

  final String id;
  final ProductCatalogQualityIssueType type;
  final String label;
  final String query;
  final bool Function(InventoryProductCatalogRecord record) matches;
  final ProductManagementPackField? packField;

  ProductCatalogReviewTarget get reviewTarget {
    return ProductCatalogReviewTarget(
      query: query,
      title: 'Catalog quality',
      reasonLabel: label,
    );
  }
}

const _qualityIssueDefinitions = [
  _ProductCatalogQualityIssueDefinition(
    id: 'missingSku',
    type: ProductCatalogQualityIssueType.missingSku,
    label: 'missing SKU',
    query: inventoryNoSkuLabel,
    matches: _isMissingSku,
  ),
  _ProductCatalogQualityIssueDefinition(
    id: 'missingCategory',
    type: ProductCatalogQualityIssueType.missingCategory,
    label: 'missing category',
    query: inventoryUncategorizedLabel,
    matches: _isMissingCategory,
  ),
  _ProductCatalogQualityIssueDefinition(
    id: 'missingDescription',
    type: ProductCatalogQualityIssueType.missingDescription,
    label: 'missing description',
    query: inventoryNoDescriptionLabel,
    matches: _isMissingDescription,
  ),
  _ProductCatalogQualityIssueDefinition(
    id: 'missingPrice',
    type: ProductCatalogQualityIssueType.missingPrice,
    label: 'missing price',
    query: inventoryMissingPriceLabel,
    matches: _isMissingPrice,
  ),
  _ProductCatalogQualityIssueDefinition(
    id: 'missingScanCode',
    type: ProductCatalogQualityIssueType.missingScanCode,
    label: 'missing scan code',
    query: inventoryMissingScanCodeLabel,
    matches: _isMissingScanCode,
  ),
];

List<_ProductCatalogQualityIssueDefinition>
_productCatalogQualityIssueDefinitions({ProductManagementPack? pack}) {
  return List.unmodifiable([
    ..._qualityIssueDefinitions,
    if (pack != null)
      for (final field in _packRequiredQualityFields(pack))
        _ProductCatalogQualityIssueDefinition(
          id: 'missing_${field.id.value}',
          type: ProductCatalogQualityIssueType.missingRequiredPackField,
          label: 'missing ${field.label.toLowerCase()}',
          query: '',
          packField: field,
          matches: (record) => _isMissingPackField(record, field),
        ),
  ]);
}

List<_ProductCatalogQualityIssueDefinition>
_productCatalogQualityIssueDefinitionsForRecord(
  InventoryProductCatalogRecord record, {
  required List<_ProductCatalogQualityIssueDefinition> definitions,
}) {
  return [
    for (final definition in definitions)
      if (definition.matches(record)) definition,
  ];
}

bool _isMissingSku(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.sku);
}

bool _isMissingCategory(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.category);
}

bool _isMissingDescription(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.description);
}

bool _isMissingPrice(InventoryProductCatalogRecord record) {
  return record.unitPrice <= 0;
}

bool _isMissingScanCode(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.barcode) &&
      !_hasText(record.product.shortcutKey);
}

bool _isMissingPackField(
  InventoryProductCatalogRecord record,
  ProductManagementPackField field,
) {
  if (field.id == ProductManagementFieldId.sku) return _isMissingSku(record);
  if (field.id == ProductManagementFieldId.category) {
    return _isMissingCategory(record);
  }
  if (field.id == ProductManagementFieldId.barcode) {
    return _isMissingScanCode(record);
  }
  if (field.id == ProductManagementFieldId.unit) {
    return !_hasText(record.product.unit);
  }

  return !_hasText(record.product.customAttributes[field.id.value]);
}

List<ProductManagementPackField> _packRequiredQualityFields(
  ProductManagementPack pack,
) {
  return [
    for (final field in pack.requiredFields)
      if (!_coreQualityFieldIds.contains(field.id)) field,
  ];
}

final _coreQualityFieldIds = {
  ProductManagementFieldId.sku,
  ProductManagementFieldId.category,
  ProductManagementFieldId.barcode,
};

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
