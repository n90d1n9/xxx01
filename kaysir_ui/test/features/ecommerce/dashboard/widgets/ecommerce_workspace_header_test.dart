import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/overview.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/action_button.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/header.dart';
import 'package:kaysir/features/ecommerce/order/models/order_insights.dart';

void main() {
  testWidgets('Header surfaces profile channel rules', (tester) async {
    var openedCheckout = false;
    var openedOrders = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 980,
              child: Header(
                overview: const Overview(
                  orderInsights: OrderInsights.empty,
                  cartLineCount: 0,
                  cartUnitCount: 0,
                  cartTotal: 0,
                  promisePolicyIssueCount: 0,
                ),
                productProfile: ProductProfile.marketplaceOperations,
                onOpenCheckout: () => openedCheckout = true,
                onOpenOrders: () => openedOrders = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Profile | Marketplace operations'), findsOneWidget);
    expect(find.text('Marketplace'), findsWidgets);
    expect(find.text('Price lists'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.byType(ActionButton), findsNWidgets(2));

    await tester.tap(find.text('Review orders'));
    await tester.pump();
    await tester.tap(find.text('Open checkout'));
    await tester.pump();

    expect(openedOrders, isTrue);
    expect(openedCheckout, isTrue);
    expect(tester.takeException(), isNull);
  });
}
