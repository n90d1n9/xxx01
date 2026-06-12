import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/product_catalog_quality_panel.dart';
import 'package:kaysir/widgets/ui/app_content_panel.dart';

void main() {
  testWidgets('catalog quality panel renders issue actions', (tester) async {
    ProductCatalogQualityIssue? selectedIssue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCatalogQualityPanel(
            summary: _qualitySummary,
            onIssueSelected: (issue) => selectedIssue = issue,
          ),
        ),
      ),
    );

    expect(find.byType(AppContentPanel), findsOneWidget);
    expect(find.text('Catalog quality'), findsOneWidget);
    expect(find.text('1/2 ready, 1 product needs setup'), findsOneWidget);
    expect(find.text('50% complete'), findsOneWidget);
    expect(find.text('missing SKU'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Clear'), findsNWidgets(4));

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('product-catalog-quality-missingSku')),
        matching: find.text('Review'),
      ),
    );
    await tester.pump();

    expect(selectedIssue?.type, ProductCatalogQualityIssueType.missingSku);
    expect(selectedIssue?.reviewTarget.query, 'No SKU');
  });

  testWidgets('catalog quality panel renders pack field issue actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1180, 920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    ProductCatalogQualityIssue? selectedIssue;
    final summary = summarizeProductCatalogQuality(
      buildInventoryProductCatalogRecords(
        products: [
          Product(
            id: 'p1',
            name: 'Draft greens',
            sku: 'GR-002',
            category: 'Fresh',
            description: 'Missing freshness data',
            barcode: '8990002',
            price: 10,
          ),
        ],
        stockRecords: const [],
      ),
      pack: groceryFreshGoodsProductManagementPack,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCatalogQualityPanel(
            summary: summary,
            onIssueSelected: (issue) => selectedIssue = issue,
          ),
        ),
      ),
    );

    expect(find.text('0/1 ready, 1 product needs setup'), findsOneWidget);
    expect(find.text('missing expiry date'), findsOneWidget);
    expect(find.text('missing batch number'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(
          const ValueKey('product-catalog-quality-missing_expiry_date'),
        ),
        matching: find.text('Review'),
      ),
    );
    await tester.pump();

    expect(
      selectedIssue?.type,
      ProductCatalogQualityIssueType.missingRequiredPackField,
    );
    expect(selectedIssue?.packField?.id, ProductManagementFieldId.expiryDate);
  });
}

final _qualitySummary = summarizeProductCatalogQuality(
  buildInventoryProductCatalogRecords(
    products: [
      Product(
        id: 'p1',
        name: 'Ready',
        sku: 'READY-001',
        category: 'Retail',
        description: 'Complete listing',
        barcode: '8990001',
        price: 12,
      ),
      Product(
        id: 'p2',
        name: 'Missing SKU',
        category: 'Retail',
        description: 'Listing without SKU',
        barcode: '8990002',
        price: 10,
      ),
    ],
    stockRecords: const [],
  ),
);
