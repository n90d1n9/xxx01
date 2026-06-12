import 'package:flutter/material.dart';

import '../models/inventory_stock_opname_worksheet_filter.dart';

/// Presentation details for a stock opname worksheet empty state.
class InventoryStockOpnameWorksheetEmptyStateDetails {
  const InventoryStockOpnameWorksheetEmptyStateDetails({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}

/// Resolves the most helpful stock opname worksheet empty-state message.
InventoryStockOpnameWorksheetEmptyStateDetails
inventoryStockOpnameWorksheetEmptyStateDetails({
  required InventoryStockOpnameWorksheetFilterState filter,
  required int totalInventoryLines,
}) {
  if (filter.hasActiveFilters) {
    return const InventoryStockOpnameWorksheetEmptyStateDetails(
      title: 'No count lines match',
      message:
          'Clear filters or search another product to review the count sheet.',
      icon: Icons.filter_alt_off_rounded,
    );
  }

  if (totalInventoryLines == 0) {
    return const InventoryStockOpnameWorksheetEmptyStateDetails(
      title: 'No stock lines to count',
      message: 'Add stock lines before starting stock opname.',
      icon: Icons.fact_check_outlined,
    );
  }

  return const InventoryStockOpnameWorksheetEmptyStateDetails(
    title: 'No stock lines to count',
    message: 'Choose another warehouse to continue counting.',
    icon: Icons.fact_check_outlined,
  );
}
