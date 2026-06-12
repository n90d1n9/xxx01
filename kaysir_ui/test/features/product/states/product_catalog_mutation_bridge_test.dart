import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/inventory/states/product_provider.dart'
    as inventory_products;
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/states/product_catalog_mutation_bridge.dart';
import 'package:kaysir/features/product/states/product_provider.dart'
    as product_products;

void main() {
  test('catalog mutation bridge syncs product add and undo across stores', () {
    final existing = Product(id: 'p1', name: 'Coffee', price: 12000);
    final inserted = Product(id: 'p2', name: 'Tea', price: 9000);
    final container = _container(products: [existing]);
    addTearDown(container.dispose);

    final result = container
        .read(productCatalogMutationBridgeProvider)
        .addProduct(inserted);

    expect(result.message, 'Tea added to catalog');
    expect(_inventoryProducts(container).map((product) => product.id), [
      'p1',
      'p2',
    ]);
    expect(_productStateProducts(container).map((product) => product.id), [
      'p1',
      'p2',
    ]);

    result.undo?.call();

    expect(_inventoryProducts(container).map((product) => product.id), ['p1']);
    expect(_productStateProducts(container).map((product) => product.id), [
      'p1',
    ]);
  });

  test(
    'catalog mutation bridge syncs product update and undo across stores',
    () {
      final existing = Product(
        id: 'p1',
        name: 'Coffee',
        sku: 'CF-001',
        price: 12000,
      );
      final updated = existing.copyWith(
        name: 'Iced Coffee',
        customAttributes: {'batch_number': 'B-01'},
      );
      final container = _container(products: [existing]);
      addTearDown(container.dispose);

      final result = container
          .read(productCatalogMutationBridgeProvider)
          .updateProduct(updated, previousProduct: existing);

      expect(result.message, 'Iced Coffee updated');
      expect(_inventoryProducts(container).single.name, 'Iced Coffee');
      expect(
        _productStateProducts(
          container,
        ).single.customAttributes['batch_number'],
        'B-01',
      );

      result.undo?.call();

      expect(_inventoryProducts(container).single.name, 'Coffee');
      expect(_productStateProducts(container).single.customAttributes, isEmpty);
    },
  );

  test('catalog mutation bridge syncs batch upserts and deletes', () {
    final coffee = Product(id: 'p1', name: 'Coffee', price: 12000);
    final tea = Product(id: 'p2', name: 'Tea', price: 9000);
    final updatedCoffee = coffee.copyWith(name: 'Iced Coffee');
    final container = _container(products: [coffee]);
    addTearDown(container.dispose);
    final bridge = container.read(productCatalogMutationBridgeProvider);

    bridge.upsertProducts([updatedCoffee, tea]);

    expect(_inventoryProducts(container).map((product) => product.name), [
      'Iced Coffee',
      'Tea',
    ]);
    expect(_productStateProducts(container).map((product) => product.name), [
      'Iced Coffee',
      'Tea',
    ]);

    bridge.deleteProductIds({'p1', 'p2'});

    expect(_inventoryProducts(container), isEmpty);
    expect(_productStateProducts(container), isEmpty);
  });
}

ProviderContainer _container({required List<Product> products}) {
  return ProviderContainer(
    overrides: [
      inventory_products.productsProvider.overrideWith(
        (ref) => _SeededInventoryProducts(products),
      ),
      product_products.productsProvider.overrideWith(
        (ref) => product_products.ProductsNotifier(
          ref,
          initialProducts: products,
          loadOnStart: false,
        ),
      ),
    ],
  );
}

List<Product> _inventoryProducts(ProviderContainer container) {
  return container.read(inventory_products.productsProvider);
}

List<Product> _productStateProducts(ProviderContainer container) {
  return container.read(product_products.productsProvider).products ?? [];
}

class _SeededInventoryProducts extends inventory_products.ProductsNotifier {
  _SeededInventoryProducts(List<Product> products) {
    state = products;
  }
}
