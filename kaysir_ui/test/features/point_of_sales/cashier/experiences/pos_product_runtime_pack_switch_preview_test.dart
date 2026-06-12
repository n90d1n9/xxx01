import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_availability.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_preview.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test(
    'runtime pack preview summarizes product line layout and scope changes',
    () {
      final onlinePack = _onlinePack();
      final availability = _availabilityFor(onlinePack, order: null);

      final preview = POSProductRuntimePackSwitchPreview.evaluate(
        availability: availability,
        currentLayoutPreference: POSLayoutPreference.auto,
      );

      expect(preview.changesProductLine, isTrue);
      expect(preview.productLineChangeLabel, 'Kaysir Core to Online');
      expect(preview.changesLayout, isTrue);
      expect(preview.layoutChangeLabel, 'Auto to Checkout');
      expect(preview.changesCatalogScope, isTrue);
      expect(preview.targetScopeLabel, '1 mode | 1 channel');
      expect(preview.items.map((item) => item.label), contains('Available'));
      expect(
        preview.compactItems().map((item) => item.label),
        containsAll([
          'Kaysir Core to Online',
          'Auto to Checkout',
          'Quick Checkout / Web store',
          '1 mode | 1 channel',
        ]),
      );
      expect(
        preview.searchTerms,
        containsAll(['product_line', 'Online Pack', 'Auto to Checkout']),
      );
    },
  );

  test('runtime pack preview keeps active order confirmation singular', () {
    final onlinePack = _onlinePack();
    final availability = _availabilityFor(onlinePack, order: _order());

    final preview = POSProductRuntimePackSwitchPreview.evaluate(
      availability: availability,
      currentLayoutPreference: POSLayoutPreference.auto,
    );

    final labels = preview.items.map((item) => item.label).toList();
    expect(preview.primaryLabel, 'Review order');
    expect(labels.where((label) => label == 'Review order'), hasLength(1));
    expect(
      preview.items.first.tone,
      POSProductRuntimePackSwitchPreviewItemTone.warning,
    );
  });

  test('runtime pack preview surfaces blocked paid order switches', () {
    final noPaymentPack = _noPaymentPack();
    final availability = _availabilityFor(
      noPaymentPack,
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

    final preview = POSProductRuntimePackSwitchPreview.evaluate(
      availability: availability,
      currentLayoutPreference: POSLayoutPreference.auto,
    );

    expect(preview.primaryLabel, 'Finish order');
    expect(
      preview.items.first.tone,
      POSProductRuntimePackSwitchPreviewItemTone.danger,
    );
    expect(preview.searchTerms, contains('No Payment Pack'));
  });
}

POSProductRuntimePackSwitchAvailability _availabilityFor(
  POSProductRuntimePack pack, {
  required Order? order,
}) {
  final plan = POSProductRuntimePackSwitchPlan.resolve(
    pack: pack,
    currentExperienceId: 'standard_cashier',
    currentCommerceChannelId: 'in_store',
  );

  return POSProductRuntimePackSwitchAvailability.evaluate(
    plan: plan,
    currentPack: defaultPOSProductRuntimePack,
    order: order,
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
