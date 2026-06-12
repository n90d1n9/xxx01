import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_relationship_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_relationship_management_panel.dart';

void main() {
  testWidgets(
    'relationship management panel renders links and delegates review',
    (tester) async {
      ProductRelationshipManagementEntry? selectedRelationship;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductRelationshipManagementPanel(
                overview: _overview,
                onRelationshipSelected:
                    (relationship) => selectedRelationship = relationship,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Relationship management'), findsOneWidget);
      expect(find.text('Relationship coverage'), findsOneWidget);
      expect(find.text('2/4 linked'), findsOneWidget);
      expect(find.text('Bundle components'), findsOneWidget);
      expect(find.text('Resolve targets'), findsOneWidget);

      await tester.tap(find.text('Resolve targets'));
      await tester.pump();

      expect(
        selectedRelationship?.id,
        ProductRelationshipType.bundleComponents.name,
      );
    },
  );
}

const _bundleComponents = ProductRelationshipManagementEntry(
  type: ProductRelationshipType.bundleComponents,
  id: 'bundleComponents',
  title: 'Bundle components',
  productCount: 1,
  referenceCount: 2,
  resolvedReferenceCount: 1,
  unresolvedReferenceCount: 1,
  attentionProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(),
);

const _complements = ProductRelationshipManagementEntry(
  type: ProductRelationshipType.complements,
  id: 'complements',
  title: 'Complements',
  productCount: 1,
  referenceCount: 1,
  resolvedReferenceCount: 1,
  unresolvedReferenceCount: 0,
  attentionProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 800,
  reviewTarget: ProductCatalogReviewTarget(),
);

final _overview = ProductRelationshipManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductRelationshipManagementSummary(
    productCount: 4,
    relationshipTypeCount: 2,
    relationshipProductCount: 2,
    relationshipReferenceCount: 3,
    resolvedReferenceCount: 2,
    unresolvedReferenceCount: 1,
    attentionProductCount: 0,
    untrackedProductCount: 0,
    totalInventoryValue: 2000,
  ),
  relationships: const [_bundleComponents, _complements],
);
