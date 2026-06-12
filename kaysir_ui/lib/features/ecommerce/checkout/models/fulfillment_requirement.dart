import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import 'fulfillment.dart';

class FulfillmentRequirement {
  final bool showsDestinationField;
  final bool requiresDestination;
  final String destinationLabel;
  final String destinationHint;
  final String missingDestinationMessage;

  const FulfillmentRequirement({
    required this.showsDestinationField,
    required this.requiresDestination,
    required this.destinationLabel,
    required this.destinationHint,
    required this.missingDestinationMessage,
  });

  factory FulfillmentRequirement.resolve({
    required FulfillmentSelection fulfillment,
    required POSCommerceChannel salesChannel,
  }) {
    return switch (fulfillment.mode) {
      POSFulfillmentMode.delivery => const FulfillmentRequirement(
        showsDestinationField: true,
        requiresDestination: true,
        destinationLabel: 'Delivery destination',
        destinationHint: 'Required address or delivery point',
        missingDestinationMessage:
            'Add a delivery destination before checkout.',
      ),
      POSFulfillmentMode.shipment => const FulfillmentRequirement(
        showsDestinationField: true,
        requiresDestination: true,
        destinationLabel: 'Shipping destination',
        destinationHint: 'Required recipient address',
        missingDestinationMessage:
            'Add a shipping destination before checkout.',
      ),
      POSFulfillmentMode.fieldDelivery => const FulfillmentRequirement(
        showsDestinationField: true,
        requiresDestination: true,
        destinationLabel: 'Field delivery destination',
        destinationHint: 'Required route, site, or delivery point',
        missingDestinationMessage:
            'Add a field delivery destination before checkout.',
      ),
      _ => FulfillmentRequirement(
        showsDestinationField: false,
        requiresDestination: false,
        destinationLabel: '${salesChannel.label} destination',
        destinationHint: 'Optional destination or service point',
        missingDestinationMessage: 'Add a destination before checkout.',
      ),
    };
  }
}
