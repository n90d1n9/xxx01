import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/header_status_pills.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/header_summary.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_summary.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  testWidgets('HeaderSummary renders operational copy and profile signals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeaderSummary(
            overview: const Overview(
              orderInsights: OrderInsights.empty,
              cartLineCount: 0,
              cartUnitCount: 0,
              cartTotal: 0,
              promisePolicyIssueCount: 0,
            ),
            productProfile: ProductProfile.marketplaceOperations,
            chipLimits: const ProductProfileChipLimits(
              channels: 2,
              capabilities: 2,
              requirements: 3,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Commerce Workspace'), findsOneWidget);
    expect(
      find.text(
        'Omnichannel checkout, fulfillment, and order health in one operational view.',
      ),
      findsOneWidget,
    );
    expect(find.byType(HeaderStatusPills), findsOneWidget);
    expect(find.text('Profile | Marketplace operations'), findsOneWidget);
    expect(find.text('Orders | 0'), findsOneWidget);
    expect(find.text('Cart | No active cart'), findsOneWidget);
    expect(find.text('Policy | Ready'), findsOneWidget);
    expect(find.text('Delivery app'), findsOneWidget);
    expect(find.text('+1 channels'), findsOneWidget);
    expect(find.text('Remote pay'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('+1 rules'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
