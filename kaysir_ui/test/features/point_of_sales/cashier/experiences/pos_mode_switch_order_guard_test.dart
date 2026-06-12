import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_order_guard.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('order guard is safe for empty or currently selected modes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(800));
    final currentOption = state.findOption(defaultPOSExperience.id)!;

    expect(
      POSModeSwitchOrderGuard.evaluate(
        option: currentOption,
        order: null,
      ).disposition,
      POSModeSwitchOrderDisposition.safe,
    );
    expect(
      POSModeSwitchOrderGuard.evaluate(
        option: currentOption,
        order: _order(),
      ).disposition,
      POSModeSwitchOrderDisposition.safe,
    );
  });

  test('order guard confirms when switching with an active order', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(800));
    final quickCheckout = state.findOption(quickCheckoutPOSExperience.id)!;

    final decision = POSModeSwitchOrderGuard.evaluate(
      option: quickCheckout,
      order: _order(),
    );

    expect(decision.disposition, POSModeSwitchOrderDisposition.confirm);
    expect(decision.needsConfirmation, isTrue);
    expect(decision.hasActiveOrder, isTrue);
    expect(decision.statusLabel, 'Keeps order');
    expect(decision.title, 'Keep current order?');
    expect(decision.confirmLabel, 'Keep order');
    expect(decision.message, contains('Switching to Quick Checkout'));
    expect(decision.message, contains('1 line, 2 items, Rp 100.000'));
  });

  test('order guard blocks payment-incompatible modes after payment', () {
    final noPaymentMode = defaultPOSExperience.copyWith(
      id: 'no_payment_mode',
      label: 'No Payment Mode',
      capabilities: defaultPOSExperience.capabilities.copyWith(payments: false),
    );
    final option = POSModeSwitchOption(
      experience: noPaymentMode,
      productProfile: null,
      decision: POSModeSwitchPolicy.evaluate(
        experience: noPaymentMode,
        viewportWidth: 800,
      ),
      selected: false,
    );

    final decision = POSModeSwitchOrderGuard.evaluate(
      option: option,
      order: _order(
        payments: [
          Payment(
            id: 'payment_1',
            amount: 100000,
            method: 'Cash',
            timestamp: DateTime(2026, 5, 30, 9, 15),
            reference: 'REF1',
            isComplete: true,
          ),
        ],
      ),
    );

    expect(decision.disposition, POSModeSwitchOrderDisposition.blocked);
    expect(decision.isBlocked, isTrue);
    expect(decision.statusLabel, 'Finish order');
    expect(decision.message, contains('does not support payments'));
  });
}

Order _order({List<Payment> payments = const []}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'order_1',
    items: [
      OrderItem(
        id: 'line_1',
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
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'pending',
  );
}
