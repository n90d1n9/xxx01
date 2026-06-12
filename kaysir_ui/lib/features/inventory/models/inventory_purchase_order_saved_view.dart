import 'inventory_purchase_order_workspace.dart';

/// Reusable preset for purchase-order queue controls.
class InventoryPurchaseOrderSavedView {
  const InventoryPurchaseOrderSavedView({
    required this.id,
    required this.label,
    required this.description,
    this.query = '',
    this.filter = InventoryPurchaseOrderFilter.all,
    this.sort = InventoryPurchaseOrderSort.urgency,
  });

  final String id;
  final String label;
  final String description;
  final String query;
  final InventoryPurchaseOrderFilter filter;
  final InventoryPurchaseOrderSort sort;

  bool matches({
    required String query,
    required InventoryPurchaseOrderFilter filter,
    required InventoryPurchaseOrderSort sort,
  }) {
    return this.query.trim() == query.trim() &&
        this.filter == filter &&
        this.sort == sort;
  }
}

const inventoryPurchaseOrderSavedViews = <InventoryPurchaseOrderSavedView>[
  InventoryPurchaseOrderSavedView(
    id: 'receiving-now',
    label: 'Receiving now',
    description: 'Orders that still need warehouse receipt',
    filter: InventoryPurchaseOrderFilter.needsReceiving,
    sort: InventoryPurchaseOrderSort.expectedDate,
  ),
  InventoryPurchaseOrderSavedView(
    id: 'highest-value',
    label: 'Highest value',
    description: 'Largest supplier commitments first',
    sort: InventoryPurchaseOrderSort.valueHigh,
  ),
  InventoryPurchaseOrderSavedView(
    id: 'overdue-first',
    label: 'Overdue first',
    description: 'Only overdue receiving commitments',
    filter: InventoryPurchaseOrderFilter.overdue,
    sort: InventoryPurchaseOrderSort.urgency,
  ),
  InventoryPurchaseOrderSavedView(
    id: 'recently-ordered',
    label: 'Recently ordered',
    description: 'Newest purchase orders first',
    sort: InventoryPurchaseOrderSort.newestOrder,
  ),
];

InventoryPurchaseOrderSavedView? matchingInventoryPurchaseOrderSavedView({
  required String query,
  required InventoryPurchaseOrderFilter filter,
  required InventoryPurchaseOrderSort sort,
  List<InventoryPurchaseOrderSavedView> views =
      inventoryPurchaseOrderSavedViews,
}) {
  for (final view in views) {
    if (view.matches(query: query, filter: filter, sort: sort)) {
      return view;
    }
  }

  return null;
}

List<String> inventoryPurchaseOrderSavedViewControlLabels(
  InventoryPurchaseOrderSavedView view,
) {
  final labels = <String>[];
  final query = view.query.trim();

  if (query.isNotEmpty) {
    labels.add('Search: $query');
  }
  if (view.filter != InventoryPurchaseOrderFilter.all) {
    labels.add('Status: ${inventoryPurchaseOrderFilterLabel(view.filter)}');
  }
  if (view.sort != InventoryPurchaseOrderSort.urgency) {
    labels.add('Sort: ${inventoryPurchaseOrderSortLabel(view.sort)}');
  }

  return labels.isEmpty ? const ['Default queue'] : labels;
}
