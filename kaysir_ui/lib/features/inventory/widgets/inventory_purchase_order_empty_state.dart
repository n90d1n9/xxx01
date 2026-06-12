import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_empty_state.dart';

/// Recovery-focused empty state for purchase-order queue results.
class InventoryPurchaseOrderEmptyState extends StatelessWidget {
  const InventoryPurchaseOrderEmptyState({
    super.key,
    required this.hasActiveFilters,
    this.onClearFilters,
    this.onCreateOrder,
  });

  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title:
          hasActiveFilters
              ? 'No purchase orders match these filters'
              : 'No purchase orders yet',
      message:
          hasActiveFilters
              ? 'Clear the current search or status filter to return to the full queue.'
              : 'Create the first purchase order to start tracking supplier commitments.',
      icon:
          hasActiveFilters
              ? Icons.filter_alt_off_outlined
              : Icons.receipt_long_outlined,
      action: _buildAction(),
    );
  }

  Widget? _buildAction() {
    if (hasActiveFilters && onClearFilters != null) {
      return FilledButton.icon(
        onPressed: onClearFilters,
        icon: const Icon(Icons.filter_alt_off_outlined),
        label: const Text('Reset filters'),
      );
    }

    if (!hasActiveFilters && onCreateOrder != null) {
      return FilledButton.icon(
        onPressed: onCreateOrder,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Create purchase order'),
      );
    }

    return null;
  }
}

@Preview(name: 'Purchase order filtered empty state')
Widget inventoryPurchaseOrderFilteredEmptyStatePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: InventoryPurchaseOrderEmptyState(
        hasActiveFilters: true,
        onClearFilters: () {},
      ),
    ),
  );
}
