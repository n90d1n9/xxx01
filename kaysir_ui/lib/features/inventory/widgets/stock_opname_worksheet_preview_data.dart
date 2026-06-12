import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_worksheet_filter.dart';

Widget inventoryStockOpnameWorksheetPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

TextEditingController inventoryStockOpnameWorksheetPreviewSearchController() {
  return TextEditingController(text: 'laptop');
}

InventoryStockOpnameWorksheetFilterState
inventoryStockOpnameWorksheetPreviewState() {
  return const InventoryStockOpnameWorksheetFilterState(
    query: 'laptop',
    filter: InventoryStockOpnameWorksheetFilter.edited,
    sort: InventoryStockOpnameWorksheetSort.varianceMagnitude,
  );
}

InventoryStockOpnameWorksheetFilterCounts
inventoryStockOpnameWorksheetPreviewCounts() {
  return const InventoryStockOpnameWorksheetFilterCounts(
    total: 24,
    edited: 3,
    invalid: 1,
    variance: 5,
    matched: 19,
    filtered: 2,
  );
}
