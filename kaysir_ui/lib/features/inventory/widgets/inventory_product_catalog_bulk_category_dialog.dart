import 'package:flutter/material.dart';

import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';
import 'inventory_product_bulk_mutation_dialog_layout.dart';

/// Dialog for applying one category to the selected catalog products.
class InventoryProductBulkCategoryDialog extends StatefulWidget {
  const InventoryProductBulkCategoryDialog({
    super.key,
    required this.selectedCount,
    required this.onSubmit,
    this.onCancel,
  });

  final int selectedCount;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<InventoryProductBulkCategoryDialog> createState() =>
      _InventoryProductBulkCategoryDialogState();
}

class _InventoryProductBulkCategoryDialogState
    extends State<InventoryProductBulkCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryProductBulkMutationDialogLayout(
      maxWidth: 520,
      formKey: _formKey,
      eyebrow: 'Bulk Edit',
      title: 'Change category',
      subtitle:
          'Apply one category to ${widget.selectedCount} selected products.',
      closeTooltip: 'Close bulk category dialog',
      statusLabel: '${widget.selectedCount} selected',
      statusIcon: Icons.library_add_check_rounded,
      statusMaxWidth: 150,
      confirmLabel: 'Apply category',
      confirmIcon: Icons.check_rounded,
      onCancel: widget.onCancel,
      onConfirm: _submit,
      children: [
        InventoryFormTextField(
          controller: _categoryController,
          label: 'Category',
          icon: Icons.category_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: inventoryProductCategoryRequiredError,
              ),
        ),
      ],
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_categoryController.text.trim());
  }
}
