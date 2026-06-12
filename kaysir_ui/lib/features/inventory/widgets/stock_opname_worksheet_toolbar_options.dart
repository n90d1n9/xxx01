import 'package:flutter/material.dart';

import '../../../widgets/ui/app_filter_chip_group.dart';
import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_stock_opname_worksheet_filter.dart';

/// Builds the stock opname worksheet filter chip options with live row counts.
List<AppFilterChipOption<InventoryStockOpnameWorksheetFilter>>
inventoryStockOpnameWorksheetFilterOptions(
  InventoryStockOpnameWorksheetFilterCounts counts,
) {
  return [
    AppFilterChipOption(
      value: InventoryStockOpnameWorksheetFilter.all,
      label: 'All',
      icon: Icons.all_inclusive_rounded,
      count: counts.total,
    ),
    AppFilterChipOption(
      value: InventoryStockOpnameWorksheetFilter.edited,
      label: 'Edited',
      icon: Icons.mode_edit_outline_rounded,
      count: counts.edited,
    ),
    AppFilterChipOption(
      value: InventoryStockOpnameWorksheetFilter.invalid,
      label: 'Invalid',
      icon: Icons.error_outline_rounded,
      count: counts.invalid,
    ),
    AppFilterChipOption(
      value: InventoryStockOpnameWorksheetFilter.variance,
      label: 'Variance',
      icon: Icons.warning_amber_rounded,
      count: counts.variance,
    ),
    AppFilterChipOption(
      value: InventoryStockOpnameWorksheetFilter.matched,
      label: 'Matched',
      icon: Icons.check_circle_outline_rounded,
      count: counts.matched,
    ),
  ];
}

/// Builds the stock opname worksheet sort menu options in display order.
List<AppSelectOption<InventoryStockOpnameWorksheetSort>>
inventoryStockOpnameWorksheetSortOptions() {
  return [
    for (final sort in InventoryStockOpnameWorksheetSort.values)
      AppSelectOption(
        value: sort,
        label: inventoryStockOpnameWorksheetSortLabel(sort),
      ),
  ];
}

/// Formats the visible and total stock opname worksheet row count label.
String inventoryStockOpnameWorksheetResultLabel(
  InventoryStockOpnameWorksheetFilterCounts counts,
) {
  final lineLabel = counts.total == 1 ? 'line' : 'lines';

  return '${counts.filtered} of ${counts.total} $lineLabel';
}
