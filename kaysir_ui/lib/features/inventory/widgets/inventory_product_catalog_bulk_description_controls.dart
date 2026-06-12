import 'package:flutter/material.dart';

import '../models/inventory_product_bulk_description_fill.dart';
import 'inventory_form_fields.dart';

class InventoryProductBulkDescriptionTemplateField extends StatelessWidget {
  const InventoryProductBulkDescriptionTemplateField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InventoryFormTextField(
      controller: controller,
      label: 'Description template',
      helperText: 'Tokens: {name}, {sku}, {category}, {price}, {scanCode}',
      icon: Icons.notes_rounded,
      alignLabelWithHint: true,
      keyboardType: TextInputType.multiline,
      maxLines: 3,
      onChanged: (_) => onChanged(),
      textCapitalization: TextCapitalization.sentences,
      validator: validateInventoryProductBulkDescriptionTemplate,
    );
  }
}
