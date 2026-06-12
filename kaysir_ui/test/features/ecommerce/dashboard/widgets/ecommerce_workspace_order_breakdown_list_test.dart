import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/empty_state.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/inset_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/order_breakdown_list.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

import '../fixtures/widget_test_harness.dart';

void main() {
  testWidgets('OrderBreakdownList renders visible rows', (tester) async {
    await tester.pumpWorkspaceWidget(
      const OrderBreakdownList(
        title: 'Sales channels',
        emptyMessage: 'No channel activity yet',
        rows: _rows,
        maxVisibleRows: 2,
      ),
    );

    expect(find.text('Sales channels'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Store pickup'), findsOneWidget);
    expect(find.text('Social commerce'), findsNothing);
    expect(find.text('3 / Rp 150.000'), findsOneWidget);
    expect(find.text('1 / Rp 30.000'), findsOneWidget);
    expect(find.byType(OrderBreakdownRow), findsNWidgets(2));
    expect(find.byType(InsetSurface), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderBreakdownList renders empty state', (tester) async {
    await tester.pumpWorkspaceWidget(
      const OrderBreakdownList(
        title: 'Fulfillment modes',
        emptyMessage: 'No fulfillment activity yet',
        rows: [],
      ),
    );

    expect(find.text('Fulfillment modes'), findsOneWidget);
    expect(find.text('No fulfillment activity yet'), findsOneWidget);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(OrderBreakdownRow), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

const _rows = [
  OrderBreakdown(
    id: 'marketplace',
    label: 'Marketplace',
    orderCount: 3,
    revenue: 150000,
  ),
  OrderBreakdown(
    id: 'pickup',
    label: 'Store pickup',
    orderCount: 1,
    revenue: 30000,
  ),
  OrderBreakdown(
    id: 'social',
    label: 'Social commerce',
    orderCount: 1,
    revenue: 25000,
  ),
];
