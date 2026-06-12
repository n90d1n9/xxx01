import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';
import 'inventory_reset_filters_button.dart';

class InventoryStockListEmptyState extends StatelessWidget {
  const InventoryStockListEmptyState({super.key, this.onResetFilters});

  final VoidCallback? onResetFilters;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'No matching stock lines',
      message: 'Try a different warehouse, status, or search term.',
      icon: Icons.inventory_2_outlined,
      action:
          onResetFilters == null
              ? null
              : InventoryResetFiltersButton(onPressed: onResetFilters!),
    );
  }
}
