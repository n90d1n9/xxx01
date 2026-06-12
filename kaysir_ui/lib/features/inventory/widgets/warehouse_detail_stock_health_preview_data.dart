import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseStockHealthPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseDetail inventoryWarehouseStockHealthPreviewDetail() {
  return preview.inventoryWarehouseStockPreviewDetail();
}
