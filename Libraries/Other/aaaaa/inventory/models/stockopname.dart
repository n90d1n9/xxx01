class StockOpname {
  final String id;
  final String warehouseId;
  final DateTime date;
  final String conductedBy;
  final StockOpnameStatus status;
  final List<StockOpnameItem> items;

  StockOpname({
    required this.id,
    required this.warehouseId,
    required this.date,
    required this.conductedBy,
    required this.status,
    required this.items,
  });
}

enum StockOpnameStatus { draft, inProgress, completed, cancelled }

class StockOpnameItem {
  final String id;
  final String productId;
  final int systemQuantity;
  final int actualQuantity;
  final String notes;

  StockOpnameItem({
    required this.id,
    required this.productId,
    required this.systemQuantity,
    required this.actualQuantity,
    this.notes = '',
  });

  int get discrepancy => actualQuantity - systemQuantity;

  StockOpnameItem copyWith({
    String? id,
    String? productId,
    int? systemQuantity,
    int? actualQuantity,
    String? notes,
  }) {
    return StockOpnameItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      systemQuantity: systemQuantity ?? this.systemQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'StockOpnameItem(id: $id, productId: $productId, systemQuantity: $systemQuantity, actualQuantity: $actualQuantity, notes: $notes, discrepancy: $discrepancy)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'systemQuantity': systemQuantity,
      'actualQuantity': actualQuantity,
      'notes': notes,
    };
  }

  factory StockOpnameItem.fromJson(Map<String, dynamic> json) {
    return StockOpnameItem(
      id: json['id'],
      productId: json['productId'],
      systemQuantity: json['systemQuantity'],
      actualQuantity: json['actualQuantity'],
      notes: json['notes'],
    );
  }
}
