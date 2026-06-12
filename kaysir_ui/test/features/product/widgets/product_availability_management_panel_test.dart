import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_availability_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_availability_management_panel.dart';

void main() {
  testWidgets(
    'availability management panel renders rules and delegates review',
    (tester) async {
      ProductAvailabilityManagementEntry? selectedRule;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductAvailabilityManagementPanel(
                overview: _overview,
                onRuleSelected: (rule) => selectedRule = rule,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Availability rules'), findsOneWidget);
      expect(find.text('Availability coverage'), findsOneWidget);
      expect(find.text('3/4 ruled'), findsOneWidget);
      expect(find.text('Channel access'), findsOneWidget);
      expect(find.text('Resolve conflicts'), findsOneWidget);

      await tester.tap(find.text('Resolve conflicts'));
      await tester.pump();

      expect(selectedRule?.id, ProductAvailabilityRuleType.channelAccess.name);
    },
  );
}

const _channelAccess = ProductAvailabilityManagementEntry(
  type: ProductAvailabilityRuleType.channelAccess,
  id: 'channelAccess',
  title: 'Channel access',
  productCount: 2,
  ruleCount: 3,
  conflictProductCount: 1,
  gatedProductCount: 0,
  stockBlockedProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(),
);

const _unconfigured = ProductAvailabilityManagementEntry(
  type: ProductAvailabilityRuleType.unconfigured,
  id: 'unconfigured',
  title: 'Unconfigured products',
  productCount: 1,
  ruleCount: 0,
  conflictProductCount: 0,
  gatedProductCount: 0,
  stockBlockedProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(),
);

final _overview = ProductAvailabilityManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductAvailabilityManagementSummary(
    productCount: 4,
    availabilityRuleTypeCount: 2,
    configuredProductCount: 3,
    openAvailabilityProductCount: 1,
    availabilityRuleCount: 5,
    conflictProductCount: 1,
    gatedProductCount: 0,
    stockBlockedProductCount: 0,
    untrackedProductCount: 0,
    availabilityRiskProductCount: 2,
    totalInventoryValue: 1200,
  ),
  rules: const [_channelAccess, _unconfigured],
);
