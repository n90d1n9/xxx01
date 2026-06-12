import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import '../models/inventory_warehouse_draft.dart';
import '../models/warehouse.dart';
import 'inventory_dialog_form_layout.dart';
import 'inventory_warehouse_form_fields.dart';
import 'warehouse_form_controller_bundle.dart';
import 'warehouse_form_preview_data.dart';

/// Dialog for creating or editing a warehouse location and capacity record.
class InventoryWarehouseDialog extends StatefulWidget {
  const InventoryWarehouseDialog({
    super.key,
    required this.onSubmit,
    this.branches = const [],
    this.warehouse,
    this.onCancel,
  });

  final List<InventoryBranch> branches;
  final Warehouse? warehouse;
  final ValueChanged<InventoryWarehouseDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryWarehouseDialog> createState() =>
      _InventoryWarehouseDialogState();
}

/// State holder that wires warehouse form controllers to validation and submit.
class _InventoryWarehouseDialogState extends State<InventoryWarehouseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final InventoryWarehouseFormControllerBundle _controllers;
  String? _formError;

  bool get _isEditing => widget.warehouse != null;

  @override
  void initState() {
    super.initState();
    _controllers = InventoryWarehouseFormControllerBundle.fromWarehouse(
      branches: widget.branches,
      warehouse: widget.warehouse,
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryDialogFormLayout(
      formKey: _formKey,
      maxWidth: 640,
      maxHeight: 820,
      eyebrow: 'Warehouse Directory',
      title: _isEditing ? 'Edit Warehouse' : 'Add Warehouse',
      subtitle:
          _isEditing
              ? 'Update location, capacity, and notes'
              : 'Create a storage location for stock operations',
      closeTooltip: 'Close warehouse dialog',
      onCancel: widget.onCancel,
      formError: _formError,
      confirmLabel: _isEditing ? 'Update warehouse' : 'Add warehouse',
      confirmIcon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
      onConfirm: _submit,
      children: [
        InventoryWarehouseFormFields(
          nameController: _controllers.nameController,
          branchController: _controllers.branchController,
          locationController: _controllers.locationController,
          capacityController: _controllers.capacityController,
          descriptionController: _controllers.descriptionController,
          branches: widget.branches,
          selectedBranchId: _controllers.selectedBranchId,
          onTextChanged: _clearFormError,
          onBranchChanged: _updateSelectedBranch,
        ),
      ],
    );
  }

  void _clearFormError([String? _]) {
    if (_formError == null) return;
    setState(() {
      _formError = null;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _controllers.toDraft(
      usesBranchDirectory: widget.branches.isNotEmpty,
    );
    final issue = validateInventoryWarehouseDraft(draft);
    if (issue != null) {
      setState(() {
        _formError = inventoryWarehouseIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }

  void _updateSelectedBranch(String branchId) {
    setState(() {
      _controllers.selectBranch(branchId, widget.branches);
      _formError = null;
    });
  }
}

@Preview(name: 'Warehouse form dialog')
Widget inventoryWarehouseDialogPreview() {
  return inventoryWarehouseFormPreviewScaffold(
    InventoryWarehouseDialog(
      branches: inventoryWarehouseFormPreviewBranches(),
      warehouse: inventoryWarehouseFormPreviewWarehouse(),
      onSubmit: (_) {},
    ),
  );
}
