import '../../inventory/models/movement_type.dart';
import '../models/product.dart';

int productStockDeltaForMovement(MovementType type, int quantity) {
  switch (type) {
    case MovementType.inbound:
    case MovementType.receipt:
    case MovementType.purchase:
      return quantity;
    case MovementType.outbound:
    case MovementType.issue:
    case MovementType.sale:
      return -quantity;
    case MovementType.transfer:
    case MovementType.adjustment:
    case MovementType.stockOpname:
      return 0;
  }
}

Product applyProductStockMovement({
  required Product product,
  required MovementType type,
  required int quantity,
  String? notes,
  DateTime? checkedAt,
}) {
  final delta = productStockDeltaForMovement(type, quantity);
  if (delta == 0 && notes == null && checkedAt == null) return product;

  final nextStock = product.currentStock + delta;
  final normalizedStock = nextStock < 0 ? 0 : nextStock;

  return product.copyWith(
    currentStock: normalizedStock,
    stockQuantity: normalizedStock,
    notes: notes ?? product.notes,
    lastChecked: checkedAt ?? product.lastChecked,
  );
}
