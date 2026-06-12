import '../states/pos_layout_provider.dart';

enum POSCommerceChannelKind {
  inStore,
  kiosk,
  mobilePOS,
  webStore,
  marketplace,
  socialOrder,
  deliveryApp,
  wholesale,
  fieldSales,
  phoneOrder,
  tableService,
}

enum POSFulfillmentMode {
  immediateHandoff,
  pickup,
  delivery,
  shipment,
  tableService,
  preorder,
  fieldDelivery,
}

enum POSCommerceChannelCapability {
  payments,
  customerIdentity,
  promotions,
  inventoryReservation,
  offlineSelling,
  returns,
  fulfillmentTracking,
  priceLists,
  tableManagement,
  orderScheduling,
}

class POSCommerceChannel {
  final String id;
  final POSCommerceChannelKind kind;
  final String label;
  final String description;
  final POSLayoutPreference preferredLayout;
  final List<POSFulfillmentMode> fulfillmentModes;
  final List<POSCommerceChannelCapability> capabilities;
  final List<String> traits;

  const POSCommerceChannel({
    required this.id,
    required this.kind,
    required this.label,
    required this.description,
    required this.preferredLayout,
    required this.fulfillmentModes,
    required this.capabilities,
    this.traits = const [],
  });

  bool supportsCapability(POSCommerceChannelCapability capability) {
    return capabilities.contains(capability);
  }

  bool supportsFulfillment(POSFulfillmentMode mode) {
    return fulfillmentModes.contains(mode);
  }

  String get capabilitySummary {
    if (capabilities.isEmpty) return 'No capabilities';
    return capabilities.map((capability) => capability.label).join(', ');
  }

  String get fulfillmentSummary {
    if (fulfillmentModes.isEmpty) return 'No fulfillment modes';
    return fulfillmentModes.map((mode) => mode.label).join(', ');
  }

  String get traitSummary {
    if (traits.isEmpty) return 'No traits';
    return traits.join(', ');
  }
}

extension POSCommerceChannelKindLabel on POSCommerceChannelKind {
  String get label {
    switch (this) {
      case POSCommerceChannelKind.inStore:
        return 'In-store';
      case POSCommerceChannelKind.kiosk:
        return 'Kiosk';
      case POSCommerceChannelKind.mobilePOS:
        return 'Mobile POS';
      case POSCommerceChannelKind.webStore:
        return 'Web store';
      case POSCommerceChannelKind.marketplace:
        return 'Marketplace';
      case POSCommerceChannelKind.socialOrder:
        return 'Social order';
      case POSCommerceChannelKind.deliveryApp:
        return 'Delivery app';
      case POSCommerceChannelKind.wholesale:
        return 'Wholesale';
      case POSCommerceChannelKind.fieldSales:
        return 'Field sales';
      case POSCommerceChannelKind.phoneOrder:
        return 'Phone order';
      case POSCommerceChannelKind.tableService:
        return 'Table service';
    }
  }
}

extension POSFulfillmentModeLabel on POSFulfillmentMode {
  String get label {
    switch (this) {
      case POSFulfillmentMode.immediateHandoff:
        return 'Immediate handoff';
      case POSFulfillmentMode.pickup:
        return 'Pickup';
      case POSFulfillmentMode.delivery:
        return 'Delivery';
      case POSFulfillmentMode.shipment:
        return 'Shipment';
      case POSFulfillmentMode.tableService:
        return 'Table service';
      case POSFulfillmentMode.preorder:
        return 'Pre-order';
      case POSFulfillmentMode.fieldDelivery:
        return 'Field delivery';
    }
  }
}

extension POSCommerceChannelCapabilityLabel on POSCommerceChannelCapability {
  String get label {
    switch (this) {
      case POSCommerceChannelCapability.payments:
        return 'Payments';
      case POSCommerceChannelCapability.customerIdentity:
        return 'Customer identity';
      case POSCommerceChannelCapability.promotions:
        return 'Promotions';
      case POSCommerceChannelCapability.inventoryReservation:
        return 'Inventory reservation';
      case POSCommerceChannelCapability.offlineSelling:
        return 'Offline selling';
      case POSCommerceChannelCapability.returns:
        return 'Returns';
      case POSCommerceChannelCapability.fulfillmentTracking:
        return 'Fulfillment tracking';
      case POSCommerceChannelCapability.priceLists:
        return 'Price lists';
      case POSCommerceChannelCapability.tableManagement:
        return 'Table management';
      case POSCommerceChannelCapability.orderScheduling:
        return 'Order scheduling';
    }
  }
}
