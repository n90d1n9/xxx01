import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../utils/inventory_form_utils.dart';
import 'branch_form_preview_data.dart';
import 'inventory_form_fields.dart';

/// Branch governance text fields for code, region, entity, and headcount.
class InventoryBranchGovernanceTextFields extends StatelessWidget {
  const InventoryBranchGovernanceTextFields({
    super.key,
    required this.codeController,
    required this.regionController,
    required this.legalEntityController,
    required this.employeeCountController,
    required this.onRequiredFieldChanged,
  });

  final TextEditingController codeController;
  final TextEditingController regionController;
  final TextEditingController legalEntityController;
  final TextEditingController employeeCountController;
  final VoidCallback onRequiredFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryFormTextField(
          controller: codeController,
          label: 'Branch code',
          icon: Icons.tag_rounded,
          textCapitalization: TextCapitalization.characters,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter a branch code',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: regionController,
          label: 'Region',
          icon: Icons.map_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter the company region',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: legalEntityController,
          label: 'Legal entity',
          icon: Icons.account_balance_rounded,
          validator:
              (value) => validateInventoryRequiredText(
                value,
                errorMessage: 'Enter the legal entity',
              ),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
        const SizedBox(height: 12),
        InventoryFormTextField(
          controller: employeeCountController,
          label: 'Employee count',
          icon: Icons.groups_rounded,
          keyboardType: TextInputType.number,
          validator:
              (value) => validateInventoryWholeNumber(value, allowZero: true),
          onChanged: (_) => onRequiredFieldChanged(),
        ),
      ],
    );
  }
}

@Preview(name: 'Inventory branch governance text fields')
Widget inventoryBranchGovernanceTextFieldsPreview() {
  final controllers = inventoryBranchFormPreviewControllers();

  return inventoryBranchFormPreviewScaffold(
    InventoryBranchGovernanceTextFields(
      codeController: controllers.codeController,
      regionController: controllers.regionController,
      legalEntityController: controllers.legalEntityController,
      employeeCountController: controllers.employeeCountController,
      onRequiredFieldChanged: () {},
    ),
  );
}
