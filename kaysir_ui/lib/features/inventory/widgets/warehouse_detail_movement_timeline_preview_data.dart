import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseMovementTimelinePreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseDetail inventoryWarehouseMovementTimelinePreviewDetail() {
  return preview.inventoryWarehouseMovementPreviewDetail();
}
