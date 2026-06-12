import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';

void main() {
  test('detail items expose complete default workspace filter state', () {
    final items = ecommerceOrderSavedWorkspaceDetailItems(
      const OrderSavedWorkspace(
        id: 'saved_default',
        label: 'Default',
        description: 'Default',
        filter: OrderFilter(),
        sortMode: OrderSortMode.newest,
      ),
    );

    expect(items.map((item) => item.id), [
      'channel',
      'fulfillment',
      'status',
      'time',
      'payment',
      'attention',
      'search',
      'sort',
    ]);
    expect(items.map((item) => item.label), [
      'Channel',
      'Fulfillment',
      'Status',
      'Time',
      'Payment',
      'Attention',
      'Search',
      'Sort',
    ]);
    expect(items.map((item) => item.value), [
      'All channels',
      'All fulfillment',
      'All statuses',
      OrderTimeScope.all.label,
      OrderPaymentScope.all.label,
      OrderAttentionScope.all.label,
      'No search query',
      OrderSortMode.newest.label,
    ]);
  });

  test('detail items normalize custom filter tokens and trim search text', () {
    final items = ecommerceOrderSavedWorkspaceDetailItems(
      const OrderSavedWorkspace(
        id: 'saved_filtered',
        label: 'Filtered',
        description: 'Filtered',
        filter: OrderFilter(
          channelId: 'delivery_app',
          fulfillmentModeKey: 'courier-pickup',
          status: 'ready now',
          timeScope: OrderTimeScope.today,
          paymentScope: OrderPaymentScope.externalSettlement,
          attentionScope: OrderAttentionScope.highPriority,
          query: '  rush pickup  ',
        ),
        sortMode: OrderSortMode.oldest,
      ),
    );

    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.channel),
      'Delivery App',
    );
    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.fulfillment),
      'Courier Pickup',
    );
    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.status),
      'Ready Now',
    );
    expect(_detailValue(items, OrderSavedWorkspaceDetailType.time), 'Today');
    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.payment),
      'External',
    );
    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.attention),
      'High priority',
    );
    expect(
      _detailValue(items, OrderSavedWorkspaceDetailType.search),
      'rush pickup',
    );
    expect(_detailValue(items, OrderSavedWorkspaceDetailType.sort), 'Oldest');
  });
}

String _detailValue(
  List<OrderSavedWorkspaceDetailItem> items,
  OrderSavedWorkspaceDetailType type,
) {
  return items.singleWhere((item) => item.type == type).value;
}
