import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_bulk_description_fill.dart';
import '../models/inventory_product_bulk_price_update.dart';
import '../models/inventory_product_bulk_shortcut_generation.dart';
import '../models/inventory_product_bulk_sku_generation.dart';
import '../models/inventory_product_catalog.dart';
import '../models/inventory_product_catalog_operation.dart';
import '../models/inventory_product_draft.dart';

export 'inventory_product_catalog_workspace_bulk_mutations.dart';
export 'inventory_product_catalog_workspace_product_mutations.dart';

mixin InventoryProductCatalogWorkspaceMutationController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T> {
  void saveProductDraft(InventoryProductDraft draft, [Product? product]);

  void duplicateProduct(Product source);

  void deleteProduct(Product product);

  void updateBulkProductPrices(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkPriceUpdateDraft draft,
  );

  void updateBulkProductCategory(Set<String> productIds, String category);

  void fillBulkProductDescriptions(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkDescriptionFillDraft draft,
  );

  void generateBulkProductSkus(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkSkuGenerationDraft draft,
  );

  void generateBulkProductShortcuts(
    List<InventoryProductCatalogRecord> selectedRecords,
    InventoryProductBulkShortcutGenerationDraft draft,
  );

  void deleteBulkProducts(Set<String> productIds);

  void restoreProducts(List<Product> products);

  void notifyOperationCompleted(InventoryProductCatalogOperationResult result);
}
