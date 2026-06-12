import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_card.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('OrderCard highlights channel fulfillment and settlement', (
    tester,
  ) async {
    String? selectedStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 760,
              child: OrderCard(
                order: _order(),
                onStatusChanged: (status) => selectedStatus = status,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('ECOM-delivery'), findsOneWidget);
    expect(find.text('Delivery app settlement'), findsOneWidget);
    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Rp 50.000'), findsOneWidget);

    await tester.tap(find.text('ECOM-delivery'));
    await tester.pumpAndSettle();

    expect(find.text('Delivery app • Delivery'), findsOneWidget);
    expect(find.text('Delivery to Jl. Sudirman 2'), findsOneWidget);
    expect(_richTextContaining('Status: Paid'), findsOneWidget);
    expect(_richTextContaining('Contact: Amina'), findsOneWidget);
    expect(_richTextContaining('Destination: Jl. Sudirman 2'), findsOneWidget);
    expect(_richTextContaining('Schedule: Today 16:00'), findsOneWidget);
    expect(
      _richTextContaining('Note: Use insulated courier bag'),
      findsOneWidget,
    );
    expect(find.text('Payment summary'), findsOneWidget);
    expect(find.text('1 complete payment'), findsOneWidget);
    expect(find.text('Paid in full'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);
    expect(find.text('Fulfillment progress'), findsOneWidget);
    expect(find.text('Delivery fulfillment'), findsOneWidget);
    expect(find.text('New order'), findsOneWidget);
    expect(find.text('Preparing'), findsOneWidget);
    expect(find.text('Courier ready'), findsOneWidget);
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Operations attention'), findsOneWidget);
    expect(find.text('Needs acceptance'), findsOneWidget);
    expect(find.text('Settlement review'), findsOneWidget);
    expect(find.text('Accept order'), findsOneWidget);
    expect(find.text('Cancel order'), findsOneWidget);
    expect(find.text('Ready for courier'), findsNothing);

    await tester.ensureVisible(find.text('Accept order'));
    await tester.tap(find.text('Accept order'));
    await tester.pump();
    expect(selectedStatus, 'processing');
  });

  testWidgets('OrderCard uses fulfillment-specific ready action labels', (
    tester,
  ) async {
    String? selectedStatus;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 760,
              child: OrderCard(
                order: _order(status: 'processing'),
                onStatusChanged: (status) => selectedStatus = status,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ECOM-delivery'));
    await tester.pumpAndSettle();

    expect(find.text('Ready for courier'), findsOneWidget);

    await tester.ensureVisible(find.text('Ready for courier'));
    await tester.tap(find.text('Ready for courier'));
    await tester.pump();
    expect(selectedStatus, 'ready');
  });
}

Order _order({String status = 'pending'}) {
  final product = Product(id: 'latte', name: 'Iced Latte', price: 50000);
  final createdAt = DateTime(2026, 5, 31, 9);

  return Order(
    id: 'ECOM-delivery',
    items: [
      OrderItem(
        id: 'line-1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: 'payment-1',
        amount: 50000,
        method: 'Delivery app settlement',
        timestamp: createdAt,
        reference: 'DELIVERY_APP-${createdAt.millisecondsSinceEpoch}',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal',
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
      note: 'Use insulated courier bag',
      statusLabel: 'Paid',
      summaryLabel: 'Delivery to Jl. Sudirman 2',
    ),
  );
}

Finder _richTextContaining(String value) {
  return find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText().contains(value),
  );
}
