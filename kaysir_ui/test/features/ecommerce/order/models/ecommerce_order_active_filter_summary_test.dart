import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/channel/models/sales_channel.dart';
import 'package:kaysir/features/ecommerce/order/models/order_active_filter_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';

void main() {
  test('active filter summary describes custom order workspace state', () {
    final items = ecommerceOrderActiveFilterSummary(
      filter: const OrderFilter(
        channelId: 'delivery_app',
        fulfillmentModeKey: 'delivery',
        status: 'ready_for_pickup',
        timeScope: OrderTimeScope.today,
        paymentScope: OrderPaymentScope.externalSettlement,
        attentionScope: OrderAttentionScope.highPriority,
        query: 'Amina',
      ),
      sortMode: OrderSortMode.highestValue,
      channels: const [SalesChannels.deliveryApp],
      fulfillmentModes: const [
        OrderFulfillmentOption(key: 'delivery', label: 'Delivery'),
      ],
    );

    expect(items.map((item) => item.displayLabel), [
      'Channel: Delivery app',
      'Fulfillment: Delivery',
      'Status: Ready For Pickup',
      'Time: Today',
      'Settlement: External',
      'Attention: High priority',
      'Search: Amina',
      'Sort: Highest value',
    ]);
  });

  test('active filter summary omits default state and formats unknown ids', () {
    expect(
      ecommerceOrderActiveFilterSummary(
        filter: const OrderFilter(),
        sortMode: OrderSortMode.newest,
      ),
      isEmpty,
    );

    final items = ecommerceOrderActiveFilterSummary(
      filter: const OrderFilter(
        channelId: 'marketplace_a',
        fulfillmentModeKey: 'curbside_pickup',
      ),
      sortMode: OrderSortMode.newest,
    );

    expect(items.map((item) => item.displayLabel), [
      'Channel: Marketplace A',
      'Fulfillment: Curbside Pickup',
    ]);
  });

  test('active filter summary clear helper resets one dimension', () {
    const filter = OrderFilter(
      channelId: 'delivery_app',
      fulfillmentModeKey: 'delivery',
      status: 'ready',
      timeScope: OrderTimeScope.today,
      paymentScope: OrderPaymentScope.externalSettlement,
      attentionScope: OrderAttentionScope.highPriority,
      query: 'Amina',
    );
    const sortMode = OrderSortMode.highestValue;

    final channelCleared = ecommerceOrderActiveFilterStateAfterClear(
      filter: filter,
      sortMode: sortMode,
      type: OrderActiveFilterSummaryType.channel,
    );

    expect(channelCleared.filter.channelId, ecommerceOrderAllChannelsFilter);
    expect(channelCleared.filter.status, 'ready');
    expect(channelCleared.sortMode, sortMode);

    final searchCleared = ecommerceOrderActiveFilterStateAfterClear(
      filter: filter,
      sortMode: sortMode,
      type: OrderActiveFilterSummaryType.search,
    );

    expect(searchCleared.filter.query, isEmpty);
    expect(searchCleared.filter.channelId, 'delivery_app');
    expect(searchCleared.sortMode, sortMode);

    final sortCleared = ecommerceOrderActiveFilterStateAfterClear(
      filter: filter,
      sortMode: sortMode,
      type: OrderActiveFilterSummaryType.sort,
    );

    expect(sortCleared.filter.channelId, filter.channelId);
    expect(sortCleared.filter.fulfillmentModeKey, filter.fulfillmentModeKey);
    expect(sortCleared.filter.status, filter.status);
    expect(sortCleared.filter.timeScope, filter.timeScope);
    expect(sortCleared.filter.paymentScope, filter.paymentScope);
    expect(sortCleared.filter.attentionScope, filter.attentionScope);
    expect(sortCleared.filter.query, filter.query);
    expect(sortCleared.sortMode, OrderSortMode.newest);
    expect(OrderActiveFilterState.defaults.filter.hasActiveFilters, isFalse);
    expect(OrderActiveFilterState.defaults.sortMode, OrderSortMode.newest);
  });
}
