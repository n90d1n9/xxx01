import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'product_profile.dart';

enum ProfileBusinessMotion {
  omnichannel,
  operations,
  assistedSelling,
  subscription,
  fulfillment,
  marketplace,
  focused,
}

extension ProfileBusinessMotionLabel on ProfileBusinessMotion {
  String get label {
    return switch (this) {
      ProfileBusinessMotion.omnichannel => 'Omnichannel motion',
      ProfileBusinessMotion.operations => 'Operations motion',
      ProfileBusinessMotion.assistedSelling => 'Assisted selling',
      ProfileBusinessMotion.subscription => 'Subscription motion',
      ProfileBusinessMotion.fulfillment => 'Fulfillment motion',
      ProfileBusinessMotion.marketplace => 'Marketplace motion',
      ProfileBusinessMotion.focused => 'Focused commerce',
    };
  }
}

ProfileBusinessMotion profileBusinessMotionForProfile(ProductProfile profile) {
  return profileBusinessMotionFor(
    capabilities: profile.capabilities,
    moduleIds: profile.modules.map((module) => module.id),
    salesChannels: profile.salesChannels,
  );
}

ProfileBusinessMotion profileBusinessMotionFor({
  required Iterable<ProductCapability> capabilities,
  Iterable<String> moduleIds = const [],
  Iterable<POSCommerceChannel> salesChannels = const [],
}) {
  final capabilitySet = capabilities.toSet();
  final hasStructuredCapabilities = capabilitySet.isNotEmpty;
  final normalizedModuleIds =
      moduleIds
          .map((moduleId) => moduleId.trim().toLowerCase())
          .where((moduleId) => moduleId.isNotEmpty)
          .toSet();
  final channelKinds = salesChannels.map((channel) => channel.kind).toSet();

  bool hasCapability(ProductCapability capability) {
    return capabilitySet.contains(capability);
  }

  bool hasModuleFragment(String fragment) {
    return normalizedModuleIds.any((moduleId) => moduleId.contains(fragment));
  }

  final hasSubscription =
      hasCapability(ProductCapability.subscriptionBilling) ||
      hasModuleFragment('subscription');
  final hasMarketplace =
      hasCapability(ProductCapability.marketplaceOrders) ||
      hasModuleFragment('marketplace') ||
      channelKinds.contains(POSCommerceChannelKind.marketplace);
  final hasRemotePayment =
      hasCapability(ProductCapability.remotePayment) ||
      hasModuleFragment('remote') ||
      channelKinds.contains(POSCommerceChannelKind.socialOrder) ||
      channelKinds.contains(POSCommerceChannelKind.phoneOrder);
  final hasFulfillment =
      hasCapability(ProductCapability.pickupDelivery) ||
      hasCapability(ProductCapability.shipping) ||
      hasModuleFragment('fulfillment') ||
      channelKinds.contains(POSCommerceChannelKind.deliveryApp) ||
      channelKinds.contains(POSCommerceChannelKind.wholesale);
  final hasStorefront =
      hasCapability(ProductCapability.storefrontCheckout) ||
      (!hasStructuredCapabilities &&
          channelKinds.contains(POSCommerceChannelKind.webStore));
  final hasOperations = hasCapability(ProductCapability.operationsReview);

  if (hasSubscription) {
    return ProfileBusinessMotion.subscription;
  }
  if (hasMarketplace && hasModuleFragment('marketplace')) {
    return ProfileBusinessMotion.marketplace;
  }
  if (hasRemotePayment && !hasMarketplace) {
    return ProfileBusinessMotion.assistedSelling;
  }
  if (hasFulfillment && hasModuleFragment('fulfillment')) {
    return ProfileBusinessMotion.fulfillment;
  }
  if (hasStorefront && hasMarketplace) {
    return ProfileBusinessMotion.omnichannel;
  }
  if (hasOperations) {
    return ProfileBusinessMotion.operations;
  }
  if (hasMarketplace) {
    return ProfileBusinessMotion.marketplace;
  }
  if (hasFulfillment) {
    return ProfileBusinessMotion.fulfillment;
  }
  if (hasRemotePayment) {
    return ProfileBusinessMotion.assistedSelling;
  }

  return ProfileBusinessMotion.focused;
}
