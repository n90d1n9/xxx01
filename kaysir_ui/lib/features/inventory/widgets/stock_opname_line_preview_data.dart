import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_session.dart';

Widget inventoryStockOpnameLinePreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

InventoryStockOpnameLine inventoryStockOpnamePreviewLine({
  String id = 'i1',
  int systemQuantity = 5,
  int actualQuantity = 7,
  String notes = 'Shelf recount',
}) {
  return InventoryStockOpnameLine(
    id: id,
    inventoryItemId: id,
    productId: 'p1',
    productName: 'Laptop',
    skuLabel: 'LT-001',
    systemQuantity: systemQuantity,
    actualQuantity: actualQuantity,
    notes: notes,
  );
}
