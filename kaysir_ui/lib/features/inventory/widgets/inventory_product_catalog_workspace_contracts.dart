import 'package:flutter/material.dart';
import 'package:kaysir/features/point_of_sales/cashier/utils/pos_browser_filter_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_browser_filter_host.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_dialog.dart';

typedef InventoryProductCatalogWorkspaceExtensionBuilder =
    List<Widget> Function(
      BuildContext context,
      InventoryProductCatalogWorkspaceContext workspace,
    );

typedef InventoryProductCatalogWorkspaceFilterAccessoryBuilder =
    Widget? Function(
      BuildContext context,
      InventoryProductCatalogWorkspaceContext workspace,
    );

typedef InventoryProductCatalogWorkspaceRecordFooterBuilder =
    Widget? Function(
      BuildContext context,
      InventoryProductCatalogWorkspaceContext workspace,
      InventoryProductCatalogRecord record,
    );

typedef InventoryProductCatalogEditorLauncher =
    void Function(
      Product product, {
      InventoryProductDialogFocusTarget? focusTarget,
    });

class InventoryProductCatalogMutationSync {
  const InventoryProductCatalogMutationSync({
    this.onProductsUpserted,
    this.onProductIdsDeleted,
  });

  final ValueChanged<List<Product>>? onProductsUpserted;
  final ValueChanged<Set<String>>? onProductIdsDeleted;

  void upsertProducts(Iterable<Product> products) {
    final nextProducts = List<Product>.unmodifiable(products);
    if (nextProducts.isEmpty) return;

    onProductsUpserted?.call(nextProducts);
  }

  void deleteProductIds(Iterable<String> productIds) {
    final nextProductIds = {
      for (final productId in productIds)
        if (productId.trim().isNotEmpty) productId,
    };
    if (nextProductIds.isEmpty) return;

    onProductIdsDeleted?.call(nextProductIds);
  }
}

class InventoryProductCatalogWorkspaceContext {
  const InventoryProductCatalogWorkspaceContext({
    required this.records,
    required this.visibleRecords,
    required this.summary,
    required this.browserController,
    required this.browserActions,
    required this.openProductEditor,
  });

  final List<InventoryProductCatalogRecord> records;
  final List<InventoryProductCatalogRecord> visibleRecords;
  final InventoryProductCatalogSummary summary;
  final POSBrowserFilterController<InventoryProductCatalogFilter>
  browserController;
  final POSBrowserFilterHostActions<InventoryProductCatalogFilter>
  browserActions;
  final InventoryProductCatalogEditorLauncher openProductEditor;
}
