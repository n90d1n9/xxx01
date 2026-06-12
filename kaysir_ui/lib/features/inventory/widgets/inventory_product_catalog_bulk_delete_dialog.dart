import 'package:flutter/material.dart';

import '../../../widgets/ui/app_status_pill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_delete_confirmation_dialog.dart';
import 'inventory_product_catalog_selection_summary.dart';

/// Confirmation dialog for deleting a selected set of catalog products.
class InventoryProductBulkDeleteDialog extends StatelessWidget {
  const InventoryProductBulkDeleteDialog({
    super.key,
    required this.selectedCount,
    required this.onConfirm,
    this.selectionSummary,
    this.onCancel,
  });

  final int selectedCount;
  final VoidCallback onConfirm;
  final InventoryProductCatalogSelectionSummary? selectionSummary;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final noun = selectedCount == 1 ? 'product' : 'products';

    return InventoryDeleteConfirmationDialog(
      title: 'Delete selected products?',
      subtitle:
          'This will remove $selectedCount selected $noun from the catalog.',
      closeTooltip: 'Close bulk delete dialog',
      showCloseButton: true,
      confirmLabel: 'Delete selected',
      onCancel: onCancel,
      onConfirm: onConfirm,
      children: [
        AppStatusPill(
          label: '$selectedCount selected',
          color: Theme.of(context).colorScheme.error,
          icon: Icons.delete_outline_rounded,
          maxWidth: 150,
        ),
        if (selectionSummary != null) ...[
          const SizedBox(height: 12),
          InventoryProductCatalogSelectionImpactStrip(
            summary: selectionSummary!,
          ),
        ],
      ],
    );
  }
}
