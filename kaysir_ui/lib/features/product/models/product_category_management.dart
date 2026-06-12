import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/utils/inventory_label_utils.dart';
import '../utils/product_catalog_review_target.dart';
import 'sales_channel_profile.dart';

enum ProductCategoryRiskStatus { action, watch, healthy }

class ProductCategoryManagementSummary {
  const ProductCategoryManagementSummary({
    required this.categoryCount,
    required this.productCount,
    required this.categorizedProductCount,
    required this.uncategorizedProductCount,
    required this.attentionProductCount,
    required this.channelRiskProductCount,
    required this.totalInventoryValue,
  });

  final int categoryCount;
  final int productCount;
  final int categorizedProductCount;
  final int uncategorizedProductCount;
  final int attentionProductCount;
  final int channelRiskProductCount;
  final double totalInventoryValue;

  int get taxonomyCoveragePercent {
    if (productCount == 0) return 0;

    return ((categorizedProductCount / productCount) * 100).round();
  }

  int get categoryRiskCount => attentionProductCount + channelRiskProductCount;

  String get coverageLabel => '$categorizedProductCount/$productCount covered';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (uncategorizedProductCount > 0) return 'Taxonomy gaps';
    if (categoryRiskCount > 0) return 'Category risk';

    return 'Category ready';
  }
}

class ProductCategoryManagementEntry {
  const ProductCategoryManagementEntry({
    required this.id,
    required this.title,
    required this.productCount,
    required this.attentionProductCount,
    required this.channelRiskProductCount,
    required this.untrackedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
    this.isUncategorized = false,
  });

  final String id;
  final String title;
  final int productCount;
  final int attentionProductCount;
  final int channelRiskProductCount;
  final int untrackedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;
  final bool isUncategorized;

  bool get hasRisk =>
      isUncategorized ||
      attentionProductCount > 0 ||
      channelRiskProductCount > 0;

  ProductCategoryRiskStatus get status {
    if (isUncategorized || attentionProductCount > 0) {
      return ProductCategoryRiskStatus.action;
    }
    if (channelRiskProductCount > 0 || untrackedProductCount > 0) {
      return ProductCategoryRiskStatus.watch;
    }

    return ProductCategoryRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Ready taxonomy';

    final parts = [
      if (isUncategorized) 'needs category',
      if (attentionProductCount > 0) '$attentionProductCount stock',
      if (channelRiskProductCount > 0) '$channelRiskProductCount channel',
      if (untrackedProductCount > 0) '$untrackedProductCount untracked',
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (isUncategorized) return 'Assign category';
    if (attentionProductCount > 0) return 'Review stock';
    if (channelRiskProductCount > 0) return 'Review launch';

    return 'Open catalog';
  }
}

class ProductCategoryManagementOverview {
  ProductCategoryManagementOverview({
    required this.summary,
    required List<ProductCategoryManagementEntry> categories,
    required this.channelProfile,
  }) : categories = List.unmodifiable(categories);

  final ProductCategoryManagementSummary summary;
  final List<ProductCategoryManagementEntry> categories;
  final ProductSalesChannelProfile channelProfile;

  ProductCategoryManagementEntry? get primaryCategory {
    if (categories.isEmpty) return null;

    return categories.firstWhere(
      (category) => category.hasRisk,
      orElse: () => categories.first,
    );
  }
}

ProductCategoryManagementOverview buildProductCategoryManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final accumulators = <String, _ProductCategoryAccumulator>{};

  for (final record in records) {
    final title = record.categoryLabel;
    final id = _categoryIdFor(title);
    accumulators
        .putIfAbsent(
          id,
          () => _ProductCategoryAccumulator(
            id: id,
            title: title,
            isUncategorized: title == inventoryUncategorizedLabel,
          ),
        )
        .add(record, channelProfile: channelProfile);
  }

  final categories =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareCategoryEntries);

  return ProductCategoryManagementOverview(
    channelProfile: channelProfile,
    summary: ProductCategoryManagementSummary(
      categoryCount: categories.where((entry) => !entry.isUncategorized).length,
      productCount: records.length,
      categorizedProductCount: categories.fold(
        0,
        (total, entry) =>
            total + (entry.isUncategorized ? 0 : entry.productCount),
      ),
      uncategorizedProductCount: categories.fold(
        0,
        (total, entry) =>
            total + (entry.isUncategorized ? entry.productCount : 0),
      ),
      attentionProductCount: categories.fold(
        0,
        (total, entry) => total + entry.attentionProductCount,
      ),
      channelRiskProductCount: categories.fold(
        0,
        (total, entry) => total + entry.channelRiskProductCount,
      ),
      totalInventoryValue: categories.fold(
        0,
        (total, entry) => total + entry.totalInventoryValue,
      ),
    ),
    categories: categories,
  );
}

class _ProductCategoryAccumulator {
  _ProductCategoryAccumulator({
    required this.id,
    required this.title,
    required this.isUncategorized,
  });

  final String id;
  final String title;
  final bool isUncategorized;
  var productCount = 0;
  var attentionProductCount = 0;
  var channelRiskProductCount = 0;
  var untrackedProductCount = 0;
  var totalInventoryValue = 0.0;

  void add(
    InventoryProductCatalogRecord record, {
    required ProductSalesChannelProfile channelProfile,
  }) {
    productCount += 1;
    totalInventoryValue += record.inventoryValue;

    if (record.needsAttention) attentionProductCount += 1;
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductCount += 1;
    }
    if (!channelProfile.definitions.every(
      (definition) => definition.readyWhen(record),
    )) {
      channelRiskProductCount += 1;
    }
  }

  ProductCategoryManagementEntry toEntry() {
    return ProductCategoryManagementEntry(
      id: id,
      title: title,
      productCount: productCount,
      attentionProductCount: attentionProductCount,
      channelRiskProductCount: channelRiskProductCount,
      untrackedProductCount: untrackedProductCount,
      totalInventoryValue: totalInventoryValue,
      isUncategorized: isUncategorized,
      reviewTarget: ProductCatalogReviewTarget(
        filter:
            attentionProductCount > 0
                ? InventoryProductCatalogFilter.attention
                : InventoryProductCatalogFilter.all,
        query: title,
        title: 'Category management',
        reasonLabel: isUncategorized ? 'uncategorized products' : title,
      ),
    );
  }
}

int _compareCategoryEntries(
  ProductCategoryManagementEntry first,
  ProductCategoryManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final riskRank = _riskCount(second).compareTo(_riskCount(first));
  if (riskRank != 0) return riskRank;

  final productRank = second.productCount.compareTo(first.productCount);
  if (productRank != 0) return productRank;

  return first.title.compareTo(second.title);
}

int _riskCount(ProductCategoryManagementEntry entry) {
  return entry.attentionProductCount +
      entry.channelRiskProductCount +
      (entry.isUncategorized ? entry.productCount : 0);
}

String _categoryIdFor(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');

  return trimmed.isEmpty ? 'uncategorized' : trimmed;
}
