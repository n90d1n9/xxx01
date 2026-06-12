import 'movement_type.dart';

class StockMovement {
  final String id;
  final String productId;
  final String? sourceWarehouseId;
  final String? destinationWarehouseId;
  final int quantity;
  final MovementType type;
  final DateTime date;
  final String reference;
  final String notes;
  final String? warehouseId;

  StockMovement({
    required this.id,
    required this.productId,
    this.sourceWarehouseId,
    this.destinationWarehouseId,
    required this.quantity,
    required this.type,
    required this.date,
    required this.reference,
    this.warehouseId,
    this.notes = '',
  });

  StockMovement copyWith({
    String? id,
    String? productId,
    String? sourceWarehouseId,
    String? destinationWarehouseId,
    int? quantity,
    MovementType? type,
    DateTime? date,
    String? reference,
    String? notes,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      sourceWarehouseId: sourceWarehouseId ?? this.sourceWarehouseId,
      destinationWarehouseId:
          destinationWarehouseId ?? this.destinationWarehouseId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'StockMovement(id: $id, productId: $productId, sourceWarehouseId: $sourceWarehouseId, destinationWarehouseId: $destinationWarehouseId, quantity: $quantity, type: $type, date: $date, reference: $reference, notes: $notes)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sourceWarehouseId': sourceWarehouseId,
      'destinationWarehouseId': destinationWarehouseId,
      'quantity': quantity,
      'type': type.toString(),
      'date': date.toIso8601String(),
      'reference': reference,
      'notes': notes,
    };
  }

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['productId'],
      sourceWarehouseId: json['sourceWarehouseId'],
      destinationWarehouseId: json['destinationWarehouseId'],
      quantity: json['quantity'],
      type: MovementType.values.firstWhere((e) => e.toString() == json['type']),
      date: DateTime.parse(json['date']),
      reference: json['reference'],
      notes: json['notes'],
    );
  }
}
