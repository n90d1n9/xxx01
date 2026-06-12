import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_saved_workspace.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_saved_workspace_details_filter_grid.dart';

void main() {
  testWidgets('details filter grid renders normalized filter pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrderSavedWorkspaceDetailsFilterGrid(
            workspace: _filteredWorkspace,
          ),
        ),
      ),
    );

    expect(_detailPill('channel'), findsOneWidget);
    expect(_detailPill('fulfillment'), findsOneWidget);
    expect(_detailPill('status'), findsOneWidget);
    expect(_detailPill('search'), findsOneWidget);
    expect(find.text('Delivery App'), findsOneWidget);
    expect(find.text('Courier Pickup'), findsOneWidget);
    expect(find.text('Ready Now'), findsOneWidget);
    expect(find.text('rush pickup'), findsOneWidget);
    expect(find.text(OrderSortMode.oldest.label), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _detailPill(String suffix) {
  return find.byKey(ValueKey('order_saved_workspace_detail_$suffix'));
}

const _filteredWorkspace = OrderSavedWorkspace(
  id: 'saved_filtered',
  label: 'Filtered workspace',
  description: 'Filtered workspace',
  filter: OrderFilter(
    channelId: 'delivery_app',
    fulfillmentModeKey: 'courier-pickup',
    status: 'ready_now',
    query: 'rush pickup',
  ),
  sortMode: OrderSortMode.oldest,
);
