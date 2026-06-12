import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_form_utils.dart';
import 'branch_form_preview_data.dart';
import 'inventory_form_fields.dart';

/// Branch identity fields for name and city.
class InventoryBranchIdentityFields extends StatelessWidget {
  const InventoryBranchIdentityFields({
    super.key,
    required this.nameController,
    required this.cityController,
    required this.onRequiredFieldChanged,
  });

  final TextEditingController nameController;
  final TextEditingController cityController;
  final VoidCallback onRequiredFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryFormTextField(
          controller: nameController,
          label: 'Branch name',
          icon: Icons.account_tree_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter a branch name',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: cityController,
          label: 'City',
          icon: Icons.location_city_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter the branch city',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch identity fields')
Widget inventoryBranchIdentityFieldsPreview() {
  final controllers = inventoryBranchFormPreviewControllers();

  return inventoryBranchFormPreviewScaffold(
    InventoryBranchIdentityFields(
      nameController: controllers.nameController,
      cityController: controllers.cityController,
      onRequiredFieldChanged: () {},
    ),
  );
}
