import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/routes.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/module.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/detail_row.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/destination_card.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/destination_grid.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/metric_block.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/panel_surface.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/responsive_wrap_grid.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  testWidgets('DestinationGrid renders route cards', (tester) async {
    final selectedPaths = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1100,
            child: DestinationGrid(
              destinations: destinationsForModules(
                overview: _overview(policyIssues: 1),
                modules: defaultModules,
              ),
              onDestinationSelected: selectedPaths.add,
            ),
          ),
        ),
      ),
    );

    expect(find.text(' POS'), findsOneWidget);
    expect(find.text('Order workspace'), findsOneWidget);
    expect(find.text('Promise policy'), findsOneWidget);
    expect(find.text('1 issue(s)'), findsOneWidget);
    expect(find.byType(ResponsiveWrapGrid), findsOneWidget);
    expect(find.byType(DestinationCard), findsNWidgets(3));
    expect(find.byType(DetailRow), findsNWidgets(3));
    expect(find.byType(MetricBlock), findsNWidgets(3));
    expect(find.byType(PanelSurface), findsNWidgets(3));
    expect(find.byType(ActionButton), findsNWidgets(3));

    await tester.tap(find.text('Open checkout'));
    await tester.pump();
    await tester.tap(find.text('Open orders'));
    await tester.pump();
    await tester.tap(find.text('Review policy'));
    await tester.pump();

    expect(selectedPaths, [
      Routes.checkoutPath,
      Routes.ordersPath,
      Routes.ordersPath,
    ]);
  });

  testWidgets('DestinationGrid stays quiet when empty', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DestinationGrid(
            destinations: const [],
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text(' POS'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Overview _overview({int policyIssues = 0}) {
  return Overview(
    orderInsights: OrderInsights.empty,
    cartLineCount: 0,
    cartUnitCount: 0,
    cartTotal: 0,
    promisePolicyIssueCount: policyIssues,
  );
}
