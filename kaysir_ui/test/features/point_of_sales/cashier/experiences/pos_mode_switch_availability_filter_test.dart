import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/ecommerce/pos/pos_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_availability_filter.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_filter.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_policy.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'availability filter searches mode metadata and order impact labels',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(posModeSwitchStateProvider(600));

      final quickResult = POSModeSwitchAvailabilityFilter(
        query: 'keeps',
        order: _order(),
      ).apply(state);

      expect(
        quickResult.options.map((option) => option.id),
        contains(quickCheckoutPOSExperience.id),
      );

      final mobileResult = const POSModeSwitchAvailabilityFilter(
        query: 'mobile',
      ).apply(state);
      expect(
        mobileResult.options.map((option) => option.id),
        containsAll([defaultPOSExperience.id, quickCheckoutPOSExperience.id]),
      );
    },
  );

  test('availability filter searches feature impact terms', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    final customerImpactResult = const POSModeSwitchAvailabilityFilter(
      query: 'customer off',
    ).apply(state);

    expect(
      customerImpactResult.options.map((option) => option.id),
      contains(quickCheckoutPOSExperience.id),
    );
    expect(
      customerImpactResult.options.map((option) => option.id),
      isNot(contains(defaultPOSExperience.id)),
    );

    final summaryImpactResult = const POSModeSwitchAvailabilityFilter(
      query: '5 off',
    ).apply(state);

    expect(summaryImpactResult.options.map((option) => option.id), [
      quickCheckoutPOSExperience.id,
      ecommercePOSExperience.id,
    ]);

    final counts = POSModeSwitchAvailabilityCounts.fromState(
      state,
      query: 'customer off',
    );

    expect(counts.countFor(POSModeSwitchFilterStatus.all), 1);
  });

  test('availability filter narrows by combined confirmation status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    final result = POSModeSwitchAvailabilityFilter(
      status: POSModeSwitchFilterStatus.confirm,
      order: _order(),
    ).apply(state);

    expect(
      result.options.map((option) => option.id),
      containsAll([
        quickCheckoutPOSExperience.id,
        assistedServicePOSExperience.id,
      ]),
    );
    expect(
      result.options.map((option) => option.id),
      isNot(contains(defaultPOSExperience.id)),
    );
  });

  test('availability counts reflect query and active order status', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));

    final counts = POSModeSwitchAvailabilityCounts.fromState(
      state,
      order: _order(),
    );

    expect(counts.countFor(POSModeSwitchFilterStatus.all), 4);
    expect(counts.countFor(POSModeSwitchFilterStatus.launchReady), 1);
    expect(counts.countFor(POSModeSwitchFilterStatus.review), 0);
    expect(counts.countFor(POSModeSwitchFilterStatus.confirm), 3);
    expect(counts.countFor(POSModeSwitchFilterStatus.blocked), 0);

    final quickCounts = POSModeSwitchAvailabilityCounts.fromState(
      state,
      query: 'quick',
      order: _order(),
    );

    expect(quickCounts.countFor(POSModeSwitchFilterStatus.all), 1);
    expect(quickCounts.countFor(POSModeSwitchFilterStatus.confirm), 1);
    expect(quickCounts.countFor(POSModeSwitchFilterStatus.launchReady), 0);
  });

  test('availability filter includes order blockers in blocked status', () {
    final state = _stateWithPaymentlessMode();

    final result = POSModeSwitchAvailabilityFilter(
      status: POSModeSwitchFilterStatus.blocked,
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
    ).apply(state);

    expect(result.matchCount, 1);
    expect(result.options.single.id, 'no_payment_mode');
    expect(result.availabilities.single.statusLabel, 'Finish order');

    final counts = POSModeSwitchAvailabilityCounts.fromState(
      state,
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

    expect(counts.countFor(POSModeSwitchFilterStatus.blocked), 1);
  });
}

POSModeSwitchState _stateWithPaymentlessMode() {
  final noPaymentMode = defaultPOSExperience.copyWith(
    id: 'no_payment_mode',
    label: 'No Payment Mode',
    capabilities: defaultPOSExperience.capabilities.copyWith(payments: false),
  );

  return POSModeSwitchState(
    currentExperience: defaultPOSExperience,
    sections: [
      POSModeSwitchSection(
        productLine: 'Test Modes',
        options: [
          POSModeSwitchOption(
            experience: defaultPOSExperience,
            productProfile: null,
            decision: POSModeSwitchPolicy.evaluate(
              experience: defaultPOSExperience,
              viewportWidth: 800,
            ),
            selected: true,
          ),
          POSModeSwitchOption(
            experience: noPaymentMode,
            productProfile: null,
            decision: POSModeSwitchPolicy.evaluate(
              experience: noPaymentMode,
              viewportWidth: 800,
            ),
            selected: false,
          ),
        ],
      ),
    ],
  );
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
