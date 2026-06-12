import 'package:flutter/material.dart';

import 'inventory_form_fields.dart';

class InventoryProductBulkGeneratedCodePrefixField extends StatelessWidget {
  const InventoryProductBulkGeneratedCodePrefixField({
    super.key,
    required this.controller,
    required this.label,
    required this.helperText,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String helperText;
  final IconData icon;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: label,
      helperText: helperText,
      icon: icon,
      textInputAction: TextInputAction.done,
      onChanged: (_) => onChanged(),
    );
  }
}
