import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_pricing_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_pricing_management_panel.dart';

void main() {
  testWidgets(
    'pricing management panel renders pricing groups and delegates review',
    (tester) async {
      ProductPricingManagementEntry? selectedEntry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductPricingManagementPanel(
                overview: _overview,
                onPricingGroupSelected: (entry) => selectedEntry = entry,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Pricing management'), findsOneWidget);
      expect(find.text('Price coverage'), findsOneWidget);
      expect(find.text('2/3 priced'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Add prices'), findsOneWidget);

      await tester.tap(find.text('Add prices'));
      await tester.pump();

      expect(selectedEntry?.id, 'electronics');
    },
  );
}

const _electronics = ProductPricingManagementEntry(
  id: 'electronics',
  title: 'Electronics',
  productCount: 3,
  pricedProductCount: 2,
  missingPriceCount: 1,
  costedProductCount: 1,
  marginRiskProductCount: 1,
  priceOutlierProductCount: 0,
  averageUnitPrice: 60,
  minimumUnitPrice: 20,
  maximumUnitPrice: 100,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(query: 'Missing price'),
);

final _overview = ProductPricingManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductPricingManagementSummary(
    productCount: 3,
    pricedProductCount: 2,
    missingPriceCount: 1,
    costedProductCount: 1,
    marginRiskProductCount: 1,
    priceOutlierProductCount: 0,
    averageUnitPrice: 60,
    totalInventoryValue: 1200,
  ),
  entries: const [_electronics],
);
