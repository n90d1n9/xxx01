import 'package:flutter/widgets.dart';

import '../models/inventory_warehouse_detail.dart';
import 'warehouse_detail_preview_data.dart' as preview;

Widget inventoryWarehouseOverviewPreviewScaffold(Widget child) {
  return preview.inventoryWarehouseDetailPreviewScaffold(child);
}

InventoryWarehouseDetail inventoryWarehouseOverviewPreviewDetail() {
  return preview.inventoryWarehouseStockPreviewDetail();
}
