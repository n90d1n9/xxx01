// Enhanced ShoppingItem model
class ShoppingItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final bool purchased;
  final String category;
  final String? notes;
  final DateTime addedDate;
  final DateTime? purchasedDate;
  final String? budgetCategory; // Linked budget category

  ShoppingItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.purchased,
    required this.category,
    this.notes,
    required this.addedDate,
    this.purchasedDate,
    this.budgetCategory,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
    'purchased': purchased,
    'category': category,
    'notes': notes,
    'addedDate': addedDate.toIso8601String(),
    'purchasedDate': purchasedDate?.toIso8601String(),
    'budgetCategory': budgetCategory,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    quantity: json['quantity'] ?? 1,
    purchased: json['purchased'],
    category: json['category'],
    notes: json['notes'],
    addedDate: DateTime.parse(json['addedDate']),
    purchasedDate:
        json['purchasedDate'] != null
            ? DateTime.parse(json['purchasedDate'])
            : null,
    budgetCategory: json['budgetCategory'],
  );

  ShoppingItem copyWith({
    String? name,
    double? price,
    int? quantity,
    bool? purchased,
    String? category,
    String? notes,
    DateTime? purchasedDate,
    String? budgetCategory,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      purchased: purchased ?? this.purchased,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      addedDate: addedDate,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      budgetCategory: budgetCategory ?? this.budgetCategory,
    );
  }
}
