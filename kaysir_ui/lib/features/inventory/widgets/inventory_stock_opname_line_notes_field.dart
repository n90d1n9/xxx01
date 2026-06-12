import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_form_fields.dart';
import 'stock_opname_line_preview_data.dart';

/// Compact notes field for a stock opname worksheet row.
///
/// The widget wraps the shared inventory text field with stable sizing and
/// keys so worksheet rows can compose notes input without owning field chrome.
class InventoryStockOpnameLineNotesField extends StatelessWidget {
  const InventoryStockOpnameLineNotesField({
    super.key,
    required this.controller,
    required this.lineId,
    this.onChanged,
    this.width = 220,
  });

  final TextEditingController controller;
  final String lineId;
  final ValueChanged<String>? onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InventoryFormTextField(
        key: ValueKey('stock-opname-notes-$lineId'),
        controller: controller,
        isDense: true,
        label: 'Notes',
        onChanged: onChanged,
      ),
    );
  }
}

@Preview(name: 'Inventory stock opname line notes field')
Widget inventoryStockOpnameLineNotesFieldPreview() {
  final controller = TextEditingController(text: 'Shelf recount');

  return inventoryStockOpnameLinePreviewScaffold(
    InventoryStockOpnameLineNotesField(
      controller: controller,
      lineId: 'i1',
      onChanged: (_) {},
    ),
  );
}
