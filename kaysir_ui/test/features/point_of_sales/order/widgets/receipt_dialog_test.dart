import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/widgets/receipt_dialog.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  testWidgets('ReceiptDialog shows channel fulfillment details', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptDialog(
            order: _order(
              fulfillment: const OrderFulfillmentSnapshot(
                commerceChannelId: 'delivery_app',
                commerceChannelLabel: 'Delivery app',
                fulfillmentModeKey: 'delivery',
                fulfillmentModeLabel: 'Delivery',
                destination: 'Jl. Merdeka 10',
                statusLabel: 'Delivery ready',
                summaryLabel: 'Jl. Merdeka 10',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Channel'), findsOneWidget);
    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('Fulfillment'), findsOneWidget);
    expect(find.text('Delivery'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Jl. Merdeka 10'), findsOneWidget);
  });
}

Order _order({OrderFulfillmentSnapshot? fulfillment}) {
  final product = Product(id: 'coffee', name: 'Coffee', price: 50000);

  return Order(
    id: 'temp_order',
    items: [
      OrderItem(
        id: 'line_1',
        product: product,
        quantity: 1,
        unitPrice: product.price,
        discount: 0,
      ),
    ],
    payments: [
      Payment(
        id: 'payment_1',
        amount: 50000,
        method: 'Cash',
        timestamp: DateTime(2026, 5, 30, 9, 15),
        reference: 'REF1',
        isComplete: true,
      ),
    ],
    terminal: Terminal(
      id: 'terminal',
      name: 'Terminal',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: const [],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'completed',
    fulfillment: fulfillment,
  );
}
