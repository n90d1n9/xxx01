import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/sales_channel_profile.dart';
import 'package:kaysir/features/product/models/product_variant_management.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_variant_management_panel.dart';

void main() {
  testWidgets(
    'variant management panel renders families and delegates review',
    (tester) async {
      ProductVariantManagementEntry? selectedFamily;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductVariantManagementPanel(
                overview: _overview,
                onFamilySelected: (family) => selectedFamily = family,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Variant management'), findsOneWidget);
      expect(find.text('Variant coverage'), findsOneWidget);
      expect(find.text('3/4 grouped'), findsOneWidget);
      expect(find.text('House Blend'), findsOneWidget);
      expect(find.text('Complete options'), findsOneWidget);

      await tester.tap(find.text('Complete options'));
      await tester.pump();

      expect(selectedFamily?.id, 'house_blend');
    },
  );
}

const _houseBlend = ProductVariantManagementEntry(
  id: 'house_blend',
  title: 'House Blend',
  productCount: 3,
  configuredVariantProductCount: 2,
  incompleteVariantProductCount: 1,
  duplicateOptionProductCount: 0,
  optionValueCount: 2,
  attentionProductCount: 0,
  untrackedProductCount: 0,
  totalInventoryValue: 1200,
  reviewTarget: ProductCatalogReviewTarget(query: 'House Blend'),
);

const _standalone = ProductVariantManagementEntry(
  id: 'standalone_products',
  title: productStandaloneVariantGroupLabel,
  productCount: 1,
  configuredVariantProductCount: 0,
  incompleteVariantProductCount: 0,
  duplicateOptionProductCount: 0,
  optionValueCount: 0,
  attentionProductCount: 1,
  untrackedProductCount: 1,
  totalInventoryValue: 0,
  reviewTarget: ProductCatalogReviewTarget(),
  isStandalone: true,
);

final _overview = ProductVariantManagementOverview(
  channelProfile: omniRetailProductSalesChannelProfile,
  summary: const ProductVariantManagementSummary(
    productCount: 4,
    variantFamilyCount: 1,
    variantProductCount: 3,
    standaloneProductCount: 1,
    configuredVariantProductCount: 2,
    incompleteVariantProductCount: 1,
    duplicateOptionProductCount: 0,
    attentionProductCount: 1,
    untrackedProductCount: 1,
    totalInventoryValue: 1200,
  ),
  families: const [_houseBlend, _standalone],
);
