import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_draft_status.dart';
import 'inventory_stock_opname_draft_status_details.dart';

/// Shared preview shell for stock opname draft status widgets.
Widget inventoryStockOpnameDraftStatusPreviewScaffold(Widget child) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      body: Padding(padding: const EdgeInsets.all(24), child: child),
    ),
  );
}

/// Representative stock opname draft state for widget previews.
InventoryStockOpnameDraftStatus inventoryStockOpnameDraftStatusPreviewStatus() {
  return const InventoryStockOpnameDraftStatus(
    changedLineCount: 3,
    invalidActualQuantityLineCount: 1,
  );
}

/// Representative draft status presentation details for widget previews.
InventoryStockOpnameDraftStatusDetails
inventoryStockOpnameDraftStatusPreviewDetails() {
  return inventoryStockOpnameDraftStatusDetails(
    inventoryStockOpnameDraftStatusPreviewStatus(),
  );
}
