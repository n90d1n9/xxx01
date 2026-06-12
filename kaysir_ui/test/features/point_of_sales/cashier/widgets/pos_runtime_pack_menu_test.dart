import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_registry.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_experience_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_profile.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_product_runtime_pack.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_product_runtime_pack_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_runtime_pack_menu.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('POSRuntimePackMenu hides when only one pack is registered', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: POSRuntimePackMenu())),
      ),
    );

    expect(find.byTooltip('Runtime pack: Kaysir Core POS'), findsNothing);
    expect(find.byIcon(Icons.apps_outlined), findsNothing);
  });

  testWidgets('POSRuntimePackMenu switches pack and dependent defaults', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(registry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(children: [POSRuntimePackMenu(), _RuntimePackProbe()]),
          ),
        ),
      ),
    );

    expect(
      find.text('kaysir_core|standard_cashier|in_store|auto'),
      findsOneWidget,
    );
    expect(find.byTooltip('Runtime pack: Kaysir Core POS'), findsOneWidget);

    await tester.tap(find.byTooltip('Runtime pack: Kaysir Core POS'));
    await tester.pumpAndSettle();

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.text('Online Pack'), findsOneWidget);
    expect(find.text('Current pack'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Kaysir Core'), findsWidgets);
    expect(find.text('Online'), findsWidgets);
    expect(find.text('1 pack'), findsWidgets);
    expect(find.text('1 mode | 1 channel'), findsOneWidget);
    expect(find.text('Switches mode and channel'), findsOneWidget);
    expect(find.text('Quick Checkout / Web store'), findsOneWidget);

    await tester.tap(_packMenuItem('Online Pack'));
    await tester.pumpAndSettle();

    expect(
      find.text('online_pack|quick_checkout|web_store|checkout'),
      findsOneWidget,
    );
    expect(find.byTooltip('Runtime pack: Online Pack'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_RuntimePackProbe)),
    );
    final history = container.read(posSwitchActionHistoryProvider);
    expect(history.latest?.result.kind, POSSwitchActionKind.runtimePack);
    expect(history.latest?.result.outcome, POSSwitchActionOutcome.applied);
    expect(history.latest?.result.targetId, 'online_pack');
  });

  testWidgets('POSRuntimePackMenu uses compact switch sheet on mobile widths', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(registry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSRuntimePackMenu(viewportWidth: 600),
                _RuntimePackProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Runtime pack: Kaysir Core POS'));
    await tester.pumpAndSettle();

    expect(find.text('Runtime packs'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Online Pack'), findsOneWidget);

    await tester.tap(find.text('Online Pack'));
    await tester.pumpAndSettle();

    expect(
      find.text('online_pack|quick_checkout|web_store|checkout'),
      findsOneWidget,
    );
  });

  testWidgets('POSRuntimePackMenu confirms before switching active orders', (
    tester,
  ) async {
    final registry = _runtimePackRegistry();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          posProductRuntimePackRegistryProvider.overrideWithValue(registry),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Column(children: [POSRuntimePackMenu(), _RuntimePackProbe()]),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_RuntimePackProbe)),
    );
    container.read(currentOrderProvider.notifier).restoreOrder(_activeOrder());
    await tester.pump();

    await tester.tap(find.byTooltip('Runtime pack: Kaysir Core POS'));
    await tester.pumpAndSettle();

    expect(find.text('Review order'), findsOneWidget);
    expect(
      find.text('Review order: Switches mode and channel'),
      findsOneWidget,
    );
    expect(find.text('Quick Checkout / Web store'), findsOneWidget);

    await tester.tap(_packMenuItem('Online Pack'));
    await tester.pumpAndSettle();

    expect(find.text('Keep current order?'), findsOneWidget);
    expect(
      find.textContaining('Switching to Online Pack keeps the current order'),
      findsOneWidget,
    );
    expect(
      find.text('kaysir_core|standard_cashier|in_store|auto'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.text('kaysir_core|standard_cashier|in_store|auto'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Runtime pack: Kaysir Core POS'));
    await tester.pumpAndSettle();
    await tester.tap(_packMenuItem('Online Pack'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep order'));
    await tester.pumpAndSettle();

    expect(
      find.text('online_pack|quick_checkout|web_store|checkout'),
      findsOneWidget,
    );
  });
}

POSProductRuntimePackRegistry _runtimePackRegistry() {
  final quickCheckoutProfile = defaultPOSProductRuntimePack
      .productProfileCatalog
      .profiles
      .firstWhere((profile) => profile.experience.id == 'quick_checkout');
  final webChannel = defaultPOSProductRuntimePack.commerceChannelRegistry
      .channelForId('web_store');
  final onlinePack = defaultPOSProductRuntimePack.copyWith(
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

  return POSProductRuntimePackRegistry(
    defaultPackId: defaultPOSProductRuntimePack.id,
    packs: [defaultPOSProductRuntimePack, onlinePack],
  );
}

Finder _packMenuItem(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(CheckedPopupMenuItem<String>),
  );
}

class _RuntimePackProbe extends ConsumerWidget {
  const _RuntimePackProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(posProductRuntimePackProvider);
    final experience = ref.watch(posExperienceProvider);
    final channel = ref.watch(posCommerceChannelProvider);
    final layoutPreference = ref.watch(posLayoutPreferenceProvider);

    return Text(
      '${pack.id}|${experience.id}|${channel.id}|${layoutPreference.name}',
    );
  }
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
