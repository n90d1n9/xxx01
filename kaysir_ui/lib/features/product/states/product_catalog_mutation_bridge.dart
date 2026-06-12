import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/models/inventory_product_catalog_operation.dart';
import '../../inventory/states/product_provider.dart' as inventory_products;
import '../models/product.dart';
import 'product_provider.dart' as product_products;

final productCatalogMutationBridgeProvider =
    Provider<ProductCatalogMutationBridge>((ref) {
      return ProductCatalogMutationBridge(ref);
    });

class ProductCatalogMutationBridge {
  ProductCatalogMutationBridge(this._ref);

  final Ref _ref;

  InventoryProductCatalogOperationResult addProduct(Product product) {
    upsertProducts([product]);

    return InventoryProductCatalogOperationResult.productAdded(
      product,
      undo: () => deleteProductIds({product.id}),
    );
  }

  InventoryProductCatalogOperationResult updateProduct(
    Product updatedProduct, {
    required Product previousProduct,
  }) {
    upsertProducts([updatedProduct]);

    return InventoryProductCatalogOperationResult.productUpdated(
      updatedProduct,
      undo: () => restoreProduct(previousProduct),
    );
  }

  void restoreProduct(Product product) {
    upsertProducts([product]);
  }

  void deleteProduct(String productId) {
    deleteProductIds({productId});
  }

  void upsertProducts(Iterable<Product> products) {
    final productNotifier = _ref.read(
      product_products.productsProvider.notifier,
    );
    for (final product in products) {
      _upsertInventoryProduct(product);
      productNotifier.updateProduct(product);
    }
  }

  void deleteProductIds(Iterable<String> productIds) {
    final inventoryNotifier = _ref.read(
      inventory_products.productsProvider.notifier,
    );
    final productNotifier = _ref.read(
      product_products.productsProvider.notifier,
    );
    for (final productId in productIds) {
      inventoryNotifier.deleteProduct(productId);
      productNotifier.deleteProduct(productId);
    }
  }

  void _upsertInventoryProduct(Product product) {
    final inventoryNotifier = _ref.read(
      inventory_products.productsProvider.notifier,
    );
    final exists = _ref
        .read(inventory_products.productsProvider)
        .any((currentProduct) => currentProduct.id == product.id);

    if (exists) {
      inventoryNotifier.updateProduct(product);
    } else {
      inventoryNotifier.addProduct(product);
    }
  }
}
