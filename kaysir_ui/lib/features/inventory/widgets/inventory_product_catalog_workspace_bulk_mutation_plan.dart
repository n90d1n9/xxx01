import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';

class InventoryProductCatalogBulkMutationPlan {
  const InventoryProductCatalogBulkMutationPlan({
    required this.previousProducts,
    required this.updatedProducts,
  });

  final List<Product> previousProducts;
  final List<Product> updatedProducts;

  int get count => updatedProducts.length;

  bool get isEmpty => previousProducts.isEmpty || updatedProducts.isEmpty;
}

InventoryProductCatalogBulkMutationPlan
inventoryProductCatalogBulkMutationFromProducts({
  required Iterable<Product> products,
  required bool Function(Product product) include,
  required Product Function(Product product) transform,
}) {
  final previousProducts = [
    for (final product in products)
      if (include(product)) product,
  ];

  return InventoryProductCatalogBulkMutationPlan(
    previousProducts: previousProducts,
    updatedProducts: [
      for (final product in previousProducts) transform(product),
    ],
  );
}

InventoryProductCatalogBulkMutationPlan
inventoryProductCatalogBulkMutationFromRecords({
  required Iterable<InventoryProductCatalogRecord> records,
  required Product Function(Product product) transform,
}) {
  return inventoryProductCatalogBulkMutationFromProducts(
    products: inventoryProductCatalogProductsForRecords(records),
    include: (_) => true,
    transform: transform,
  );
}

List<Product> inventoryProductCatalogProductsForRecords(
  Iterable<InventoryProductCatalogRecord> records,
) {
  return [for (final record in records) record.product];
}

List<Product> inventoryProductCatalogProductsForIds({
  required Iterable<Product> products,
  required Set<String> productIds,
}) {
  if (productIds.isEmpty) return const <Product>[];

  return [
    for (final product in products)
      if (productIds.contains(product.id)) product,
  ];
}
