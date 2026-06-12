import 'package:flutter/material.dart';

import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_bulk_action_bar_layout.dart';
import 'inventory_product_catalog_bulk_action_cluster.dart';
import 'inventory_product_catalog_bulk_selection_control.dart';
import 'inventory_product_catalog_selection_summary.dart';

class InventoryProductCatalogBulkActionBar extends StatelessWidget {
  const InventoryProductCatalogBulkActionBar({
    super.key,
    required this.selectedCount,
    required this.visibleCount,
    required this.allVisibleSelected,
    required this.onSelectVisibleChanged,
    required this.onChangeCategory,
    required this.onDeleteSelected,
    required this.onClearSelection,
    this.onFillDescription,
    this.onGenerateSku,
    this.onGenerateShortcut,
    this.onUpdatePrice,
    this.selectionSummary,
  });

  final int selectedCount;
  final int visibleCount;
  final bool allVisibleSelected;
  final ValueChanged<bool> onSelectVisibleChanged;
  final VoidCallback onChangeCategory;
  final VoidCallback onDeleteSelected;
  final VoidCallback onClearSelection;
  final VoidCallback? onFillDescription;
  final VoidCallback? onGenerateSku;
  final VoidCallback? onGenerateShortcut;
  final VoidCallback? onUpdatePrice;
  final InventoryProductCatalogSelectionSummary? selectionSummary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fillDescriptionAction = onFillDescription;
    final generateSkuAction = onGenerateSku;
    final generateShortcutAction = onGenerateShortcut;
    final updatePriceAction = onUpdatePrice;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.24)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: InventoryProductCatalogBulkActionBarLayout(
          selector: InventoryProductCatalogBulkSelectionControl(
            selectedCount: selectedCount,
            visibleCount: visibleCount,
            allVisibleSelected: allVisibleSelected,
            onSelectVisibleChanged: onSelectVisibleChanged,
          ),
          actions: InventoryProductCatalogBulkActionCluster(
            selectionSummary: selectionSummary,
            onChangeCategory: onChangeCategory,
            onDeleteSelected: onDeleteSelected,
            onClearSelection: onClearSelection,
            onFillDescription: fillDescriptionAction,
            onGenerateSku: generateSkuAction,
            onGenerateShortcut: generateShortcutAction,
            onUpdatePrice: updatePriceAction,
          ),
          impactStrip:
              selectionSummary == null
                  ? null
                  : InventoryProductCatalogSelectionImpactStrip(
                    summary: selectionSummary!,
                  ),
        ),
      ),
    );
  }
}
