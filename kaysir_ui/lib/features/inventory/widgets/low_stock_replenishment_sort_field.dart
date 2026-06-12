import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_replenishment_plan.dart';
import 'low_stock_replenishment_preview_data.dart';

/// Sort selector for the low-stock replenishment queue.
class LowStockReplenishmentSortField extends StatelessWidget {
  const LowStockReplenishmentSortField({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 240,
  });

  final InventoryReplenishmentPlanSort value;
  final ValueChanged<InventoryReplenishmentPlanSort> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryReplenishmentPlanSort>(
      label: 'Sort by',
      value: value,
      width: width,
      icon: Icons.sort_rounded,
      menuMaxHeight: 260,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      options: const [
        AppSelectOption(
          value: InventoryReplenishmentPlanSort.priority,
          label: 'Priority',
        ),
        AppSelectOption(
          value: InventoryReplenishmentPlanSort.estimatedCost,
          label: 'Estimated cost',
        ),
        AppSelectOption(
          value: InventoryReplenishmentPlanSort.suggestedQuantity,
          label: 'Suggested units',
        ),
        AppSelectOption(
          value: InventoryReplenishmentPlanSort.productName,
          label: 'Product name',
        ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Low stock replenishment sort field')
Widget lowStockReplenishmentSortFieldPreview() {
  return lowStockReplenishmentPreviewScaffold(
    LowStockReplenishmentSortField(
      value: InventoryReplenishmentPlanSort.priority,
      onChanged: (_) {},
    ),
  );
}
