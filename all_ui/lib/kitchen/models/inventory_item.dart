class InventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final DateTime expiryDate;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.expiryDate,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    double? price,
    DateTime? expiryDate,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
