class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    this.description = '',
  });

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }
}
