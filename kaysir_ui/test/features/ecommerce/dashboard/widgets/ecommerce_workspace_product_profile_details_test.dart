import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_details.dart';

void main() {
  testWidgets('ProductProfileDetails renders embeddable topology', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductProfileDetails(
              profile: ProductProfile.marketplaceOperations,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('product_profile_details_marketplace_operations'),
      ),
      findsOneWidget,
    );
    expect(find.text('Marketplace operations'), findsOneWidget);
    expect(find.text('Order workspace'), findsOneWidget);
    expect(find.text('Marketplace Orders'), findsOneWidget);
    expect(find.text('Route: /commerce/orders/marketplace'), findsOneWidget);
    expect(find.text('Capabilities'), findsOneWidget);
    expect(find.text('Sales channels'), findsOneWidget);
    expect(find.text('Coverage rules'), findsOneWidget);
    expect(find.text('Registry shape'), findsOneWidget);
    expect(find.text('Price lists'), findsWidgets);
    expect(find.text('Marketplace Queue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
