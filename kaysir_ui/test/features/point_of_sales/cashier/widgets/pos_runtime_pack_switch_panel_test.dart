import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_experience.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_recipe.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack_controller.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_runtime_pack_switch_panel.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('runtime pack switch panel renders grouped packs and counts', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(_host(registry: registry, onPackSelected: (_) {}));

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsWidgets);
    expect(find.text('Online'), findsWidgets);
    expect(find.text('Kaysir Core POS'), findsWidgets);
    expect(find.text('Online Pack'), findsOneWidget);
    expect(find.text('Current pack'), findsOneWidget);
    expect(find.text('Available'), findsWidgets);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'All'),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Current'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('runtime pack switch panel reports selected packs', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();
    String? selectedPackId;

    await tester.pumpWidget(
      _host(
        registry: registry,
        onPackSelected: (pack) => selectedPackId = pack.id,
      ),
    );

    await tester.tap(find.text('Online Pack'));
    await tester.pumpAndSettle();

    expect(selectedPackId, 'online_pack');
  });

  testWidgets('runtime pack switch panel filters packs by query', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(_host(registry: registry, onPackSelected: (_) {}));

    await tester.enterText(find.byType(TextField), 'online');
    await tester.pumpAndSettle();

    expect(find.text('Online Pack'), findsOneWidget);
    expect(find.text('Current pack'), findsNothing);
  });

  testWidgets('runtime pack switch panel filters active order reviews', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(
      _host(
        registry: registry,
        currentOrder: _activeOrder(),
        onPackSelected: (_) {},
      ),
    );

    expect(find.text('Active order'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Review'));
    await tester.pumpAndSettle();

    expect(find.text('Online Pack'), findsOneWidget);
    expect(find.text('Review order'), findsWidgets);
    expect(
      find.text('Review order: Switches mode and channel'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Review'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('runtime pack switch panel filters blocked paid order packs', (
    tester,
  ) async {
    final registry = POSProductRuntimePackRegistry(
      defaultPackId: defaultPOSProductRuntimePack.id,
      packs: [defaultPOSProductRuntimePack, _noPaymentPack()],
    );

    await tester.pumpWidget(
      _host(
        registry: registry,
        currentOrder: _activeOrder(
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
        onPackSelected: (_) {},
      ),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pumpAndSettle();

    expect(find.text('No Payment Pack'), findsOneWidget);
    expect(find.text('Finish order'), findsOneWidget);
    expect(
      find.descendant(
        of: find.widgetWithText(ChoiceChip, 'Blocked'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });
}

Widget _host({
  required POSProductRuntimePackRegistry registry,
  required ValueChanged<POSProductRuntimePack> onPackSelected,
  Order? currentOrder,
}) {
  return ProviderScope(
    overrides: [
      posProductRuntimePackRegistryProvider.overrideWithValue(registry),
      selectedPOSProductRuntimePackIdProvider.overrideWith(
        (ref) => defaultPOSProductRuntimePack.id,
      ),
      selectedPOSExperienceIdProvider.overrideWith(
        (ref) => defaultPOSExperience.id,
      ),
      selectedPOSCommerceChannelIdProvider.overrideWith(
        (ref) =>
            defaultPOSProductRuntimePack
                .commerceChannelRegistry
                .defaultChannelId,
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Consumer(
          builder: (context, ref, _) {
            final controller = ref.watch(
              posProductRuntimePackSwitchControllerProvider,
            );

            return SizedBox(
              height: 560,
              child: POSRuntimePackSwitchPanel(
                controller: controller,
                currentOrder: currentOrder,
                onPackSelected: onPackSelected,
              ),
            );
          },
        ),
      ),
    ),
  );
}

POSProductRuntimePackRegistry _runtimePackRegistry() {
  final onlinePack = _onlinePack();

  return POSProductRuntimePackRegistry(
    defaultPackId: defaultPOSProductRuntimePack.id,
    packs: [defaultPOSProductRuntimePack, onlinePack],
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

Order _activeOrder({List<Payment> payments = const []}) {
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
