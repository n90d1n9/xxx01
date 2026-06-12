import 'package:flutter/material.dart';

import '../../../widgets/ui/app_filter_chip_group.dart';
import '../models/inventory_stock_record.dart';
import 'inventory_stock_toolbar_state.dart';

class InventoryStockFilterChips extends StatelessWidget {
  const InventoryStockFilterChips({
    super.key,
    required this.value,
    required this.counts,
    required this.onChanged,
  });

  final InventoryStockFilter value;
  final InventoryStockToolbarCounts counts;
  final ValueChanged<InventoryStockFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppFilterChipGroup<InventoryStockFilter>(
      value: value,
      options: [
        AppFilterChipOption(
          value: InventoryStockFilter.all,
          label: 'All',
          icon: Icons.all_inclusive_rounded,
          count: counts.total,
        ),
        AppFilterChipOption(
          value: InventoryStockFilter.needsAttention,
          label: 'Attention',
          icon: Icons.warning_amber_rounded,
          count: counts.needsAttention,
        ),
        AppFilterChipOption(
          value: InventoryStockFilter.inStock,
          label: 'In stock',
          icon: Icons.check_circle_outline_rounded,
          count: counts.inStock,
        ),
      ],
      onChanged: onChanged,
    );
  }
}
