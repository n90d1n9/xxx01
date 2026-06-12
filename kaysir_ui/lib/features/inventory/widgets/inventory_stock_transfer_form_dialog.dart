import 'package:flutter/material.dart';

import '../models/inventory_stock_record.dart';
import '../models/inventory_stock_transfer_draft.dart';
import '../models/warehouse.dart';
import 'inventory_dialog_content_layout.dart';
import 'inventory_stock_transfer_dialog_state.dart';
import 'inventory_stock_transfer_empty_state.dart';
import 'inventory_stock_transfer_form.dart';

/// Dialog for transferring product quantity between warehouse locations.
class InventoryStockTransferDialog extends StatefulWidget {
  const InventoryStockTransferDialog({
    super.key,
    required this.record,
    required this.warehouses,
    required this.existingRecords,
    required this.onSubmit,
    this.onCancel,
  });

  final InventoryStockRecord record;
  final List<Warehouse> warehouses;
  final List<InventoryStockRecord> existingRecords;
  final ValueChanged<InventoryStockTransferDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryStockTransferDialog> createState() =>
      _InventoryStockTransferDialogState();
}

class _InventoryStockTransferDialogState
    extends State<InventoryStockTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late final List<Warehouse> _destinationWarehouses;

  String? _selectedWarehouseId;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
    _destinationWarehouses = inventoryStockTransferDestinationWarehouses(
      record: widget.record,
      warehouses: widget.warehouses,
    );
    _selectedWarehouseId = initialInventoryStockTransferDestinationId(
      _destinationWarehouses,
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryDialogContentLayout(
      maxWidth: 680,
      maxHeight: 820,
      padding: const EdgeInsets.all(16),
      bodySpacing: 14,
      eyebrow: 'Warehouse Transfer',
      title: 'Transfer ${widget.record.productName}',
      subtitle:
          '${widget.record.skuLabel} | From ${widget.record.warehouseName} - ${widget.record.warehouseLocation}',
      closeTooltip: 'Close stock transfer',
      onClose: widget.onCancel,
      child:
          _destinationWarehouses.isEmpty
              ? const InventoryStockTransferEmptyState()
              : InventoryStockTransferForm(
                formKey: _formKey,
                selectedWarehouseId: _selectedWarehouseId!,
                destinationWarehouses: _destinationWarehouses,
                record: widget.record,
                destinationRecord: _destinationRecord,
                draft: _currentDraft(),
                quantityController: _quantityController,
                notesController: _notesController,
                formError: _formError,
                onDestinationChanged: _updateDestination,
                onQuantityChanged: _clearFormError,
                onCancel: widget.onCancel,
                onSubmit: _submit,
              ),
    );
  }

  InventoryStockRecord? get _destinationRecord {
    return inventoryStockTransferDestinationRecord(
      record: widget.record,
      destinationWarehouseId: _selectedWarehouseId,
      existingRecords: widget.existingRecords,
    );
  }

  InventoryStockTransferDraft? _currentDraft() {
    return inventoryStockTransferDraftFromInput(
      destinationWarehouseId: _selectedWarehouseId,
      quantityText: _quantityController.text,
      notes: _notesController.text,
    );
  }

  void _updateDestination(String value) {
    setState(() {
      _selectedWarehouseId = value;
      _formError = null;
    });
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

    final issue = validateInventoryStockTransferDraft(
      draft,
      currentQuantity: widget.record.quantity,
      sourceWarehouseId: widget.record.warehouse.id,
      warehouses: widget.warehouses,
    );
    if (issue != null) {
      setState(() {
        _formError = inventoryStockTransferIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }
}
