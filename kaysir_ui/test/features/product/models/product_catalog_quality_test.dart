import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';
import 'package:kaysir/features/product/models/management_pack.dart';

void main() {
  test('catalog quality summarizes completeness and issue counts', () {
    final summary = summarizeProductCatalogQuality(
      buildInventoryProductCatalogRecords(
        products: [
          Product(
            id: 'p1',
            name: 'Ready product',
            sku: 'READY-001',
            category: 'Retail',
            description: 'Complete listing',
            barcode: '8990001',
            price: 12,
          ),
          Product(id: 'p2', name: 'Draft product', price: 0),
          Product(
            id: 'p3',
            name: 'No scan product',
            sku: 'SCAN-001',
            category: 'Retail',
            description: 'Missing scan code only',
            price: 15,
          ),
        ],
        stockRecords: const [],
      ),
    );

    expect(summary.productCount, 3);
    expect(summary.completeProductCount, 1);
    expect(summary.issueProductCount, 2);
    expect(summary.totalIssueCount, 6);
    expect(summary.completePercent, 33);
    expect(summary.completeCountLabel, '1/3 ready');
    expect(summary.activeIssues.map((issue) => issue.countLabel), [
      '2 missing scan code',
      '1 missing SKU',
      '1 missing category',
      '1 missing description',
      '1 missing price',
    ]);
    expect(summary.activeIssues.first.reviewTarget.query, 'Missing scan code');
  });

  test('catalog quality issue types resolve from record data', () {
    final record =
        buildInventoryProductCatalogRecords(
          products: [Product(id: 'p1', name: 'Incomplete', price: 0)],
          stockRecords: const [],
        ).single;

    expect(productCatalogQualityIssueTypes(record), [
      ProductCatalogQualityIssueType.missingSku,
      ProductCatalogQualityIssueType.missingCategory,
      ProductCatalogQualityIssueType.missingDescription,
      ProductCatalogQualityIssueType.missingPrice,
      ProductCatalogQualityIssueType.missingScanCode,
    ]);
    expect(
      productCatalogQualityIssuesForRecord(record).map((issue) => issue.label),
      [
        'missing SKU',
        'missing category',
        'missing description',
        'missing price',
        'missing scan code',
      ],
    );
  });

  test('catalog quality includes active product pack required fields', () {
    final records = buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'p1',
          name: 'Ready greens',
          sku: 'GR-001',
          category: 'Fresh',
          description: 'Washed greens',
          barcode: '8990001',
          price: 12,
          customAttributes: {
            'expiry_date': '2026-07-01',
            'batch_number': 'B-01',
          },
        ),
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
    );
    final summary = summarizeProductCatalogQuality(
      records,
      pack: groceryFreshGoodsProductManagementPack,
    );

    expect(summary.productCount, 2);
    expect(summary.completeProductCount, 1);
    expect(summary.issueProductCount, 1);
    expect(summary.totalIssueCount, 2);
    expect(summary.activeIssues.map((issue) => issue.id), [
      'missing_batch_number',
      'missing_expiry_date',
    ]);
    expect(summary.activeIssues.map((issue) => issue.label), [
      'missing batch number',
      'missing expiry date',
    ]);
    expect(
      summary.activeIssues.first.packField?.id,
      ProductManagementFieldId.batchNumber,
    );

    final draftRecord = records.singleWhere((record) => record.id == 'p2');

    expect(
      productCatalogQualityIssueTypes(
        draftRecord,
        pack: groceryFreshGoodsProductManagementPack,
      ),
      [
        ProductCatalogQualityIssueType.missingRequiredPackField,
        ProductCatalogQualityIssueType.missingRequiredPackField,
      ],
    );
  });
}
