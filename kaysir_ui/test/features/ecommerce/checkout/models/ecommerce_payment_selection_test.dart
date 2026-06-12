import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/payment_selection.dart';
import 'package:kaysir/features/ecommerce/order/order.dart';

void main() {
  test('payment selection wraps manual ecommerce tenders', () {
    final timestamp = DateTime(2026, 6, 1, 10);
    final payment = PaymentSelection.method(PaymentMethod.mobilePay);

    expect(payment.method, PaymentMethod.mobilePay);
    expect(payment.label, 'Mobile Pay');
    expect(payment.isExternal, isFalse);
    expect(
      payment.referenceFor(timestamp),
      'MOBILE-${timestamp.millisecondsSinceEpoch}',
    );
  });

  test('payment policy defaults unpaid channels to external settlement', () {
    final deliveryApp = SalesChannels.deliveryApp;
    final webStore = SalesChannels.webStore;
    final payment = PaymentPolicy.defaultPaymentForChannel(deliveryApp);

    expect(payment?.isExternal, isTrue);
    expect(payment?.label, 'Delivery app settlement');
    expect(PaymentPolicy.defaultPaymentForChannel(webStore), isNull);
  });
}
