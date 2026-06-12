import '../../../point_of_sales/order/models/order.dart' as pos_order;

enum OrderFinancialLineKind { subtotal, discount, total, paid, balance }

class OrderFinancialLine {
  final OrderFinancialLineKind kind;
  final String label;
  final double amount;
  final bool isDeduction;
  final bool isEmphasized;

  const OrderFinancialLine({
    required this.kind,
    required this.label,
    required this.amount,
    this.isDeduction = false,
    this.isEmphasized = false,
  });
}

class OrderFinancialSummary {
  final double subtotal;
  final double discountTotal;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final int completedPaymentCount;
  final int pendingPaymentCount;

  const OrderFinancialSummary({
    required this.subtotal,
    required this.discountTotal,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.completedPaymentCount,
    required this.pendingPaymentCount,
  });

  factory OrderFinancialSummary.fromOrder(pos_order.Order order) {
    return OrderFinancialSummary(
      subtotal: order.subtotal,
      discountTotal: order.discountTotal,
      total: order.total,
      paidAmount: order.paidAmount,
      remainingAmount: order.remainingAmount,
      completedPaymentCount:
          order.payments.where((payment) => payment.isComplete).length,
      pendingPaymentCount:
          order.payments.where((payment) => !payment.isComplete).length,
    );
  }

  bool get hasDiscount => discountTotal > 0;

  bool get hasBalanceDue => remainingAmount > 0;

  bool get hasOverpayment => remainingAmount < 0;

  double get balanceAmount {
    if (hasOverpayment) return remainingAmount.abs();
    if (hasBalanceDue) return remainingAmount;
    return 0;
  }

  String get balanceLabel {
    if (hasOverpayment) return 'Overpaid';
    return 'Remaining';
  }

  String get statusLabel {
    if (hasOverpayment) return 'Overpaid';
    if (hasBalanceDue) return 'Balance due';
    return 'Paid in full';
  }

  String get paymentCountLabel {
    final completed = completedPaymentCount;
    final pending = pendingPaymentCount;
    final completedLabel =
        '$completed complete payment${completed == 1 ? '' : 's'}';
    if (pending == 0) return completedLabel;
    return '$completedLabel, $pending pending';
  }

  List<OrderFinancialLine> get lines {
    return List.unmodifiable([
      OrderFinancialLine(
        kind: OrderFinancialLineKind.subtotal,
        label: 'Subtotal',
        amount: subtotal,
      ),
      if (hasDiscount)
        OrderFinancialLine(
          kind: OrderFinancialLineKind.discount,
          label: 'Discount',
          amount: discountTotal,
          isDeduction: true,
        ),
      OrderFinancialLine(
        kind: OrderFinancialLineKind.total,
        label: 'Total',
        amount: total,
        isEmphasized: true,
      ),
      OrderFinancialLine(
        kind: OrderFinancialLineKind.paid,
        label: 'Paid',
        amount: paidAmount,
      ),
      OrderFinancialLine(
        kind: OrderFinancialLineKind.balance,
        label: balanceLabel,
        amount: balanceAmount,
        isEmphasized: hasBalanceDue || hasOverpayment,
      ),
    ]);
  }
}
