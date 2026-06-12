import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/states/pos_layout_provider.dart';
import '../../checkout/models/fulfillment.dart';

abstract final class SalesChannels {
  static const webStore = POSCommerceChannel(
    id: 'web_store',
    kind: POSCommerceChannelKind.webStore,
    label: 'Web store',
    description: 'Owned online storefront for direct-to-customer orders.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [
      POSFulfillmentMode.pickup,
      POSFulfillmentMode.delivery,
      POSFulfillmentMode.shipment,
    ],
    capabilities: [
      POSCommerceChannelCapability.payments,
      POSCommerceChannelCapability.customerIdentity,
      POSCommerceChannelCapability.promotions,
      POSCommerceChannelCapability.inventoryReservation,
      POSCommerceChannelCapability.fulfillmentTracking,
    ],
    traits: ['owned-online', 'async-order', 'customer-account'],
  );

  static const marketplace = POSCommerceChannel(
    id: 'marketplace',
    kind: POSCommerceChannelKind.marketplace,
    label: 'Marketplace',
    description: 'Third-party marketplace orders with platform policies.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [
      POSFulfillmentMode.delivery,
      POSFulfillmentMode.shipment,
    ],
    capabilities: [
      POSCommerceChannelCapability.inventoryReservation,
      POSCommerceChannelCapability.fulfillmentTracking,
      POSCommerceChannelCapability.priceLists,
    ],
    traits: ['third-party', 'fees', 'policy-bound'],
  );

  static const socialOrder = POSCommerceChannel(
    id: 'social_order',
    kind: POSCommerceChannelKind.socialOrder,
    label: 'Social order',
    description: 'Orders captured from chat, social, or assisted selling.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [
      POSFulfillmentMode.pickup,
      POSFulfillmentMode.delivery,
      POSFulfillmentMode.preorder,
    ],
    capabilities: [
      POSCommerceChannelCapability.customerIdentity,
      POSCommerceChannelCapability.payments,
      POSCommerceChannelCapability.fulfillmentTracking,
    ],
    traits: ['conversation-led', 'assisted', 'manual-confirmation'],
  );

  static const deliveryApp = POSCommerceChannel(
    id: 'delivery_app',
    kind: POSCommerceChannelKind.deliveryApp,
    label: 'Delivery app',
    description: 'Aggregator delivery orders with courier fulfillment.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [POSFulfillmentMode.delivery],
    capabilities: [
      POSCommerceChannelCapability.inventoryReservation,
      POSCommerceChannelCapability.fulfillmentTracking,
      POSCommerceChannelCapability.priceLists,
    ],
    traits: ['aggregator', 'courier', 'prep-time'],
  );

  static const phoneOrder = POSCommerceChannel(
    id: 'phone_order',
    kind: POSCommerceChannelKind.phoneOrder,
    label: 'Phone order',
    description: 'Assisted remote orders captured by staff.',
    preferredLayout: POSLayoutPreference.checkout,
    fulfillmentModes: [
      POSFulfillmentMode.pickup,
      POSFulfillmentMode.delivery,
      POSFulfillmentMode.preorder,
    ],
    capabilities: [
      POSCommerceChannelCapability.customerIdentity,
      POSCommerceChannelCapability.payments,
      POSCommerceChannelCapability.promotions,
      POSCommerceChannelCapability.fulfillmentTracking,
      POSCommerceChannelCapability.orderScheduling,
    ],
    traits: ['assisted-remote', 'manual-confirmation', 'callback-ready'],
  );

  static const wholesale = POSCommerceChannel(
    id: 'wholesale',
    kind: POSCommerceChannelKind.wholesale,
    label: 'Wholesale',
    description: 'B2B sales with negotiated pricing and staged fulfillment.',
    preferredLayout: POSLayoutPreference.counter,
    fulfillmentModes: [
      POSFulfillmentMode.pickup,
      POSFulfillmentMode.delivery,
      POSFulfillmentMode.shipment,
      POSFulfillmentMode.preorder,
    ],
    capabilities: [
      POSCommerceChannelCapability.customerIdentity,
      POSCommerceChannelCapability.priceLists,
      POSCommerceChannelCapability.inventoryReservation,
      POSCommerceChannelCapability.fulfillmentTracking,
      POSCommerceChannelCapability.returns,
    ],
    traits: ['b2b', 'price-list', 'account-managed'],
  );

  static const all = [
    webStore,
    marketplace,
    socialOrder,
    deliveryApp,
    phoneOrder,
    wholesale,
  ];

  static const defaultChannel = webStore;

  static POSCommerceChannel forId(String id) {
    final normalizedId = id.trim();
    for (final channel in all) {
      if (channel.id == normalizedId) return channel;
    }

    throw StateError('No ecommerce sales channel registered for "$id".');
  }

  static POSCommerceChannel? findById(String id) {
    final normalizedId = id.trim();
    for (final channel in all) {
      if (channel.id == normalizedId) return channel;
    }

    return null;
  }

  static List<FulfillmentSelection> fulfillmentOptionsFor(
    POSCommerceChannel channel,
  ) {
    return List.unmodifiable(
      channel.fulfillmentModes.map(FulfillmentOptions.forMode),
    );
  }

  static FulfillmentSelection defaultFulfillmentFor(
    POSCommerceChannel channel,
  ) {
    final modes = channel.fulfillmentModes;
    if (modes.isEmpty) return FulfillmentOptions.shipment;
    return FulfillmentOptions.forMode(modes.first);
  }
}
