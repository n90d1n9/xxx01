import '../models/movement_type.dart';

/// Lightweight movement row data for dashboard and compact activity lists.
class InventoryMovementListEntry {
  const InventoryMovementListEntry({
    required this.productName,
    required this.type,
    required this.quantity,
    required this.reference,
    required this.date,
  });

  final String productName;
  final MovementType type;
  final int quantity;
  final String reference;
  final DateTime date;
}
