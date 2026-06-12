import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_catalog.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_switch_availability_filter.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('runtime pack availability filter searches pack metadata', () {
    final onlinePack = _onlinePack();
    final catalog = POSProductRuntimePackCatalog.fromPacks([
      defaultPOSProductRuntimePack,
      onlinePack,
    ]);

    final result = const POSProductRuntimePackSwitchAvailabilityFilter(
      query: 'online',
    ).apply(
      catalog: catalog,
      currentPack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    expect(result.totalCount, 2);
    expect(result.matchCount, 1);
    expect(result.sections.single.productLine, 'Online');
    expect(result.sections.single.packCount, 1);
    expect(result.packs.single.id, onlinePack.id);
    expect(result.availabilities.single.statusLabel, 'Available');
  });

  test(
    'runtime pack availability filter narrows active order confirmations',
    () {
      final onlinePack = _onlinePack();
      final catalog = POSProductRuntimePackCatalog.fromPacks([
        defaultPOSProductRuntimePack,
        onlinePack,
      ]);

      final result = POSProductRuntimePackSwitchAvailabilityFilter(
        status: POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm,
        order: _order(),
      ).apply(
        catalog: catalog,
        currentPack: defaultPOSProductRuntimePack,
        currentExperienceId: 'standard_cashier',
        currentCommerceChannelId: 'in_store',
      );

      expect(result.packs.map((pack) => pack.id), [onlinePack.id]);
      expect(result.availabilities.single.statusLabel, 'Review order');

      final currentResult = POSProductRuntimePackSwitchAvailabilityFilter(
        status: POSProductRuntimePackSwitchAvailabilityFilterStatus.current,
        order: _order(),
      ).apply(
        catalog: catalog,
        currentPack: defaultPOSProductRuntimePack,
        currentExperienceId: 'standard_cashier',
        currentCommerceChannelId: 'in_store',
      );

      expect(currentResult.packs.single.id, defaultPOSProductRuntimePack.id);
    },
  );

  test('runtime pack availability counts reflect order-sensitive status', () {
    final onlinePack = _onlinePack();
    final catalog = POSProductRuntimePackCatalog.fromPacks([
      defaultPOSProductRuntimePack,
      onlinePack,
    ]);

    final counts = POSProductRuntimePackSwitchAvailabilityCounts.fromCatalog(
      catalog: catalog,
      currentPack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
      order: _order(),
    );

    expect(
      counts.countFor(POSProductRuntimePackSwitchAvailabilityFilterStatus.all),
      2,
    );
    expect(
      counts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.current,
      ),
      1,
    );
    expect(
      counts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.available,
      ),
      0,
    );
    expect(
      counts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm,
      ),
      1,
    );
    expect(
      counts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked,
      ),
      0,
    );

    final queryCounts =
        POSProductRuntimePackSwitchAvailabilityCounts.fromCatalog(
          catalog: catalog,
          currentPack: defaultPOSProductRuntimePack,
          currentExperienceId: 'standard_cashier',
          currentCommerceChannelId: 'in_store',
          query: 'switches mode',
          order: _order(),
        );

    expect(
      queryCounts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.all,
      ),
      1,
    );
    expect(
      queryCounts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm,
      ),
      1,
    );
  });

  test('runtime pack availability filter includes blocked paid orders', () {
    final noPaymentPack = _noPaymentPack();
    final catalog = POSProductRuntimePackCatalog.fromPacks([
      defaultPOSProductRuntimePack,
      noPaymentPack,
    ]);

    final result = POSProductRuntimePackSwitchAvailabilityFilter(
      status: POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked,
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
    ).apply(
      catalog: catalog,
      currentPack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
    );

    expect(result.matchCount, 1);
    expect(result.packs.single.id, noPaymentPack.id);
    expect(result.availabilities.single.statusLabel, 'Finish order');

    final counts = POSProductRuntimePackSwitchAvailabilityCounts.fromCatalog(
      catalog: catalog,
      currentPack: defaultPOSProductRuntimePack,
      currentExperienceId: 'standard_cashier',
      currentCommerceChannelId: 'in_store',
      query: 'no payment',
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
      counts.countFor(POSProductRuntimePackSwitchAvailabilityFilterStatus.all),
      1,
    );
    expect(
      counts.countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked,
      ),
      1,
    );
  });

  test('runtime pack switch controller exposes filtered availability', () {
    final onlinePack = _onlinePack();
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: defaultPOSProductRuntimePack.id,
      packs: [defaultPOSProductRuntimePack, onlinePack],
    );
    final container = ProviderContainer(
      overrides: [
        posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      posProductRuntimePackSwitchControllerProvider,
    );
    final result = controller.filterAvailability(
      const POSProductRuntimePackSwitchAvailabilityFilter(query: 'online'),
    );

    expect(result.packs.single.id, onlinePack.id);
    expect(
      controller.availabilityCounts().countFor(
        POSProductRuntimePackSwitchAvailabilityFilterStatus.all,
      ),
      2,
    );
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
