import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_promise_policy.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_launch_context.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_content.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderWorkspaceContent renders workspace controls and orders', (
    tester,
  ) async {
    _setViewport(tester, const Size(1360, 1400));
    OrderWorkspaceView? selectedWorkspace;
    (String, String)? statusChange;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OrderWorkspaceContent(
              orders: [_order(id: 'ECOM-ready', status: 'ready'), _order()],
              filter: const OrderFilter(),
              sortMode: OrderSortMode.newest,
              fulfillmentPromisePolicy: const OrderFulfillmentPromisePolicy(),
              launchContext: const OrderWorkspaceLaunchContext(
                sourceProfileId: 'fulfillment_first',
                sourceProfileLabel: 'Fulfillment first commerce',
                orderWorkspaceProfileId: 'delivery_ops',
                reason: OrderWorkspaceLaunchReason.profileDetails,
              ),
              salesChannels: const [SalesChannels.deliveryApp],
              now: DateTime(2026, 6, 2, 10),
              onFilterChanged: (_) {},
              onSortChanged: (_) {},
              onWorkspaceViewSelected:
                  (workspace) => selectedWorkspace = workspace,
              onOrderStatusChanged:
                  (order, status) => statusChange = (order.id, status),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_workspace_content')),
      findsOneWidget,
    );
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Opened from Fulfillment first commerce'), findsOneWidget);
    expect(find.text('Profile details - delivery_ops'), findsOneWidget);
    expect(find.text('All orders'), findsWidgets);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('ECOM-delivery'), findsOneWidget);
    expect(find.text('ECOM-ready'), findsOneWidget);
    expect(find.text('Clear active exceptions'), findsOneWidget);
    expect(find.text('Delivery app'), findsWidgets);
    expect(find.text('Web store'), findsNothing);

    await tester.ensureVisible(_choiceChip('Priority queue'));
    await tester.pump();
    await tester.tap(_choiceChip('Priority queue'));
    await tester.pump();

    expect(selectedWorkspace?.id, 'priority_queue');

    await tester.tap(find.text('ECOM-delivery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept order'));
    await tester.pump();

    expect(statusChange, ('ECOM-delivery', 'processing'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderWorkspaceContent renders empty workspace guidance', (
    tester,
  ) async {
    _setViewport(tester, const Size(620, 720));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: OrderWorkspaceContent(
              orders: const [],
              filter: const OrderFilter(),
              sortMode: OrderSortMode.newest,
              fulfillmentPromisePolicy: const OrderFulfillmentPromisePolicy(),
              now: DateTime(2026, 6, 2, 10),
              onFilterChanged: (_) {},
              onSortChanged: (_) {},
              onWorkspaceViewSelected: (_) {},
              onOrderStatusChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('0/0'), findsOneWidget);
    expect(find.text('No orders yet'), findsOneWidget);
    expect(
      find.text('Orders created from ecommerce checkout will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Finder _choiceChip(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip));
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Order _order({String id = 'ECOM-delivery', String status = 'pending'}) {
  final product = Product(id: '$id-product', name: 'Iced Latte', price: 50000);
  final createdAt = DateTime(2026, 6, 2, 9);

  return Order(
    id: id,
    items: [
      OrderItem(
        id: '$id-line',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: '$id-payment',
        amount: product.price,
        method: 'Delivery app settlement',
        timestamp: createdAt,
        reference: 'DELIVERY_APP-${createdAt.millisecondsSinceEpoch}',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: '$id-terminal',
      name: 'Terminal',
      location: 'Online',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: createdAt,
    status: status,
    fulfillment: const OrderFulfillmentSnapshot(
      commerceChannelId: 'delivery_app',
      commerceChannelLabel: 'Delivery app',
      fulfillmentModeKey: 'delivery',
      fulfillmentModeLabel: 'Delivery',
      contactName: 'Amina',
      destination: 'Jl. Sudirman 2',
      scheduleLabel: 'Today 16:00',
      statusLabel: 'Paid',
      summaryLabel: 'Delivery to Jl. Sudirman 2',
    ),
  );
}
