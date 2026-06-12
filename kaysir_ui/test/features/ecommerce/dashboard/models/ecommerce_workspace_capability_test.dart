import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/capability.dart';

void main() {
  test('CapabilityGate.any accepts one matching capability', () {
    const gate = CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.remotePayment,
    ]);

    expect(gate.allows(const [ProductCapability.remotePayment]), isTrue);
    expect(gate.allows(const [ProductCapability.subscriptionBilling]), isFalse);
  });

  test('CapabilityGate.all requires every capability', () {
    const gate = CapabilityGate.all([
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
    ]);

    expect(
      gate.allows(const [
        ProductCapability.pickupDelivery,
        ProductCapability.shipping,
      ]),
      isTrue,
    );
    expect(gate.allows(const [ProductCapability.pickupDelivery]), isFalse);
  });
}
