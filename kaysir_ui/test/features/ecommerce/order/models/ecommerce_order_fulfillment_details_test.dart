import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_details.dart';
import 'package:kaysir/features/point_of_sales/order/models/order_fulfillment_snapshot.dart';

void main() {
  test(
    'ecommerceOrderFulfillmentDetails exposes operator details in order',
    () {
      final details = ecommerceOrderFulfillmentDetails(
        const OrderFulfillmentSnapshot(
          commerceChannelId: 'delivery_app',
          commerceChannelLabel: 'Delivery app',
          fulfillmentModeKey: 'delivery',
          fulfillmentModeLabel: 'Delivery',
          contactName: 'Amina',
          destination: 'Jl. Sudirman 2',
          tableName: 'Patio 4',
          scheduleLabel: 'Today 16:00',
          note: 'Use insulated courier bag',
          statusLabel: 'Paid',
          summaryLabel: 'Delivery to Jl. Sudirman 2',
        ),
      );

      expect(details.map((detail) => detail.label), [
        'Status',
        'Contact',
        'Destination',
        'Table',
        'Schedule',
        'Note',
      ]);
      expect(details.map((detail) => detail.value), [
        'Paid',
        'Amina',
        'Jl. Sudirman 2',
        'Patio 4',
        'Today 16:00',
        'Use insulated courier bag',
      ]);
    },
  );

  test('ecommerceOrderFulfillmentDetails skips blank values', () {
    final details = ecommerceOrderFulfillmentDetails(
      const OrderFulfillmentSnapshot(
        commerceChannelId: 'web_store',
        commerceChannelLabel: 'Web store',
        fulfillmentModeKey: 'pickup',
        fulfillmentModeLabel: 'Pickup',
        contactName: ' ',
        statusLabel: 'Ready',
      ),
    );

    expect(details.length, 1);
    expect(details.single.kind, OrderFulfillmentDetailKind.status);
    expect(details.single.value, 'Ready');
  });
}
