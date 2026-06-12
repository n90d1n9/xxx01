import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_description_fill.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_bulk_mutation_dialog_layout.dart';
import 'inventory_product_catalog_bulk_description_controls.dart';
import 'inventory_product_catalog_bulk_description_preview.dart';

/// Dialog for filling missing catalog descriptions in bulk.
class InventoryProductBulkDescriptionDialog extends StatefulWidget {
  const InventoryProductBulkDescriptionDialog({
    super.key,
    required this.selectedRecords,
    required this.onSubmit,
    this.onCancel,
  });

  final List<InventoryProductCatalogRecord> selectedRecords;
  final ValueChanged<InventoryProductBulkDescriptionFillDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryProductBulkDescriptionDialog> createState() =>
      _InventoryProductBulkDescriptionDialogState();
}

class _InventoryProductBulkDescriptionDialogState
    extends State<InventoryProductBulkDescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _templateController = TextEditingController(
    text: inventoryProductBulkDescriptionDefaultTemplate,
  );

  @override
  void dispose() {
    _templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = InventoryProductBulkDescriptionFillDraft(
      template: _templateController.text,
    );
    final noun = widget.selectedRecords.length == 1 ? 'product' : 'products';

    return InventoryProductBulkMutationDialogLayout(
      maxWidth: 640,
      formKey: _formKey,
      eyebrow: 'Bulk Quality Repair',
      title: 'Fill missing descriptions',
      subtitle:
          'Apply one description template to ${widget.selectedRecords.length} selected $noun.',
      closeTooltip: 'Close bulk description dialog',
      statusLabel: '${widget.selectedRecords.length} missing description',
      statusIcon: Icons.notes_rounded,
      statusMaxWidth: 210,
      confirmLabel: 'Fill descriptions',
      confirmIcon: Icons.notes_rounded,
      onCancel: widget.onCancel,
      onConfirm: _submit,
      children: [
        InventoryProductBulkDescriptionTemplateField(
          controller: _templateController,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        InventoryProductBulkDescriptionPreview(
          records: widget.selectedRecords,
          draft: draft,
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSubmit(
      InventoryProductBulkDescriptionFillDraft(
        template: _templateController.text,
      ),
    );
  }
}
