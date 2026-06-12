import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_assortment_plan.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_assortment_plan_panel.dart';

void main() {
  testWidgets('assortment plan panel renders segments and delegates review', (
    tester,
  ) async {
    ProductAssortmentSegment? selectedSegment;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductAssortmentPlanPanel(
              plan: _plan,
              onSegmentSelected: (segment) => selectedSegment = segment,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Assortment planning'), findsOneWidget);
    expect(find.text('Launch-ready'), findsOneWidget);
    expect(find.text('1/2 ready'), findsAtLeastNWidgets(1));
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Review stock'), findsOneWidget);

    await tester.tap(find.text('Review stock'));
    await tester.pump();

    expect(selectedSegment?.id, 'electronics');
  });
}

const _segment = ProductAssortmentSegment(
  id: 'electronics',
  title: 'Electronics',
  productCount: 2,
  launchReadyProductCount: 1,
  attentionProductCount: 1,
  qualityIssueCount: 2,
  channelBlockerProductCount: 1,
  untrackedProductCount: 0,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(query: 'Electronics'),
);

final _plan = ProductAssortmentPlan(
  managementPack: coreProductManagementPack,
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductAssortmentPlanSummary(
    segmentCount: 1,
    productCount: 2,
    launchReadyProductCount: 1,
    attentionProductCount: 1,
    qualityIssueCount: 2,
    channelBlockerProductCount: 1,
    untrackedProductCount: 0,
    totalInventoryValue: 1200,
  ),
  segments: const [_segment],
);
