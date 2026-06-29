class InventoryMovement {
  final String id;
  final String productId;
  final String sourceWarehouseId;
  final String? destinationWarehouseId;
  final int quantity;
  final MovementType type;
  final DateTime date;
  final String reference;
  final String notes;
  final String? warehouseId;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.sourceWarehouseId,
    this.destinationWarehouseId,
    required this.quantity,
    required this.type,
    required this.date,
    required this.reference,
    this.warehouseId,
    this.notes = '',
  });

  InventoryMovement copyWith({
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
    return InventoryMovement(
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
    return 'InventoryMovement(id: $id, productId: $productId, sourceWarehouseId: $sourceWarehouseId, destinationWarehouseId: $destinationWarehouseId, quantity: $quantity, type: $type, date: $date, reference: $reference, notes: $notes)';
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

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
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

enum MovementType {
  receipt,
  issue,
  transfer,
  adjustment,
  stockOpname,
  purchase,
  sale,
}
