import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'capability.dart';

enum ChannelCoverageRequirementType {
  payments,
  customers,
  fulfillmentTracking,
  custom,
}

class ChannelCoverageRequirement {
  final String id;
  final ChannelCoverageRequirementType type;
  final String label;
  final CapabilityGate capabilityGate;
  final POSCommerceChannelCapability channelCapability;
  final String coveredDetail;
  final String missingDetail;
  final String optionalDetail;
  final ChannelCoverageRecommendationCopy? recommendation;

  const ChannelCoverageRequirement({
    required this.id,
    required this.type,
    required this.label,
    required this.capabilityGate,
    required this.channelCapability,
    required this.coveredDetail,
    required this.missingDetail,
    required this.optionalDetail,
    this.recommendation,
  });

  bool isRequiredFor(Iterable<ProductCapability> capabilities) {
    return capabilityGate.allows(capabilities);
  }

  int coveredChannelCount(Iterable<POSCommerceChannel> channels) {
    return channels
        .where((channel) => channel.supportsCapability(channelCapability))
        .length;
  }
}

class ChannelCoverageRecommendationCopy {
  final String title;
  final String detail;
  final String actionLabel;
  final int priority;

  const ChannelCoverageRecommendationCopy({
    required this.title,
    required this.detail,
    required this.actionLabel,
    required this.priority,
  });
}

const List<ChannelCoverageRequirement> defaultChannelCoverageRequirements = [
  ChannelCoverageRequirement(
    id: 'payments',
    type: ChannelCoverageRequirementType.payments,
    label: 'Payments',
    capabilityGate: CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.remotePayment,
      ProductCapability.subscriptionBilling,
    ]),
    channelCapability: POSCommerceChannelCapability.payments,
    coveredDetail: 'Payment-capable channels',
    missingDetail: 'No payment-capable channel',
    optionalDetail: 'Not required by profile',
  ),
  ChannelCoverageRequirement(
    id: 'customers',
    type: ChannelCoverageRequirementType.customers,
    label: 'Customers',
    capabilityGate: CapabilityGate.any([
      ProductCapability.storefrontCheckout,
      ProductCapability.remotePayment,
      ProductCapability.subscriptionBilling,
    ]),
    channelCapability: POSCommerceChannelCapability.customerIdentity,
    coveredDetail: 'Customer-aware channels',
    missingDetail: 'No customer-aware channel',
    optionalDetail: 'Not required by profile',
  ),
  ChannelCoverageRequirement(
    id: 'fulfillment_tracking',
    type: ChannelCoverageRequirementType.fulfillmentTracking,
    label: 'Tracking',
    capabilityGate: CapabilityGate.any([
      ProductCapability.pickupDelivery,
      ProductCapability.shipping,
    ]),
    channelCapability: POSCommerceChannelCapability.fulfillmentTracking,
    coveredDetail: 'Fulfillment tracking channels',
    missingDetail: 'No fulfillment tracking',
    optionalDetail: 'Not required by profile',
  ),
];

const ecommerceMarketplacePriceListChannelCoverageRequirement =
    ChannelCoverageRequirement(
      id: 'price_lists',
      type: ChannelCoverageRequirementType.custom,
      label: 'Price lists',
      capabilityGate: CapabilityGate.any([ProductCapability.marketplaceOrders]),
      channelCapability: POSCommerceChannelCapability.priceLists,
      coveredDetail: 'Price-list channels',
      missingDetail: 'No price-list channel',
      optionalDetail: 'Not required by profile',
      recommendation: ChannelCoverageRecommendationCopy(
        title: 'Add price-list channel coverage',
        detail:
            'Marketplace operations need a channel that can apply marketplace-specific price lists before orders are reconciled.',
        actionLabel: 'Review price lists',
        priority: 55,
      ),
    );

ChannelCoverageRequirement channelCoverageRequirementFor({
  required ChannelCoverageRequirementType type,
  Iterable<ChannelCoverageRequirement> requirements =
      defaultChannelCoverageRequirements,
}) {
  return requirements.firstWhere((requirement) => requirement.type == type);
}
