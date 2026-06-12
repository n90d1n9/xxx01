import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'stock_opname_worksheet_preview_data.dart';
import 'stock_opname_worksheet_toolbar_options.dart';

/// Sort selector for the stock opname worksheet review toolbar.
class InventoryStockOpnameWorksheetSortField extends StatelessWidget {
  const InventoryStockOpnameWorksheetSortField({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 220,
  });

  final InventoryStockOpnameWorksheetSort value;
  final ValueChanged<InventoryStockOpnameWorksheetSort> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryStockOpnameWorksheetSort>(
      label: 'Sort rows',
      value: value,
      width: width,
      icon: Icons.sort_rounded,
      menuMaxHeight: 280,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      options: inventoryStockOpnameWorksheetSortOptions(),
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet sort field')
Widget inventoryStockOpnameWorksheetSortFieldPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetSortField(
      value: InventoryStockOpnameWorksheetSort.varianceMagnitude,
      onChanged: (_) {},
    ),
  );
}
