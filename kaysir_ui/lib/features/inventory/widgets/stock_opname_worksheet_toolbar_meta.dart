import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/inventory_stock_opname_worksheet_filter.dart';
import 'inventory_reset_filters_button.dart';
import 'stock_opname_worksheet_preview_data.dart';
import 'stock_opname_worksheet_toolbar_options.dart';

/// Result count and reset action for the stock opname worksheet toolbar.
class InventoryStockOpnameWorksheetToolbarMeta extends StatelessWidget {
  const InventoryStockOpnameWorksheetToolbarMeta({
    super.key,
    required this.counts,
    required this.hasActiveFilters,
    required this.onResetFilters,
  });

  final InventoryStockOpnameWorksheetFilterCounts counts;
  final bool hasActiveFilters;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            inventoryStockOpnameWorksheetResultLabel(counts),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(width: 8),
          InventoryResetFiltersButton(
            label: 'Clear',
            icon: Icons.filter_alt_off_rounded,
            onPressed: onResetFilters,
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Inventory stock opname worksheet toolbar meta')
Widget inventoryStockOpnameWorksheetToolbarMetaPreview() {
  return inventoryStockOpnameWorksheetPreviewScaffold(
    InventoryStockOpnameWorksheetToolbarMeta(
      counts: inventoryStockOpnameWorksheetPreviewCounts(),
      hasActiveFilters: true,
      onResetFilters: () {},
    ),
  );
}
