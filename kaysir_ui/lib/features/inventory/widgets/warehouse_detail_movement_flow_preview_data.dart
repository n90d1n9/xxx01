import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseMovementFlowPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseMovementFlowLine inventoryWarehouseMovementFlowPreviewLine(
  InventoryWarehouseDetail detail,
) {
  return preview.inventoryWarehouseMovementFlowPreviewLine(detail);
}

InventoryWarehouseDetail inventoryWarehouseMovementFlowPreviewDetail() {
  return preview.inventoryWarehouseMovementPreviewDetail();
}
