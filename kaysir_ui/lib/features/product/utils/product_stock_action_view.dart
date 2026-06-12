import '../models/product.dart';
import 'product_filtering.dart';

class ProductStockActionView {
  const ProductStockActionView({required this.entries, required this.summary});

  final List<ProductStockActionEntry> entries;
  final ProductStockActionSummary summary;
}

class ProductStockActionEntry {
  const ProductStockActionEntry({required this.product});

  final Product product;

  String get nameLabel {
    final name = product.name.trim();
    return name.isEmpty ? 'Unnamed product' : name;
  }

  String get skuLabel {
    final sku = product.sku?.trim();
    return sku == null || sku.isEmpty ? 'No SKU' : sku;
  }

  String get categoryLabel {
    final category = product.category?.trim();
    return category == null || category.isEmpty ? 'Uncategorized' : category;
  }

  String get stockLabel => '${product.currentStock} units';

  bool get canRemoveStock => product.currentStock > 0;
}

class ProductStockActionSummary {
  const ProductStockActionSummary({
    required this.totalProducts,
    required this.stockedProducts,
    required this.outOfStockProducts,
    required this.totalUnits,
  });

  final int totalProducts;
  final int stockedProducts;
  final int outOfStockProducts;
  final int totalUnits;

  bool get isEmpty => totalProducts == 0;
}

ProductStockActionView buildProductStockActionView({
  required Iterable<Product> products,
  String query = '',
}) {
  final entries =
      filterProductsForManagement(
          products: products,
          query: query,
        ).map((product) => ProductStockActionEntry(product: product)).toList()
        ..sort(_sortStockActionEntries);

  return ProductStockActionView(
    entries: entries,
    summary: _summarizeStockActions(entries),
  );
}

int _sortStockActionEntries(
  ProductStockActionEntry left,
  ProductStockActionEntry right,
) {
  if (left.canRemoveStock != right.canRemoveStock) {
    return left.canRemoveStock ? -1 : 1;
  }

  return left.nameLabel.toLowerCase().compareTo(right.nameLabel.toLowerCase());
}

ProductStockActionSummary _summarizeStockActions(
  List<ProductStockActionEntry> entries,
) {
  var stockedProducts = 0;
  var outOfStockProducts = 0;
  var totalUnits = 0;

  for (final entry in entries) {
    final stock = entry.product.currentStock;
    totalUnits += stock;
    if (stock > 0) {
      stockedProducts += 1;
    } else {
      outOfStockProducts += 1;
    }
  }

  return ProductStockActionSummary(
    totalProducts: entries.length,
    stockedProducts: stockedProducts,
    outOfStockProducts: outOfStockProducts,
    totalUnits: totalUnits,
  );
}
