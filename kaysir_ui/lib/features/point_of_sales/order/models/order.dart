import '../../cashier/models/customer.dart';
import 'order_item.dart';
import 'order_fulfillment_snapshot.dart';
import '../../payment/models/payment.dart';
import '../../promotion/models/promotion.dart';
import '../../cashier/models/terminal.dart';

class Order {
  final String id;
  final List<OrderItem> items;
  final Customer? customer;
  final List<Payment> payments;
  final Terminal terminal;
  final List<Promotion> appliedPromotions;
  final DateTime createdAt;
  final String status;
  final OrderFulfillmentSnapshot? fulfillment;

  Order({
    required this.id,
    required this.items,
    this.customer,
    required this.payments,
    required this.terminal,
    required this.appliedPromotions,
    required this.createdAt,
    required this.status,
    this.fulfillment,
  });

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    Customer? customer,
    bool clearCustomer = false,
    List<Payment>? payments,
    Terminal? terminal,
    List<Promotion>? appliedPromotions,
    DateTime? createdAt,
    String? status,
    OrderFulfillmentSnapshot? fulfillment,
    bool clearFulfillment = false,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      customer: clearCustomer ? null : customer ?? this.customer,
      payments: payments ?? this.payments,
      terminal: terminal ?? this.terminal,
      appliedPromotions: appliedPromotions ?? this.appliedPromotions,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      fulfillment: clearFulfillment ? null : fulfillment ?? this.fulfillment,
    );
  }

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);

  double get discountTotal => appliedPromotions.fold(
    0,
    (sum, promo) =>
        sum +
        (promo.discountAmount + (subtotal * promo.discountPercentage / 100)),
  );

  double get total => subtotal - discountTotal;

  double get paidAmount => payments.fold(
    0,
    (sum, payment) => sum + (payment.isComplete ? payment.amount : 0),
  );

  double get remainingAmount => total - paidAmount;

  bool get isPaid => remainingAmount <= 0;
}
