import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'product_catalog_quality.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

enum ProductLifecycleStage { draft, active, blocked, retiring, archived }

enum ProductLifecycleRiskStatus { action, watch, healthy }

class ProductLifecycleManagementSummary {
  const ProductLifecycleManagementSummary({
    required this.productCount,
    required this.activeProductCount,
    required this.draftProductCount,
    required this.blockedProductCount,
    required this.retiringProductCount,
    required this.archivedProductCount,
    required this.attentionProductCount,
    required this.channelRiskProductCount,
    required this.qualityIssueProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
  });

  final int productCount;
  final int activeProductCount;
  final int draftProductCount;
  final int blockedProductCount;
  final int retiringProductCount;
  final int archivedProductCount;
  final int attentionProductCount;
  final int channelRiskProductCount;
  final int qualityIssueProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;

  int get activeCoveragePercent {
    if (productCount == 0) return 0;

    return ((activeProductCount / productCount) * 100).round();
  }

  int get lifecycleRiskCount {
    return draftProductCount +
        blockedProductCount +
        retiringProductCount +
        channelRiskProductCount +
        qualityIssueProductCount +
        untrackedProductCount;
  }

  String get coverageLabel => '$activeProductCount/$productCount active';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (blockedProductCount > 0) return 'Lifecycle blockers';
    if (draftProductCount > 0) return 'Launch setup';
    if (retiringProductCount > 0) return 'Retirement review';
    if (channelRiskProductCount > 0) return 'Channel review';

    return 'Lifecycle ready';
  }
}

class ProductLifecycleManagementEntry {
  const ProductLifecycleManagementEntry({
    required this.id,
    required this.stage,
    required this.title,
    required this.productCount,
    required this.attentionProductCount,
    required this.channelRiskProductCount,
    required this.qualityIssueProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
  });

  final String id;
  final ProductLifecycleStage stage;
  final String title;
  final int productCount;
  final int attentionProductCount;
  final int channelRiskProductCount;
  final int qualityIssueProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;

  int get riskCount {
    return (_stageNeedsGovernance ? productCount : 0) +
        attentionProductCount +
        channelRiskProductCount +
        qualityIssueProductCount +
        untrackedProductCount;
  }

  bool get hasRisk => riskCount > 0;

  ProductLifecycleRiskStatus get status {
    if (stage == ProductLifecycleStage.blocked ||
        stage == ProductLifecycleStage.draft ||
        qualityIssueProductCount > 0) {
      return ProductLifecycleRiskStatus.action;
    }
    if (stage == ProductLifecycleStage.retiring ||
        attentionProductCount > 0 ||
        channelRiskProductCount > 0 ||
        untrackedProductCount > 0) {
      return ProductLifecycleRiskStatus.watch;
    }

    return ProductLifecycleRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Lifecycle ready';

    final parts = [
      if (stage == ProductLifecycleStage.blocked) 'blocked',
      if (stage == ProductLifecycleStage.draft) 'setup',
      if (stage == ProductLifecycleStage.retiring) 'retiring',
      if (qualityIssueProductCount > 0) '$qualityIssueProductCount quality',
      if (channelRiskProductCount > 0) '$channelRiskProductCount channel',
      if (attentionProductCount > 0) '$attentionProductCount stock',
      if (untrackedProductCount > 0) '$untrackedProductCount untracked',
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (stage == ProductLifecycleStage.blocked) return 'Clear blockers';
    if (stage == ProductLifecycleStage.draft) return 'Complete setup';
    if (qualityIssueProductCount > 0) return 'Resolve setup';
    if (stage == ProductLifecycleStage.retiring) return 'Review retirement';
    if (channelRiskProductCount > 0) return 'Review channels';
    if (stage == ProductLifecycleStage.archived) return 'Review archive';

    return 'Open catalog';
  }

  bool get _stageNeedsGovernance {
    return stage == ProductLifecycleStage.blocked ||
        stage == ProductLifecycleStage.draft ||
        stage == ProductLifecycleStage.retiring;
  }
}

class ProductLifecycleManagementOverview {
  ProductLifecycleManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductLifecycleManagementEntry> stages,
  }) : stages = List.unmodifiable(stages);

  final ProductLifecycleManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductLifecycleManagementEntry> stages;

  ProductLifecycleManagementEntry? get primaryStage {
    if (stages.isEmpty) return null;

    return stages.firstWhere(
      (stage) => stage.hasRisk,
      orElse: () => stages.first,
    );
  }
}

ProductLifecycleManagementOverview buildProductLifecycleManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
  ProductManagementPack? managementPack,
}) {
  final accumulators = <ProductLifecycleStage, _ProductLifecycleAccumulator>{};

  for (final record in records) {
    final hasQualityIssues =
        productCatalogQualityIssuesForRecord(
          record,
          pack: managementPack,
        ).isNotEmpty;
    final hasChannelRisk = productLifecycleHasChannelRisk(
      record,
      channelProfile: channelProfile,
    );
    final stage = _productLifecycleStageForRecord(
      record,
      hasQualityIssues: hasQualityIssues,
      hasChannelRisk: hasChannelRisk,
    );

    accumulators
        .putIfAbsent(stage, () => _ProductLifecycleAccumulator(stage: stage))
        .add(
          record,
          hasQualityIssues: hasQualityIssues,
          hasChannelRisk: hasChannelRisk,
        );
  }

  final stages =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareLifecycleEntries);

  return ProductLifecycleManagementOverview(
    channelProfile: channelProfile,
    summary: ProductLifecycleManagementSummary(
      productCount: stages.fold(
        0,
        (total, entry) => total + entry.productCount,
      ),
      activeProductCount: _productCountForStage(
        stages,
        ProductLifecycleStage.active,
      ),
      draftProductCount: _productCountForStage(
        stages,
        ProductLifecycleStage.draft,
      ),
      blockedProductCount: _productCountForStage(
        stages,
        ProductLifecycleStage.blocked,
      ),
      retiringProductCount: _productCountForStage(
        stages,
        ProductLifecycleStage.retiring,
      ),
      archivedProductCount: _productCountForStage(
        stages,
        ProductLifecycleStage.archived,
      ),
      attentionProductCount: stages.fold(
        0,
        (total, entry) => total + entry.attentionProductCount,
      ),
      channelRiskProductCount: stages.fold(
        0,
        (total, entry) => total + entry.channelRiskProductCount,
      ),
      qualityIssueProductCount: stages.fold(
        0,
        (total, entry) => total + entry.qualityIssueProductCount,
      ),
      untrackedProductCount: stages.fold(
        0,
        (total, entry) => total + entry.untrackedProductCount,
      ),
      totalInventoryValue: stages.fold(
        0,
        (total, entry) => total + entry.totalInventoryValue,
      ),
    ),
    stages: stages,
  );
}

ProductLifecycleStage productLifecycleStageForRecord(
  InventoryProductCatalogRecord record, {
  required ProductSalesChannelProfile channelProfile,
  ProductManagementPack? managementPack,
}) {
  final hasQualityIssues =
      productCatalogQualityIssuesForRecord(
        record,
        pack: managementPack,
      ).isNotEmpty;
  final hasChannelRisk = productLifecycleHasChannelRisk(
    record,
    channelProfile: channelProfile,
  );

  return _productLifecycleStageForRecord(
    record,
    hasQualityIssues: hasQualityIssues,
    hasChannelRisk: hasChannelRisk,
  );
}

ProductLifecycleStage? productExplicitLifecycleStageFor(Product product) {
  for (final key in _lifecycleAttributeKeys) {
    final value = _customAttributeValue(product, key);
    final stage = _productLifecycleStageFromValue(value);
    if (stage != null) return stage;
  }

  return null;
}

bool productLifecycleHasChannelRisk(
  InventoryProductCatalogRecord record, {
  required ProductSalesChannelProfile channelProfile,
}) {
  return channelProfile.definitions.any((definition) {
    return !definition.readyWhen(record);
  });
}

ProductLifecycleStage _productLifecycleStageForRecord(
  InventoryProductCatalogRecord record, {
  required bool hasQualityIssues,
  required bool hasChannelRisk,
}) {
  final explicitStage = productExplicitLifecycleStageFor(record.product);
  if (explicitStage != null) return explicitStage;

  if (hasQualityIssues) return ProductLifecycleStage.draft;
  if (record.status == InventoryProductCatalogStatus.untracked) {
    return ProductLifecycleStage.draft;
  }
  if (record.status == InventoryProductCatalogStatus.outOfStock) {
    return ProductLifecycleStage.retiring;
  }
  if (hasChannelRisk) return ProductLifecycleStage.blocked;

  return ProductLifecycleStage.active;
}

class _ProductLifecycleAccumulator {
  _ProductLifecycleAccumulator({required this.stage});

  final ProductLifecycleStage stage;
  var productCount = 0;
  var attentionProductCount = 0;
  var channelRiskProductCount = 0;
  var qualityIssueProductCount = 0;
  var untrackedProductCount = 0;
  var totalInventoryValue = 0.0;

  void add(
    InventoryProductCatalogRecord record, {
    required bool hasQualityIssues,
    required bool hasChannelRisk,
  }) {
    productCount += 1;
    totalInventoryValue += record.inventoryValue;

    if (record.needsAttention) attentionProductCount += 1;
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductCount += 1;
    }
    if (hasQualityIssues) qualityIssueProductCount += 1;
    if (hasChannelRisk) channelRiskProductCount += 1;
  }

  ProductLifecycleManagementEntry toEntry() {
    return ProductLifecycleManagementEntry(
      id: _stageId(stage),
      stage: stage,
      title: _stageTitle(stage),
      productCount: productCount,
      attentionProductCount: attentionProductCount,
      channelRiskProductCount: channelRiskProductCount,
      qualityIssueProductCount: qualityIssueProductCount,
      untrackedProductCount: untrackedProductCount,
      totalInventoryValue: totalInventoryValue,
      reviewTarget: ProductCatalogReviewTarget(
        query: '',
        title: 'Lifecycle management',
        reasonLabel: '${_stageTitle(stage).toLowerCase()} products',
      ),
    );
  }
}

int _productCountForStage(
  List<ProductLifecycleManagementEntry> entries,
  ProductLifecycleStage stage,
) {
  for (final entry in entries) {
    if (entry.stage == stage) return entry.productCount;
  }

  return 0;
}

int _compareLifecycleEntries(
  ProductLifecycleManagementEntry first,
  ProductLifecycleManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final stageRank = _stageSortRank(
    first.stage,
  ).compareTo(_stageSortRank(second.stage));
  if (stageRank != 0) return stageRank;

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final valueRank = second.totalInventoryValue.compareTo(
    first.totalInventoryValue,
  );
  if (valueRank != 0) return valueRank;

  return first.title.compareTo(second.title);
}

int _stageSortRank(ProductLifecycleStage stage) {
  return switch (stage) {
    ProductLifecycleStage.blocked => 0,
    ProductLifecycleStage.draft => 1,
    ProductLifecycleStage.retiring => 2,
    ProductLifecycleStage.active => 3,
    ProductLifecycleStage.archived => 4,
  };
}

String _stageId(ProductLifecycleStage stage) {
  return switch (stage) {
    ProductLifecycleStage.draft => 'draft',
    ProductLifecycleStage.active => 'active',
    ProductLifecycleStage.blocked => 'blocked',
    ProductLifecycleStage.retiring => 'retiring',
    ProductLifecycleStage.archived => 'archived',
  };
}

String _stageTitle(ProductLifecycleStage stage) {
  return switch (stage) {
    ProductLifecycleStage.draft => 'Draft',
    ProductLifecycleStage.active => 'Active',
    ProductLifecycleStage.blocked => 'Blocked',
    ProductLifecycleStage.retiring => 'Retiring',
    ProductLifecycleStage.archived => 'Archived',
  };
}

ProductLifecycleStage? _productLifecycleStageFromValue(String? value) {
  final normalized = value?.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );

  switch (normalized) {
    case 'active':
    case 'available':
    case 'enabled':
    case 'launched':
    case 'live':
    case 'published':
    case 'sellable':
      return ProductLifecycleStage.active;
    case 'draft':
    case 'new':
    case 'pending':
    case 'planned':
    case 'pre_launch':
    case 'prelaunch':
    case 'setup':
    case 'staged':
      return ProductLifecycleStage.draft;
    case 'blocked':
    case 'disabled':
    case 'hold':
    case 'on_hold':
    case 'paused':
    case 'suspended':
    case 'unavailable':
      return ProductLifecycleStage.blocked;
    case 'clearance':
    case 'end_of_life':
    case 'eol':
    case 'phase_out':
    case 'phaseout':
    case 'retire':
    case 'retiring':
    case 'run_out':
    case 'runout':
      return ProductLifecycleStage.retiring;
    case 'archived':
    case 'deleted':
    case 'discontinued':
    case 'hidden':
    case 'inactive':
    case 'retired':
      return ProductLifecycleStage.archived;
  }

  return null;
}

String? _customAttributeValue(Product product, String key) {
  for (final entry in product.customAttributes.entries) {
    final normalizedKey = entry.key.trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    final normalizedValue = entry.value.trim();
    if (normalizedKey == key && normalizedValue.isNotEmpty) {
      return normalizedValue;
    }
  }

  return null;
}

const _lifecycleAttributeKeys = [
  'lifecycle',
  'lifecycle_status',
  'product_status',
  'status',
  'launch_status',
  'availability',
];
