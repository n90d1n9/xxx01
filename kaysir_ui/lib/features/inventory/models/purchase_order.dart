import '../../ecommerce/order/order.dart';
import 'purchase_order_item.dart';

class PurchaseOrder {
  final String id;
  final String? vendorName;
  final DateTime orderDate;
  final double totalAmount;
  final OrderStatus status;
  final List<PurchaseOrderItem> items;
  final DateTime? expectedDeliveryDate;

  final String? supplierName;

  final String? notes;

  PurchaseOrder({
    this.supplierName,
    this.notes,
    required this.id,
    this.vendorName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.expectedDeliveryDate,
  });

  PurchaseOrder copyWith({
    String? id,
    String? vendorName,
    DateTime? orderDate,
    double? totalAmount,
    OrderStatus? status,
    List<PurchaseOrderItem>? items,
    DateTime? expectedDeliveryDate,
    String? supplierName,
    String? notes,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      vendorName: vendorName ?? this.vendorName,
      orderDate: orderDate ?? this.orderDate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      items: items ?? this.items,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      supplierName: supplierName ?? this.supplierName,
      notes: notes ?? this.notes,
    );
  }
}
