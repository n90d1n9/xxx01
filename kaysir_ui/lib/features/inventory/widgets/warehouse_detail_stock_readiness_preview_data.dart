import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseStockReadinessPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseDetail inventoryWarehouseStockReadinessPreviewDetail() {
  return preview.inventoryWarehouseStockPreviewDetail();
}
