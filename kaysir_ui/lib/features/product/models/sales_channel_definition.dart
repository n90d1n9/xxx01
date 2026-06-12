import '../../inventory/models/inventory_product_catalog.dart';
import '../../inventory/utils/inventory_label_utils.dart';
import 'sales_channel_types.dart';

/// Predicate used to evaluate a product catalog record for a channel.
typedef ProductSalesChannelRecordMatcher =
    bool Function(InventoryProductCatalogRecord record);

/// Readiness contract for one product sales channel.
class ProductSalesChannelDefinition {
  const ProductSalesChannelDefinition({
    required this.channel,
    required this.title,
    required this.subtitle,
    required this.readyWhen,
    required this.reviewFilter,
    required this.issueDefinitions,
  });

  final ProductSalesChannel channel;
  final String title;
  final String subtitle;
  final ProductSalesChannelRecordMatcher readyWhen;
  final InventoryProductCatalogFilter reviewFilter;
  final List<ProductSalesChannelIssueDefinition> issueDefinitions;
}

/// Issue rule that explains why a product is blocked for a channel.
class ProductSalesChannelIssueDefinition {
  const ProductSalesChannelIssueDefinition({
    required this.blocker,
    required this.label,
    required this.reviewFilter,
    required this.matches,
    this.reviewQuery = '',
  });

  final ProductSalesChannelBlocker blocker;
  final String label;
  final InventoryProductCatalogFilter reviewFilter;
  final String reviewQuery;
  final ProductSalesChannelRecordMatcher matches;
}

List<ProductSalesChannelDefinition> get defaultProductSalesChannelDefinitions {
  return List.unmodifiable(_defaultProductSalesChannelDefinitions);
}

/// Resolves the default sales-channel definition for a supported channel.
ProductSalesChannelDefinition productSalesChannelDefinitionFor(
  ProductSalesChannel channel,
) {
  return _defaultProductSalesChannelDefinitions.firstWhere(
    (definition) => definition.channel == channel,
  );
}

final _defaultProductSalesChannelDefinitions = [
  ProductSalesChannelDefinition(
    channel: ProductSalesChannel.posCheckout,
    title: 'POS Checkout',
    subtitle: 'Priced products with sellable stock',
    readyWhen: _isPosReady,
    reviewFilter: InventoryProductCatalogFilter.attention,
    issueDefinitions: [_missingPriceIssue, _stockNotSellableIssue],
  ),
  ProductSalesChannelDefinition(
    channel: ProductSalesChannel.onlineStore,
    title: 'Online Store',
    subtitle: 'SKU, product copy, and active stock',
    readyWhen: _isOnlineStoreReady,
    reviewFilter: InventoryProductCatalogFilter.all,
    issueDefinitions: [..._commerceIssueDefinitions, _missingCopyIssue],
  ),
  ProductSalesChannelDefinition(
    channel: ProductSalesChannel.marketplace,
    title: 'Marketplace',
    subtitle: 'Complete listing basics for syndication',
    readyWhen: _isMarketplaceReady,
    reviewFilter: InventoryProductCatalogFilter.all,
    issueDefinitions: [
      ..._commerceIssueDefinitions,
      _missingCopyIssue,
      _missingCategoryIssue,
    ],
  ),
  ProductSalesChannelDefinition(
    channel: ProductSalesChannel.kiosk,
    title: 'Self-Service Kiosk',
    subtitle: 'Fast-scan products ready for assisted checkout',
    readyWhen: _isKioskReady,
    reviewFilter: InventoryProductCatalogFilter.inStock,
    issueDefinitions: [..._commerceIssueDefinitions, _missingScanCodeIssue],
  ),
];

const _missingPriceIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.missingPrice,
  label: 'missing price',
  reviewFilter: InventoryProductCatalogFilter.all,
  reviewQuery: inventoryMissingPriceLabel,
  matches: _isMissingPrice,
);

const _stockNotSellableIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.stockNotSellable,
  label: 'stock not sellable',
  reviewFilter: InventoryProductCatalogFilter.attention,
  matches: _hasStockIssue,
);

const _missingSkuIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.missingSku,
  label: 'missing SKU',
  reviewFilter: InventoryProductCatalogFilter.all,
  reviewQuery: inventoryNoSkuLabel,
  matches: _isMissingSku,
);

const _missingCopyIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.missingCopy,
  label: 'missing copy',
  reviewFilter: InventoryProductCatalogFilter.all,
  reviewQuery: inventoryNoDescriptionLabel,
  matches: _isMissingCopy,
);

const _missingCategoryIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.missingCategory,
  label: 'missing category',
  reviewFilter: InventoryProductCatalogFilter.all,
  reviewQuery: inventoryUncategorizedLabel,
  matches: _isMissingCategory,
);

const _missingScanCodeIssue = ProductSalesChannelIssueDefinition(
  blocker: ProductSalesChannelBlocker.missingScanCode,
  label: 'missing scan code',
  reviewFilter: InventoryProductCatalogFilter.inStock,
  reviewQuery: inventoryMissingScanCodeLabel,
  matches: _isMissingScanCode,
);

const _commerceIssueDefinitions = [
  _missingPriceIssue,
  _stockNotSellableIssue,
  _missingSkuIssue,
];

bool _isPosReady(InventoryProductCatalogRecord record) {
  return !_isMissingPrice(record) && !_hasStockIssue(record);
}

bool _isOnlineStoreReady(InventoryProductCatalogRecord record) {
  return _isPosReady(record) &&
      !_isMissingSku(record) &&
      !_isMissingCopy(record);
}

bool _isMarketplaceReady(InventoryProductCatalogRecord record) {
  return _isOnlineStoreReady(record) && !_isMissingCategory(record);
}

bool _isKioskReady(InventoryProductCatalogRecord record) {
  return _isPosReady(record) && !_isMissingScanCode(record);
}

bool _isMissingPrice(InventoryProductCatalogRecord record) {
  return record.unitPrice <= 0;
}

bool _hasStockIssue(InventoryProductCatalogRecord record) {
  return record.status != InventoryProductCatalogStatus.inStock;
}

bool _isMissingSku(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.sku);
}

bool _isMissingCopy(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.description);
}

bool _isMissingCategory(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.category);
}

bool _isMissingScanCode(InventoryProductCatalogRecord record) {
  return !_hasText(record.product.barcode) &&
      !_hasText(record.product.shortcutKey);
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
