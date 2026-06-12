import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/ecommerce/dashboard/models/product_profile.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/icon_label_chip.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/profile_registry_insights.dart';
import 'package:kaysir/features/ecommerce/dashboard/widgets/text_badge.dart';

void main() {
  testWidgets('ProfileRegistryInsights summarizes profile', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileRegistryInsights(profile: ProductProfile.standard),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('profile_registry_insights')),
      findsOneWidget,
    );
    expect(find.text('Standard workspace'), findsOneWidget);
    expect(find.text('3 channels'), findsOneWidget);
    expect(find.text('3 modules'), findsOneWidget);
    expect(find.text('7 rules'), findsOneWidget);
    expect(find.text('5 capabilities'), findsOneWidget);
    expect(find.text('Search keywords'), findsOneWidget);
    expect(find.text('Retail'), findsOneWidget);
    expect(find.text('Storefront'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Promise Policy'), findsOneWidget);
    expect(find.text('Action rules'), findsOneWidget);
    expect(find.text('Product Profile Review'), findsOneWidget);
    expect(find.text('+3 more'), findsOneWidget);
    expect(find.byType(IconLabelChip), findsNWidgets(5));
    expect(find.byType(TextBadge), findsNWidgets(13));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileRegistryInsights reflects specialized profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileRegistryInsights(
            profile: ProductProfile.marketplaceOperations,
            maxKeywords: 4,
            maxModules: 6,
            maxActionRules: 3,
          ),
        ),
      ),
    );

    expect(find.text('Operations first workspace'), findsOneWidget);
    expect(find.text('6 modules'), findsOneWidget);
    expect(find.text('10 rules'), findsOneWidget);
    expect(find.text('Marketplace Seller'), findsOneWidget);
    expect(find.text('Seller Center'), findsOneWidget);
    expect(find.text('Marketplace Queue'), findsOneWidget);
    expect(find.text('Fulfillment Queue'), findsOneWidget);
    expect(find.text('+7 more'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
