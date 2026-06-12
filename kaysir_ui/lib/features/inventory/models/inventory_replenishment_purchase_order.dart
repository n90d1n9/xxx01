import 'inventory_purchase_order_create.dart';
import 'inventory_replenishment_plan.dart';
import 'purchase_order_item.dart';

const inventoryReplenishmentPurchaseOrderSupplierName =
    'Replenishment Supplier';

/// Purchase-order proposal generated from visible replenishment recommendations.
class InventoryReplenishmentPurchaseOrderProposal {
  InventoryReplenishmentPurchaseOrderProposal({
    required Iterable<InventoryReplenishmentPlan> plans,
    this.supplierName = inventoryReplenishmentPurchaseOrderSupplierName,
  }) : plans = List.unmodifiable(plans);

  final List<InventoryReplenishmentPlan> plans;
  final String supplierName;

  int get planCount => plans.length;

  int get warehouseCount {
    return {for (final plan in plans) plan.record.warehouse.id}.length;
  }

  int get criticalCount {
    return plans
        .where(
          (plan) => plan.severity == InventoryReplenishmentSeverity.critical,
        )
        .length;
  }

  late final List<PurchaseOrderItem> items =
      inventoryReplenishmentPurchaseOrderItems(plans);

  int get itemCount => items.length;

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  String get notes {
    final lineLabel =
        planCount == 1 ? '1 low-stock line' : '$planCount low-stock lines';
    final warehouseLabel =
        warehouseCount == 1 ? '1 warehouse' : '$warehouseCount warehouses';
    final criticalLabel =
        criticalCount == 1
            ? '1 critical line'
            : '$criticalCount critical lines';
    return 'Generated from $lineLabel across $warehouseLabel. $criticalLabel need immediate attention.';
  }

  InventoryPurchaseOrderCreateDraft toCreateDraft({
    DateTime? expectedDeliveryDate,
  }) {
    return InventoryPurchaseOrderCreateDraft(
      supplierName: supplierName,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      items: items,
    );
  }
}

/// Returns purchase-order items aggregated by product from replenishment plans.
List<PurchaseOrderItem> inventoryReplenishmentPurchaseOrderItems(
  Iterable<InventoryReplenishmentPlan> plans,
) {
  final linesByProductId = <String, _PurchaseOrderLineAccumulator>{};

  for (final plan in plans) {
    final product = plan.record.product;
    final existing = linesByProductId[product.id];
    if (existing == null) {
      linesByProductId[product.id] = _PurchaseOrderLineAccumulator(
        id: product.id,
        name: plan.record.productName,
        sku: product.sku,
        quantity: plan.suggestedQuantity,
        unitPrice: product.price,
      );
    } else {
      existing.quantity += plan.suggestedQuantity;
    }
  }

  final lines =
      linesByProductId.values.toList()
        ..sort((first, second) => first.name.compareTo(second.name));
  return [for (final line in lines) line.toPurchaseOrderItem()];
}

/// Mutable accumulator used while grouping low-stock plans into PO lines.
class _PurchaseOrderLineAccumulator {
  _PurchaseOrderLineAccumulator({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.sku,
  });

  final String id;
  final String name;
  final String? sku;
  int quantity;
  final double unitPrice;

  PurchaseOrderItem toPurchaseOrderItem() {
    return PurchaseOrderItem(
      id: id,
      name: name,
      sku: sku,
      quantity: quantity,
      unitPrice: unitPrice,
    );
  }
}
