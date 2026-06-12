import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('runtime pack availability reports the current pack', () {
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    final availability = POSProductRuntimePackSwitchAvailability.evaluate(
      plan: plan,
      currentPack: defaultPOSProductRuntimePack,
      order: _order(),
    );

    expect(
      availability.status,
      POSProductRuntimePackSwitchAvailabilityStatus.current,
    );
    expect(availability.statusLabel, 'Current pack');
    expect(availability.isCurrent, isTrue);
    expect(availability.canSwitch, isTrue);
    expect(availability.needsConfirmation, isFalse);
  });

  test('runtime pack availability allows inactive order switches', () {
    final onlinePack = _onlinePack();
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: onlinePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    final availability = POSProductRuntimePackSwitchAvailability.evaluate(
      plan: plan,
      currentPack: defaultPOSProductRuntimePack,
      order: null,
    );

    expect(
      availability.status,
      POSProductRuntimePackSwitchAvailabilityStatus.available,
    );
    expect(availability.statusLabel, 'Available');
    expect(availability.canSwitch, isTrue);
    expect(availability.needsConfirmation, isFalse);
    expect(availability.isBlocked, isFalse);
  });

  test('runtime pack availability confirms active order context changes', () {
    final onlinePack = _onlinePack();
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: onlinePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    final availability = POSProductRuntimePackSwitchAvailability.evaluate(
      plan: plan,
      currentPack: defaultPOSProductRuntimePack,
      order: _order(),
    );

    expect(
      availability.status,
      POSProductRuntimePackSwitchAvailabilityStatus.confirm,
    );
    expect(availability.statusLabel, 'Review order');
    expect(availability.needsConfirmation, isTrue);
    expect(availability.canSwitch, isTrue);
    expect(availability.decision.message, contains('Switching to Online Pack'));
  });

  test('runtime pack availability blocks paid orders for no-payment packs', () {
    final noPaymentPack = _noPaymentPack();
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: noPaymentPack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    final availability = POSProductRuntimePackSwitchAvailability.evaluate(
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
      availability.status,
      POSProductRuntimePackSwitchAvailabilityStatus.blocked,
    );
    expect(availability.statusLabel, 'Finish order');
    expect(availability.isBlocked, isTrue);
    expect(availability.canSwitch, isFalse);
  });
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
