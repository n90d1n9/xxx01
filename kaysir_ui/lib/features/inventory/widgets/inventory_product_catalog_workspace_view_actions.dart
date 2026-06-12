import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';

typedef InventoryProductCatalogRecordSelectionChanged =
    void Function(InventoryProductCatalogRecord record, bool selected);

class InventoryProductCatalogWorkspaceViewActions {
  const InventoryProductCatalogWorkspaceViewActions({
    required this.onAddProduct,
    required this.onSelectionChanged,
    required this.onSelectVisibleChanged,
    required this.onSelectRepairCandidates,
    required this.onClearSelection,
    required this.onBulkChangeCategory,
    required this.onBulkUpdatePrice,
    required this.onBulkGenerateSku,
    required this.onBulkGenerateShortcut,
    required this.onBulkFillDescription,
    required this.onBulkDeleteSelected,
    required this.onEditRecord,
    required this.onDuplicateRecord,
    required this.onDeleteRecord,
  });

  final VoidCallback onAddProduct;
  final InventoryProductCatalogRecordSelectionChanged onSelectionChanged;
  final ValueChanged<bool> onSelectVisibleChanged;
  final ValueChanged<InventoryProductCatalogRepairTarget>
  onSelectRepairCandidates;
  final VoidCallback onClearSelection;
  final VoidCallback onBulkChangeCategory;
  final VoidCallback onBulkUpdatePrice;
  final VoidCallback onBulkGenerateSku;
  final VoidCallback onBulkGenerateShortcut;
  final VoidCallback onBulkFillDescription;
  final VoidCallback onBulkDeleteSelected;
  final ValueChanged<InventoryProductCatalogRecord> onEditRecord;
  final ValueChanged<InventoryProductCatalogRecord> onDuplicateRecord;
  final ValueChanged<InventoryProductCatalogRecord> onDeleteRecord;
}
