import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/models/customer.dart';
import '../../../point_of_sales/order/models/order.dart' as pos_order;
import '../../cart/states/cart_providers.dart';
import '../../channel/models/sales_channel.dart';
import '../../order/cart_item.dart';
import '../../order/order.dart' show PaymentMethod;
import '../../order/states/order_provider.dart';
import '../models/checkout_session.dart';
import '../models/fulfillment.dart';
import '../models/payment_selection.dart';

final ecommerceCheckoutSessionProvider =
    StateNotifierProvider<CheckoutSessionNotifier, CheckoutSession>((ref) {
      return CheckoutSessionNotifier(ref);
    });

final ecommerceActiveCheckoutSessionProvider = Provider<CheckoutSession>((ref) {
  final session = ref.watch(ecommerceCheckoutSessionProvider);
  final cartItems = ref.watch(cartProvider);
  return session.copyWith(cartItems: cartItems);
});

class CheckoutSessionNotifier extends StateNotifier<CheckoutSession> {
  final Ref _ref;

  CheckoutSessionNotifier(this._ref) : super(CheckoutSession());

  void syncCart(Iterable<CartItem> cartItems) {
    state = state.copyWith(cartItems: cartItems);
  }

  void selectPaymentMethod(PaymentMethod paymentMethod) {
    state = state.copyWith(paymentMethod: paymentMethod);
  }

  void selectFulfillment(FulfillmentSelection fulfillment) {
    state = state.copyWith(fulfillment: fulfillment);
  }

  void selectSalesChannel(POSCommerceChannel channel) {
    final fulfillment =
        channel.supportsFulfillment(state.fulfillment.mode)
            ? state.fulfillment
            : state.fulfillment.copyWith(
              mode: SalesChannels.defaultFulfillmentFor(channel).mode,
            );

    final payment = PaymentPolicy.defaultPaymentForChannel(channel);

    state = state.copyWith(
      salesChannel: channel,
      fulfillment: fulfillment,
      payment: payment,
      clearPayment: payment == null,
    );
  }

  void selectFulfillmentMode(POSFulfillmentMode mode) {
    state = state.copyWith(fulfillment: state.fulfillment.copyWith(mode: mode));
  }

  void updateFulfillmentDetails({
    String? contactName,
    String? destination,
    String? scheduleLabel,
    String? note,
  }) {
    state = state.copyWith(
      fulfillment: state.fulfillment.copyWith(
        contactName: contactName,
        destination: destination,
        scheduleLabel: scheduleLabel,
        note: note,
      ),
    );
  }

  void setCustomer(Customer? customer) {
    state =
        customer == null
            ? state.copyWith(clearCustomer: true)
            : state.copyWith(customer: customer);
  }

  void reset() {
    state = CheckoutSession();
  }

  pos_order.Order complete({DateTime? createdAt}) {
    final cartItems = _ref.read(cartProvider);
    final checkout = state.copyWith(cartItems: cartItems);
    checkout.throwIfInvalid();

    final order = _ref
        .read(ecommerceOrdersProvider.notifier)
        .addCheckoutSession(checkout, createdAt: createdAt);
    _ref.read(cartProvider.notifier).clearCart();
    reset();
    return order;
  }
}
