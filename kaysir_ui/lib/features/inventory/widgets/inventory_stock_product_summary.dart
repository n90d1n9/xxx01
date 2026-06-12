import 'package:flutter/material.dart';

import '../../../widgets/ui/app_info_row.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_list_item_state.dart';

class InventoryStockProductSummary extends StatelessWidget {
  const InventoryStockProductSummary({super.key, required this.record});

  final InventoryStockRecord record;

  @override
  Widget build(BuildContext context) {
    return AppInfoRow(
      icon: Icons.inventory_2_rounded,
      iconStyle: AppInfoRowIconStyle.badge,
      title: record.productName,
      subtitle: inventoryStockProductSummarySubtitle(record),
      titleMaxLines: 2,
      subtitleMaxLines: 2,
      padding: EdgeInsets.zero,
    );
  }
}
