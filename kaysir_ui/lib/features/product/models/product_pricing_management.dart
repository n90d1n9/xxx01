import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/utils/inventory_label_utils.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'sales_channel_profile.dart';

enum ProductPricingRiskStatus { action, watch, healthy }

class ProductPricingManagementSummary {
  const ProductPricingManagementSummary({
    required this.productCount,
    required this.pricedProductCount,
    required this.missingPriceCount,
    required this.costedProductCount,
    required this.marginRiskProductCount,
    required this.priceOutlierProductCount,
    required this.averageUnitPrice,
    required this.totalInventoryValue,
  });

  final int productCount;
  final int pricedProductCount;
  final int missingPriceCount;
  final int costedProductCount;
  final int marginRiskProductCount;
  final int priceOutlierProductCount;
  final double averageUnitPrice;
  final double totalInventoryValue;

  int get pricingCoveragePercent {
    if (productCount == 0) return 0;

    return ((pricedProductCount / productCount) * 100).round();
  }

  int get marginCoveragePercent {
    if (productCount == 0) return 0;

    return ((costedProductCount / productCount) * 100).round();
  }

  int get pricingRiskCount {
    return missingPriceCount +
        marginRiskProductCount +
        priceOutlierProductCount;
  }

  String get coverageLabel => '$pricedProductCount/$productCount priced';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (missingPriceCount > 0) return 'Pricing gaps';
    if (marginRiskProductCount > 0) return 'Margin risk';
    if (priceOutlierProductCount > 0) return 'Price review';

    return 'Pricing ready';
  }
}

class ProductPricingManagementEntry {
  const ProductPricingManagementEntry({
    required this.id,
    required this.title,
    required this.productCount,
    required this.pricedProductCount,
    required this.missingPriceCount,
    required this.costedProductCount,
    required this.marginRiskProductCount,
    required this.priceOutlierProductCount,
    required this.averageUnitPrice,
    required this.minimumUnitPrice,
    required this.maximumUnitPrice,
    required this.totalInventoryValue,
    required this.reviewTarget,
  });

  final String id;
  final String title;
  final int productCount;
  final int pricedProductCount;
  final int missingPriceCount;
  final int costedProductCount;
  final int marginRiskProductCount;
  final int priceOutlierProductCount;
  final double averageUnitPrice;
  final double minimumUnitPrice;
  final double maximumUnitPrice;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;

  int get pricingCoveragePercent {
    if (productCount == 0) return 0;

    return ((pricedProductCount / productCount) * 100).round();
  }

  int get riskCount {
    return missingPriceCount +
        marginRiskProductCount +
        priceOutlierProductCount;
  }

  bool get hasRisk => riskCount > 0;

  ProductPricingRiskStatus get status {
    if (missingPriceCount > 0 || marginRiskProductCount > 0) {
      return ProductPricingRiskStatus.action;
    }
    if (priceOutlierProductCount > 0 || pricingCoveragePercent < 100) {
      return ProductPricingRiskStatus.watch;
    }

    return ProductPricingRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get priceRangeLabel {
    if (pricedProductCount == 0) return 'No price range';
    if (minimumUnitPrice == maximumUnitPrice) {
      return _formatPricingAmount(minimumUnitPrice);
    }

    return '${_formatPricingAmount(minimumUnitPrice)} - '
        '${_formatPricingAmount(maximumUnitPrice)}';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Pricing ready';

    final parts = [
      if (missingPriceCount > 0) '$missingPriceCount missing',
      if (marginRiskProductCount > 0) '$marginRiskProductCount margin',
      if (priceOutlierProductCount > 0) '$priceOutlierProductCount outlier',
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (missingPriceCount > 0) return 'Add prices';
    if (marginRiskProductCount > 0) return 'Review margin';
    if (priceOutlierProductCount > 0) return 'Review bands';

    return 'Open catalog';
  }
}

class ProductPricingManagementOverview {
  ProductPricingManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductPricingManagementEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final ProductPricingManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductPricingManagementEntry> entries;

  ProductPricingManagementEntry? get primaryEntry {
    if (entries.isEmpty) return null;

    return entries.firstWhere(
      (entry) => entry.hasRisk,
      orElse: () => entries.first,
    );
  }
}

ProductPricingManagementOverview buildProductPricingManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final accumulators = <String, _ProductPricingAccumulator>{};

  for (final record in records) {
    final title = record.categoryLabel;
    final id = _pricingGroupIdFor(title);
    accumulators
        .putIfAbsent(id, () => _ProductPricingAccumulator(id: id, title: title))
        .add(record);
  }

  final entries =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_comparePricingEntries);

  final productCount = entries.fold(
    0,
    (total, entry) => total + entry.productCount,
  );
  final pricedProductCount = entries.fold(
    0,
    (total, entry) => total + entry.pricedProductCount,
  );
  final totalPrice = entries.fold(
    0.0,
    (total, entry) =>
        total + (entry.averageUnitPrice * entry.pricedProductCount),
  );

  return ProductPricingManagementOverview(
    channelProfile: channelProfile,
    summary: ProductPricingManagementSummary(
      productCount: productCount,
      pricedProductCount: pricedProductCount,
      missingPriceCount: entries.fold(
        0,
        (total, entry) => total + entry.missingPriceCount,
      ),
      costedProductCount: entries.fold(
        0,
        (total, entry) => total + entry.costedProductCount,
      ),
      marginRiskProductCount: entries.fold(
        0,
        (total, entry) => total + entry.marginRiskProductCount,
      ),
      priceOutlierProductCount: entries.fold(
        0,
        (total, entry) => total + entry.priceOutlierProductCount,
      ),
      averageUnitPrice:
          pricedProductCount == 0 ? 0 : totalPrice / pricedProductCount,
      totalInventoryValue: entries.fold(
        0,
        (total, entry) => total + entry.totalInventoryValue,
      ),
    ),
    entries: entries,
  );
}

class _ProductPricingAccumulator {
  _ProductPricingAccumulator({required this.id, required this.title});

  final String id;
  final String title;
  final records = <InventoryProductCatalogRecord>[];

  void add(InventoryProductCatalogRecord record) {
    records.add(record);
  }

  ProductPricingManagementEntry toEntry() {
    var pricedProductCount = 0;
    var missingPriceCount = 0;
    var costedProductCount = 0;
    var marginRiskProductCount = 0;
    var totalPrice = 0.0;
    var minimumUnitPrice = 0.0;
    var maximumUnitPrice = 0.0;
    var totalInventoryValue = 0.0;
    final pricedValues = <double>[];

    for (final record in records) {
      final price = record.unitPrice;
      totalInventoryValue += record.inventoryValue;

      if (price <= 0) {
        missingPriceCount += 1;
        continue;
      }

      pricedProductCount += 1;
      totalPrice += price;
      pricedValues.add(price);
      if (minimumUnitPrice == 0 || price < minimumUnitPrice) {
        minimumUnitPrice = price;
      }
      if (price > maximumUnitPrice) {
        maximumUnitPrice = price;
      }

      final cost = productPricingCostFor(record.product);
      if (cost == null) continue;

      costedProductCount += 1;
      if (_hasMarginRisk(price: price, cost: cost)) {
        marginRiskProductCount += 1;
      }
    }

    final priceOutlierProductCount = _countPriceOutliers(pricedValues);
    final hasMissingPrices = missingPriceCount > 0;

    return ProductPricingManagementEntry(
      id: id,
      title: title,
      productCount: records.length,
      pricedProductCount: pricedProductCount,
      missingPriceCount: missingPriceCount,
      costedProductCount: costedProductCount,
      marginRiskProductCount: marginRiskProductCount,
      priceOutlierProductCount: priceOutlierProductCount,
      averageUnitPrice:
          pricedProductCount == 0 ? 0 : totalPrice / pricedProductCount,
      minimumUnitPrice: minimumUnitPrice,
      maximumUnitPrice: maximumUnitPrice,
      totalInventoryValue: totalInventoryValue,
      reviewTarget: ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.all,
        query: hasMissingPrices ? inventoryMissingPriceLabel : title,
        title: 'Pricing management',
        reasonLabel: hasMissingPrices ? 'missing prices in $title' : title,
      ),
    );
  }
}

double? productPricingCostFor(Product product) {
  for (final key in _costAttributeKeys) {
    final value = product.customAttributes[key];
    final parsed = _parsePricingAmount(value);
    if (parsed != null && parsed > 0) return parsed;
  }

  return null;
}

bool _hasMarginRisk({required double price, required double cost}) {
  if (price <= 0 || cost <= 0) return false;
  if (price <= cost) return true;

  return ((price - cost) / price) < 0.15;
}

int _countPriceOutliers(List<double> prices) {
  if (prices.length < 3) return 0;

  final sorted = prices.toList()..sort();
  final median = _median(sorted);
  if (median <= 0) return 0;

  return sorted
      .where((price) => price < median * 0.4 || price > median * 2.5)
      .length;
}

double _median(List<double> sorted) {
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];

  return (sorted[middle - 1] + sorted[middle]) / 2;
}

int _comparePricingEntries(
  ProductPricingManagementEntry first,
  ProductPricingManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final valueRank = second.totalInventoryValue.compareTo(
    first.totalInventoryValue,
  );
  if (valueRank != 0) return valueRank;

  return first.title.compareTo(second.title);
}

String _pricingGroupIdFor(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');

  return trimmed.isEmpty ? 'uncategorized' : trimmed;
}

double? _parsePricingAmount(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;

  return double.tryParse(normalized.replaceAll(RegExp(r'[^0-9.-]'), ''));
}

String _formatPricingAmount(double value) {
  if (value >= 1000000) return '\$${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}K';

  return '\$${value.toStringAsFixed(value >= 100 ? 0 : 2)}';
}

const _costAttributeKeys = [
  'cost',
  'unit_cost',
  'base_cost',
  'landed_cost',
  'purchase_price',
  'cogs',
  'hpp',
];
