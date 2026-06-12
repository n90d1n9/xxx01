import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_financial_summary.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/point_of_sales/promotion/models/promotion.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('financial summary tracks discount, paid, and remaining balances', () {
    final order = _order(
      payments: [
        _payment(amount: 30000, complete: true),
        _payment(amount: 10000, complete: false),
      ],
      promotions: [
        Promotion(
          id: 'promo-1',
          name: 'Launch discount',
          code: 'LAUNCH',
          discountPercentage: 10,
          discountAmount: 5000,
          isActive: true,
          validUntil: DateTime(2026, 12, 31),
        ),
      ],
    );

    final summary = OrderFinancialSummary.fromOrder(order);

    expect(summary.subtotal, 100000);
    expect(summary.discountTotal, 15000);
    expect(summary.total, 85000);
    expect(summary.paidAmount, 30000);
    expect(summary.remainingAmount, 55000);
    expect(summary.statusLabel, 'Balance due');
    expect(summary.paymentCountLabel, '1 complete payment, 1 pending');
    expect(summary.lines.map((line) => line.label), [
      'Subtotal',
      'Discount',
      'Total',
      'Paid',
      'Remaining',
    ]);
    expect(summary.lines[1].isDeduction, isTrue);
  });

  test('financial summary detects overpayment as a separate balance state', () {
    final summary = OrderFinancialSummary.fromOrder(
      _order(payments: [_payment(amount: 120000, complete: true)]),
    );

    expect(summary.hasOverpayment, isTrue);
    expect(summary.balanceLabel, 'Overpaid');
    expect(summary.balanceAmount, 20000);
    expect(summary.statusLabel, 'Overpaid');
  });
}

Order _order({
  List<Payment> payments = const [],
  List<Promotion> promotions = const [],
}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order-1',
    items: [
      OrderItem(
        id: 'line-1',
        product: product,
        quantity: 2,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: payments,
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: promotions,
    createdAt: DateTime(2026, 5, 31, 9),
    status: 'completed',
  );
}

Payment _payment({required double amount, required bool complete}) {
  return Payment(
    id: 'payment-$amount-$complete',
    amount: amount,
    method: 'Card',
    timestamp: DateTime(2026, 5, 31, 9),
    reference: 'REF-$amount',
    isComplete: complete,
  );
}
