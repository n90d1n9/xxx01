import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_product_bulk_description_fill.dart';
import '../models/inventory_product_bulk_price_update.dart';
import '../models/inventory_product_bulk_shortcut_generation.dart';
import '../models/inventory_product_bulk_sku_generation.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_operation.dart';
import '../states/product_provider.dart';
import 'inventory_product_catalog_workspace_bulk_mutation_plan.dart';
import 'inventory_product_catalog_workspace_product_mutations.dart';

mixin InventoryProductCatalogWorkspaceBulkMutationController<
  T extends ConsumerStatefulWidget
>
    on
        ConsumerState<T>,
        InventoryProductCatalogWorkspaceProductMutationController<T> {
  void clearSelection();

  void updateBulkProductCategory(Set<String> productIds, String category) {
    final normalizedCategory = category.trim();
    if (normalizedCategory.isEmpty) return;

    final mutation = inventoryProductCatalogBulkMutationFromProducts(
      products: ref.read(productsProvider),
      include: (product) => productIds.contains(product.id),
      transform: (product) => product.copyWith(category: normalizedCategory),
    );
    if (!_applyBulkProductMutation(mutation)) return;

    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkCategoryUpdated(
        count: mutation.count,
        category: normalizedCategory,
        undo: () => restoreProducts(mutation.previousProducts),
      ),
    );
  }

  void updateBulkProductPrices(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkPriceUpdateDraft draft,
  ) {
    final mutation = inventoryProductCatalogBulkMutationFromRecords(
      records: selectedRecords,
      transform: draft.apply,
    );
    if (!_applyBulkProductMutation(mutation)) return;

    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkPriceUpdated(
        mutation.count,
        undo: () => restoreProducts(mutation.previousProducts),
      ),
    );
  }

  void fillBulkProductDescriptions(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkDescriptionFillDraft draft,
  ) {
    final previousProducts = inventoryProductCatalogProductsForRecords(
      selectedRecords,
    );
    final mutation = InventoryProductCatalogBulkMutationPlan(
      previousProducts: previousProducts,
      updatedProducts: draft.applyAll(previousProducts),
    );
    if (!_applyBulkProductMutation(mutation)) return;

    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkDescriptionsFilled(
        mutation.count,
        undo: () => restoreProducts(mutation.previousProducts),
      ),
    );
  }

  void generateBulkProductSkus(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkSkuGenerationDraft draft,
  ) {
    final previousProducts = inventoryProductCatalogProductsForRecords(
      selectedRecords,
    );
    final mutation = InventoryProductCatalogBulkMutationPlan(
      previousProducts: previousProducts,
      updatedProducts: draft.applyAll(
        previousProducts,
        existingProducts: ref.read(productsProvider),
      ),
    );
    if (!_applyBulkProductMutation(mutation)) return;

    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkSkusGenerated(
        mutation.count,
        undo: () => restoreProducts(mutation.previousProducts),
      ),
    );
  }

  void generateBulkProductShortcuts(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkShortcutGenerationDraft draft,
  ) {
    final previousProducts = inventoryProductCatalogProductsForRecords(
      selectedRecords,
    );
    final mutation = InventoryProductCatalogBulkMutationPlan(
      previousProducts: previousProducts,
      updatedProducts: draft.applyAll(
        previousProducts,
        existingProducts: ref.read(productsProvider),
      ),
    );
    if (!_applyBulkProductMutation(mutation)) return;

    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkShortcutsGenerated(
        mutation.count,
        undo: () => restoreProducts(mutation.previousProducts),
      ),
    );
  }

  void deleteBulkProducts(Set<String> productIds) {
    final deletedProducts = inventoryProductCatalogProductsForIds(
      products: ref.read(productsProvider),
      productIds: productIds,
    );
    if (deletedProducts.isEmpty) return;

    final notifier = ref.read(productsProvider.notifier);
    for (final product in deletedProducts) {
      notifier.deleteProduct(product.id);
    }
    syncProductCatalogDeletes({
      for (final product in deletedProducts) product.id,
    });

    clearSelection();
    notifyOperationCompleted(
      InventoryProductCatalogOperationResult.bulkDeleted(
        deletedProducts.length,
        undo: () => restoreProducts(deletedProducts),
      ),
    );
  }

  bool _applyBulkProductMutation(
    InventoryProductCatalogBulkMutationPlan mutation,
  ) {
    if (mutation.isEmpty) return false;

    final notifier = ref.read(productsProvider.notifier);
    for (final product in mutation.updatedProducts) {
      notifier.updateProduct(product);
    }
    syncProductCatalogUpserts(mutation.updatedProducts);
    clearSelection();
    return true;
  }
}
