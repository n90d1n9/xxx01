import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../point_of_sales/cashier/models/customer.dart';
import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../../channel/models/sales_channel.dart';
import '../../checkout/models/checkout_session.dart';
import '../../checkout/models/fulfillment.dart';
import '../../checkout/models/payment_selection.dart';
import '../../pos/pos_bridge.dart';
import '../cart_item.dart';
import '../models/order_lifecycle.dart';
import '../models/order_status.dart';
import '../order.dart' show PaymentMethod;

final ecommerceOrdersProvider =
    StateNotifierProvider<OrdersNotifier, List<pos_order.Order>>((ref) {
      return OrdersNotifier();
    });

class OrdersNotifier extends StateNotifier<List<pos_order.Order>> {
  OrdersNotifier() : super(const []);

  pos_order.Order addOrder(
    List<CartItem> cartItems,
    PaymentMethod paymentMethod, {
    DateTime? createdAt,
    Customer? customer,
    POSCommerceChannel salesChannel = SalesChannels.defaultChannel,
    PaymentSelection? payment,
    FulfillmentSelection fulfillment = const FulfillmentSelection.shipment(),
  }) {
    final order = buildPOSOrder(
      cartItems: cartItems,
      paymentMethod: paymentMethod,
      payment: payment,
      createdAt: createdAt,
      customer: customer,
      salesChannel: salesChannel,
      fulfillment: fulfillment,
    );
    state = [order, ...state];
    return order;
  }

  pos_order.Order addCheckoutSession(
    CheckoutSession checkout, {
    DateTime? createdAt,
  }) {
    checkout.throwIfInvalid();
    final order = buildPOSOrder(
      cartItems: checkout.cartItems,
      payment: checkout.resolvedPayment,
      createdAt: createdAt,
      customer: checkout.customer,
      salesChannel: checkout.salesChannel,
      fulfillment: checkout.fulfillment,
    );
    state = [order, ...state];
    return order;
  }

  bool updateOrderStatus(String orderId, String status) {
    var didUpdate = false;
    final nextStatus = normalizeOrderStatus(status);

    state =
        state.map((order) {
          if (order.id != orderId) return order;

          if (normalizeOrderStatus(order.status) == nextStatus) {
            didUpdate = true;
            return order;
          }

          if (!canTransitionOrderStatus(order, nextStatus)) {
            return order;
          }

          didUpdate = true;
          return order.copyWith(status: nextStatus);
        }).toList();

    return didUpdate;
  }
}
