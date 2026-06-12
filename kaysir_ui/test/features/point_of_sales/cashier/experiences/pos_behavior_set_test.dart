import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_behavior_set.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_catalog_behavior.dart';

void main() {
  test('standard behavior set groups the default POS behaviors', () {
    const behaviors = POSBehaviorSet.standard;

    expect(behaviors.catalog.actionLabel, 'Add');
    expect(behaviors.cart.defaultQuantity, 1);
    expect(behaviors.checkout.completeButtonLabel, 'Complete order');
    expect(behaviors.payment.defaultMethod, 'Cash');
    expect(behaviors.orderSync.drainLimit, 20);
  });

  test('quick checkout behavior set composes fast checkout policies', () {
    const behaviors = POSBehaviorSet.quickCheckout;

    expect(behaviors.catalog.actionLabel, 'Quick add');
    expect(behaviors.cart.maxQuantityPerLine, 99);
    expect(behaviors.checkout.autoCompleteOnFinalPayment, isTrue);
    expect(behaviors.payment.allowPartialPayments, isFalse);
    expect(behaviors.orderSync.retryFailedByDefault, isFalse);
  });

  test(
    'behavior set can override one behavior without rebuilding the rest',
    () {
      const behaviors = POSBehaviorSet.quickCheckout;

      final customized = behaviors.copyWith(
        catalog: const POSCatalogBehavior(
          actionLabel: 'Serve',
          emptyMessage: 'No service catalog items',
        ),
      );

      expect(customized.catalog.actionLabel, 'Serve');
      expect(customized.catalog.emptyMessage, 'No service catalog items');
      expect(customized.cart, behaviors.cart);
      expect(customized.checkout, behaviors.checkout);
      expect(customized.payment, behaviors.payment);
      expect(customized.orderSync, behaviors.orderSync);
    },
  );
}
