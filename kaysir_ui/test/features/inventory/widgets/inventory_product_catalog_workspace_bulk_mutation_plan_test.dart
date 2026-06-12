import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_workspace_bulk_mutation_plan.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('bulk mutation plan transforms matching products', () {
    final plan = inventoryProductCatalogBulkMutationFromProducts(
      products: _products,
      include: (product) => product.id != 'p2',
      transform: (product) => product.copyWith(category: 'Retail'),
    );

    expect(plan.isEmpty, isFalse);
    expect(plan.count, 2);
    expect(plan.previousProducts.map((product) => product.id), ['p1', 'p3']);
    expect(plan.updatedProducts.map((product) => product.category), [
      'Retail',
      'Retail',
    ]);
  });

  test('bulk mutation plan can derive products from catalog records', () {
    final records = buildInventoryProductCatalogRecords(
      products: _products.take(2).toList(),
      stockRecords: const [],
    );
    final plan = inventoryProductCatalogBulkMutationFromRecords(
      records: records,
      transform: (product) => product.copyWith(price: product.price + 5),
    );

    expect(
      plan.previousProducts.map((product) => product.id),
      records.map((record) => record.id),
    );
    expect(
      plan.updatedProducts.map((product) => product.price),
      records.map((record) => record.unitPrice + 5),
    );
  });

  test('bulk mutation helpers pick products by id', () {
    final selectedProducts = inventoryProductCatalogProductsForIds(
      products: _products,
      productIds: {'p2', 'missing'},
    );

    expect(selectedProducts.map((product) => product.id), ['p2']);
    expect(
      inventoryProductCatalogProductsForIds(
        products: _products,
        productIds: const {},
      ),
      isEmpty,
    );
  });
}

final _products = [
  Product(id: 'p1', name: 'Cable', category: 'Accessories', price: 10),
  Product(id: 'p2', name: 'Adapter', category: 'Accessories', price: 20),
  Product(id: 'p3', name: 'Scanner', category: 'Hardware', price: 30),
];
