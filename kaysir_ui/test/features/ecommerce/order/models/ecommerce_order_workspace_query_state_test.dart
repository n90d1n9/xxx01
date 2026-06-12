import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/order/models/order_attention.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_fulfillment_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_payment_scope.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_query_state.dart';

void main() {
  test('workspace query state round-trips custom filters and sorting', () {
    const state = OrderWorkspaceQueryState(
      filter: OrderFilter(
        channelId: 'delivery_app',
        fulfillmentModeKey: 'delivery',
        status: 'ready',
        timeScope: OrderTimeScope.today,
        paymentScope: OrderPaymentScope.externalSettlement,
        attentionScope: OrderAttentionScope.actionable,
        query: 'Amina',
      ),
      sortMode: OrderSortMode.status,
    );

    final location = state.locationForPath(Routes.deliveryOrdersPath);
    final uri = Uri.parse(location);

    expect(uri.path, Routes.deliveryOrdersPath);
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.channelIdQueryKey],
      'delivery_app',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.fulfillmentModeQueryKey],
      'delivery',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.statusQueryKey],
      'ready',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.timeScopeQueryKey],
      'today',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.paymentScopeQueryKey],
      'externalSettlement',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.attentionScopeQueryKey],
      'actionable',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.searchQueryKey],
      'Amina',
    );
    expect(
      uri.queryParameters[OrderWorkspaceQueryState.sortModeQueryKey],
      'status',
    );

    final decoded = OrderWorkspaceQueryState.fromQueryParameters(
      uri.queryParameters,
    );

    expect(decoded, isNotNull);
    expect(decoded!.filter.channelId, 'delivery_app');
    expect(decoded.filter.fulfillmentModeKey, 'delivery');
    expect(decoded.filter.status, 'ready');
    expect(decoded.filter.timeScope, OrderTimeScope.today);
    expect(decoded.filter.paymentScope, OrderPaymentScope.externalSettlement);
    expect(decoded.filter.attentionScope, OrderAttentionScope.actionable);
    expect(decoded.filter.query, 'Amina');
    expect(decoded.sortMode, OrderSortMode.status);
  });

  test('workspace query state omits defaults and falls back safely', () {
    const defaults = OrderWorkspaceQueryState(
      filter: OrderFilter(),
      sortMode: OrderSortMode.newest,
    );

    expect(defaults.toQueryParameters(), isEmpty);
    expect(OrderWorkspaceQueryState.fromQueryParameters(const {}), isNull);

    final decoded = OrderWorkspaceQueryState.fromQueryParameters(const {
      OrderWorkspaceQueryState.timeScopeQueryKey: 'unknown',
      OrderWorkspaceQueryState.sortModeQueryKey: 'also_unknown',
    });

    expect(decoded, isNotNull);
    expect(decoded!.filter.channelId, ecommerceOrderAllChannelsFilter);
    expect(
      decoded.filter.fulfillmentModeKey,
      ecommerceOrderAllFulfillmentModesFilter,
    );
    expect(decoded.filter.timeScope, OrderTimeScope.all);
    expect(decoded.sortMode, OrderSortMode.newest);
  });
}
