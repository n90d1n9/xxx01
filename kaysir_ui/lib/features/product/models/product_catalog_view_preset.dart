import '../../inventory/models/inventory_product_catalog.dart';

enum ProductCatalogViewPresetId {
  allProducts,
  attentionQueue,
  inStock,
  untrackedSetup,
}

class ProductCatalogViewPreset {
  const ProductCatalogViewPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.filter,
    required this.count,
    required this.countLabel,
    required this.intentLabel,
  });

  final ProductCatalogViewPresetId id;
  final String title;
  final String subtitle;
  final InventoryProductCatalogFilter filter;
  final int count;
  final String countLabel;
  final String intentLabel;
}

List<ProductCatalogViewPreset> buildProductCatalogViewPresets(
  InventoryProductCatalogSummary summary,
) {
  return [
    ProductCatalogViewPreset(
      id: ProductCatalogViewPresetId.allProducts,
      title: 'All Products',
      subtitle: 'Full SKU directory with pricing and stock context',
      filter: InventoryProductCatalogFilter.all,
      count: summary.productCount,
      countLabel: '${summary.productCount} total',
      intentLabel: 'Catalog',
    ),
    ProductCatalogViewPreset(
      id: ProductCatalogViewPresetId.attentionQueue,
      title: 'Attention Queue',
      subtitle: 'Products that need replenishment, setup, or review',
      filter: InventoryProductCatalogFilter.attention,
      count: summary.attentionProductCount,
      countLabel: '${summary.attentionProductCount} review',
      intentLabel: 'Review',
    ),
    ProductCatalogViewPreset(
      id: ProductCatalogViewPresetId.inStock,
      title: 'In Stock',
      subtitle: 'Healthy products that are ready to sell',
      filter: InventoryProductCatalogFilter.inStock,
      count: summary.inStockProductCount,
      countLabel: '${summary.inStockProductCount} ready',
      intentLabel: 'Sellable',
    ),
    ProductCatalogViewPreset(
      id: ProductCatalogViewPresetId.untrackedSetup,
      title: 'Untracked Setup',
      subtitle: 'Products missing stock records or warehouse coverage',
      filter: InventoryProductCatalogFilter.untracked,
      count: summary.untrackedProductCount,
      countLabel: '${summary.untrackedProductCount} setup',
      intentLabel: 'Setup',
    ),
  ];
}
