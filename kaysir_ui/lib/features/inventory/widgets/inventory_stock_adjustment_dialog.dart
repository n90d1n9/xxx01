import 'package:flutter/material.dart';

import '../models/inventory_stock_adjustment_draft.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_dialog_content_layout.dart';
import 'inventory_stock_adjustment_dialog_state.dart';
import 'inventory_stock_adjustment_form.dart';

/// Dialog for increasing or decreasing a stock line with audit context.
class InventoryStockAdjustmentDialog extends StatefulWidget {
  const InventoryStockAdjustmentDialog({
    super.key,
    required this.record,
    required this.direction,
    required this.onSubmit,
    this.onCancel,
  });

  final InventoryStockRecord record;
  final InventoryStockAdjustmentDirection direction;
  final ValueChanged<InventoryStockAdjustmentDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryStockAdjustmentDialog> createState() =>
      _InventoryStockAdjustmentDialogState();
}

class _InventoryStockAdjustmentDialogState
    extends State<InventoryStockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _reasonController;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _currentDraft();
    final projectedQuantity = inventoryStockAdjustmentProjectedQuantity(
      currentQuantity: widget.record.quantity,
      draft: draft,
    );

    return InventoryDialogContentLayout(
      maxWidth: 620,
      maxHeight: 760,
      eyebrow: 'Stock Adjustment',
      title:
          '${inventoryStockAdjustmentDirectionLabel(widget.direction)} ${widget.record.productName}',
      subtitle:
          '${widget.record.skuLabel} | ${widget.record.warehouseName} - ${widget.record.warehouseLocation}',
      closeTooltip: 'Close stock adjustment',
      onClose: widget.onCancel,
      child: InventoryStockAdjustmentForm(
        formKey: _formKey,
        direction: widget.direction,
        currentQuantity: widget.record.quantity,
        projectedQuantity: projectedQuantity,
        quantityController: _quantityController,
        reasonController: _reasonController,
        formError: _formError,
        onQuantityChanged: _clearFormError,
        onCancel: widget.onCancel,
        onSubmit: _submit,
      ),
    );
  }

  InventoryStockAdjustmentDraft? _currentDraft() {
    return inventoryStockAdjustmentDraftFromInput(
      direction: widget.direction,
      quantityText: _quantityController.text,
      reason: _reasonController.text,
    );
  }

  void _clearFormError(String _) {
    setState(() {
      _formError = null;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _currentDraft();
    if (draft == null) return;

    final issue = validateInventoryStockAdjustmentDraft(
      draft,
      currentQuantity: widget.record.quantity,
    );
    if (issue != null) {
      setState(() {
        _formError = inventoryStockAdjustmentIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }
}
