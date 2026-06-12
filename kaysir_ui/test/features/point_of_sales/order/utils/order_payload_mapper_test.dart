import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/customer.dart';
import 'package:kaysir/features/point_of_sales/cashier/models/terminal.dart';
import 'package:kaysir/features/point_of_sales/order/models/order.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_item.dart';
import 'package:kaysir/features/point_of_sales/order/utils/order_payload_mapper.dart';
import 'package:kaysir/features/point_of_sales/payment/models/payment.dart';
import 'package:kaysir/features/point_of_sales/promotion/models/promotion.dart';
import 'package:kaysir/features/product/models/product.dart';

void main() {
  test('buildPOSOrderPayload includes order totals and line details', () {
    final payload = buildPOSOrderPayload(_order());
    final totals = payload['totals']! as Map<String, Object?>;
    final items = payload['items']! as List<Object?>;
    final item = items.single! as Map<String, Object?>;
    final product = item['product']! as Map<String, Object?>;

    expect(payload['id'], 'order_1');
    expect(payload['status'], 'completed');
    expect(payload['createdAt'], '2026-05-30T09:00:00.000');
    expect(totals['subtotal'], 100000);
    expect(totals['discountTotal'], 15000);
    expect(totals['total'], 85000);
    expect(totals['paidAmount'], 100000);
    expect(totals['remainingAmount'], -15000);
    expect(totals['isPaid'], isTrue);
    expect(item['quantity'], 2);
    expect(item['unitPrice'], 50000);
    expect(item['discount'], 0);
    expect(item['total'], 100000);
    expect(product['id'], 'coffee');
    expect(product['sku'], 'COF-1');
    expect(product['barcode'], '899123');
  });

  test(
    'payload carries customer, payment, promotion, and fulfillment data',
    () {
      final payload = _order().toPOSPayload();
      final customer = payload['customer']! as Map<String, Object?>;
      final terminal = payload['terminal']! as Map<String, Object?>;
      final fulfillment = payload['fulfillment']! as Map<String, Object?>;
      final payments = payload['payments']! as List<Object?>;
      final payment = payments.single! as Map<String, Object?>;
      final promotions = payload['promotions']! as List<Object?>;
      final promotion = promotions.single! as Map<String, Object?>;

      expect(customer['id'], 'customer_1');
      expect(customer['loyaltyPoints'], 10);
      expect(terminal['name'], 'Terminal 1');
      expect(fulfillment['commerceChannelId'], 'delivery_app');
      expect(fulfillment['fulfillmentModeKey'], 'delivery');
      expect(fulfillment['destination'], 'Jl. Merdeka 10');
      expect(fulfillment['note'], 'Call before drop-off');
      expect(payment['method'], 'Cash');
      expect(payment['timestamp'], '2026-05-30T09:15:00.000');
      expect(promotion['code'], 'WELCOME');
      expect(promotion['validUntil'], '2026-06-30T00:00:00.000');
    },
  );

  test('payload can omit nullable customer and fulfillment data', () {
    final payload = buildPOSOrderPayload(
      _order(includeCustomer: false, includeFulfillment: false),
    );

    expect(payload['customer'], isNull);
    expect(payload['fulfillment'], isNull);
  });
}

Order _order({
  Customer? customer,
  OrderFulfillmentSnapshot? fulfillment,
  bool includeCustomer = true,
  bool includeFulfillment = true,
}) {
  final product = Product(
    id: 'coffee',
    name: 'Coffee',
    price: 50000,
    sku: 'COF-1',
    barcode: '899123',
    category: 'Drinks',
    unit: 'cup',
  );

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
    customer:
        includeCustomer
            ? customer ??
                Customer(
                  id: 'customer_1',
                  name: 'Aisyah',
                  phone: '08123456789',
                  email: 'aisyah@example.com',
                  loyaltyPoints: 10,
                )
            : null,
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
    terminal: Terminal(
      id: 'terminal_1',
      name: 'Terminal 1',
      location: 'Front',
      isActive: true,
    ),
    appliedPromotions: [
      Promotion(
        id: 'promotion_1',
        name: 'Welcome',
        code: 'WELCOME',
        discountPercentage: 10,
        discountAmount: 5000,
        isActive: true,
        validUntil: DateTime(2026, 6, 30),
      ),
    ],
    createdAt: DateTime(2026, 5, 30, 9),
    status: 'completed',
    fulfillment:
        includeFulfillment
            ? fulfillment ??
                const OrderFulfillmentSnapshot(
                  commerceChannelId: 'delivery_app',
                  commerceChannelLabel: 'Delivery app',
                  fulfillmentModeKey: 'delivery',
                  fulfillmentModeLabel: 'Delivery',
                  destination: 'Jl. Merdeka 10',
                  note: 'Call before drop-off',
                  statusLabel: 'Delivery ready',
                  summaryLabel: 'Jl. Merdeka 10',
                )
            : null,
  );
}
