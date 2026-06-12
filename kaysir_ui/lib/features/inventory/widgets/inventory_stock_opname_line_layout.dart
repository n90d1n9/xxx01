import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'inventory_stock_opname_count_stepper.dart';
import 'inventory_stock_opname_line_identity.dart';
import 'inventory_stock_opname_line_match_action.dart';
import 'inventory_stock_opname_line_notes_field.dart';
import 'stock_opname_line_preview_data.dart';
import 'stock_opname_variance_pill.dart';

/// Responsive layout shell for a stock opname worksheet row.
///
/// Separates compact and wide row composition from the editable row state so
/// controller synchronization and visual layout can evolve independently.
class InventoryStockOpnameLineLayout extends StatelessWidget {
  const InventoryStockOpnameLineLayout({
    super.key,
    required this.identity,
    required this.actualField,
    required this.notesField,
    required this.variance,
    required this.action,
    this.compactBreakpoint = 860,
  });

  final Widget identity;
  final Widget actualField;
  final Widget notesField;
  final Widget variance;
  final Widget action;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [actualField, notesField, variance, action],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: identity),
            const SizedBox(width: 12),
            actualField,
            const SizedBox(width: 10),
            notesField,
            const SizedBox(width: 10),
            variance,
            const SizedBox(width: 8),
            action,
          ],
        );
      },
    );
  }
}

@Preview(name: 'Inventory stock opname line layout')
Widget inventoryStockOpnameLineLayoutPreview() {
  final line = inventoryStockOpnamePreviewLine();
  final actualController = TextEditingController(
    text: '${line.actualQuantity}',
  );
  final notesController = TextEditingController(text: line.notes);

  return inventoryStockOpnameLinePreviewScaffold(
    InventoryStockOpnameLineLayout(
      identity: InventoryStockOpnameLineIdentity(line: line),
      actualField: InventoryStockOpnameCountStepper(
        controller: actualController,
        value: line.actualQuantity,
        productName: line.productName,
        onChanged: (_) {},
      ),
      notesField: InventoryStockOpnameLineNotesField(
        controller: notesController,
        lineId: line.id,
        onChanged: (_) {},
      ),
      variance: InventoryStockOpnameVariancePill(line: line),
      action: InventoryStockOpnameLineMatchAction(
        productName: line.productName,
        hasVariance: line.discrepancy != 0,
        onPressed: () {},
      ),
    ),
  );
}
