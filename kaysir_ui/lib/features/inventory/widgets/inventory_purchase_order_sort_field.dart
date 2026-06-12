import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../widgets/ui/app_select_field.dart';
import '../models/inventory_purchase_order_workspace.dart';

/// Sort selector for the purchase-order queue toolbar.
class InventoryPurchaseOrderSortField extends StatelessWidget {
  const InventoryPurchaseOrderSortField({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 220,
  });

  final InventoryPurchaseOrderSort value;
  final ValueChanged<InventoryPurchaseOrderSort> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return AppSelectField<InventoryPurchaseOrderSort>(
      label: 'Sort by',
      value: value,
      width: width,
      icon: Icons.sort_rounded,
      menuMaxHeight: 260,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      options: const [
        AppSelectOption(
          value: InventoryPurchaseOrderSort.urgency,
          label: 'Urgency',
        ),
        AppSelectOption(
          value: InventoryPurchaseOrderSort.expectedDate,
          label: 'Expected date',
        ),
        AppSelectOption(
          value: InventoryPurchaseOrderSort.newestOrder,
          label: 'Newest order',
        ),
        AppSelectOption(
          value: InventoryPurchaseOrderSort.valueHigh,
          label: 'Highest value',
        ),
        AppSelectOption(
          value: InventoryPurchaseOrderSort.supplierName,
          label: 'Supplier name',
        ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Purchase order sort field')
Widget inventoryPurchaseOrderSortFieldPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: InventoryPurchaseOrderSortField(
          value: InventoryPurchaseOrderSort.urgency,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}
