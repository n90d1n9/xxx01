enum OrderStatus { pending, processing, ready, delivered, cancelled }

class Order {
  final String id;
  final DateTime orderTime;
  final List<OrderItem> items;
  final OrderStatus status;
  final String customerName;
  final double totalAmount;
  final String? notes;

  Order({
    required this.id,
    required this.orderTime,
    required this.items,
    required this.status,
    required this.customerName,
    required this.totalAmount,
    this.notes,
  });

  Order copyWith({
    String? id,
    DateTime? orderTime,
    List<OrderItem>? items,
    OrderStatus? status,
    String? customerName,
    double? totalAmount,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      orderTime: orderTime ?? this.orderTime,
      items: items ?? this.items,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
    );
  }
}

class OrderItem {
  final String recipeId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.recipeId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}
