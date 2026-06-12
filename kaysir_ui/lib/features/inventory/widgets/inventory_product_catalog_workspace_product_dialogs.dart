import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import 'inventory_dialog.dart';
import 'inventory_product_catalog_workspace_mutations.dart';
import 'inventory_product_dialog.dart';

mixin InventoryProductCatalogWorkspaceProductDialogController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T>, InventoryProductCatalogWorkspaceMutationController<T> {
  void showAddEditProductDialog(
    BuildContext context, {
    Product? product,
    InventoryProductDialogFocusTarget? focusTarget,
  }) {
    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductDialog(
          product: product,
          initialFocusTarget: focusTarget,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            saveProductDraft(draft, product);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showDeleteConfirmation(BuildContext context, Product product) {
    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductDeleteDialog(
          product: product,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            deleteProduct(product);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
