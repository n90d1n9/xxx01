import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/capability_chips.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('CapabilityChips renders capability labels', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CapabilityChips(
            capabilities: [
              ProductCapability.storefrontCheckout,
              ProductCapability.marketplaceOrders,
              ProductCapability.pickupDelivery,
            ],
          ),
        ),
      ),
    );

    expect(find.text('Storefront'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Pickup/delivery'), findsOneWidget);
    expect(find.byType(TextBadge), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('CapabilityChips summarizes hidden capabilities', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CapabilityChips(
            maxVisible: 2,
            capabilities: [
              ProductCapability.storefrontCheckout,
              ProductCapability.marketplaceOrders,
              ProductCapability.pickupDelivery,
              ProductCapability.shipping,
            ],
          ),
        ),
      ),
    );

    expect(find.text('Storefront'), findsOneWidget);
    expect(find.text('Marketplace'), findsOneWidget);
    expect(find.text('Pickup/delivery'), findsNothing);
    expect(find.text('Shipping'), findsNothing);
    expect(find.text('+2 more'), findsOneWidget);
    expect(find.byType(TextBadge), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
