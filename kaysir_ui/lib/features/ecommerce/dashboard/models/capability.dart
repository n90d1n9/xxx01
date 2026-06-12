enum ProductCapability {
  storefrontCheckout,
  marketplaceOrders,
  remotePayment,
  pickupDelivery,
  shipping,
  subscriptionBilling,
  operationsReview,
}

extension ProductCapabilityLabel on ProductCapability {
  String get label {
    return switch (this) {
      ProductCapability.storefrontCheckout => 'Storefront',
      ProductCapability.marketplaceOrders => 'Marketplace',
      ProductCapability.remotePayment => 'Remote pay',
      ProductCapability.pickupDelivery => 'Pickup/delivery',
      ProductCapability.shipping => 'Shipping',
      ProductCapability.subscriptionBilling => 'Subscriptions',
      ProductCapability.operationsReview => 'Ops review',
    };
  }
}

enum CapabilityGateMode { any, all }

class CapabilityGate {
  final List<ProductCapability> capabilities;
  final CapabilityGateMode mode;

  const CapabilityGate.any(this.capabilities) : mode = CapabilityGateMode.any;

  const CapabilityGate.all(this.capabilities) : mode = CapabilityGateMode.all;

  const CapabilityGate._({required this.capabilities, required this.mode});

  static const always = CapabilityGate._(
    capabilities: [],
    mode: CapabilityGateMode.any,
  );

  bool allows(Iterable<ProductCapability> activeCapabilities) {
    if (capabilities.isEmpty) return true;

    final activeCapabilitySet = activeCapabilities.toSet();
    if (activeCapabilitySet.isEmpty) return false;

    return switch (mode) {
      CapabilityGateMode.any => capabilities.any(activeCapabilitySet.contains),
      CapabilityGateMode.all => capabilities.every(
        activeCapabilitySet.contains,
      ),
    };
  }
}
