class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
  });
}
