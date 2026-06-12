import '../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../point_of_sales/cashier/models/customer.dart';
import '../../point_of_sales/cashier/models/terminal.dart';
import '../../point_of_sales/order/models/order.dart' as pos_order;
import '../../point_of_sales/order/models/order_fulfillment_snapshot.dart';
import '../../point_of_sales/order/models/order_item.dart';
import '../../point_of_sales/payment/models/payment.dart';
import '../channel/models/sales_channel.dart';
import '../checkout/models/fulfillment.dart';
import '../checkout/models/payment_selection.dart'
    hide ecommercePaymentMethodLabel, ecommercePaymentReferencePrefix;
import '../order/cart_item.dart';
import '../order/order.dart' show PaymentMethod;

const ecommercePOSChannelId = 'web_store';
const ecommercePOSChannelLabel = 'Web store';

final ecommercePOSTerminal = Terminal(
  id: 'web',
  name: ' storefront',
  location: 'Online',
  isActive: true,
);

List<OrderItem> ecommerceCartToPOSOrderItems(List<CartItem> cartItems) {
  return List.unmodifiable(
    cartItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return OrderItem(
        id: 'line_${index + 1}_${item.product.id}',
        product: item.product,
        quantity: item.quantity,
        unitPrice: item.product.price,
        discount: 0,
      );
    }),
  );
}

Payment ecommercePaymentForMethod({
  required PaymentMethod method,
  required double amount,
  required DateTime timestamp,
}) {
  return ecommercePaymentForSelection(
    payment: PaymentSelection.method(method),
    amount: amount,
    timestamp: timestamp,
  );
}

Payment ecommercePaymentForSelection({
  required PaymentSelection payment,
  required double amount,
  required DateTime timestamp,
}) {
  return Payment(
    id: 'payment_${timestamp.microsecondsSinceEpoch}',
    amount: amount,
    method: payment.label,
    timestamp: timestamp,
    reference: payment.referenceFor(timestamp),
    isComplete: true,
  );
}

pos_order.Order buildPOSOrder({
  required List<CartItem> cartItems,
  PaymentMethod? paymentMethod,
  PaymentSelection? payment,
  DateTime? createdAt,
  String? id,
  Customer? customer,
  POSCommerceChannel salesChannel = SalesChannels.defaultChannel,
  FulfillmentSelection fulfillment = const FulfillmentSelection.shipment(),
}) {
  final timestamp = createdAt ?? DateTime.now();
  final items = ecommerceCartToPOSOrderItems(cartItems);
  final total = items.fold<double>(0, (sum, item) => sum + item.total);
  final paymentSelection =
      payment ??
      (paymentMethod == null
          ? throw ArgumentError(' checkout requires a payment.')
          : PaymentSelection.method(paymentMethod));

  return pos_order.Order(
    id: id ?? 'ECOM${timestamp.millisecondsSinceEpoch}',
    items: items,
    customer: customer,
    payments: [
      ecommercePaymentForSelection(
        payment: paymentSelection,
        amount: total,
        timestamp: timestamp,
      ),
    ],
    terminal: ecommercePOSTerminal,
    appliedPromotions: const [],
    createdAt: timestamp,
    status: 'pending',
    fulfillment: ecommerceFulfillmentSnapshot(
      fulfillment,
      salesChannel: salesChannel,
    ),
  );
}

OrderFulfillmentSnapshot ecommerceFulfillmentSnapshot(
  FulfillmentSelection fulfillment, {
  POSCommerceChannel salesChannel = SalesChannels.defaultChannel,
}) {
  return OrderFulfillmentSnapshot(
    commerceChannelId: salesChannel.id,
    commerceChannelLabel: salesChannel.label,
    fulfillmentModeKey: fulfillment.modeKey,
    fulfillmentModeLabel: fulfillment.modeLabel,
    contactName: fulfillment.contactName,
    destination: fulfillment.destination,
    scheduleLabel: fulfillment.scheduleLabel,
    note: fulfillment.note,
    statusLabel: 'Paid',
    summaryLabel: fulfillment.summaryLabel,
  );
}

String ecommercePaymentMethodLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.card:
      return 'Card';
    case PaymentMethod.mobilePay:
      return 'Mobile Pay';
  }
}

String ecommercePaymentReference(PaymentMethod method, DateTime timestamp) {
  final prefix = switch (method) {
    PaymentMethod.cash => 'CASH',
    PaymentMethod.card => 'CARD',
    PaymentMethod.mobilePay => 'MOBILE',
  };
  return '$prefix-${timestamp.millisecondsSinceEpoch}';
}
