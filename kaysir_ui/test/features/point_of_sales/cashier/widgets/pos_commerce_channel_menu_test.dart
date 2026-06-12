import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_order_fulfillment_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_history.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_switch_action_result.dart';
import 'package:kaysir/features/point_of_sales/cashier/states/pos_layout_provider.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_commerce_channel_menu.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/states/current_order_provider.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('POSCommerceChannelMenu switches channel and layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSCommerceChannelMenu(),
                _SelectedCommerceChannelProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('in_store:auto'), findsOneWidget);
    expect(find.byTooltip('Channel: In-store'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Commerce channels'), findsOneWidget);
    expect(find.text('Web store'), findsOneWidget);
    expect(find.text('Delivery, Shipment'), findsWidgets);
    expect(find.text('Checkout'), findsWidgets);

    await tester.tap(_channelMenuItem('Web store'));
    await tester.pumpAndSettle();

    expect(find.text('web_store:checkout'), findsOneWidget);
    expect(find.byTooltip('Channel: Web store'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SelectedCommerceChannelProbe)),
    );
    final history = container.read(posSwitchActionHistoryProvider);
    expect(history.latest?.result.kind, POSSwitchActionKind.commerceChannel);
    expect(history.latest?.result.outcome, POSSwitchActionOutcome.applied);
    expect(history.latest?.result.targetId, 'web_store');
  });

  testWidgets('POSCommerceChannelMenu opens compact switch sheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSCommerceChannelMenu(viewportWidth: 600),
                _SelectedCommerceChannelProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('in_store:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Commerce channels'), findsOneWidget);
    expect(find.text('Search channels'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'courier');
    await tester.pump();

    expect(find.text('Delivery app'), findsOneWidget);

    await tester.tap(find.text('Delivery app'));
    await tester.pumpAndSettle();

    expect(find.text('delivery_app:checkout'), findsOneWidget);
    expect(find.byTooltip('Channel: Delivery app'), findsOneWidget);
  });

  testWidgets(
    'POSCommerceChannelMenu compact sheet shows active order context',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  POSCommerceChannelMenu(viewportWidth: 600),
                  _SelectedCommerceChannelProbe(),
                ],
              ),
            ),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(_SelectedCommerceChannelProbe)),
      );
      container
          .read(currentOrderProvider.notifier)
          .restoreOrder(_activeOrder());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.storefront_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Commerce channels'), findsOneWidget);
      expect(find.text('Active order'), findsOneWidget);
      expect(find.text('1 line, 2 items, Rp 100.000'), findsOneWidget);
      expect(find.text('Payment due'), findsOneWidget);
    },
  );

  testWidgets('POSCommerceChannelMenu confirms active order channel changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                POSCommerceChannelMenu(),
                _SelectedCommerceChannelProbe(),
              ],
            ),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(_SelectedCommerceChannelProbe)),
    );
    container.read(currentOrderProvider.notifier).restoreOrder(_activeOrder());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Current channel'), findsOneWidget);
    expect(find.text('Review order'), findsWidgets);

    await tester.tap(_channelMenuItem('Web store'));
    await tester.pumpAndSettle();

    expect(find.text('Keep current order?'), findsOneWidget);
    expect(
      find.textContaining('Switching to Web store keeps the current order'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Add a customer or pickup name before closing.'),
      findsWidgets,
    );
    expect(find.text('Order stays active'), findsWidgets);
    expect(find.text('Fulfillment changes to Pickup'), findsWidgets);
    expect(find.text('Customer/contact required'), findsWidgets);
    expect(find.text('Pickup contact'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Keep order'))
          .onPressed,
      isNull,
    );
    expect(find.text('in_store:auto'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('in_store:auto'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await tester.pumpAndSettle();
    await tester.tap(_channelMenuItem('Web store'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('pos_channel_preflight_contact')),
      'Aisyah',
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Keep order'))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('Keep order'));
    await tester.pumpAndSettle();

    expect(find.text('web_store:checkout'), findsOneWidget);
    expect(
      container.read(posOrderFulfillmentContextProvider).contactName,
      'Aisyah',
    );
  });
}

Finder _channelMenuItem(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byType(CheckedPopupMenuItem<String>),
  );
}

class _SelectedCommerceChannelProbe extends ConsumerWidget {
  const _SelectedCommerceChannelProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channel = ref.watch(posCommerceChannelProvider);
    final layoutPreference = ref.watch(posLayoutPreferenceProvider);

    return Text('${channel.id}:${layoutPreference.name}');
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
