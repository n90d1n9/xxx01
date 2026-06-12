import 'package:flutter/material.dart';

import '../../../widgets/ui/app_empty_state.dart';

class InventoryStockCreateEmptyState extends StatelessWidget {
  const InventoryStockCreateEmptyState({
    super.key,
    required this.hasProducts,
    required this.hasWarehouses,
  });

  final bool hasProducts;
  final bool hasWarehouses;

  @override
  Widget build(BuildContext context) {
    final message =
        !hasProducts
            ? 'Create a product before assigning warehouse stock.'
            : !hasWarehouses
            ? 'Create a warehouse before assigning product stock.'
            : 'Every product-location pair is already tracked.';

    return AppEmptyState(
      title: 'No stock line available',
      message: message,
      icon: Icons.inventory_2_outlined,
      action:
          hasProducts && hasWarehouses
              ? TextButton.icon(
                onPressed: Navigator.of(context).maybePop,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
              )
              : null,
    );
  }
}
