import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'stock_opname_worksheet_empty_state_details.dart';
import 'stock_opname_worksheet_preview_data.dart';

/// Empty-state messaging for stock opname worksheet visibility.
class InventoryStockOpnameWorksheetEmptyState extends StatelessWidget {
  const InventoryStockOpnameWorksheetEmptyState({
    super.key,
    required this.filter,
    required this.totalInventoryLines,
  });

  final InventoryStockOpnameWorksheetFilterState filter;
  final int totalInventoryLines;

  @override
  Widget build(BuildContext context) {
    final details = inventoryStockOpnameWorksheetEmptyStateDetails(
      filter: filter,
      totalInventoryLines: totalInventoryLines,
    );

    return AppEmptyState(
      title: details.title,
      message: details.message,
      icon: details.icon,
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet empty state')
Widget inventoryStockOpnameWorksheetEmptyStatePreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    const InventoryStockOpnameWorksheetEmptyState(
      filter: InventoryStockOpnameWorksheetFilterState(
        query: 'missing',
        filter: InventoryStockOpnameWorksheetFilter.variance,
      ),
      totalInventoryLines: 12,
    ),
  );
}
