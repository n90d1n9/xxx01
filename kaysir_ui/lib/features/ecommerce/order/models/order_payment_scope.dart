import '../../../point_of_sales/order/models/order.dart' as pos_order;

enum OrderPaymentScope { all, internalPaid, externalSettlement, unpaid }

extension OrderPaymentScopeLabel on OrderPaymentScope {
  String get label {
    return switch (this) {
      OrderPaymentScope.all => 'All',
      OrderPaymentScope.internalPaid => 'Internal',
      OrderPaymentScope.externalSettlement => 'External',
      OrderPaymentScope.unpaid => 'Unpaid',
    };
  }
}

bool matchesOrderPaymentScope(pos_order.Order order, OrderPaymentScope scope) {
  return switch (scope) {
    OrderPaymentScope.all => true,
    OrderPaymentScope.internalPaid =>
      order.isPaid && !ecommerceOrderUsesExternalSettlement(order),
    OrderPaymentScope.externalSettlement =>
      order.isPaid && ecommerceOrderUsesExternalSettlement(order),
    OrderPaymentScope.unpaid => !order.isPaid,
  };
}

bool ecommerceOrderUsesExternalSettlement(pos_order.Order order) {
  return order.payments.any((payment) {
    final normalizedMethod = payment.method.trim().toLowerCase();
    return normalizedMethod.endsWith('settlement') ||
        normalizedMethod.contains('external settlement');
  });
}
