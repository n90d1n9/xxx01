import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseCategoryMixPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseCategoryMixLine inventoryWarehouseCategoryMixPreviewLine([
  InventoryWarehouseDetail? detail,
]) {
  return preview.inventoryWarehouseCategoryMixPreviewLine(detail);
}

InventoryWarehouseDetail inventoryWarehouseCategoryMixPreviewDetail() {
  return preview.inventoryWarehouseStockPreviewDetail();
}
