import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment.dart';
import 'package:kaysir/features/ecommerce/checkout/models/fulfillment_requirement.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';

void main() {
  test('fulfillment requirements describe address-based modes', () {
    final delivery = FulfillmentRequirement.resolve(
      fulfillment: const FulfillmentSelection.delivery(),
      salesChannel: SalesChannels.webStore,
    );
    final shipment = FulfillmentRequirement.resolve(
      fulfillment: const FulfillmentSelection.shipment(),
      salesChannel: SalesChannels.webStore,
    );

    expect(delivery.showsDestinationField, isTrue);
    expect(delivery.requiresDestination, isTrue);
    expect(delivery.destinationLabel, 'Delivery destination');
    expect(
      delivery.missingDestinationMessage,
      'Add a delivery destination before checkout.',
    );

    expect(shipment.showsDestinationField, isTrue);
    expect(shipment.requiresDestination, isTrue);
    expect(shipment.destinationLabel, 'Shipping destination');
    expect(
      shipment.missingDestinationMessage,
      'Add a shipping destination before checkout.',
    );
  });

  test('fulfillment requirements keep destination hidden for pickup modes', () {
    final requirement = FulfillmentRequirement.resolve(
      fulfillment: const FulfillmentSelection.pickup(),
      salesChannel: SalesChannels.webStore,
    );

    expect(requirement.showsDestinationField, isFalse);
    expect(requirement.requiresDestination, isFalse);
  });

  test('fulfillment requirements support extended POS fulfillment modes', () {
    final requirement = FulfillmentRequirement.resolve(
      fulfillment: const FulfillmentSelection(
        mode: POSFulfillmentMode.fieldDelivery,
      ),
      salesChannel: SalesChannels.wholesale,
    );

    expect(requirement.showsDestinationField, isTrue);
    expect(requirement.requiresDestination, isTrue);
    expect(requirement.destinationLabel, 'Field delivery destination');
  });
}
