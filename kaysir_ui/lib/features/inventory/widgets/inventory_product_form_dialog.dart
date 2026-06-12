import 'package:flutter/material.dart';

import '../../product/models/product.dart';
import '../models/inventory_product_draft.dart';
import 'inventory_dialog_form_layout.dart';
import 'inventory_product_commercial_fields.dart';
import 'inventory_product_dialog_focus.dart';
import 'inventory_product_dialog_form_controller.dart';
import 'inventory_product_identity_fields.dart';
import 'inventory_product_scan_code_fields.dart';

class InventoryProductDialog extends StatefulWidget {
  const InventoryProductDialog({
    super.key,
    required this.onSubmit,
    this.product,
    this.onCancel,
    this.initialFocusTarget,
  });

  final Product? product;
  final ValueChanged<InventoryProductDraft> onSubmit;
  final VoidCallback? onCancel;
  final InventoryProductDialogFocusTarget? initialFocusTarget;

  @override
  State<InventoryProductDialog> createState() => _InventoryProductDialogState();
}

class _InventoryProductDialogState extends State<InventoryProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final InventoryProductDialogFormController _formController;
  String? _formError;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _formController = InventoryProductDialogFormController.fromProduct(
      widget.product,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final focusNode = _formController.focusNodeFor(widget.initialFocusTarget);
      if (focusNode != null) {
        focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryDialogFormLayout(
      formKey: _formKey,
      maxWidth: 640,
      maxHeight: 760,
      eyebrow: 'Inventory Catalog',
      title: _isEditing ? 'Edit Product' : 'Add Product',
      subtitle:
          _isEditing
              ? 'Update product identity, categorization, and pricing.'
              : 'Create a reusable product record for stock operations.',
      subtitleMaxLines: 3,
      closeTooltip: 'Close product dialog',
      onCancel: widget.onCancel,
      formError: _formError,
      confirmLabel: _isEditing ? 'Update product' : 'Add product',
      confirmIcon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
      onConfirm: _submit,
      children: [
        InventoryProductIdentityFields(
          nameController: _formController.nameController,
          skuController: _formController.skuController,
          categoryController: _formController.categoryController,
          nameFocusNode: _formController.nameFocusNode,
          skuFocusNode: _formController.skuFocusNode,
          categoryFocusNode: _formController.categoryFocusNode,
          onChanged: _clearFormError,
        ),
        const SizedBox(height: 12),
        InventoryProductCommercialFields(
          priceController: _formController.priceController,
          descriptionController: _formController.descriptionController,
          priceFocusNode: _formController.priceFocusNode,
          descriptionFocusNode: _formController.descriptionFocusNode,
          onChanged: _clearFormError,
        ),
        const SizedBox(height: 12),
        InventoryProductScanCodeFields(
          barcodeController: _formController.barcodeController,
          shortcutKeyController: _formController.shortcutKeyController,
          barcodeFocusNode: _formController.barcodeFocusNode,
          shortcutKeyFocusNode: _formController.shortcutKeyFocusNode,
          onChanged: _clearFormError,
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

  InventoryProductDraft _draft() {
    return _formController.draft();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = _draft();
    final issue = validateInventoryProductDraft(draft);
    if (issue != null) {
      setState(() {
        _formError = inventoryProductDraftIssueLabel(issue);
      });
      return;
    }

    widget.onSubmit(draft);
  }
}
