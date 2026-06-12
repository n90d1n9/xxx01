import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog_operation.dart';
import '../models/inventory_product_duplicate.dart';
import '../models/inventory_product_draft.dart';
import '../states/product_provider.dart';

mixin InventoryProductCatalogWorkspaceProductMutationController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T> {
  Set<String> get selectedProductIds;

  void notifyOperationCompleted(InventoryProductCatalogOperationResult result);

  void syncProductCatalogUpserts(List<Product> products) {}

  void syncProductCatalogDeletes(Set<String> productIds) {}

  void saveProductDraft(InventoryProductDraft draft, [Product? product]) {
    final notifier = ref.read(productsProvider.notifier);
    if (product == null) {
      final createdProduct = draft.toProduct(
        id: inventoryProductIdForDate(DateTime.now()),
      );
      notifier.addProduct(createdProduct);
      syncProductCatalogUpserts([createdProduct]);
      notifyOperationCompleted(
        InventoryProductCatalogOperationResult.productAdded(
          createdProduct,
          undo: () {
            ref
                .read(productsProvider.notifier)
                .deleteProduct(createdProduct.id);
            syncProductCatalogDeletes({createdProduct.id});
          },
        ),
      );
      return;
    }

    final updatedProduct = draft.apply(product);
    notifier.updateProduct(updatedProduct);
    syncProductCatalogUpserts([updatedProduct]);
    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.productUpdated(
        updatedProduct,
        undo: () => restoreProducts([product]),
      ),
    );
  }

  void duplicateProduct(Product source) {
    final duplicate = duplicateInventoryProduct(
      source: source,
      existingProducts: ref.read(productsProvider),
      id: inventoryProductIdForDate(DateTime.now()),
    );

    ref.read(productsProvider.notifier).addProduct(duplicate);
    syncProductCatalogUpserts([duplicate]);
    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.productDuplicated(
        source: source,
        duplicate: duplicate,
        undo: () {
          ref.read(productsProvider.notifier).deleteProduct(duplicate.id);
          syncProductCatalogDeletes({duplicate.id});
        },
      ),
    );
  }

  void deleteProduct(Product product) {
    ref.read(productsProvider.notifier).deleteProduct(product.id);
    syncProductCatalogDeletes({product.id});
    selectedProductIds.remove(product.id);
    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.productDeleted(
        product,
        undo: () => restoreProducts([product]),
      ),
    );
  }

  void restoreProducts(List<Product> products) {
    final notifier = ref.read(productsProvider.notifier);
    final currentIds = {
      for (final product in ref.read(productsProvider)) product.id,
    };
    for (final product in products) {
      if (currentIds.contains(product.id)) {
        notifier.updateProduct(product);
      } else {
        notifier.addProduct(product);
        currentIds.add(product.id);
      }
    }
    syncProductCatalogUpserts(products);
  }
}
