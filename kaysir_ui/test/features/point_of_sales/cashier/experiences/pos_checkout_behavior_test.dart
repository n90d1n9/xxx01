import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_checkout_behavior.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/point_of_sales/payment/utils/payment_tendering.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('standard checkout behavior keeps manual closeout defaults', () {
    const behavior = POSCheckoutBehavior.standard;
    final order = _order(payments: const []);

    expect(behavior.autoCompleteOnFinalPayment, isFalse);
    expect(behavior.showReceiptAfterCompletion, isTrue);
    expect(behavior.readinessLabel(order), 'Payment due');
    expect(behavior.completeButtonLabel, 'Complete order');
  });

  test('quick checkout auto-completes only final valid tenders', () {
    const behavior = POSCheckoutBehavior.quickCheckout;

    final partial = const PaymentTenderEvaluation(
      amount: 25000,
      remainingAmount: 50000,
      method: 'Cash',
      isValid: true,
    );
    final finalPayment = const PaymentTenderEvaluation(
      amount: 50000,
      remainingAmount: 50000,
      method: 'Cash',
      isValid: true,
    );

    expect(behavior.shouldAutoComplete(partial), isFalse);
    expect(behavior.shouldAutoComplete(finalPayment), isTrue);
    expect(behavior.paymentActionLabel(finalPayment), 'Pay and complete');
    expect(behavior.showReceiptAfterCompletion, isFalse);
  });

  test('checkout behavior exposes product-specific readiness labels', () {
    const behavior = POSCheckoutBehavior.assistedService;
    final emptyOrder = _order(items: const []);
    final unpaidOrder = _order(payments: const []);
    final paidOrder = _order(
      payments: [
        Payment(
          id: 'payment_1',
          amount: 50000,
          method: 'Cash',
          timestamp: DateTime(2026, 5, 30, 9, 15),
          reference: 'REF1',
          isComplete: true,
        ),
      ],
    );

    expect(behavior.readinessLabel(emptyOrder), 'Build service order');
    expect(behavior.readinessLabel(unpaidOrder), 'Service payment due');
    expect(behavior.readinessLabel(paidOrder), 'Ready for handoff');
  });
}

Order _order({List<OrderItem>? items, List<Payment>? payments}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'temp_order',
    items:
        items ??
        [
          OrderItem(
            id: 'line_1',
            product: product,
            quantity: 1,
            unitPrice: product.price,
            discount: 0,
          ),
        ],
    payments: payments ?? const [],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
