import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_filter_chip_group.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'stock_opname_worksheet_preview_data.dart';
import 'stock_opname_worksheet_toolbar_options.dart';

/// Filter chip group for stock opname worksheet row states.
class InventoryStockOpnameWorksheetFilterChips extends StatelessWidget {
  const InventoryStockOpnameWorksheetFilterChips({
    super.key,
    required this.value,
    required this.counts,
    required this.onChanged,
  });

  final InventoryStockOpnameWorksheetFilter value;
  final InventoryStockOpnameWorksheetFilterCounts counts;
  final ValueChanged<InventoryStockOpnameWorksheetFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipGroup<InventoryStockOpnameWorksheetFilter>(
      value: value,
      options: inventoryStockOpnameWorksheetFilterOptions(counts),
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet filter chips')
Widget inventoryStockOpnameWorksheetFilterChipsPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetFilterChips(
      value: InventoryStockOpnameWorksheetFilter.edited,
      counts: inventoryStockOpnameWorksheetPreviewCounts(),
      onChanged: (_) {},
    ),
  );
}
