import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/product_category_management.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_category_management_panel.dart';

void main() {
  testWidgets(
    'category management panel renders categories and delegates review',
    (tester) async {
      ProductCategoryManagementEntry? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductCategoryManagementPanel(
                overview: _overview,
                onCategorySelected: (category) => selectedCategory = category,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Category management'), findsOneWidget);
      expect(find.text('Taxonomy coverage'), findsOneWidget);
      expect(find.text('2/3 covered'), findsOneWidget);
      expect(find.text('Uncategorized'), findsAtLeastNWidgets(1));
      expect(find.text('Assign category'), findsOneWidget);

      await tester.tap(find.text('Assign category'));
      await tester.pump();

      expect(selectedCategory?.id, 'uncategorized');
    },
  );
}

const _uncategorized = ProductCategoryManagementEntry(
  id: 'uncategorized',
  title: 'Uncategorized',
  productCount: 1,
  attentionProductCount: 1,
  channelRiskProductCount: 1,
  untrackedProductCount: 0,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(query: 'Uncategorized'),
  isUncategorized: true,
);

const _electronics = ProductCategoryManagementEntry(
  id: 'electronics',
  title: 'Electronics',
  productCount: 2,
  attentionProductCount: 0,
  channelRiskProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 2400,
  reviewTarget: ProductCatalogReviewTarget(query: 'Electronics'),
);

final _overview = ProductCategoryManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductCategoryManagementSummary(
    categoryCount: 1,
    productCount: 3,
    categorizedProductCount: 2,
    uncategorizedProductCount: 1,
    attentionProductCount: 1,
    channelRiskProductCount: 1,
    totalInventoryValue: 2400,
  ),
  categories: const [_uncategorized, _electronics],
);
