import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_form_utils.dart';
import 'branch_form_preview_data.dart';
import 'inventory_form_fields.dart';

/// Branch contact fields for manager owner and operational contact.
class InventoryBranchContactFields extends StatelessWidget {
  const InventoryBranchContactFields({
    super.key,
    required this.managerController,
    required this.contactController,
    required this.onRequiredFieldChanged,
  });

  final TextEditingController managerController;
  final TextEditingController contactController;
  final VoidCallback onRequiredFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryFormTextField(
          controller: managerController,
          label: 'Manager',
          icon: Icons.manage_accounts_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter the branch manager',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: contactController,
          label: 'Contact',
          icon: Icons.alternate_email_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter a branch contact',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch contact fields')
Widget inventoryBranchContactFieldsPreview() {
  final controllers = inventoryBranchFormPreviewControllers();

  return inventoryBranchFormPreviewScaffold(
    InventoryBranchContactFields(
      managerController: controllers.managerController,
      contactController: controllers.contactController,
      onRequiredFieldChanged: () {},
    ),
  );
}
