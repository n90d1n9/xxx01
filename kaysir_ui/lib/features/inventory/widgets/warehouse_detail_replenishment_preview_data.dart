import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseReplenishmentPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseDetail inventoryWarehouseReplenishmentPreviewDetail() {
  return preview.inventoryWarehouseStockPreviewDetail();
}
