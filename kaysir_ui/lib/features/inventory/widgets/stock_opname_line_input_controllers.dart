import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_session.dart';

/// Text controller bundle for editable stock opname worksheet row inputs.
class InventoryStockOpnameLineInputControllers {
  InventoryStockOpnameLineInputControllers({
    required this.actualQuantityController,
    required this.notesController,
  });

  factory InventoryStockOpnameLineInputControllers.fromLine(
    InventoryStockOpnameLine line,
  ) {
    return InventoryStockOpnameLineInputControllers(
      actualQuantityController: TextEditingController(
        text: line.actualQuantity.toString(),
      ),
      notesController: TextEditingController(text: line.notes),
    );
  }

  final TextEditingController actualQuantityController;
  final TextEditingController notesController;

  void syncActualQuantityFromLine(InventoryStockOpnameLine line) {
    final nextText = line.actualQuantity.toString();
    if (actualQuantityController.text == nextText) return;
    _replaceControllerText(actualQuantityController, nextText);
  }

  void syncNotesFromLine(InventoryStockOpnameLine line) {
    if (notesController.text == line.notes) return;
    _replaceControllerText(notesController, line.notes);
  }

  void dispose() {
    actualQuantityController.dispose();
    notesController.dispose();
  }

  void _replaceControllerText(
    TextEditingController controller,
    String nextText,
  ) {
    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }
}
