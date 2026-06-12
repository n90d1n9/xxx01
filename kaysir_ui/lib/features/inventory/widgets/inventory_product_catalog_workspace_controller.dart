import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_workspace_mutations.dart';
import 'inventory_product_dialog.dart';

export 'inventory_product_catalog_workspace_bulk_dialogs.dart';
export 'inventory_product_catalog_workspace_product_dialogs.dart';

mixin InventoryProductCatalogWorkspaceOperationController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T>, InventoryProductCatalogWorkspaceMutationController<T> {
  void showAddEditProductDialog(
    BuildContext context, {
    Product? product,
    InventoryProductDialogFocusTarget? focusTarget,
  });

  void showBulkCategoryDialog(
    BuildContext context,
    Set<String> selectedProductIds,
  );

  void showBulkPriceDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  );

  void showBulkDescriptionDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  );

  void showBulkSkuDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  );

  void showBulkShortcutDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  );

  void showBulkDeleteConfirmation(
    BuildContext context,
    Set<String> selectedProductIds,
    InventoryProductCatalogSelectionSummary selectionSummary,
  );

  void showDeleteConfirmation(BuildContext context, Product product);
}
