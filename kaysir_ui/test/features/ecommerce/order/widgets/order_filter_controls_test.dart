import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/order/models/order_filter.dart';
import 'package:kaysir/features/ecommerce/order/models/order_sort.dart';
import 'package:kaysir/features/ecommerce/order/models/order_workspace_view.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_filter_choice_strip.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_search_field.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_sort_menu.dart';
import 'package:kaysir/features/ecommerce/order/widgets/order_workspace_view_strip.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('order search field emits text and clear actions', (
    tester,
  ) async {
    final emittedQueries = <String>[];

    await tester.pumpWidget(
      _wrap(OrderSearchField(query: 'ready', onChanged: emittedQueries.add)),
    );

    expect(find.text('ready'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('order_search_field')),
      'rush',
    );

    expect(emittedQueries.last, 'rush');

    await tester.pumpWidget(
      _wrap(OrderSearchField(query: 'rush', onChanged: emittedQueries.add)),
    );
    await tester.tap(find.byTooltip('Clear search'));

    expect(emittedQueries.last, '');
  });

  testWidgets('order sort menu emits selected sort mode', (tester) async {
    OrderSortMode? selectedMode;

    await tester.pumpWidget(
      _wrap(
        OrderSortMenu(
          sortMode: OrderSortMode.newest,
          onChanged: (mode) => selectedMode = mode,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('order_sort_menu')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(
        CheckedPopupMenuItem<OrderSortMode>,
        OrderSortMode.attention.label,
      ),
    );

    expect(selectedMode, OrderSortMode.attention);
  });

  testWidgets('workspace view strip renders counts and emits selection', (
    tester,
  ) async {
    OrderWorkspaceView? selectedView;
    final views = ecommerceDefaultOrderWorkspaceViews.take(2).toList();

    await tester.pumpWidget(
      _wrap(
        OrderWorkspaceViewStrip(
          views: views,
          activeFilter: const OrderFilter(),
          activeSortMode: OrderSortMode.newest,
          counts: const {'all_orders': 8},
          onSelected: (view) => selectedView = view,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('order_workspace_view_count_all_orders')),
      findsOneWidget,
    );

    await tester.tap(find.text('Priority queue'));

    expect(selectedView?.id, 'priority_queue');
  });

  testWidgets('filter choice strip renders label and child choices', (
    tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      _wrap(
        OrderFilterChoiceStrip(
          label: 'Channel',
          children: [
            POSChoicePill(
              label: 'Marketplace',
              selected: false,
              onSelected: (value) => selected = value,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Channel'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);

    await tester.tap(find.text('Marketplace'));

    expect(selected, isTrue);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}
