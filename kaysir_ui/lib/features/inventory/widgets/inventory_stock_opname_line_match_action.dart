import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_icon_action_button.dart';
import 'stock_opname_line_preview_data.dart';

/// Row action that reconciles a stock opname line with the system quantity.
///
/// The widget owns the small presentation decision around matched versus
/// actionable rows so worksheet row layouts can stay focused on structure.
class InventoryStockOpnameLineMatchAction extends StatelessWidget {
  const InventoryStockOpnameLineMatchAction({
    super.key,
    required this.productName,
    required this.hasVariance,
    this.onPressed,
  });

  final String productName;
  final bool hasVariance;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final effectivePressed = hasVariance ? onPressed : null;

    return AppIconActionButton(
      icon:
          hasVariance
              ? Icons.done_all_rounded
              : Icons.check_circle_outline_rounded,
      tooltip:
          hasVariance
              ? 'Match system count for $productName'
              : 'Already matches system count for $productName',
      variant: AppIconActionButtonVariant.outlined,
      onPressed: effectivePressed,
    );
  }
}

@Preview(name: 'Inventory stock opname line match action')
Widget inventoryStockOpnameLineMatchActionPreview() {
  return inventoryStockOpnameLinePreviewScaffold(
    Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        InventoryStockOpnameLineMatchAction(
          productName: 'Laptop',
          hasVariance: true,
          onPressed: () {},
        ),
        InventoryStockOpnameLineMatchAction(
          productName: 'Keyboard',
          hasVariance: false,
          onPressed: () {},
        ),
      ],
    ),
  );
}
