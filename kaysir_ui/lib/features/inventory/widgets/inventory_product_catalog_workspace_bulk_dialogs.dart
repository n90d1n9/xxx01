import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_product_bulk_description_fill.dart';
import '../models/inventory_product_bulk_shortcut_generation.dart';
import '../models/inventory_product_bulk_sku_generation.dart';
import '../models/inventory_product_catalog.dart';
import '../states/inventory_projection_provider.dart';
import '../states/product_provider.dart';
import 'inventory_dialog.dart';
import 'inventory_product_catalog_bulk_actions.dart';
import 'inventory_product_catalog_bulk_description_dialog.dart';
import 'inventory_product_catalog_bulk_price_dialog.dart';
import 'inventory_product_catalog_bulk_shortcut_dialog.dart';
import 'inventory_product_catalog_bulk_sku_dialog.dart';
import 'inventory_product_catalog_workspace_mutations.dart';

mixin InventoryProductCatalogWorkspaceBulkDialogController<
  T extends ConsumerStatefulWidget
>
    on ConsumerState<T>, InventoryProductCatalogWorkspaceMutationController<T> {
  void showBulkCategoryDialog(
    BuildContext context,
    Set<String> selectedProductIds,
  ) {
    if (selectedProductIds.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkCategoryDialog(
          selectedCount: selectedProductIds.length,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (category) {
            updateBulkProductCategory(selectedProductIds, category);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showBulkPriceDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  ) {
    if (selectedRecords.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkPriceDialog(
          selectedRecords: selectedRecords,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            updateBulkProductPrices(selectedRecords, draft);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showBulkDescriptionDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  ) {
    final missingDescriptionRecords =
        selectedRecords
            .where((record) => inventoryProductNeedsDescription(record.product))
            .toList();
    if (missingDescriptionRecords.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkDescriptionDialog(
          selectedRecords: missingDescriptionRecords,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            fillBulkProductDescriptions(missingDescriptionRecords, draft);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showBulkSkuDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  ) {
    final missingSkuRecords =
        selectedRecords
            .where((record) => inventoryProductNeedsSku(record.product))
            .toList();
    if (missingSkuRecords.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkSkuDialog(
          selectedRecords: missingSkuRecords,
          existingProducts: buildInventoryProductCatalogRecords(
            products: ref.read(productsProvider),
            stockRecords: ref.read(inventoryStockRecordsProvider),
          ),
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            generateBulkProductSkus(missingSkuRecords, draft);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showBulkShortcutDialog(
    BuildContext context,
    List<InventoryProductCatalogRecord> selectedRecords,
  ) {
    final missingScanCodeRecords =
        selectedRecords
            .where((record) => inventoryProductNeedsScanCode(record.product))
            .toList();
    if (missingScanCodeRecords.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkShortcutDialog(
          selectedRecords: missingScanCodeRecords,
          existingProducts: buildInventoryProductCatalogRecords(
            products: ref.read(productsProvider),
            stockRecords: ref.read(inventoryStockRecordsProvider),
          ),
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (draft) {
            generateBulkProductShortcuts(missingScanCodeRecords, draft);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void showBulkDeleteConfirmation(
    BuildContext context,
    Set<String> selectedProductIds,
    InventoryProductCatalogSelectionSummary selectionSummary,
  ) {
    if (selectedProductIds.isEmpty) return;

    showInventoryDialog<void>(
      context: context,
      builder: (dialogContext) {
        return InventoryProductBulkDeleteDialog(
          selectedCount: selectedProductIds.length,
          selectionSummary: selectionSummary,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () {
            deleteBulkProducts(selectedProductIds);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
