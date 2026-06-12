import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_price_update.dart';
import '../models/inventory_product_catalog.dart';
import 'inventory_product_bulk_mutation_dialog_layout.dart';
import 'inventory_product_catalog_bulk_price_controls.dart';
import 'inventory_product_catalog_bulk_price_preview.dart';

/// Dialog for applying a bulk price update rule to selected products.
class InventoryProductBulkPriceDialog extends StatefulWidget {
  const InventoryProductBulkPriceDialog({
    super.key,
    required this.selectedRecords,
    required this.onSubmit,
    this.onCancel,
  });

  final List<InventoryProductCatalogRecord> selectedRecords;
  final ValueChanged<InventoryProductBulkPriceUpdateDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryProductBulkPriceDialog> createState() =>
      _InventoryProductBulkPriceDialogState();
}

class _InventoryProductBulkPriceDialogState
    extends State<InventoryProductBulkPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  var _mode = InventoryProductBulkPriceUpdateMode.setFixed;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draftOrNull();
    final noun = widget.selectedRecords.length == 1 ? 'product' : 'products';

    return InventoryProductBulkMutationDialogLayout(
      maxWidth: 600,
      formKey: _formKey,
      eyebrow: 'Bulk Pricing',
      title: 'Update selected prices',
      subtitle:
          'Apply a pricing rule to ${widget.selectedRecords.length} selected $noun.',
      closeTooltip: 'Close bulk price dialog',
      statusLabel: '${widget.selectedRecords.length} selected',
      statusIcon: Icons.library_add_check_rounded,
      statusMaxWidth: 150,
      confirmLabel: 'Apply prices',
      confirmIcon: Icons.price_change_rounded,
      onCancel: widget.onCancel,
      onConfirm: _submit,
      children: [
        InventoryProductBulkPriceModeSelector(
          mode: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        const SizedBox(height: 16),
        InventoryProductBulkPriceValueField(
          controller: _valueController,
          mode: _mode,
          onChanged: () => setState(() {}),
        ),
        if (draft != null) ...[
          const SizedBox(height: 16),
          InventoryProductBulkPricePreview(
            records: widget.selectedRecords,
            draft: draft,
          ),
        ],
      ],
    );
  }

  InventoryProductBulkPriceUpdateDraft? _draftOrNull() {
    if (validateInventoryProductBulkPriceValue(_valueController.text, _mode) !=
        null) {
      return null;
    }

    return InventoryProductBulkPriceUpdateDraft(
      mode: _mode,
      value: parseInventoryProductBulkPriceValue(_valueController.text)!,
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSubmit(
      InventoryProductBulkPriceUpdateDraft(
        mode: _mode,
        value: parseInventoryProductBulkPriceValue(_valueController.text)!,
      ),
    );
  }
}
