import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/models/customer.dart';

import '../../channel/models/sales_channel.dart';
import '../../order/cart_item.dart';
import '../../order/order.dart' show PaymentMethod;
import 'fulfillment.dart';
import 'fulfillment_requirement.dart';
import 'payment_selection.dart';

enum CheckoutIssueType {
  emptyCart,
  missingPaymentMethod,
  unsupportedFulfillmentMode,
  missingDeliveryDestination,
  missingFulfillmentDestination,
}

class CheckoutIssue {
  final CheckoutIssueType type;
  final String message;

  const CheckoutIssue({required this.type, required this.message});
}

class CheckoutSession {
  final List<CartItem> cartItems;
  final PaymentSelection? payment;
  final Customer? customer;
  final POSCommerceChannel salesChannel;
  final FulfillmentSelection fulfillment;

  CheckoutSession({
    Iterable<CartItem> cartItems = const [],
    PaymentSelection? payment,
    PaymentMethod? paymentMethod,
    this.customer,
    POSCommerceChannel? salesChannel,
    this.fulfillment = const FulfillmentSelection.shipment(),
  }) : cartItems = List.unmodifiable(cartItems),
       salesChannel = salesChannel ?? SalesChannels.defaultChannel,
       payment =
           payment ??
           (paymentMethod == null
               ? PaymentPolicy.defaultPaymentForChannel(
                 salesChannel ?? SalesChannels.defaultChannel,
               )
               : PaymentSelection.method(paymentMethod));

  PaymentMethod? get paymentMethod => payment?.method;

  bool get isEmpty => cartItems.isEmpty;

  double get total {
    return cartItems.fold(0, (sum, item) => sum + item.total);
  }

  List<CheckoutIssue> get validationIssues {
    final fulfillmentRequirement = FulfillmentRequirement.resolve(
      fulfillment: fulfillment,
      salesChannel: salesChannel,
    );

    final issues = <CheckoutIssue>[
      if (cartItems.isEmpty)
        const CheckoutIssue(
          type: CheckoutIssueType.emptyCart,
          message: 'Add at least one item before checkout.',
        ),
      if (payment == null)
        const CheckoutIssue(
          type: CheckoutIssueType.missingPaymentMethod,
          message: 'Choose a payment method before checkout.',
        ),
      if (!salesChannel.supportsFulfillment(fulfillment.mode))
        CheckoutIssue(
          type: CheckoutIssueType.unsupportedFulfillmentMode,
          message:
              '${fulfillment.modeLabel} is not available for ${salesChannel.label}.',
        ),
      if (cartItems.isNotEmpty &&
          fulfillmentRequirement.requiresDestination &&
          !fulfillment.hasDestination)
        CheckoutIssue(
          type: CheckoutIssueType.missingFulfillmentDestination,
          message: fulfillmentRequirement.missingDestinationMessage,
        ),
    ];

    return List.unmodifiable(issues);
  }

  bool get canSubmit => validationIssues.isEmpty;

  List<CheckoutIssue> get paymentBlockingIssues {
    return List.unmodifiable(
      validationIssues.where(
        (issue) => issue.type != CheckoutIssueType.missingPaymentMethod,
      ),
    );
  }

  bool get canSelectPayment => paymentBlockingIssues.isEmpty;

  PaymentMethod get resolvedPaymentMethod {
    final method = payment?.method;
    if (method == null) {
      throw StateError('Choose a payment method before checkout.');
    }

    return method;
  }

  PaymentSelection get resolvedPayment {
    final selection = payment;
    if (selection == null) {
      throw StateError('Choose a payment method before checkout.');
    }

    return selection;
  }

  void throwIfInvalid() {
    final issues = validationIssues;
    if (issues.isEmpty) return;

    throw StateError(issues.map((issue) => issue.message).join(' '));
  }

  CheckoutSession copyWith({
    Iterable<CartItem>? cartItems,
    PaymentSelection? payment,
    PaymentMethod? paymentMethod,
    bool clearPayment = false,
    bool clearPaymentMethod = false,
    Customer? customer,
    bool clearCustomer = false,
    POSCommerceChannel? salesChannel,
    FulfillmentSelection? fulfillment,
  }) {
    final nextPayment =
        clearPayment || clearPaymentMethod
            ? null
            : payment ??
                (paymentMethod == null
                    ? this.payment
                    : PaymentSelection.method(paymentMethod));

    return CheckoutSession(
      cartItems: cartItems ?? this.cartItems,
      payment: nextPayment,
      customer: clearCustomer ? null : customer ?? this.customer,
      salesChannel: salesChannel ?? this.salesChannel,
      fulfillment: fulfillment ?? this.fulfillment,
    );
  }
}
