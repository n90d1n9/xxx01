import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/models/inventory_product_catalog.dart';
import 'package:kaysir/features/product/models/sales_channel_readiness.dart';
import 'package:kaysir/features/product/utils/product_catalog_channel_readiness.dart';
import 'package:kaysir/features/product/utils/product_catalog_review_target.dart';

void main() {
  test('review target exposes catalog state flags', () {
    const emptyTarget = ProductCatalogReviewTarget();
    const filteredTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
    );
    const searchedTarget = ProductCatalogReviewTarget(query: ' cable ');

    expect(emptyTarget.hasFilter, isFalse);
    expect(emptyTarget.hasQuery, isFalse);
    expect(emptyTarget.hasCatalogState, isFalse);
    expect(filteredTarget.hasFilter, isTrue);
    expect(filteredTarget.hasCatalogState, isTrue);
    expect(searchedTarget.hasQuery, isTrue);
    expect(searchedTarget.normalizedQuery, 'cable');
  });

  test(
    'review target compares catalog state apart from presentation labels',
    () {
      const routeTarget = ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.attention,
        query: ' cable ',
        title: 'Route review',
        reasonLabel: 'stock not sellable',
      );
      const currentTarget = ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.attention,
        query: 'cable',
      );

      expect(routeTarget.hasSameCatalogStateAs(currentTarget), isTrue);
      expect(routeTarget, isNot(currentTarget));
    },
  );

  test('review target supports copy and route-equivalent equality', () {
    const target = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: ' cable ',
      title: 'Route review',
      reasonLabel: 'stock not sellable',
    );

    expect(
      target,
      const ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.attention,
        query: 'cable',
        title: 'Route review',
        reasonLabel: 'stock not sellable',
      ),
    );
    expect(
      target.copyWith(query: 'adapter'),
      const ProductCatalogReviewTarget(
        filter: InventoryProductCatalogFilter.attention,
        query: 'adapter',
        title: 'Route review',
        reasonLabel: 'stock not sellable',
      ),
    );
  });

  test('review target serializes catalog query parameters', () {
    const target = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.inStock,
      query: ' cable ',
      title: 'Stock review',
    );

    expect(target.normalizedQuery, 'cable');
    expect(target.toCatalogQueryParameters(), {
      'filter': 'in_stock',
      'q': 'cable',
    });
    expect(
      const ProductCatalogReviewTarget().toCatalogQueryParameters(),
      isEmpty,
    );
  });

  test('review target serializes optional presentation query parameters', () {
    const target = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: ' No SKU ',
      title: 'Online Store',
      reasonLabel: 'missing SKU',
    );

    expect(
      target.toCatalogQueryParameters(titleKey: 'review', reasonKey: 'reason'),
      {
        'filter': 'attention',
        'q': 'No SKU',
        'review': 'Online Store',
        'reason': 'missing SKU',
      },
    );
  });

  test('review target parses catalog query parameters', () {
    final target = ProductCatalogReviewTarget.fromCatalogQueryParameters(
      {
        'filter': 'attention',
        'q': 'No description',
        'review': 'Catalog quality',
        'reason': 'missing description',
      },
      titleKey: 'review',
      reasonKey: 'reason',
      title: 'Imported review',
    );

    expect(target.filter, InventoryProductCatalogFilter.attention);
    expect(target.query, 'No description');
    expect(target.summaryLabel, 'Catalog quality: missing description');
  });

  test('review target resolver preserves matching active target labels', () {
    const initialTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.all,
      title: 'Product review',
    );
    const activeTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: 'No SKU',
      title: 'Online Store',
      reasonLabel: 'missing SKU',
    );

    final resolved = ProductCatalogReviewTarget.resolveForCatalogState(
      initialTarget: initialTarget,
      activeTarget: activeTarget,
      filter: InventoryProductCatalogFilter.attention,
      query: ' No SKU ',
    );

    expect(resolved, activeTarget);
    expect(resolved.summaryLabel, 'Online Store: missing SKU');
  });

  test('review target resolver preserves matching initial route labels', () {
    const initialTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: 'cable',
      title: 'Route review',
    );

    final resolved = ProductCatalogReviewTarget.resolveForCatalogState(
      initialTarget: initialTarget,
      filter: InventoryProductCatalogFilter.attention,
      query: ' cable ',
    );

    expect(resolved, initialTarget);
    expect(resolved.summaryLabel, 'Route review');
  });

  test('review target resolver falls back to current manual catalog state', () {
    const initialTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: 'cable',
      title: 'Route review',
    );
    const activeTarget = ProductCatalogReviewTarget(
      filter: InventoryProductCatalogFilter.attention,
      query: 'No SKU',
      title: 'Online Store',
      reasonLabel: 'missing SKU',
    );

    final resolved = ProductCatalogReviewTarget.resolveForCatalogState(
      initialTarget: initialTarget,
      activeTarget: activeTarget,
      filter: InventoryProductCatalogFilter.inStock,
      query: 'adapter',
    );

    expect(resolved.filter, InventoryProductCatalogFilter.inStock);
    expect(resolved.query, 'adapter');
    expect(resolved.summaryLabel, ProductCatalogReviewTarget.defaultTitle);
  });

  test('review target prefers the primary aggregate readiness issue', () {
    const readiness = ProductSalesChannelReadiness(
      channel: ProductSalesChannel.onlineStore,
      title: 'Online Store',
      subtitle: 'Product listing readiness',
      readyCount: 1,
      totalCount: 3,
      reviewFilter: InventoryProductCatalogFilter.all,
      issues: [
        ProductSalesChannelReadinessIssue(
          blocker: ProductSalesChannelBlocker.missingSku,
          label: 'missing SKU',
          count: 0,
          reviewFilter: InventoryProductCatalogFilter.all,
          reviewQuery: 'No SKU',
        ),
        ProductSalesChannelReadinessIssue(
          blocker: ProductSalesChannelBlocker.missingCopy,
          label: 'missing copy',
          count: 2,
          reviewFilter: InventoryProductCatalogFilter.all,
          reviewQuery: 'No description',
        ),
      ],
    );

    final target = ProductCatalogReviewTarget.fromReadiness(readiness);

    expect(target.filter, InventoryProductCatalogFilter.all);
    expect(target.query, 'No description');
    expect(target.summaryLabel, 'Online Store: missing copy');
    expect(target.announcementLabel, 'Reviewing Online Store: missing copy');
  });

  test('review target falls back to channel review filter', () {
    const readiness = ProductSalesChannelReadiness(
      channel: ProductSalesChannel.kiosk,
      title: 'Self-Service Kiosk',
      subtitle: 'Fast scan readiness',
      readyCount: 2,
      totalCount: 2,
      reviewFilter: InventoryProductCatalogFilter.inStock,
    );

    final target = ProductCatalogReviewTarget.fromReadiness(readiness);

    expect(target.filter, InventoryProductCatalogFilter.inStock);
    expect(target.query, isEmpty);
    expect(target.summaryLabel, 'Self-Service Kiosk');
  });

  test('review target maps explicit aggregate issue', () {
    const issue = ProductSalesChannelReadinessIssue(
      blocker: ProductSalesChannelBlocker.stockNotSellable,
      label: 'stock not sellable',
      count: 4,
      reviewFilter: InventoryProductCatalogFilter.attention,
    );

    final target = ProductCatalogReviewTarget.fromReadinessIssue(issue);

    expect(target.filter, InventoryProductCatalogFilter.attention);
    expect(target.query, isEmpty);
    expect(target.summaryLabel, 'Channel readiness: stock not sellable');
  });

  test('review target maps per-product catalog item issue', () {
    final item = ProductCatalogChannelReadinessItem(
      channel: ProductSalesChannel.kiosk,
      title: 'Self-Service Kiosk',
      reviewFilter: InventoryProductCatalogFilter.inStock,
      ready: false,
      issues: [
        ProductSalesChannelIssueDefinition(
          blocker: ProductSalesChannelBlocker.missingScanCode,
          label: 'missing scan code',
          reviewFilter: InventoryProductCatalogFilter.inStock,
          reviewQuery: 'No barcode',
          matches: (_) => true,
        ),
      ],
    );

    final target = ProductCatalogReviewTarget.fromCatalogItem(item);

    expect(target.filter, InventoryProductCatalogFilter.inStock);
    expect(target.query, 'No barcode');
    expect(target.summaryLabel, 'Self-Service Kiosk: missing scan code');
  });
}
