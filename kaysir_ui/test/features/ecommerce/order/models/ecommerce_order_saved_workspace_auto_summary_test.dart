import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';

void main() {
  test('auto summary preview describes an unfiltered saved workspace', () {
    final description =
        ecommerceOrderSavedWorkspaceAutoSummaryPreviewDescription(
          const OrderSavedWorkspace(
            id: 'saved_default',
            label: 'Default',
            description: 'Default',
            filter: OrderFilter(),
            sortMode: OrderSortMode.newest,
          ),
        );

    expect(description, 'Saved custom order workspace.');
  });

  test('auto summary preview derives readable active filters', () {
    final description =
        ecommerceOrderSavedWorkspaceAutoSummaryPreviewDescription(
          const OrderSavedWorkspace(
            id: 'saved_filtered',
            label: 'Filtered',
            description: 'Filtered',
            filter: OrderFilter(
              channelId: 'delivery_app',
              fulfillmentModeKey: 'courier-pickup',
              status: 'ready_now',
              query: '  rush pickup  ',
            ),
            sortMode: OrderSortMode.oldest,
          ),
        );

    expect(
      description,
      'Channel: Delivery App • Fulfillment: Courier Pickup • '
      'Status: Ready Now • Search: rush pickup • Sort: Oldest',
    );
  });
}
