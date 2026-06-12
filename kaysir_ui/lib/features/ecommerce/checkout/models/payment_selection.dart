import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../order/order.dart' show PaymentMethod;

class PaymentSelection {
  final PaymentMethod? method;
  final String label;
  final String referencePrefix;
  final bool isExternal;

  const PaymentSelection({
    required this.label,
    required this.referencePrefix,
    this.method,
    this.isExternal = false,
  });

  factory PaymentSelection.method(PaymentMethod method) {
    return PaymentSelection(
      method: method,
      label: ecommercePaymentMethodLabel(method),
      referencePrefix: ecommercePaymentReferencePrefix(method),
    );
  }

  factory PaymentSelection.externalChannel(POSCommerceChannel channel) {
    return PaymentSelection(
      label: '${channel.label} settlement',
      referencePrefix: channel.id.toUpperCase(),
      isExternal: true,
    );
  }

  String referenceFor(DateTime timestamp) {
    return '$referencePrefix-${timestamp.millisecondsSinceEpoch}';
  }
}

abstract final class PaymentPolicy {
  static bool usesExternalSettlement(POSCommerceChannel channel) {
    return !channel.supportsCapability(POSCommerceChannelCapability.payments);
  }

  static PaymentSelection? defaultPaymentForChannel(
    POSCommerceChannel channel,
  ) {
    if (!usesExternalSettlement(channel)) return null;
    return PaymentSelection.externalChannel(channel);
  }
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

String ecommercePaymentReferencePrefix(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'CASH';
    case PaymentMethod.card:
      return 'CARD';
    case PaymentMethod.mobilePay:
      return 'MOBILE';
  }
}
