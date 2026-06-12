import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_lifecycle_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_lifecycle_management_panel.dart';

void main() {
  testWidgets(
    'lifecycle management panel renders stages and delegates review',
    (tester) async {
      ProductLifecycleManagementEntry? selectedStage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductLifecycleManagementPanel(
                overview: _overview,
                onStageSelected: (stage) => selectedStage = stage,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lifecycle management'), findsOneWidget);
      expect(find.text('Active coverage'), findsOneWidget);
      expect(find.text('1/3 active'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('Clear blockers'), findsOneWidget);

      await tester.tap(find.text('Clear blockers'));
      await tester.pump();

      expect(selectedStage?.stage, ProductLifecycleStage.blocked);
    },
  );
}

const _blocked = ProductLifecycleManagementEntry(
  id: 'blocked',
  stage: ProductLifecycleStage.blocked,
  title: 'Blocked',
  productCount: 1,
  attentionProductCount: 0,
  channelRiskProductCount: 0,
  qualityIssueProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(reasonLabel: 'blocked products'),
);

const _active = ProductLifecycleManagementEntry(
  id: 'active',
  stage: ProductLifecycleStage.active,
  title: 'Active',
  productCount: 1,
  attentionProductCount: 0,
  channelRiskProductCount: 0,
  qualityIssueProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(reasonLabel: 'active products'),
);

const _draft = ProductLifecycleManagementEntry(
  id: 'draft',
  stage: ProductLifecycleStage.draft,
  title: 'Draft',
  productCount: 1,
  attentionProductCount: 1,
  channelRiskProductCount: 1,
  qualityIssueProductCount: 1,
  untrackedProductCount: 1,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(reasonLabel: 'draft products'),
);

final _overview = ProductLifecycleManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductLifecycleManagementSummary(
    productCount: 3,
    activeProductCount: 1,
    draftProductCount: 1,
    blockedProductCount: 1,
    retiringProductCount: 0,
    archivedProductCount: 0,
    attentionProductCount: 1,
    channelRiskProductCount: 1,
    qualityIssueProductCount: 1,
    untrackedProductCount: 1,
    totalInventoryValue: 1200,
  ),
  stages: const [_blocked, _draft, _active],
);
