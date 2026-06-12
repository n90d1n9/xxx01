import '../../inventory/models/inventory_product_catalog.dart';
import 'product.dart';
import 'product_availability_management.dart';
import 'management_pack.dart';

class ProductAvailabilityRuleTemplateId {
  const ProductAvailabilityRuleTemplateId(this.value);

  static const counterService = ProductAvailabilityRuleTemplateId(
    'counter_service',
  );
  static const onlineStore = ProductAvailabilityRuleTemplateId('online_store');
  static const marketplace = ProductAvailabilityRuleTemplateId('marketplace');
  static const kiosk = ProductAvailabilityRuleTemplateId('kiosk');
  static const wholesale = ProductAvailabilityRuleTemplateId('wholesale');
  static const temporarilyPaused = ProductAvailabilityRuleTemplateId(
    'temporarily_paused',
  );
  static const freshShelf = ProductAvailabilityRuleTemplateId('fresh_shelf');
  static const freshnessHold = ProductAvailabilityRuleTemplateId(
    'freshness_hold',
  );

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductAvailabilityRuleTemplateId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

enum ProductAvailabilityRuleAuthoringTarget {
  unconfigured,
  availabilityRisk,
  stockAttention,
  allProducts,
}

class ProductAvailabilityRuleTemplate {
  const ProductAvailabilityRuleTemplate({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.attributes,
  });

  final ProductAvailabilityRuleTemplateId id;
  final String title;
  final String subtitle;
  final Map<String, String> attributes;

  int get attributeCount => attributes.length;

  String get attributeCountLabel {
    return attributeCount == 1 ? '1 rule field' : '$attributeCount rule fields';
  }

  String get channelLabel {
    return attributes['available_channels'] ??
        attributes['enabled_channels'] ??
        attributes['sales_channels'] ??
        'No channel';
  }
}

const productAvailabilityRuleTemplateAllSourceId = '__all__';
const productAvailabilityRuleTemplateCoreSourceId = 'core';
const productAvailabilityRuleTemplateCoreSourceTitle = 'Core templates';

class ProductAvailabilityRuleTemplateEntry {
  const ProductAvailabilityRuleTemplateEntry({
    required this.template,
    this.sourceId = productAvailabilityRuleTemplateCoreSourceId,
    this.sourceTitle = productAvailabilityRuleTemplateCoreSourceTitle,
    this.contributionId,
    this.contributionTitle,
  });

  final ProductAvailabilityRuleTemplate template;
  final String sourceId;
  final String sourceTitle;
  final String? contributionId;
  final String? contributionTitle;

  bool get isCore => sourceId == productAvailabilityRuleTemplateCoreSourceId;

  String get normalizedSourceId {
    final normalized = sourceId.trim();
    if (normalized.isNotEmpty) return normalized;

    return productAvailabilityRuleTemplateCoreSourceId;
  }

  String get sourceLabel {
    final normalized = sourceTitle.trim();
    if (normalized.isNotEmpty) return normalized;

    return productAvailabilityRuleTemplateCoreSourceTitle;
  }
}

class ProductAvailabilityRuleTemplateSourceSummary {
  const ProductAvailabilityRuleTemplateSourceSummary({
    required this.id,
    required this.title,
    required this.templateCount,
  });

  final String id;
  final String title;
  final int templateCount;

  String get templateCountLabel {
    return templateCount == 1 ? '1 template' : '$templateCount templates';
  }
}

typedef ProductAvailabilityRuleTemplateContributionPredicate =
    bool Function(ProductManagementPack pack);

/// Extension hook that contributes availability rule templates for a pack.
class ProductAvailabilityRuleTemplateContribution {
  const ProductAvailabilityRuleTemplateContribution({
    required this.id,
    required this.title,
    required this.templates,
    this.isActive,
  });

  final String id;
  final String title;
  final List<ProductAvailabilityRuleTemplate> templates;
  final ProductAvailabilityRuleTemplateContributionPredicate? isActive;

  String get normalizedId => id.trim();

  String get titleLabel {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isNotEmpty) return normalizedTitle;

    return normalizedId;
  }

  bool get hasTemplates {
    return templates.any(_isValidAvailabilityRuleTemplate);
  }

  bool isActiveFor(ProductManagementPack pack) {
    return normalizedId.isNotEmpty && (isActive?.call(pack) ?? true);
  }

  List<ProductAvailabilityRuleTemplate> templatesFor(
    ProductManagementPack pack,
  ) {
    if (!isActiveFor(pack)) return const [];

    return List.unmodifiable(templates.where(_isValidAvailabilityRuleTemplate));
  }
}

class ProductAvailabilityRuleTemplateRegistry {
  factory ProductAvailabilityRuleTemplateRegistry({
    required ProductManagementPack pack,
    List<ProductAvailabilityRuleTemplate> baseTemplates =
        defaultProductAvailabilityRuleTemplates,
    List<ProductAvailabilityRuleTemplateContribution> contributions = const [],
  }) {
    final activeContributions = [
      for (final contribution in contributions)
        if (contribution.isActiveFor(pack)) contribution,
    ];
    final mergeResult = _mergeAvailabilityRuleTemplateEntries([
      for (final template in baseTemplates)
        ProductAvailabilityRuleTemplateEntry(template: template),
      for (final contribution in activeContributions)
        for (final template in contribution.templatesFor(pack))
          ProductAvailabilityRuleTemplateEntry(
            template: template,
            sourceId: contribution.normalizedId,
            sourceTitle: contribution.titleLabel,
            contributionId: contribution.normalizedId,
            contributionTitle: contribution.titleLabel,
          ),
    ]);

    return ProductAvailabilityRuleTemplateRegistry._(
      pack: pack,
      contributions: activeContributions,
      entries: mergeResult.entries,
      ignoredTemplateCount: mergeResult.ignoredTemplateCount,
    );
  }

  const ProductAvailabilityRuleTemplateRegistry._({
    required this.pack,
    required this.contributions,
    required this.entries,
    required this.ignoredTemplateCount,
  });

  final ProductManagementPack pack;
  final List<ProductAvailabilityRuleTemplateContribution> contributions;
  final List<ProductAvailabilityRuleTemplateEntry> entries;
  final int ignoredTemplateCount;

  int get contributionCount => contributions.length;
  bool get hasContributions => contributions.isNotEmpty;
  int get templateCount => entries.length;
  int get sourceCount => sourceSummaries.length;
  int get coreTemplateCount => entries.where((entry) => entry.isCore).length;
  int get contributedTemplateCount => templateCount - coreTemplateCount;
  bool get hasDuplicateTemplates => ignoredTemplateCount > 0;

  List<ProductAvailabilityRuleTemplate> get templates {
    return List.unmodifiable(entries.map((entry) => entry.template));
  }

  List<ProductAvailabilityRuleTemplateId> get templateIds {
    return List.unmodifiable(entries.map((entry) => entry.template.id));
  }

  List<ProductAvailabilityRuleTemplateSourceSummary> get sourceSummaries {
    return summarizeProductAvailabilityRuleTemplateSources(entries);
  }

  String get templateCountLabel => _countLabel(templateCount, 'template');
  String get sourceCountLabel => _countLabel(sourceCount, 'source');
  String get contributionCountLabel {
    return _countLabel(contributionCount, 'contribution');
  }

  String get coreTemplateCountLabel {
    return _countLabel(coreTemplateCount, 'core template');
  }

  String get contributedTemplateCountLabel {
    return _countLabel(contributedTemplateCount, 'contributed template');
  }

  String get ignoredTemplateCountLabel {
    return _countLabel(
      ignoredTemplateCount,
      'duplicate skipped',
      'duplicates skipped',
    );
  }
}

bool _isValidAvailabilityRuleTemplate(
  ProductAvailabilityRuleTemplate template,
) {
  return template.id.value.trim().isNotEmpty &&
      template.title.trim().isNotEmpty;
}

class ProductAvailabilityRuleAuthoringPlan {
  ProductAvailabilityRuleAuthoringPlan({
    required this.template,
    required this.target,
    required List<InventoryProductCatalogRecord> targetRecords,
    required List<InventoryProductCatalogRecord> changedRecords,
    required List<InventoryProductCatalogRecord> unchangedRecords,
  }) : targetRecords = List.unmodifiable(targetRecords),
       changedRecords = List.unmodifiable(changedRecords),
       unchangedRecords = List.unmodifiable(unchangedRecords);

  final ProductAvailabilityRuleTemplate template;
  final ProductAvailabilityRuleAuthoringTarget target;
  final List<InventoryProductCatalogRecord> targetRecords;
  final List<InventoryProductCatalogRecord> changedRecords;
  final List<InventoryProductCatalogRecord> unchangedRecords;

  int get targetProductCount => targetRecords.length;
  int get changedProductCount => changedRecords.length;
  int get unchangedProductCount => unchangedRecords.length;
  bool get canApply => changedRecords.isNotEmpty;

  List<Product> get updatedProducts {
    return [
      for (final record in changedRecords)
        applyProductAvailabilityRuleTemplate(record.product, template),
    ];
  }

  String get targetCountLabel => _productCountLabel(targetProductCount);

  String get changeCountLabel {
    return changedProductCount == 1
        ? '1 change'
        : '$changedProductCount changes';
  }

  String get unchangedCountLabel {
    return unchangedProductCount == 1
        ? '1 already matched'
        : '$unchangedProductCount already matched';
  }

  String get previewProductLabel {
    if (changedRecords.isEmpty) return 'No products to update';

    final names = changedRecords
        .take(3)
        .map((record) => record.productName)
        .toList(growable: false);
    final remainingCount = changedRecords.length - names.length;
    if (remainingCount <= 0) return names.join(', ');

    return '${names.join(', ')} + $remainingCount more';
  }

  String get appliedMessage {
    return changedProductCount == 1
        ? '1 product updated with ${template.title}'
        : '$changedProductCount products updated with ${template.title}';
  }
}

const defaultProductAvailabilityRuleTemplates = [
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.counterService,
    title: 'Counter service',
    subtitle: 'POS-first selling with stock required before checkout.',
    attributes: {
      'available_channels': 'POS',
      'sales_status': 'active',
      'stock_policy': 'in_stock_only',
      'fulfillment_modes': 'pickup',
    },
  ),
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.onlineStore,
    title: 'Online store',
    subtitle: 'Digital catalog selling with delivery and shipping enabled.',
    attributes: {
      'available_channels': 'Online Store',
      'sales_status': 'published',
      'stock_policy': 'allow_backorder',
      'fulfillment_modes': 'delivery, shipping',
    },
  ),
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.marketplace,
    title: 'Marketplace',
    subtitle: 'Marketplace-ready listing with stock-controlled shipping.',
    attributes: {
      'available_channels': 'Marketplace',
      'sales_status': 'published',
      'stock_policy': 'stock_required',
      'fulfillment_modes': 'shipping',
    },
  ),
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.kiosk,
    title: 'Kiosk',
    subtitle: 'Self-service catalog access with strict stock gates.',
    attributes: {
      'available_channels': 'Kiosk',
      'sales_status': 'active',
      'stock_policy': 'in_stock_only',
      'fulfillment_modes': 'self_service',
    },
  ),
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.wholesale,
    title: 'Wholesale',
    subtitle: 'Partner selling with controlled stock and pickup or shipping.',
    attributes: {
      'available_channels': 'Wholesale',
      'sales_status': 'active',
      'stock_policy': 'stock_required',
      'fulfillment_modes': 'pickup, shipping',
    },
  ),
  ProductAvailabilityRuleTemplate(
    id: ProductAvailabilityRuleTemplateId.temporarilyPaused,
    title: 'Temporarily paused',
    subtitle: 'Keep the rule visible while blocking current selling.',
    attributes: {
      'availability_status': 'paused',
      'availability_window': 'paused',
    },
  ),
];

ProductAvailabilityRuleTemplate productAvailabilityRuleTemplateFor(
  ProductAvailabilityRuleTemplateId id, {
  List<ProductAvailabilityRuleTemplate> templates =
      defaultProductAvailabilityRuleTemplates,
}) {
  for (final template in templates) {
    if (template.id == id) return template;
  }

  return templates.first;
}

List<ProductAvailabilityRuleTemplateEntry>
productAvailabilityRuleTemplateEntriesFor(
  List<ProductAvailabilityRuleTemplate> templates,
) {
  return List.unmodifiable([
    for (final template in templates)
      ProductAvailabilityRuleTemplateEntry(template: template),
  ]);
}

ProductAvailabilityRuleTemplateEntry productAvailabilityRuleTemplateEntryFor(
  ProductAvailabilityRuleTemplateId id, {
  required List<ProductAvailabilityRuleTemplateEntry> entries,
}) {
  for (final entry in entries) {
    if (entry.template.id == id) return entry;
  }

  return entries.first;
}

List<ProductAvailabilityRuleTemplateSourceSummary>
summarizeProductAvailabilityRuleTemplateSources(
  List<ProductAvailabilityRuleTemplateEntry> entries,
) {
  final orderedIds = <String>[];
  final titles = <String, String>{};
  final counts = <String, int>{};

  for (final entry in entries) {
    final id = entry.normalizedSourceId;
    if (!counts.containsKey(id)) {
      orderedIds.add(id);
      titles[id] = entry.sourceLabel;
      counts[id] = 0;
    }
    counts[id] = counts[id]! + 1;
  }

  return List.unmodifiable([
    for (final id in orderedIds)
      ProductAvailabilityRuleTemplateSourceSummary(
        id: id,
        title: titles[id] ?? productAvailabilityRuleTemplateCoreSourceTitle,
        templateCount: counts[id] ?? 0,
      ),
  ]);
}

ProductAvailabilityRuleAuthoringPlan buildProductAvailabilityRuleAuthoringPlan({
  required List<InventoryProductCatalogRecord> records,
  required ProductAvailabilityRuleTemplate template,
  required ProductAvailabilityRuleAuthoringTarget target,
}) {
  final targetRecords = [
    for (final record in records)
      if (_recordMatchesAuthoringTarget(record, target)) record,
  ];
  final changedRecords = [
    for (final record in targetRecords)
      if (productAvailabilityRuleTemplateWouldChange(record.product, template))
        record,
  ];
  final changedIds = changedRecords.map((record) => record.id).toSet();
  final unchangedRecords = [
    for (final record in targetRecords)
      if (!changedIds.contains(record.id)) record,
  ];

  return ProductAvailabilityRuleAuthoringPlan(
    template: template,
    target: target,
    targetRecords: targetRecords,
    changedRecords: changedRecords,
    unchangedRecords: unchangedRecords,
  );
}

Product applyProductAvailabilityRuleTemplate(
  Product product,
  ProductAvailabilityRuleTemplate template,
) {
  return product.copyWith(
    customAttributes: {...product.customAttributes, ...template.attributes},
  );
}

bool productAvailabilityRuleTemplateWouldChange(
  Product product,
  ProductAvailabilityRuleTemplate template,
) {
  for (final entry in template.attributes.entries) {
    if (product.customAttributes[entry.key] != entry.value) return true;
  }

  return false;
}

String productAvailabilityRuleAuthoringTargetTitle(
  ProductAvailabilityRuleAuthoringTarget target,
) {
  switch (target) {
    case ProductAvailabilityRuleAuthoringTarget.unconfigured:
      return 'Missing rules';
    case ProductAvailabilityRuleAuthoringTarget.availabilityRisk:
      return 'Availability risk';
    case ProductAvailabilityRuleAuthoringTarget.stockAttention:
      return 'Stock attention';
    case ProductAvailabilityRuleAuthoringTarget.allProducts:
      return 'All products';
  }
}

String productAvailabilityRuleAuthoringTargetSubtitle(
  ProductAvailabilityRuleAuthoringTarget target,
) {
  switch (target) {
    case ProductAvailabilityRuleAuthoringTarget.unconfigured:
      return 'Products without availability attributes';
    case ProductAvailabilityRuleAuthoringTarget.availabilityRisk:
      return 'Missing, conflicting, blocked, or untracked products';
    case ProductAvailabilityRuleAuthoringTarget.stockAttention:
      return 'Products with low, empty, or untracked stock';
    case ProductAvailabilityRuleAuthoringTarget.allProducts:
      return 'Every product in the current catalog';
  }
}

bool _recordMatchesAuthoringTarget(
  InventoryProductCatalogRecord record,
  ProductAvailabilityRuleAuthoringTarget target,
) {
  switch (target) {
    case ProductAvailabilityRuleAuthoringTarget.unconfigured:
      return productAvailabilityRuleSignalsFor(record.product).isEmpty;
    case ProductAvailabilityRuleAuthoringTarget.availabilityRisk:
      return _recordHasAvailabilityRisk(record);
    case ProductAvailabilityRuleAuthoringTarget.stockAttention:
      return record.needsAttention;
    case ProductAvailabilityRuleAuthoringTarget.allProducts:
      return true;
  }
}

bool _recordHasAvailabilityRisk(InventoryProductCatalogRecord record) {
  final signals = productAvailabilityRuleSignalsFor(record.product);
  if (signals.isEmpty) return true;
  if (record.status == InventoryProductCatalogStatus.untracked) return true;
  if (_hasChannelConflict(signals)) return true;
  if (_hasStockGate(signals) && record.needsAttention) return true;

  return signals.any((signal) => signal.isBlocking);
}

bool _hasChannelConflict(List<ProductAvailabilityRuleSignal> signals) {
  final enabledChannels = {
    for (final signal in signals)
      if (signal.type == ProductAvailabilityRuleType.channelAccess &&
          !signal.isDisabledChannel)
        _normalizedAvailabilityRuleValue(signal.value),
  };
  final disabledChannels = {
    for (final signal in signals)
      if (signal.type == ProductAvailabilityRuleType.channelAccess &&
          signal.isDisabledChannel)
        _normalizedAvailabilityRuleValue(signal.value),
  };

  enabledChannels.remove('');
  disabledChannels.remove('');

  return enabledChannels.any(disabledChannels.contains);
}

bool _hasStockGate(List<ProductAvailabilityRuleSignal> signals) {
  return signals.any((signal) => signal.isStockRequired);
}

String _normalizedAvailabilityRuleValue(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

String _productCountLabel(int count) {
  return count == 1 ? '1 product' : '$count products';
}

String _countLabel(int count, String singular, [String? plural]) {
  if (count == 1) return '1 $singular';

  return '$count ${plural ?? '${singular}s'}';
}

class _ProductAvailabilityRuleTemplateMergeResult {
  const _ProductAvailabilityRuleTemplateMergeResult({
    required this.entries,
    required this.ignoredTemplateCount,
  });

  final List<ProductAvailabilityRuleTemplateEntry> entries;
  final int ignoredTemplateCount;
}

_ProductAvailabilityRuleTemplateMergeResult
_mergeAvailabilityRuleTemplateEntries(
  List<ProductAvailabilityRuleTemplateEntry> entries,
) {
  final seenIds = <ProductAvailabilityRuleTemplateId>{};
  final merged = <ProductAvailabilityRuleTemplateEntry>[];

  for (final entry in entries) {
    if (seenIds.contains(entry.template.id)) continue;

    seenIds.add(entry.template.id);
    merged.add(entry);
  }

  return _ProductAvailabilityRuleTemplateMergeResult(
    entries: List.unmodifiable(merged),
    ignoredTemplateCount: entries.length - merged.length,
  );
}
