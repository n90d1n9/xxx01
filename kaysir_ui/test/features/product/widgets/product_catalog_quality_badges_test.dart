import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/product_catalog_quality_badges.dart';

void main() {
  testWidgets('catalog quality badges expose row quick fix actions', (
    tester,
  ) async {
    ProductCatalogQualityIssue? selectedIssue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCatalogQualityBadges(
            record: _record,
            onIssueSelected: (issue) => selectedIssue = issue,
          ),
        ),
      ),
    );

    expect(find.text('2 quality fixes'), findsOneWidget);
    expect(find.text('Fix SKU'), findsOneWidget);
    expect(find.text('Fix scan code'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('product-catalog-quality-badge-p1-missingScanCode'),
      ),
    );
    await tester.pump();

    expect(selectedIssue?.type, ProductCatalogQualityIssueType.missingScanCode);
  });

  testWidgets('catalog quality badges render ready state', (tester) async {
    final record =
        buildInventoryProductCatalogRecords(
          products: [
            Product(
              id: 'p1',
              name: 'Ready',
              sku: 'RD-001',
              category: 'Retail',
              description: 'Ready listing',
              barcode: '8990001',
              price: 12,
            ),
          ],
          stockRecords: const [],
        ).single;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProductCatalogQualityBadges(record: record)),
      ),
    );

    expect(find.text('Quality ready'), findsOneWidget);
  });

  testWidgets('catalog quality badges render pack field fixes', (tester) async {
    ProductCatalogQualityIssue? selectedIssue;
    final record =
        buildInventoryProductCatalogRecords(
          products: [
            Product(
              id: 'p2',
              name: 'Draft greens',
              sku: 'GR-002',
              category: 'Fresh',
              description: 'Missing freshness data',
              barcode: '8990002',
              price: 10,
            ),
          ],
          stockRecords: const [],
        ).single;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCatalogQualityBadges(
            record: record,
            pack: groceryFreshGoodsProductManagementPack,
            onIssueSelected: (issue) => selectedIssue = issue,
          ),
        ),
      ),
    );

    expect(find.text('2 quality fixes'), findsOneWidget);
    expect(find.text('Fix expiry date'), findsOneWidget);
    expect(find.text('Fix batch number'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('product-catalog-quality-badge-p2-missing_expiry_date'),
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

final _record =
    buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'p1',
          name: 'Cable',
          category: 'Accessories',
          description: 'USB cable',
          price: 25,
        ),
      ],
      stockRecords: const [],
    ).single;
