import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product_catalog_quality.dart';
import 'management_pack.dart';
import 'sales_channel_profile.dart';

enum ProductAssortmentSegmentStatus { action, watch, healthy }

class ProductAssortmentPlanSummary {
  const ProductAssortmentPlanSummary({
    required this.segmentCount,
    required this.productCount,
    required this.launchReadyProductCount,
    required this.attentionProductCount,
    required this.qualityIssueCount,
    required this.channelBlockerProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
  });

  final int segmentCount;
  final int productCount;
  final int launchReadyProductCount;
  final int attentionProductCount;
  final int qualityIssueCount;
  final int channelBlockerProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;

  int get launchReadyPercent {
    if (productCount == 0) return 0;

    return ((launchReadyProductCount / productCount) * 100).round();
  }

  int get impactedProductCount => productCount - launchReadyProductCount;

  String get launchReadyLabel => '$launchReadyProductCount/$productCount ready';

  String get statusLabel {
    if (productCount == 0) return 'No assortment';
    if (launchReadyPercent >= 80) return 'Healthy assortment';
    if (launchReadyPercent >= 50) return 'Needs tuning';

    return 'Action plan';
  }
}

class ProductAssortmentSegment {
  const ProductAssortmentSegment({
    required this.id,
    required this.title,
    required this.productCount,
    required this.launchReadyProductCount,
    required this.attentionProductCount,
    required this.qualityIssueCount,
    required this.channelBlockerProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
  });

  final String id;
  final String title;
  final int productCount;
  final int launchReadyProductCount;
  final int attentionProductCount;
  final int qualityIssueCount;
  final int channelBlockerProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;

  int get launchReadyPercent {
    if (productCount == 0) return 0;

    return ((launchReadyProductCount / productCount) * 100).round();
  }

  int get impactedProductCount => productCount - launchReadyProductCount;

  bool get hasAction => impactedProductCount > 0;

  ProductAssortmentSegmentStatus get status {
    if (launchReadyPercent >= 80) return ProductAssortmentSegmentStatus.healthy;
    if (launchReadyPercent >= 50) return ProductAssortmentSegmentStatus.watch;

    return ProductAssortmentSegmentStatus.action;
  }

  String get readinessLabel => '$launchReadyProductCount/$productCount ready';

  String get actionLabel {
    if (attentionProductCount > 0) return 'Review stock';
    if (qualityIssueCount > 0) return 'Fix setup';
    if (channelBlockerProductCount > 0) return 'Review channel';

    return 'Open catalog';
  }

  String get issueSummaryLabel {
    if (!hasAction) return 'Launch-ready';

    final parts = [
      if (attentionProductCount > 0) '$attentionProductCount stock',
      if (qualityIssueCount > 0) '$qualityIssueCount setup',
      if (channelBlockerProductCount > 0) '$channelBlockerProductCount channel',
    ];

    return parts.join(' | ');
  }
}

class ProductAssortmentPlan {
  ProductAssortmentPlan({
    required this.managementPack,
    required this.channelProfile,
    required this.summary,
    required List<ProductAssortmentSegment> segments,
  }) : segments = List.unmodifiable(segments);

  final ProductManagementPack managementPack;
  final ProductSalesChannelProfile channelProfile;
  final ProductAssortmentPlanSummary summary;
  final List<ProductAssortmentSegment> segments;

  ProductAssortmentSegment? get primarySegment {
    if (segments.isEmpty) return null;

    return segments.firstWhere(
      (segment) => segment.hasAction,
      orElse: () => segments.first,
    );
  }
}

ProductAssortmentPlan buildProductAssortmentPlan({
  required List<InventoryProductCatalogRecord> records,
  required ProductManagementPack managementPack,
  required ProductSalesChannelProfile channelProfile,
}) {
  final accumulators = <String, _ProductAssortmentSegmentAccumulator>{};

  for (final record in records) {
    final title = record.categoryLabel;
    final id = _segmentIdFor(title);
    final accumulator = accumulators.putIfAbsent(
      id,
      () => _ProductAssortmentSegmentAccumulator(id: id, title: title),
    );
    accumulator.add(
      record,
      managementPack: managementPack,
      channelProfile: channelProfile,
    );
  }

  final segments =
      accumulators.values.map((accumulator) => accumulator.toSegment()).toList()
        ..sort(_compareAssortmentSegments);

  return ProductAssortmentPlan(
    managementPack: managementPack,
    channelProfile: channelProfile,
    summary: ProductAssortmentPlanSummary(
      segmentCount: segments.length,
      productCount: records.length,
      launchReadyProductCount: segments.fold(
        0,
        (total, segment) => total + segment.launchReadyProductCount,
      ),
      attentionProductCount: segments.fold(
        0,
        (total, segment) => total + segment.attentionProductCount,
      ),
      qualityIssueCount: segments.fold(
        0,
        (total, segment) => total + segment.qualityIssueCount,
      ),
      channelBlockerProductCount: segments.fold(
        0,
        (total, segment) => total + segment.channelBlockerProductCount,
      ),
      untrackedProductCount: segments.fold(
        0,
        (total, segment) => total + segment.untrackedProductCount,
      ),
      totalInventoryValue: segments.fold(
        0,
        (total, segment) => total + segment.totalInventoryValue,
      ),
    ),
    segments: segments,
  );
}

class _ProductAssortmentSegmentAccumulator {
  _ProductAssortmentSegmentAccumulator({required this.id, required this.title});

  final String id;
  final String title;
  var productCount = 0;
  var launchReadyProductCount = 0;
  var attentionProductCount = 0;
  var qualityIssueCount = 0;
  var channelBlockerProductCount = 0;
  var untrackedProductCount = 0;
  var totalInventoryValue = 0.0;

  void add(
    InventoryProductCatalogRecord record, {
    required ProductManagementPack managementPack,
    required ProductSalesChannelProfile channelProfile,
  }) {
    productCount += 1;
    totalInventoryValue += record.inventoryValue;

    final hasAttention = record.needsAttention;
    final qualityIssues = productCatalogQualityIssuesForRecord(
      record,
      pack: managementPack,
    );
    final isChannelReady = channelProfile.definitions.every(
      (definition) => definition.readyWhen(record),
    );

    if (hasAttention) attentionProductCount += 1;
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductCount += 1;
    }
    if (qualityIssues.isNotEmpty) {
      qualityIssueCount += qualityIssues.length;
    }
    if (!isChannelReady) channelBlockerProductCount += 1;

    if (!hasAttention && qualityIssues.isEmpty && isChannelReady) {
      launchReadyProductCount += 1;
    }
  }

  ProductAssortmentSegment toSegment() {
    return ProductAssortmentSegment(
      id: id,
      title: title,
      productCount: productCount,
      launchReadyProductCount: launchReadyProductCount,
      attentionProductCount: attentionProductCount,
      qualityIssueCount: qualityIssueCount,
      channelBlockerProductCount: channelBlockerProductCount,
      untrackedProductCount: untrackedProductCount,
      totalInventoryValue: totalInventoryValue,
      reviewTarget: ProductCatalogReviewTarget(
        filter:
            attentionProductCount > 0
                ? InventoryProductCatalogFilter.attention
                : InventoryProductCatalogFilter.all,
        query: title,
        title: 'Assortment planning',
        reasonLabel: '$title segment',
      ),
    );
  }
}

int _compareAssortmentSegments(
  ProductAssortmentSegment first,
  ProductAssortmentSegment second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final impactRank = second.impactedProductCount.compareTo(
    first.impactedProductCount,
  );
  if (impactRank != 0) return impactRank;

  final countRank = second.productCount.compareTo(first.productCount);
  if (countRank != 0) return countRank;

  return first.title.compareTo(second.title);
}

String _segmentIdFor(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');

  return trimmed.isEmpty ? 'uncategorized' : trimmed;
}
