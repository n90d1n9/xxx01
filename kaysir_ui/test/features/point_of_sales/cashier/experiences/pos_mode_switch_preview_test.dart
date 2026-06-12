import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_mode_switch_preview.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'mode switch preview composes availability layout and feature changes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(posModeSwitchStateProvider(600));
      final option = state.findOption(quickCheckoutPOSExperience.id)!;
      final availability = POSModeSwitchAvailability.evaluate(
        option: option,
        order: null,
      );

      final preview = POSModeSwitchPreview.evaluate(
        availability: availability,
        currentExperience: state.currentExperience,
      );

      expect(preview.changesLayout, isTrue);
      expect(preview.layoutChangeLabel, 'Auto to Checkout');
      expect(preview.impact.summaryLabel, '5 off');
      expect(preview.items.map((item) => item.label), contains('Review'));
      expect(
        preview.compactItems().map((item) => item.label),
        containsAll(['Auto to Checkout', '5 off', 'Customer off']),
      );
      expect(
        preview.searchTerms,
        containsAll(['customer_selection', 'Promos off']),
      );
    },
  );

  test('mode switch preview summarizes active order confirmation once', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final state = container.read(posModeSwitchStateProvider(600));
    final option = state.findOption(quickCheckoutPOSExperience.id)!;
    final availability = POSModeSwitchAvailability.evaluate(
      option: option,
      order: _activeOrder(),
    );

    final preview = POSModeSwitchPreview.evaluate(
      availability: availability,
      currentExperience: state.currentExperience,
    );

    final labels = preview.items.map((item) => item.label).toList();
    expect(preview.primaryLabel, 'Keeps order');
    expect(labels.where((label) => label == 'Keeps order'), hasLength(1));
    expect(preview.items.first.tone, POSModeSwitchPreviewItemTone.warning);
  });
}

Order _activeOrder() {
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
    payments: const [],
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
