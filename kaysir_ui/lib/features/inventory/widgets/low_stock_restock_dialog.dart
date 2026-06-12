import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inventory_replenishment_plan.dart';
import '../models/inventory_restock_draft.dart';
import 'inventory_dialog_content_layout.dart';
import 'low_stock_restock_dialog_state.dart';
import 'low_stock_restock_form.dart';

/// Dialog for turning a low-stock replenishment plan into a restock draft.
class LowStockRestockDialog extends StatefulWidget {
  const LowStockRestockDialog({
    super.key,
    required this.plan,
    required this.onSubmit,
    this.onCancel,
    this.currencyFormat,
  });

  final InventoryReplenishmentPlan plan;
  final ValueChanged<InventoryRestockDraft> onSubmit;
  final VoidCallback? onCancel;
  final NumberFormat? currencyFormat;

  @override
  State<LowStockRestockDialog> createState() => _LowStockRestockDialogState();
}

class _LowStockRestockDialogState extends State<LowStockRestockDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.plan.suggestedQuantity.toString(),
    );
    _notesController = TextEditingController(text: lowStockRestockDefaultNotes);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.plan.record;

    return InventoryDialogContentLayout(
      maxWidth: 660,
      maxHeight: 780,
      eyebrow: 'Replenishment Order',
      title: 'Restock ${record.productName}',
      subtitle:
          '${record.skuLabel} | ${record.warehouseName} - ${record.warehouseLocation}',
      closeTooltip: 'Close restock dialog',
      onClose: widget.onCancel,
      child: LowStockRestockForm(
        formKey: _formKey,
        plan: widget.plan,
        draft: _currentDraft(),
        quantityController: _quantityController,
        notesController: _notesController,
        formError: _formError,
        onQuantityChanged: _clearFormError,
        onCancel: widget.onCancel,
        onSubmit: _submit,
        currencyFormat: widget.currencyFormat,
      ),
    );
  }

  InventoryRestockDraft? _currentDraft() {
    return lowStockRestockDraftFromInput(
      quantityText: _quantityController.text,
      notes: _notesController.text,
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

    final issue = validateInventoryRestockDraft(draft);
    if (issue != null) {
      setState(() {
        _formError = inventoryRestockIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }
}
