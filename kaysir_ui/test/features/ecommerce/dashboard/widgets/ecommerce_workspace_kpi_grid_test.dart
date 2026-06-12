import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/kpi_card.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/kpi_grid.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  testWidgets('KpiGrid renders KPI cards on shared panels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1040,
            child: KpiGrid(
              overview: Overview(
                orderInsights: OrderInsights.empty,
                cartLineCount: 0,
                cartUnitCount: 0,
                cartTotal: 0,
                promisePolicyIssueCount: 2,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Order volume'), findsOneWidget);
    expect(find.text('Net revenue'), findsOneWidget);
    expect(find.text('Active checkout'), findsOneWidget);
    expect(find.text('Ops alerts'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(find.byType(KpiCard), findsNWidgets(4));
    expect(find.byType(MetricBlock), findsNWidgets(4));
    expect(find.byType(PanelSurface), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
