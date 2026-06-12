import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('availability reports the selected mode as current', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    final currentOption = state.findOption(defaultPOSExperience.id)!;

    final availability = POSModeSwitchAvailability.evaluate(
      option: currentOption,
      order: _order(),
    );

    expect(availability.status, POSModeSwitchAvailabilityStatus.current);
    expect(availability.statusLabel, 'Current mode');
    expect(availability.canSwitch, isTrue);
    expect(availability.needsConfirmation, isFalse);
    expect(availability.orderDecision.statusLabel, 'Current order');
  });

  test('availability uses order confirmation when launch policy is ready', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    final quickCheckout = state.findOption(quickCheckoutPOSExperience.id)!;

    final availability = POSModeSwitchAvailability.evaluate(
      option: quickCheckout,
      order: _order(),
    );

    expect(availability.status, POSModeSwitchAvailabilityStatus.confirm);
    expect(availability.statusLabel, 'Keeps order');
    expect(availability.modeConfirmation, isNull);
    expect(availability.orderConfirmation, isNotNull);
  });

  test('availability keeps screen confirmation before order confirmation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(1280));
    final quickCheckout = state.findOption(quickCheckoutPOSExperience.id)!;

    final availability = POSModeSwitchAvailability.evaluate(
      option: quickCheckout,
      order: _order(),
    );

    expect(availability.status, POSModeSwitchAvailabilityStatus.confirm);
    expect(availability.statusLabel, 'Confirm');
    expect(availability.modeConfirmation, isNotNull);
    expect(availability.orderConfirmation, isNotNull);
  });

  test('availability blocks payment-incompatible modes for paid orders', () {
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

    final availability = POSModeSwitchAvailability.evaluate(
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

    expect(availability.status, POSModeSwitchAvailabilityStatus.blocked);
    expect(availability.statusLabel, 'Finish order');
    expect(availability.blockedModeDecision, isNull);
    expect(availability.blockedOrderDecision, isNotNull);
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
