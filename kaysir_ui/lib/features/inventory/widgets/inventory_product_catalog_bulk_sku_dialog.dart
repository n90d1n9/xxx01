import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_sku_generation.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_bulk_mutation_dialog_layout.dart';
import 'inventory_product_catalog_bulk_generated_code_controls.dart';
import 'inventory_product_catalog_bulk_generated_code_preview.dart';

/// Dialog for generating missing SKUs for selected catalog records.
class InventoryProductBulkSkuDialog extends StatefulWidget {
  const InventoryProductBulkSkuDialog({
    super.key,
    required this.selectedRecords,
    required this.existingProducts,
    required this.onSubmit,
    this.onCancel,
  });

  final List<InventoryProductCatalogRecord> selectedRecords;
  final List<InventoryProductCatalogRecord> existingProducts;
  final ValueChanged<InventoryProductBulkSkuGenerationDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryProductBulkSkuDialog> createState() =>
      _InventoryProductBulkSkuDialogState();
}

class _InventoryProductBulkSkuDialogState
    extends State<InventoryProductBulkSkuDialog> {
  final _prefixController = TextEditingController();

  @override
  void dispose() {
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = InventoryProductBulkSkuGenerationDraft(
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
      title: 'Generate missing SKUs',
      subtitle:
          'Create unique SKUs for ${widget.selectedRecords.length} selected $noun.',
      closeTooltip: 'Close bulk SKU dialog',
      statusLabel: '${widget.selectedRecords.length} missing SKU',
      statusIcon: Icons.tag_rounded,
      statusMaxWidth: 170,
      confirmLabel: 'Generate SKUs',
      confirmIcon: Icons.tag_rounded,
      onCancel: widget.onCancel,
      onConfirm: () => widget.onSubmit(draft),
      children: [
        InventoryProductBulkGeneratedCodePrefixField(
          controller: _prefixController,
          label: 'SKU prefix',
          helperText: 'Optional. Example: RETAIL or POS',
          icon: Icons.short_text_rounded,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        InventoryProductBulkGeneratedCodePreview(
          title: 'SKU preview',
          records: widget.selectedRecords,
          previewProducts: previewProducts,
          generatedValueFor: (product) => product.sku ?? '',
          labelBuilder:
              (product, generatedValue) => inventoryProductBulkSkuPreviewLabel(
                product: product,
                sku: generatedValue,
              ),
        ),
      ],
    );
  }
}
