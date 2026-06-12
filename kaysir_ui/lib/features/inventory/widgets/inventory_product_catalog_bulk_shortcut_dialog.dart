import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_shortcut_generation.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_bulk_mutation_dialog_layout.dart';
import 'inventory_product_catalog_bulk_generated_code_controls.dart';
import 'inventory_product_catalog_bulk_generated_code_preview.dart';

/// Dialog for generating POS shortcut keys for selected catalog records.
class InventoryProductBulkShortcutDialog extends StatefulWidget {
  const InventoryProductBulkShortcutDialog({
    super.key,
    required this.selectedRecords,
    required this.existingProducts,
    required this.onSubmit,
    this.onCancel,
  });

  final List<InventoryProductCatalogRecord> selectedRecords;
  final List<InventoryProductCatalogRecord> existingProducts;
  final ValueChanged<InventoryProductBulkShortcutGenerationDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryProductBulkShortcutDialog> createState() =>
      _InventoryProductBulkShortcutDialogState();
}

class _InventoryProductBulkShortcutDialogState
    extends State<InventoryProductBulkShortcutDialog> {
  final _prefixController = TextEditingController(text: 'K');

  @override
  void dispose() {
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = InventoryProductBulkShortcutGenerationDraft(
      prefix: _prefixController.text,
    );
    final previewProducts = draft.applyAll(
      widget.selectedRecords.map((record) => record.product),
      existingProducts:
          widget.existingProducts.map((record) => record.product).toList(),
    );
    final noun = widget.selectedRecords.length == 1 ? 'product' : 'products';

    return InventoryProductBulkMutationDialogLayout(
      maxWidth: 600,
      eyebrow: 'Bulk Quality Repair',
      title: 'Generate shortcut keys',
      subtitle:
          'Create unique POS shortcut keys for ${widget.selectedRecords.length} selected $noun.',
      closeTooltip: 'Close bulk shortcut dialog',
      statusLabel: '${widget.selectedRecords.length} missing scan code',
      statusIcon: Icons.qr_code_scanner_rounded,
      statusMaxWidth: 190,
      confirmLabel: 'Generate shortcuts',
      confirmIcon: Icons.keyboard_rounded,
      onCancel: widget.onCancel,
      onConfirm: () => widget.onSubmit(draft),
      children: [
        InventoryProductBulkGeneratedCodePrefixField(
          controller: _prefixController,
          label: 'Shortcut prefix',
          helperText: 'Examples: K, POS, HOT',
          icon: Icons.keyboard_rounded,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        InventoryProductBulkGeneratedCodePreview(
          title: 'Shortcut preview',
          records: widget.selectedRecords,
          previewProducts: previewProducts,
          generatedValueFor: (product) => product.shortcutKey,
          labelBuilder:
              (product, generatedValue) =>
                  inventoryProductBulkShortcutPreviewLabel(
                    product: product,
                    shortcutKey: generatedValue,
                  ),
        ),
      ],
    );
  }
}
