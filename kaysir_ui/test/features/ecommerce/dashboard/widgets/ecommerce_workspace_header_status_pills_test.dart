import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/header_status_pills.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('HeaderStatusPills renders ready summary', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Scaffold(
          body: HeaderStatusPills(
            overview: const Overview(
              orderInsights: OrderInsights.empty,
              cartLineCount: 0,
              cartUnitCount: 0,
              cartTotal: 0,
              promisePolicyIssueCount: 0,
            ),
            productProfile: ProductProfile.marketplaceOperations,
          ),
        ),
      ),
    );

    expect(find.text('Profile | Marketplace operations'), findsOneWidget);
    expect(find.text('Orders | 0'), findsOneWidget);
    expect(find.text('Cart | No active cart'), findsOneWidget);
    expect(find.text('Policy | Ready'), findsOneWidget);

    final pills =
        tester.widgetList<POSMetricPill>(find.byType(POSMetricPill)).toList();

    expect(pills, hasLength(4));
    expect(pills[0].backgroundColor, scheme.surfaceContainerHighest);
    expect(pills[0].foregroundColor, scheme.onSurfaceVariant);
    expect(pills[1].backgroundColor, isNull);
    expect(pills[1].foregroundColor, isNull);
    expect(pills[2].backgroundColor, scheme.secondaryContainer);
    expect(pills[2].foregroundColor, scheme.onSecondaryContainer);
    expect(pills[3].backgroundColor, scheme.tertiaryContainer);
    expect(pills[3].foregroundColor, scheme.onTertiaryContainer);
  });

  testWidgets('HeaderStatusPills surfaces policy issue state', (tester) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Scaffold(
          body: HeaderStatusPills(
            overview: const Overview(
              orderInsights: OrderInsights.empty,
              cartLineCount: 2,
              cartUnitCount: 3,
              cartTotal: 0,
              promisePolicyIssueCount: 2,
            ),
            productProfile: ProductProfile.standard,
          ),
        ),
      ),
    );

    expect(find.text('Cart | 3 items'), findsOneWidget);
    expect(find.text('Policy | 2 issue(s)'), findsOneWidget);

    final policyPill = tester
        .widgetList<POSMetricPill>(find.byType(POSMetricPill))
        .singleWhere((pill) => pill.label == 'Policy');

    expect(policyPill.backgroundColor, scheme.errorContainer);
    expect(policyPill.foregroundColor, scheme.onErrorContainer);
  });
}
