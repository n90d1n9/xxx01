import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_workspace_controller.dart';
import 'inventory_product_catalog_workspace_mutations.dart';
import 'inventory_product_catalog_workspace_selection.dart';
import 'inventory_product_catalog_workspace_view_actions.dart';

mixin InventoryProductCatalogWorkspaceActionController<
  T extends ConsumerStatefulWidget
>
    on
        ConsumerState<T>,
        InventoryProductCatalogWorkspaceSelectionController<T>,
        InventoryProductCatalogWorkspaceMutationController<T>,
        InventoryProductCatalogWorkspaceOperationController<T> {
  InventoryProductCatalogWorkspaceViewActions
  buildProductCatalogWorkspaceViewActions({
    required BuildContext context,
    required List<InventoryProductCatalogRecord> visibleRecords,
    required InventoryProductCatalogWorkspaceSelectionSnapshot activeSelection,
    VoidCallback? onAddProductOverride,
    ValueChanged<Product>? onEditProductOverride,
  }) {
    return InventoryProductCatalogWorkspaceViewActions(
      onAddProduct:
          onAddProductOverride ?? () => showAddEditProductDialog(context),
      onSelectionChanged: setProductSelected,
      onSelectVisibleChanged:
          (selected) =>
              setVisibleProductsSelected(visibleRecords, selected: selected),
      onSelectRepairCandidates:
          (target) => selectVisibleRepairCandidates(visibleRecords, target),
      onClearSelection: clearSelection,
      onBulkChangeCategory:
          () => showBulkCategoryDialog(context, activeSelection.selectedIds),
      onBulkUpdatePrice:
          () => showBulkPriceDialog(context, activeSelection.selectedRecords),
      onBulkGenerateSku:
          () => showBulkSkuDialog(context, activeSelection.selectedRecords),
      onBulkGenerateShortcut:
          () =>
              showBulkShortcutDialog(context, activeSelection.selectedRecords),
      onBulkFillDescription:
          () => showBulkDescriptionDialog(
            context,
            activeSelection.selectedRecords,
          ),
      onBulkDeleteSelected:
          () => showBulkDeleteConfirmation(
            context,
            activeSelection.selectedIds,
            activeSelection.summary,
          ),
      onEditRecord:
          (record) =>
              onEditProductOverride == null
                  ? showAddEditProductDialog(context, product: record.product)
                  : onEditProductOverride(record.product),
      onDuplicateRecord: (record) => duplicateProduct(record.product),
      onDeleteRecord:
          (record) => showDeleteConfirmation(context, record.product),
    );
  }
}
