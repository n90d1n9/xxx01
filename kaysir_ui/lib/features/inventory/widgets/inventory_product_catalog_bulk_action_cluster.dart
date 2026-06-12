import 'package:flutter/material.dart';

import '../../../widgets/ui/app_action_button.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_catalog_bulk_repair_actions.dart';

class InventoryProductCatalogBulkActionCluster extends StatelessWidget {
  const InventoryProductCatalogBulkActionCluster({
    super.key,
    required this.onChangeCategory,
    required this.onDeleteSelected,
    required this.onClearSelection,
    this.selectionSummary,
    this.onFillDescription,
    this.onGenerateSku,
    this.onGenerateShortcut,
    this.onUpdatePrice,
  });

  final InventoryProductCatalogSelectionSummary? selectionSummary;
  final VoidCallback onChangeCategory;
  final VoidCallback onDeleteSelected;
  final VoidCallback onClearSelection;
  final VoidCallback? onFillDescription;
  final VoidCallback? onGenerateSku;
  final VoidCallback? onGenerateShortcut;
  final VoidCallback? onUpdatePrice;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        AppActionButton(
          label: 'Change category',
          icon: Icons.category_rounded,
          variant: AppActionButtonVariant.secondary,
          compact: true,
          onPressed: onChangeCategory,
        ),
        if (onUpdatePrice != null)
          AppActionButton(
            label: 'Update price',
            icon: Icons.price_change_rounded,
            variant: AppActionButtonVariant.secondary,
            compact: true,
            onPressed: onUpdatePrice,
          ),
        if (onGenerateSku != null)
          InventoryProductCatalogBulkRepairActionButton(
            label: 'Generate SKU',
            icon: Icons.tag_rounded,
            repairCount: selectionSummary?.missingSkuCount,
            issueLabel: 'SKU',
            emptyTooltip: 'Selected products already have SKUs',
            onPressed: onGenerateSku!,
          ),
        if (onGenerateShortcut != null)
          InventoryProductCatalogBulkRepairActionButton(
            label: 'Generate shortcut',
            icon: Icons.keyboard_rounded,
            repairCount: selectionSummary?.missingScanCodeCount,
            issueLabel: 'scan code',
            pluralIssueLabel: 'scan codes',
            emptyTooltip: 'Selected products already have scan codes',
            onPressed: onGenerateShortcut!,
          ),
        if (onFillDescription != null)
          InventoryProductCatalogBulkRepairActionButton(
            label: 'Fill description',
            icon: Icons.notes_rounded,
            repairCount: selectionSummary?.missingDescriptionCount,
            issueLabel: 'description',
            emptyTooltip: 'Selected products already have descriptions',
            onPressed: onFillDescription!,
          ),
        AppActionButton(
          label: 'Delete selected',
          icon: Icons.delete_outline_rounded,
          variant: AppActionButtonVariant.destructive,
          compact: true,
          onPressed: onDeleteSelected,
        ),
        AppActionButton(
          label: 'Clear',
          icon: Icons.close_rounded,
          variant: AppActionButtonVariant.text,
          compact: true,
          onPressed: onClearSelection,
        ),
      ],
    );
  }
}
