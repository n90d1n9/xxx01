class Item {
  final String id;
  final String name;
  final double price;
  final String barcode;
  final String category;
  final int stock;
  
  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    required this.category,
    required this.stock,
  });
}

// lib/models/cart_item.dart
class CartItem {
  final Item item;
  int quantity;
  double discount;
  
  CartItem({
    required this.item,
    this.quantity = 1,
    this.discount = 0,
  });
  
  double get total => item.price * quantity - discount;
}
