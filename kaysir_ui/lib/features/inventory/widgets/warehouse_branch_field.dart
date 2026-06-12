import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_branch.dart';
import '../utils/inventory_form_utils.dart';
import 'inventory_form_fields.dart';
import 'warehouse_form_preview_data.dart';

/// Branch input for warehouse forms, switching between text and directory select.
class InventoryWarehouseBranchField extends StatelessWidget {
  const InventoryWarehouseBranchField({
    super.key,
    required this.controller,
    required this.branches,
    required this.selectedBranchId,
    required this.onTextChanged,
    required this.onBranchChanged,
  });

  final TextEditingController controller;
  final List<InventoryBranch> branches;
  final String? selectedBranchId;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onBranchChanged;

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) {
      return InventoryFormTextField(
        controller: controller,
        label: 'Branch',
        icon: Icons.account_tree_rounded,
        validator:
            (value) => validateInventoryRequiredText(
              value,
              errorMessage: inventoryWarehouseBranchRequiredError,
            ),
        onChanged: onTextChanged,
      );
    }

    return AppSelectField<String>(
      label: 'Branch',
      icon: Icons.account_tree_rounded,
      value: selectedBranchId ?? branches.first.id,
      options: [
        for (final branch in branches)
          AppSelectOption(value: branch.id, label: branch.nameLabel),
      ],
      onChanged: onBranchChanged,
    );
  }
}

@Preview(name: 'Warehouse branch field')
Widget inventoryWarehouseBranchFieldPreview() {
  final controller = TextEditingController(text: 'Jakarta Central');
  final branches = inventoryWarehouseFormPreviewBranches();

  return inventoryWarehouseFormPreviewScaffold(
    InventoryWarehouseBranchField(
      controller: controller,
      branches: branches,
      selectedBranchId: branches.first.id,
      onTextChanged: (_) {},
      onBranchChanged: (_) {},
    ),
  );
}
