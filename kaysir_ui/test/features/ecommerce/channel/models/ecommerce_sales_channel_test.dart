import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/point_of_sales/cashier/experiences/pos_commerce_channel.dart';

void main() {
  test('ecommerce sales channels expose omni-channel checkout options', () {
    expect(SalesChannels.defaultChannel.id, 'web_store');
    expect(
      SalesChannels.all.map((channel) => channel.id),
      containsAll([
        'web_store',
        'marketplace',
        'social_order',
        'delivery_app',
        'phone_order',
        'wholesale',
      ]),
    );
    expect(SalesChannels.forId('marketplace').label, 'Marketplace');
    expect(SalesChannels.findById('missing'), isNull);
  });

  test(
    'ecommerce sales channels map POS fulfillment into checkout options',
    () {
      final marketplace = SalesChannels.marketplace;
      final deliveryApp = SalesChannels.deliveryApp;

      expect(
        SalesChannels.fulfillmentOptionsFor(
          marketplace,
        ).map((option) => option.mode),
        [POSFulfillmentMode.delivery, POSFulfillmentMode.shipment],
      );
      expect(
        SalesChannels.defaultFulfillmentFor(deliveryApp).mode,
        POSFulfillmentMode.delivery,
      );
    },
  );
}
