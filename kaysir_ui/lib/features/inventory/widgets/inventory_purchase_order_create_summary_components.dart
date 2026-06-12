import 'package:flutter/material.dart';

import '../../../widgets/ui/app_metric_grid.dart';
import '../models/inventory_purchase_order_create.dart';
import '../utils/inventory_formatters.dart';

class InventoryPurchaseOrderCreateSummaryGrid extends StatelessWidget {
  const InventoryPurchaseOrderCreateSummaryGrid({
    super.key,
    required this.draft,
  });

  final InventoryPurchaseOrderCreateDraft draft;

  @override
  Widget build(BuildContext context) {
    final issue = validateInventoryPurchaseOrderCreateDraft(draft);

    return AppMetricGrid(
      metrics: [
        AppMetricGridItem(
          title: 'Order Value',
          value: formatInventoryCurrency(draft.totalAmount),
          helper: issue == null ? 'Ready to create' : 'Draft in progress',
          icon: Icons.payments_rounded,
          accentColor:
              issue == null ? Colors.green.shade700 : Colors.indigo.shade700,
        ),
        AppMetricGridItem(
          title: 'Items',
          value: formatInventoryNumber(draft.itemCount),
          helper: '${formatInventoryNumber(draft.totalQuantity)} total units',
          icon: Icons.shopping_cart_rounded,
          accentColor:
              draft.itemCount == 0
                  ? Colors.orange.shade700
                  : Colors.blue.shade700,
        ),
        AppMetricGridItem(
          title: 'Supplier',
          value: draft.normalizedSupplierName.isEmpty ? 'Unset' : 'Set',
          helper:
              draft.normalizedSupplierName.isEmpty
                  ? 'Supplier required'
                  : draft.normalizedSupplierName,
          icon: Icons.business_rounded,
          accentColor:
              draft.normalizedSupplierName.isEmpty
                  ? Colors.orange.shade700
                  : Colors.teal.shade700,
        ),
        AppMetricGridItem(
          title: 'Delivery',
          value:
              draft.expectedDeliveryDate == null
                  ? 'Open'
                  : formatInventoryShortDate(draft.expectedDeliveryDate!),
          helper:
              draft.expectedDeliveryDate == null
                  ? 'No ETA selected'
                  : formatInventoryIsoDate(draft.expectedDeliveryDate!),
          icon: Icons.event_available_rounded,
          accentColor: Colors.purple.shade700,
        ),
      ],
    );
  }
}
