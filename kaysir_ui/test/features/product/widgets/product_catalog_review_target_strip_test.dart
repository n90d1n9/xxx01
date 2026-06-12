import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';
import 'package:kaysir/features/product/widgets/product_catalog_review_target_strip.dart';

void main() {
  testWidgets('renders review target context and clear action', (tester) async {
    var cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: ProductCatalogReviewTargetStrip(
              target: const ProductCatalogReviewTarget(
                filter: InventoryProductCatalogFilter.attention,
                query: 'cable',
                title: 'Route review',
                reasonLabel: 'stock not sellable',
              ),
              visibleCount: 1,
              totalCount: 2,
              onClear: () => cleared = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Route review: stock not sellable'), findsOneWidget);
    expect(find.text('Focused catalog review'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Search "cable"'), findsOneWidget);
    expect(find.text('1 of 2 products'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear review target'));

    expect(cleared, isTrue);
  });

  testWidgets('stays empty without an active catalog state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCatalogReviewTargetStrip(
            target: const ProductCatalogReviewTarget(),
            visibleCount: 2,
            totalCount: 2,
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.text('Focused catalog review'), findsNothing);
    expect(find.byTooltip('Clear review target'), findsNothing);
  });
}
