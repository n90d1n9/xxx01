import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/product_profile_icon_badge.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('ProductProfileIconBadge derives profile icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ProductProfileIconBadge(
                profile: ProductProfile.subscriptionCommerce,
              ),
              ProductProfileIconBadge(profile: ProductProfile.remotePayment),
              ProductProfileIconBadge(
                profile: ProductProfile.marketplaceOperations,
              ),
              ProductProfileIconBadge(profile: ProductProfile.fulfillmentFirst),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.autorenew_outlined), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(find.byIcon(Icons.store_mall_directory_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('productProfileIcon keeps default icon fallback', () {
    final focusedProfile = ProductProfile.standard.copyWith(
      id: 'focused',
      capabilities: const [ProductCapability.operationsReview],
    );

    expect(productProfileIcon(focusedProfile), Icons.view_quilt_outlined);
  });

  testWidgets('ProductProfileIconBadge reflects selected chrome', (
    tester,
  ) async {
    final scheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: scheme),
        home: Scaffold(
          body: Column(
            children: [
              ProductProfileIconBadge(profile: ProductProfile.standard),
              ProductProfileIconBadge(
                profile: ProductProfile.standard,
                selected: true,
              ),
            ],
          ),
        ),
      ),
    );

    final badges =
        tester.widgetList<POSIconBadge>(find.byType(POSIconBadge)).toList();

    expect(badges, hasLength(2));
    expect(badges.first.backgroundColor, scheme.surfaceContainerHighest);
    expect(badges.first.foregroundColor, scheme.onSurfaceVariant);
    expect(badges.last.backgroundColor, scheme.primaryContainer);
    expect(badges.last.foregroundColor, scheme.onPrimaryContainer);
  });
}
