import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/models/product.dart';
import 'package:kaysir/features/product/models/product_catalog_quality_badge_strip_state.dart';
import 'package:kaysir/features/product/models/product_catalog_quality.dart';

void main() {
  test('catalog quality badge strip state renders ready rows', () {
    final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
      record: _readyRecord,
      maxVisibleIssues: 3,
    );

    expect(viewState.isReady, isTrue);
    expect(viewState.readyLabel, 'Quality ready');
    expect(viewState.visibleIssues, isEmpty);
    expect(viewState.hasHiddenIssues, isFalse);
  });

  test('catalog quality badge strip state caps visible issues', () {
    final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
      record: _draftRecord,
      maxVisibleIssues: 1,
    );

    expect(viewState.isReady, isFalse);
    expect(viewState.summaryLabel, '2 quality fixes');
    expect(viewState.visibleIssues.map((issue) => issue.type), [
      ProductCatalogQualityIssueType.missingSku,
    ]);
    expect(viewState.hiddenIssueCount, 1);
    expect(viewState.hiddenLabel, '+1 more');
  });

  test(
    'catalog quality badge strip state supports singular quality fix label',
    () {
      final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
        record: _missingScanOnlyRecord,
        maxVisibleIssues: 3,
      );

      expect(viewState.summaryLabel, '1 quality fix');
      expect(viewState.visibleIssues.single.type, missingScanCode);
      expect(viewState.hasHiddenIssues, isFalse);
    },
  );

  test('catalog quality badge strip state supports pack required fields', () {
    final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
      record: _freshDraftRecord,
      maxVisibleIssues: 3,
      pack: groceryFreshGoodsProductManagementPack,
    );

    expect(viewState.summaryLabel, '2 quality fixes');
    expect(viewState.visibleIssues.map((issue) => issue.id), [
      'missing_expiry_date',
      'missing_batch_number',
    ]);
  });

  test(
    'catalog quality badge strip state sanitizes negative visible counts',
    () {
      final viewState = ProductCatalogQualityBadgeStripViewState.fromRecord(
        record: _draftRecord,
        maxVisibleIssues: -1,
      );

      expect(viewState.maxVisibleIssues, 0);
      expect(viewState.visibleIssues, isEmpty);
      expect(viewState.hiddenIssueCount, 2);
      expect(viewState.hiddenLabel, '+2 more');
    },
  );
}

const missingScanCode = ProductCatalogQualityIssueType.missingScanCode;

final _readyRecord =
    buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'ready',
          name: 'Ready cable',
          sku: 'RD-001',
          category: 'Accessories',
          description: 'Complete listing',
          barcode: '8990001',
          price: 12,
        ),
      ],
      stockRecords: const [],
    ).single;

final _draftRecord =
    buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'draft',
          name: 'Draft cable',
          category: 'Accessories',
          description: 'USB cable',
          price: 25,
        ),
      ],
      stockRecords: const [],
    ).single;

final _missingScanOnlyRecord =
    buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'missing-scan',
          name: 'Keyboard',
          sku: 'KB-001',
          category: 'Accessories',
          description: 'Mechanical keyboard',
          price: 80,
        ),
      ],
      stockRecords: const [],
    ).single;

final _freshDraftRecord =
    buildInventoryProductCatalogRecords(
      products: [
        Product(
          id: 'fresh-draft',
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
