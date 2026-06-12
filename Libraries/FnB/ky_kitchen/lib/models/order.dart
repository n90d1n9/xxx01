import 'package:ky_fnb_core/ky_fnb_core.dart';

/// Tracks the lifecycle of a kitchen order from intake through completion.
enum OrderStatus { pending, processing, ready, delivered, cancelled }

/// Shared FnB pressure mapping for kitchen order states.
extension OrderStatusServiceStatus on OrderStatus {
  FnbServiceStatus get serviceStatus => switch (this) {
    OrderStatus.pending => FnbServiceStatus.busy,
    OrderStatus.processing => FnbServiceStatus.critical,
    OrderStatus.ready => FnbServiceStatus.busy,
    OrderStatus.delivered => FnbServiceStatus.calm,
    OrderStatus.cancelled => FnbServiceStatus.blocked,
  };

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.processing => 'Processing',
    OrderStatus.ready => 'Ready',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };
}

/// Represents a customer order managed by the kitchen workflow.
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

/// Represents one recipe item and quantity inside a kitchen order.
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
