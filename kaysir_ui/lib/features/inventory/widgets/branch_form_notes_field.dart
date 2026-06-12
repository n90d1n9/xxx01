import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'branch_form_preview_data.dart';
import 'inventory_form_fields.dart';

/// Optional branch note field for operational context.
class InventoryBranchNotesField extends StatelessWidget {
  const InventoryBranchNotesField({super.key, required this.notesController});

  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: notesController,
      label: 'Notes',
      icon: Icons.notes_rounded,
      maxLines: 3,
    );
  }
}

@Preview(name: 'Inventory branch notes field')
Widget inventoryBranchNotesFieldPreview() {
  final controllers = inventoryBranchFormPreviewControllers();

  return inventoryBranchFormPreviewScaffold(
    InventoryBranchNotesField(notesController: controllers.notesController),
  );
}
