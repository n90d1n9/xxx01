import '../../inventory/models/inventory_product_catalog.dart';
import '../utils/product_catalog_review_target.dart';
import 'product.dart';
import 'product_pricing_management.dart';
import 'sales_channel_profile.dart';

const productUnassignedSupplierLabel = 'Unassigned supplier';

enum ProductSourcingRiskStatus { action, watch, healthy }

class ProductSourcingManagementSummary {
  const ProductSourcingManagementSummary({
    required this.supplierCount,
    required this.productCount,
    required this.assignedProductCount,
    required this.unassignedProductCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.costedProductCount,
    required this.totalInventoryValue,
  });

  final int supplierCount;
  final int productCount;
  final int assignedProductCount;
  final int unassignedProductCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final int costedProductCount;
  final double totalInventoryValue;

  int get sourcingCoveragePercent {
    if (productCount == 0) return 0;

    return ((assignedProductCount / productCount) * 100).round();
  }

  int get costCoveragePercent {
    if (productCount == 0) return 0;

    return ((costedProductCount / productCount) * 100).round();
  }

  int get costGapProductCount => productCount - costedProductCount;

  int get sourcingRiskCount {
    return unassignedProductCount +
        attentionProductCount +
        untrackedProductCount +
        costGapProductCount;
  }

  String get coverageLabel => '$assignedProductCount/$productCount assigned';

  String get statusLabel {
    if (productCount == 0) return 'No products';
    if (unassignedProductCount > 0) return 'Supplier gaps';
    if (attentionProductCount > 0) return 'Supply risk';
    if (costGapProductCount > 0) return 'Cost visibility';

    return 'Sourcing ready';
  }
}

class ProductSourcingManagementEntry {
  const ProductSourcingManagementEntry({
    required this.id,
    required this.title,
    required this.productCount,
    required this.attentionProductCount,
    required this.untrackedProductCount,
    required this.costedProductCount,
    required this.totalInventoryValue,
    required this.reviewTarget,
    this.isUnassigned = false,
  });

  final String id;
  final String title;
  final int productCount;
  final int attentionProductCount;
  final int untrackedProductCount;
  final int costedProductCount;
  final double totalInventoryValue;
  final ProductCatalogReviewTarget reviewTarget;
  final bool isUnassigned;

  int get costGapProductCount => productCount - costedProductCount;

  int get costCoveragePercent {
    if (productCount == 0) return 0;

    return ((costedProductCount / productCount) * 100).round();
  }

  int get riskCount {
    return (isUnassigned ? productCount : 0) +
        attentionProductCount +
        untrackedProductCount +
        costGapProductCount;
  }

  bool get hasRisk => riskCount > 0;

  ProductSourcingRiskStatus get status {
    if (isUnassigned || attentionProductCount > 0) {
      return ProductSourcingRiskStatus.action;
    }
    if (untrackedProductCount > 0 || costGapProductCount > 0) {
      return ProductSourcingRiskStatus.watch;
    }

    return ProductSourcingRiskStatus.healthy;
  }

  String get productCountLabel {
    return productCount == 1 ? '1 product' : '$productCount products';
  }

  String get issueSummaryLabel {
    if (!hasRisk) return 'Sourcing ready';

    final parts = [
      if (isUnassigned) 'needs supplier',
      if (attentionProductCount > 0) '$attentionProductCount supply',
      if (untrackedProductCount > 0) '$untrackedProductCount untracked',
      if (costGapProductCount > 0) '$costGapProductCount cost gap',
    ];

    return parts.join(' | ');
  }

  String get actionLabel {
    if (isUnassigned) return 'Assign supplier';
    if (attentionProductCount > 0) return 'Review supply';
    if (untrackedProductCount > 0) return 'Review tracking';
    if (costGapProductCount > 0) return 'Add cost data';

    return 'Open catalog';
  }
}

class ProductSourcingManagementOverview {
  ProductSourcingManagementOverview({
    required this.summary,
    required this.channelProfile,
    required List<ProductSourcingManagementEntry> suppliers,
  }) : suppliers = List.unmodifiable(suppliers);

  final ProductSourcingManagementSummary summary;
  final ProductSalesChannelProfile channelProfile;
  final List<ProductSourcingManagementEntry> suppliers;

  ProductSourcingManagementEntry? get primarySupplier {
    if (suppliers.isEmpty) return null;

    return suppliers.firstWhere(
      (supplier) => supplier.hasRisk,
      orElse: () => suppliers.first,
    );
  }
}

ProductSourcingManagementOverview buildProductSourcingManagementOverview({
  required List<InventoryProductCatalogRecord> records,
  required ProductSalesChannelProfile channelProfile,
}) {
  final accumulators = <String, _ProductSourcingAccumulator>{};

  for (final record in records) {
    final supplier = productSourcingPartnerFor(record.product);
    final title = supplier ?? productUnassignedSupplierLabel;
    final id = _sourcingGroupIdFor(title);
    accumulators
        .putIfAbsent(
          id,
          () => _ProductSourcingAccumulator(
            id: id,
            title: title,
            isUnassigned: supplier == null,
          ),
        )
        .add(record);
  }

  final suppliers =
      accumulators.values.map((accumulator) => accumulator.toEntry()).toList()
        ..sort(_compareSourcingEntries);

  return ProductSourcingManagementOverview(
    channelProfile: channelProfile,
    summary: ProductSourcingManagementSummary(
      supplierCount: suppliers.where((entry) => !entry.isUnassigned).length,
      productCount: suppliers.fold(
        0,
        (total, entry) => total + entry.productCount,
      ),
      assignedProductCount: suppliers.fold(
        0,
        (total, entry) => total + (entry.isUnassigned ? 0 : entry.productCount),
      ),
      unassignedProductCount: suppliers.fold(
        0,
        (total, entry) => total + (entry.isUnassigned ? entry.productCount : 0),
      ),
      attentionProductCount: suppliers.fold(
        0,
        (total, entry) => total + entry.attentionProductCount,
      ),
      untrackedProductCount: suppliers.fold(
        0,
        (total, entry) => total + entry.untrackedProductCount,
      ),
      costedProductCount: suppliers.fold(
        0,
        (total, entry) => total + entry.costedProductCount,
      ),
      totalInventoryValue: suppliers.fold(
        0,
        (total, entry) => total + entry.totalInventoryValue,
      ),
    ),
    suppliers: suppliers,
  );
}

class _ProductSourcingAccumulator {
  _ProductSourcingAccumulator({
    required this.id,
    required this.title,
    required this.isUnassigned,
  });

  final String id;
  final String title;
  final bool isUnassigned;
  var productCount = 0;
  var attentionProductCount = 0;
  var untrackedProductCount = 0;
  var costedProductCount = 0;
  var totalInventoryValue = 0.0;

  void add(InventoryProductCatalogRecord record) {
    productCount += 1;
    totalInventoryValue += record.inventoryValue;

    if (record.needsAttention) attentionProductCount += 1;
    if (record.status == InventoryProductCatalogStatus.untracked) {
      untrackedProductCount += 1;
    }
    if (productPricingCostFor(record.product) != null) {
      costedProductCount += 1;
    }
  }

  ProductSourcingManagementEntry toEntry() {
    return ProductSourcingManagementEntry(
      id: id,
      title: title,
      productCount: productCount,
      attentionProductCount: attentionProductCount,
      untrackedProductCount: untrackedProductCount,
      costedProductCount: costedProductCount,
      totalInventoryValue: totalInventoryValue,
      isUnassigned: isUnassigned,
      reviewTarget: ProductCatalogReviewTarget(
        filter:
            attentionProductCount > 0
                ? InventoryProductCatalogFilter.attention
                : InventoryProductCatalogFilter.all,
        query: isUnassigned ? '' : title,
        title: 'Sourcing management',
        reasonLabel: isUnassigned ? 'unassigned supplier products' : title,
      ),
    );
  }
}

String? productSourcingPartnerFor(Product product) {
  for (final key in _supplierAttributeKeys) {
    final value = _customAttributeValue(product, key);
    if (value != null) return value;
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

int _compareSourcingEntries(
  ProductSourcingManagementEntry first,
  ProductSourcingManagementEntry second,
) {
  final statusRank = first.status.index.compareTo(second.status.index);
  if (statusRank != 0) return statusRank;

  if (first.isUnassigned != second.isUnassigned) {
    return first.isUnassigned ? -1 : 1;
  }

  final riskRank = second.riskCount.compareTo(first.riskCount);
  if (riskRank != 0) return riskRank;

  final valueRank = second.totalInventoryValue.compareTo(
    first.totalInventoryValue,
  );
  if (valueRank != 0) return valueRank;

  return first.title.compareTo(second.title);
}

String _sourcingGroupIdFor(String title) {
  final normalized = title.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  final trimmed = normalized.replaceAll(RegExp(r'^_+|_+$'), '');

  return trimmed.isEmpty ? 'unassigned_supplier' : trimmed;
}

const _supplierAttributeKeys = [
  'supplier',
  'supplier_name',
  'vendor',
  'vendor_name',
  'brand',
  'manufacturer',
  'maker',
  'source',
  'sourcing_partner',
];
