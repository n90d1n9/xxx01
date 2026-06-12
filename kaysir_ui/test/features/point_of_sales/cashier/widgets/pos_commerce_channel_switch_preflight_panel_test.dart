import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/default_pos_commerce_channels.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_switch_plan.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_switch_preflight_panel.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('switch preflight panel saves target channel draft', (
    tester,
  ) async {
    final canConfirmNotifier = ValueNotifier<bool>(true);
    addTearDown(canConfirmNotifier.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSCommerceChannelSwitchPreflightPanel(
                  plan: _plan(targetChannelId: 'delivery_app'),
                  canConfirmNotifier: canConfirmNotifier,
                ),
                const _ProviderProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_ProviderProbe)),
    );

    expect(find.text('Delivery app fulfillment'), findsOneWidget);
    expect(find.text('Delivery destination'), findsOneWidget);
    expect(canConfirmNotifier.value, isFalse);

    await tester.enterText(
      find.byKey(const ValueKey('pos_channel_preflight_destination')),
      'Jl. Merdeka 10',
    );
    await tester.pump();

    final draftKey = posOrderFulfillmentDraftKey('order_1', 'delivery_app');
    final draft = container.read(posOrderFulfillmentDraftsProvider)[draftKey];

    expect(draft, isNotNull);
    expect(draft?.mode, POSFulfillmentMode.delivery);
    expect(draft?.destination, 'Jl. Merdeka 10');
    expect(canConfirmNotifier.value, isTrue);
  });
}

class _ProviderProbe extends ConsumerWidget {
  const _ProviderProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

POSCommerceChannelSwitchPlan _plan({required String targetChannelId}) {
  final currentChannel = defaultPOSCommerceChannelRegistry.channelForId(
    'in_store',
  );
  final targetChannel = defaultPOSCommerceChannelRegistry.channelForId(
    targetChannelId,
  );

  return POSCommerceChannelSwitchPlan.resolve(
    currentChannel: currentChannel,
    targetChannel: targetChannel,
    currentLayoutPreference: POSLayoutPreference.auto,
    currentFulfillmentContext: POSOrderFulfillmentContext.forChannel(
      currentChannel,
    ),
    targetFulfillmentContext: POSOrderFulfillmentContext.forChannel(
      targetChannel,
    ),
    order: _order(),
  );
}

Order _order() {
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
