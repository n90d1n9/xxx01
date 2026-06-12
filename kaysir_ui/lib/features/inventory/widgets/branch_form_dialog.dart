import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_branch.dart';
import '../models/inventory_branch_draft.dart';
import 'branch_form_controller_bundle.dart';
import 'branch_preview_data.dart';
import 'inventory_branch_form_fields.dart';
import 'inventory_branch_governance_fields.dart';
import 'inventory_dialog_form_layout.dart';

/// Dialog for creating or editing a branch governance and contact record.
class InventoryBranchDialog extends StatefulWidget {
  const InventoryBranchDialog({
    super.key,
    required this.onSubmit,
    this.branch,
    this.onCancel,
  });

  final InventoryBranch? branch;
  final ValueChanged<InventoryBranchDraft> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryBranchDialog> createState() => _InventoryBranchDialogState();
}

/// State holder that wires branch form controllers to validation and submit.
class _InventoryBranchDialogState extends State<InventoryBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  late final InventoryBranchFormControllerBundle _controllers;
  String? _formError;

  bool get _isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();
    _controllers = InventoryBranchFormControllerBundle.fromBranch(
      widget.branch,
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
      eyebrow: 'Branch Directory',
      title: _isEditing ? 'Edit Branch' : 'Add Branch',
      subtitle:
          _isEditing
              ? 'Update ownership, governance, contact, and status'
              : 'Create a company branch for governance and warehouse assignment',
      closeTooltip: 'Close branch dialog',
      onCancel: widget.onCancel,
      formError: _formError,
      confirmLabel: _isEditing ? 'Update branch' : 'Add branch',
      confirmIcon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
      onConfirm: _submit,
      children: [
        InventoryBranchFormFields(
          nameController: _controllers.nameController,
          cityController: _controllers.cityController,
          managerController: _controllers.managerController,
          contactController: _controllers.contactController,
          codeController: _controllers.codeController,
          regionController: _controllers.regionController,
          legalEntityController: _controllers.legalEntityController,
          employeeCountController: _controllers.employeeCountController,
          notesController: _controllers.notesController,
          onRequiredFieldChanged: _clearFormError,
        ),
        const SizedBox(height: 12),
        InventoryBranchGovernanceFields(
          type: _controllers.type,
          complianceTier: _controllers.complianceTier,
          status: _controllers.status,
          onTypeChanged: _updateType,
          onComplianceTierChanged: _updateComplianceTier,
          onStatusChanged: _updateStatus,
        ),
      ],
    );
  }

  void _clearFormError() {
    if (_formError == null) return;
    setState(() {
      _formError = null;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _controllers.toDraft();
    final issue = validateInventoryBranchDraft(draft);
    if (issue != null) {
      setState(() {
        _formError = inventoryBranchIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }

  void _updateType(InventoryBranchType type) {
    setState(() {
      _controllers.type = type;
      _formError = null;
    });
  }

  void _updateComplianceTier(InventoryBranchComplianceTier tier) {
    setState(() {
      _controllers.complianceTier = tier;
      _formError = null;
    });
  }

  void _updateStatus(InventoryBranchStatus status) {
    setState(() {
      _controllers.status = status;
      _formError = null;
    });
  }
}

@Preview(name: 'Inventory branch form dialog')
Widget inventoryBranchDialogPreview() {
  return inventoryBranchPreviewScaffold(
    InventoryBranchDialog(
      branch: inventoryBranchPreviewBranch(),
      onSubmit: (_) {},
    ),
  );
}
