import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_opname_session.dart';
import 'inventory_separated_list.dart';
import 'inventory_stock_opname_line_components.dart';
import 'stock_opname_line_preview_data.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Separated list of editable stock opname worksheet rows.
class InventoryStockOpnameWorksheetLineList extends StatelessWidget {
  const InventoryStockOpnameWorksheetLineList({
    super.key,
    required this.lines,
    this.onActualQuantityChanged,
    this.onNotesChanged,
    this.onMatchSystem,
    this.lineKeyBuilder,
  });

  final List<InventoryStockOpnameLine> lines;
  final void Function(InventoryStockOpnameLine line, String value)?
  onActualQuantityChanged;
  final void Function(InventoryStockOpnameLine line, String value)?
  onNotesChanged;
  final ValueChanged<InventoryStockOpnameLine>? onMatchSystem;
  final Key Function(InventoryStockOpnameLine line)? lineKeyBuilder;

  @override
  Widget build(BuildContext context) {
    return InventorySeparatedList<InventoryStockOpnameLine>(
      items: lines,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      itemBuilder: (context, line, index) {
        return InventoryStockOpnameLineTile(
          key: lineKeyBuilder?.call(line),
          line: line,
          onActualQuantityChanged:
              onActualQuantityChanged == null
                  ? null
                  : (value) => onActualQuantityChanged!(line, value),
          onNotesChanged:
              onNotesChanged == null
                  ? null
                  : (value) => onNotesChanged!(line, value),
          onMatchSystem:
              onMatchSystem == null ? null : () => onMatchSystem!(line),
        );
      },
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet line list')
Widget inventoryStockOpnameWorksheetLineListPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetLineList(
      lines: [
        inventoryStockOpnamePreviewLine(),
        inventoryStockOpnamePreviewLine(id: 'i2', actualQuantity: 5, notes: ''),
      ],
      onActualQuantityChanged: (_, _) {},
      onNotesChanged: (_, _) {},
      onMatchSystem: (_) {},
    ),
  );
}
