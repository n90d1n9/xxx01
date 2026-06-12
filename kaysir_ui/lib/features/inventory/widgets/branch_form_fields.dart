import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'branch_form_contact_fields.dart';
import 'branch_form_governance_text_fields.dart';
import 'branch_form_identity_fields.dart';
import 'branch_form_notes_field.dart';
import 'branch_form_preview_data.dart';

/// Complete branch text-field stack for identity, contact, governance, and notes.
class InventoryBranchFormFields extends StatelessWidget {
  const InventoryBranchFormFields({
    super.key,
    required this.nameController,
    required this.cityController,
    required this.managerController,
    required this.contactController,
    required this.codeController,
    required this.regionController,
    required this.legalEntityController,
    required this.employeeCountController,
    required this.notesController,
    required this.onRequiredFieldChanged,
  });

  final TextEditingController nameController;
  final TextEditingController cityController;
  final TextEditingController managerController;
  final TextEditingController contactController;
  final TextEditingController codeController;
  final TextEditingController regionController;
  final TextEditingController legalEntityController;
  final TextEditingController employeeCountController;
  final TextEditingController notesController;
  final VoidCallback onRequiredFieldChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InventoryBranchIdentityFields(
          nameController: nameController,
          cityController: cityController,
          onRequiredFieldChanged: onRequiredFieldChanged,
        ),
        const SizedBox(height: 12),
        InventoryBranchContactFields(
          managerController: managerController,
          contactController: contactController,
          onRequiredFieldChanged: onRequiredFieldChanged,
        ),
        const SizedBox(height: 12),
        InventoryBranchGovernanceTextFields(
          codeController: codeController,
          regionController: regionController,
          legalEntityController: legalEntityController,
          employeeCountController: employeeCountController,
          onRequiredFieldChanged: onRequiredFieldChanged,
        ),
        const SizedBox(height: 12),
        InventoryBranchNotesField(notesController: notesController),
      ],
    );
  }
}

@Preview(name: 'Inventory branch form fields')
Widget inventoryBranchFormFieldsPreview() {
  final controllers = inventoryBranchFormPreviewControllers();

  return inventoryBranchFormPreviewScaffold(
    InventoryBranchFormFields(
      nameController: controllers.nameController,
      cityController: controllers.cityController,
      managerController: controllers.managerController,
      contactController: controllers.contactController,
      codeController: controllers.codeController,
      regionController: controllers.regionController,
      legalEntityController: controllers.legalEntityController,
      employeeCountController: controllers.employeeCountController,
      notesController: controllers.notesController,
      onRequiredFieldChanged: () {},
    ),
  );
}
