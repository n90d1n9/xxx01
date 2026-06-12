import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_guard.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'runtime pack switch guard is safe for current pack or empty orders',
    () {
      final plan = POSProductRuntimePackSwitchPlan.resolve(
        pack: defaultPOSProductRuntimePack,
        currentExperienceId: 'standard_cashier',
        currentCommerceChannelId: 'in_store',
      );

      expect(
        POSProductRuntimePackSwitchGuard.evaluate(
          plan: plan,
          currentPack: defaultPOSProductRuntimePack,
          order: _order(),
        ).disposition,
        POSProductRuntimePackSwitchDisposition.safe,
      );
      expect(
        POSProductRuntimePackSwitchGuard.evaluate(
          plan: plan,
          currentPack: defaultPOSProductRuntimePack,
          order: null,
        ).statusLabel,
        'Current pack',
      );
    },
  );

  test(
    'runtime pack switch guard confirms context changes with active orders',
    () {
      final onlinePack = _onlinePack();
      final plan = POSProductRuntimePackSwitchPlan.resolve(
        pack: onlinePack,
        currentExperienceId: 'standard_cashier',
        currentCommerceChannelId: 'in_store',
      );

      final decision = POSProductRuntimePackSwitchGuard.evaluate(
        plan: plan,
        currentPack: defaultPOSProductRuntimePack,
        order: _order(),
      );

      expect(
        decision.disposition,
        POSProductRuntimePackSwitchDisposition.confirm,
      );
      expect(decision.needsConfirmation, isTrue);
      expect(decision.statusLabel, 'Review order');
      expect(decision.title, 'Keep current order?');
      expect(decision.confirmLabel, 'Keep order');
      expect(decision.message, contains('Switching to Online Pack'));
      expect(decision.message, contains('1 line, 2 items, Rp 100.000'));
      expect(decision.message, contains('Quick Checkout / Web store'));
    },
  );

  test(
    'runtime pack switch guard blocks paid orders for non-payment modes',
    () {
      final noPaymentPack = _noPaymentPack();
      final plan = POSProductRuntimePackSwitchPlan.resolve(
        pack: noPaymentPack,
        currentExperienceId: 'standard_cashier',
        currentCommerceChannelId: 'in_store',
      );

      final decision = POSProductRuntimePackSwitchGuard.evaluate(
        plan: plan,
        currentPack: defaultPOSProductRuntimePack,
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

      expect(
        decision.disposition,
        POSProductRuntimePackSwitchDisposition.blocked,
      );
      expect(decision.isBlocked, isTrue);
      expect(decision.statusLabel, 'Finish order');
      expect(decision.message, contains('does not support payments'));
    },
  );
}

POSProductRuntimePack _onlinePack() {
  final quickCheckoutProfile = defaultPOSProductRuntimePack
      .productProfileCatalog
      .profiles
      .firstWhere((profile) => profile.experience.id == 'quick_checkout');
  final webChannel = defaultPOSProductRuntimePack.commerceChannelRegistry
      .channelForId('web_store');

  return defaultPOSProductRuntimePack.copyWith(
    id: 'online_pack',
    label: 'Online Pack',
    productLine: 'Online',
    productProfileCatalog: POSProductProfileCatalog(
      profiles: [quickCheckoutProfile],
    ),
    commerceChannelRegistry: POSCommerceChannelRegistry(
      defaultChannelId: webChannel.id,
      channels: [webChannel],
    ),
  );
}

POSProductRuntimePack _noPaymentPack() {
  final noPaymentMode = defaultPOSExperience.copyWith(
    id: 'no_payment_mode',
    label: 'No Payment Mode',
    capabilities: defaultPOSExperience.capabilities.copyWith(payments: false),
  );
  final noPaymentProfile = POSProductProfile(
    id: 'no_payment_profile',
    label: 'No Payment Profile',
    description: noPaymentMode.description,
    recipe: POSExperienceRecipe.fromExperience(noPaymentMode),
    experienceOverride: noPaymentMode,
  );

  return defaultPOSProductRuntimePack.copyWith(
    id: 'no_payment_pack',
    label: 'No Payment Pack',
    productLine: 'Test',
    productProfileCatalog: POSProductProfileCatalog(
      profiles: [noPaymentProfile],
    ),
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
